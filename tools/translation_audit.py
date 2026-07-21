#!/usr/bin/env python3
"""Deterministic reference and structure audit for translated Lua scripts.

The English text at ``DEFAULT_BASE_REF`` is treated as immutable source data.
Current short-string tokens are paired with that source by their position inside
known semantic tables.  Reference replacements are intentionally conservative:
the CSV must match the table's exact semantic group, otherwise the XLSX data is
consulted only for the corresponding domain.  Ambiguous candidates are never
applied.
"""

from __future__ import annotations

import argparse
import csv
from collections import defaultdict
from dataclasses import dataclass
import os
from pathlib import Path
import posixpath
import re
import subprocess
import sys
import tempfile
from typing import Iterable
import xml.etree.ElementTree as ET
import zipfile


DEFAULT_BASE_REF = "e8d381e69a8480193ebf0419382df6025255dd56"

SEMANTIC_TABLES = {
    "speciesNamesList": "species",
    "starterPokemonNames": "species",
    "moveNamesList": "moves",
    "abilityNamesList": "abilities",
    "itemNamesList": "items",
    "natureNamesList": "natures",
    "locationNamesList": "locations",
    "charMap": "charMap",
}

LOCATION_GROUPS = {"rs", "e", "frlg", "dppt", "hgss", "bw", "bw2", "bdsp"}

XLSX_SECTION_NAMES = {
    "宝可梦": "species",
    "宝可梦列表": "species",
    "招式": "moves",
    "招式列表": "moves",
    "特性": "abilities",
    "特性列表": "abilities",
    "道具": "items",
    "道具列表": "items",
    "性格": "natures",
    "性格列表": "natures",
    "地点": "locations",
    "地点列表": "locations",
}

CandidateMap = dict[str, dict[str, set[str]]]


@dataclass(frozen=True)
class StringToken:
    """A Lua single- or double-quoted string's raw content span."""

    value: str
    start: int
    end: int
    quote: str


@dataclass(frozen=True)
class Fix:
    path: Path
    line: int
    semantic_group: str
    english: str
    before: str
    after: str
    source: str


@dataclass
class AuditResult:
    fixes: list[Fix]
    errors: list[str]
    warnings: list[str]

    @property
    def ok(self) -> bool:
        return not self.fixes and not self.errors


@dataclass(frozen=True)
class TableRange:
    name: str
    semantic_group: str | None
    start: int
    end: int
    tokens: tuple[StringToken, ...]


@dataclass(frozen=True)
class _LuaRegion:
    kind: str
    start: int
    end: int
    token: StringToken | None = None


@dataclass(frozen=True)
class _Replacement:
    fix: Fix
    start: int
    end: int


@dataclass
class _FileState:
    relative_path: Path
    absolute_path: Path
    current_source: str
    current_has_bom: bool
    base_source: str
    current_tables: list[TableRange]
    base_tables: list[TableRange]


@dataclass
class _AuditDetails:
    result: AuditResult
    replacements: list[_Replacement]
    files: dict[Path, _FileState]
    unsafe: bool


_LONG_BRACKET_OPEN_RE = re.compile(r"\[(=*)\[")
_TABLE_ASSIGNMENT_RE = re.compile(
    r"\b(?P<name>" + "|".join(map(re.escape, SEMANTIC_TABLES)) + r")\s*=\s*(?P<brace>\{)"
)
_FORMAT_PART_RE = re.compile(
    r"%(?:%|[-+ #0]*\d*(?:\.\d+)?[cdiouxXeEfgGqsaA])"
    r"|\\(?:x[0-9A-Fa-f]{2}|u\{[0-9A-Fa-f]+\}|\d{1,3}|\r?\n|[abfnrtvz\\\"'])"
)
_CODE_TOKEN_RE = re.compile(
    r"[A-Za-z_][A-Za-z0-9_]*"
    r"|0[xX](?:[0-9A-Fa-f]+(?:\.[0-9A-Fa-f]*)?|\.[0-9A-Fa-f]+)(?:[pP][+-]?\d+)?"
    r"|(?:\d+(?:\.\d*)?|\.\d+)(?:[eE][+-]?\d+)?"
    r"|\.\.\.|==|~=|<=|>=|::|//|<<|>>|\.\."
    r"|[^\s]"
)
_ASCII_LETTER_RE = re.compile(r"[A-Za-z]")
_CJK_RE = re.compile(r"[\u3400-\u9fff]")
_JAPANESE_KANA_RE = re.compile(r"[\u3040-\u30ff]")
_HEX_DIGITS = frozenset("0123456789abcdefABCDEF")
_LUA_SIMPLE_ESCAPES = frozenset("abfnrtv\\\"'")
_LUA_WHITESPACE = frozenset(" \t\v\f\r\n")


def _long_bracket_end(source: str, start: int) -> tuple[int, bool] | None:
    match = _LONG_BRACKET_OPEN_RE.match(source, start)
    if match is None:
        return None
    close = "]" + match.group(1) + "]"
    close_start = source.find(close, match.end())
    if close_start < 0:
        return len(source), False
    return close_start + len(close), True


def _scan_lua_regions(source: str) -> list[_LuaRegion]:
    """Return comments and strings while respecting Lua lexical boundaries."""

    regions: list[_LuaRegion] = []
    index = 0
    length = len(source)

    while index < length:
        if source.startswith("--", index):
            long_bracket = _long_bracket_end(source, index + 2)
            if long_bracket is not None:
                long_end, terminated = long_bracket
                kind = "comment" if terminated else "unterminated_long_comment"
                regions.append(_LuaRegion(kind, index, long_end))
                index = long_end
                continue
            newline = source.find("\n", index + 2)
            end = length if newline < 0 else newline
            regions.append(_LuaRegion("comment", index, end))
            index = end
            continue

        character = source[index]
        if character in {'"', "'"}:
            quote = character
            content_start = index + 1
            cursor = content_start
            while cursor < length:
                if source[cursor] == "\\":
                    if cursor + 1 < length and source[cursor + 1] == "z":
                        cursor += 2
                        while cursor < length and source[cursor].isspace():
                            cursor += 1
                    elif (
                        cursor + 2 < length
                        and source[cursor + 1] == "\r"
                        and source[cursor + 2] == "\n"
                    ):
                        cursor += 3
                    else:
                        cursor += 2
                    continue
                if source[cursor] in "\r\n":
                    token = StringToken(source[content_start:cursor], content_start, cursor, quote)
                    regions.append(_LuaRegion("unterminated_string", index, cursor, token))
                    break
                if source[cursor] == quote:
                    token = StringToken(source[content_start:cursor], content_start, cursor, quote)
                    regions.append(_LuaRegion("short_string", index, cursor + 1, token))
                    cursor += 1
                    break
                cursor += 1
            else:
                token = StringToken(source[content_start:length], content_start, length, quote)
                regions.append(_LuaRegion("unterminated_string", index, length, token))
                cursor = length
            index = cursor
            continue

        if character == "[":
            long_bracket = _long_bracket_end(source, index)
            if long_bracket is not None:
                long_end, terminated = long_bracket
                kind = "long_string" if terminated else "unterminated_long_string"
                regions.append(_LuaRegion(kind, index, long_end))
                index = long_end
                continue

        index += 1

    return regions


def extract_lua_short_strings(source: str) -> list[StringToken]:
    """Extract raw Lua short-string contents, excluding comments/long strings."""

    return [
        region.token
        for region in _scan_lua_regions(source)
        if region.kind in {"short_string", "unterminated_string"} and region.token is not None
    ]


def format_signature(value: str) -> tuple[str, ...]:
    """Return ordered printf placeholders and literal Lua escape sequences."""

    return tuple(match.group(0) for match in _FORMAT_PART_RE.finditer(value))


def _masked_executable_source(source: str) -> str:
    characters = list(source)
    for region in _scan_lua_regions(source):
        for index in range(region.start, region.end):
            if characters[index] not in "\r\n":
                characters[index] = " "
        if region.kind in {
            "short_string",
            "unterminated_string",
            "long_string",
            "unterminated_long_string",
        }:
            characters[region.start] = "@"
    return "".join(characters)


def executable_skeleton(source: str) -> tuple[str, ...]:
    """Tokenize executable Lua while ignoring comments and string contents."""

    return tuple(_CODE_TOKEN_RE.findall(_masked_executable_source(source)))


def _location_group(path: Path) -> str | None:
    stem = path.stem.casefold()
    if "b2w2" in stem:
        return "bw2"
    if re.search(r"(?:^|_)bw(?:_|$)", stem):
        return "bw"
    if "hgss" in stem:
        return "hgss"
    if "frlg" in stem:
        return "frlg"
    if "bdsp" in stem:
        return "bdsp"
    if re.search(r"(?:^|_)(?:dp|pt)(?:_|$)", stem):
        return "dppt"
    if re.search(r"(?:^|_)rs(?:_|$)", stem):
        return "rs"
    if re.search(r"(?:^|_)e(?:_|$)", stem):
        return "e"
    return None


def _semantic_group(table_name: str, path: Path) -> str | None:
    group = SEMANTIC_TABLES[table_name]
    return _location_group(path) if group == "locations" else group


def find_semantic_tables(source: str, path: str | Path = "") -> list[TableRange]:
    """Find known table assignments using braces outside comments and strings."""

    source_path = Path(path)
    masked = _masked_executable_source(source)
    all_strings = extract_lua_short_strings(source)
    tables: list[TableRange] = []

    for match in _TABLE_ASSIGNMENT_RE.finditer(masked):
        open_brace = match.start("brace")
        depth = 0
        close_brace: int | None = None
        for index in range(open_brace, len(masked)):
            if masked[index] == "{":
                depth += 1
            elif masked[index] == "}":
                depth -= 1
                if depth == 0:
                    close_brace = index
                    break
        if close_brace is None:
            close_brace = len(source)
        table_tokens = tuple(
            token for token in all_strings if open_brace < token.start and token.end <= close_brace
        )
        name = match.group("name")
        tables.append(
            TableRange(
                name=name,
                semantic_group=_semantic_group(name, source_path),
                start=open_brace,
                end=close_brace + (close_brace < len(source)),
                tokens=table_tokens,
            )
        )
    return tables


def _empty_candidates() -> defaultdict[str, defaultdict[str, set[str]]]:
    return defaultdict(lambda: defaultdict(set))


def _freeze_candidates(
    candidates: defaultdict[str, defaultdict[str, set[str]]],
) -> CandidateMap:
    return {
        group: {english: set(values) for english, values in sorted(entries.items())}
        for group, entries in sorted(candidates.items())
    }


def load_csv_candidates(csv_path: str | Path) -> CandidateMap:
    """Load only the CSV's context-qualified ``统一中文建议`` values."""

    candidates = _empty_candidates()
    with Path(csv_path).open("r", encoding="utf-8-sig", newline="") as stream:
        reader = csv.DictReader(stream)
        required = {"分组", "英文原文", "统一中文建议"}
        if reader.fieldnames is None or not required.issubset(reader.fieldnames):
            missing = ", ".join(sorted(required - set(reader.fieldnames or [])))
            raise ValueError(f"CSV is missing required columns: {missing}")
        for row in reader:
            group = (row.get("分组") or "").strip().casefold()
            english = (row.get("英文原文") or "").strip()
            suggestion = (row.get("统一中文建议") or "").strip()
            if group and english and suggestion:
                candidates[group][english].add(suggestion)
    return _freeze_candidates(candidates)


def normalize_xlsx_term(value: str, semantic_group: str) -> str:
    """Remove spreadsheet metadata without changing the represented term."""

    normalized = value.strip()
    if semantic_group.casefold() in {"species", "pokemon", "宝可梦"}:
        normalized = re.sub(r"\s*[\*＊]+\s*$", "", normalized).rstrip()
    return normalized


def _xml_text(element: ET.Element) -> str:
    return "".join(node.text or "" for node in element.iter() if node.tag.rsplit("}", 1)[-1] == "t")


def _xlsx_shared_strings(archive: zipfile.ZipFile) -> list[str]:
    try:
        root = ET.fromstring(archive.read("xl/sharedStrings.xml"))
    except KeyError:
        return []
    return [_xml_text(item) for item in root if item.tag.rsplit("}", 1)[-1] == "si"]


def _xlsx_sheet_paths(archive: zipfile.ZipFile) -> list[tuple[str, str]]:
    workbook = ET.fromstring(archive.read("xl/workbook.xml"))
    relationships = ET.fromstring(archive.read("xl/_rels/workbook.xml.rels"))
    targets = {
        relationship.attrib["Id"]: relationship.attrib["Target"]
        for relationship in relationships
        if "Id" in relationship.attrib and "Target" in relationship.attrib
    }
    sheets: list[tuple[str, str]] = []
    for sheet in workbook.iter():
        if sheet.tag.rsplit("}", 1)[-1] != "sheet":
            continue
        relation_id = next(
            (value for key, value in sheet.attrib.items() if key.rsplit("}", 1)[-1] == "id"),
            None,
        )
        if relation_id is None or relation_id not in targets:
            continue
        target = targets[relation_id].replace("\\", "/")
        if target.startswith("/"):
            archive_path = target.lstrip("/")
        else:
            archive_path = posixpath.normpath(posixpath.join("xl", target))
        sheets.append((sheet.attrib.get("name", relation_id), archive_path))
    return sheets


def _column_index(reference: str) -> int:
    result = 0
    for character in reference:
        if not character.isalpha():
            break
        result = result * 26 + ord(character.upper()) - ord("A") + 1
    return result


def _xlsx_cell_value(cell: ET.Element, shared_strings: list[str]) -> str:
    cell_type = cell.attrib.get("t")
    if cell_type == "inlineStr":
        return _xml_text(cell)
    value_node = next(
        (child for child in cell if child.tag.rsplit("}", 1)[-1] == "v"),
        None,
    )
    value = "" if value_node is None or value_node.text is None else value_node.text
    if cell_type == "s" and value:
        try:
            return shared_strings[int(value)]
        except (IndexError, ValueError):
            return ""
    return value


def _looks_english_term(value: str) -> bool:
    return bool(_ASCII_LETTER_RE.search(value)) and not _CJK_RE.search(value) and not _JAPANESE_KANA_RE.search(value)


def _looks_chinese_term(value: str) -> bool:
    return bool(_CJK_RE.search(value)) and not _JAPANESE_KANA_RE.search(value)


def load_xlsx_candidates(xlsx_path: str | Path) -> CandidateMap:
    """Read reference terms directly from XLSX OOXML using no third party code."""

    candidates = _empty_candidates()
    with zipfile.ZipFile(xlsx_path) as archive:
        shared_strings = _xlsx_shared_strings(archive)
        for _sheet_name, sheet_path in _xlsx_sheet_paths(archive):
            sheet = ET.fromstring(archive.read(sheet_path))
            active_group: str | None = None
            for row in sheet.iter():
                if row.tag.rsplit("}", 1)[-1] != "row":
                    continue
                cells: list[tuple[int, str]] = []
                for cell in row:
                    if cell.tag.rsplit("}", 1)[-1] != "c":
                        continue
                    value = _xlsx_cell_value(cell, shared_strings).strip()
                    if value:
                        cells.append((_column_index(cell.attrib.get("r", "")), value))
                if not cells:
                    continue

                section = next((XLSX_SECTION_NAMES[value] for _, value in cells if value in XLSX_SECTION_NAMES), None)
                if section is not None:
                    active_group = section
                    if len(cells) == 1:
                        continue
                if active_group is None:
                    continue

                english_cells = [item for item in cells if _looks_english_term(item[1])]
                if not english_cells:
                    continue
                english_column, english = english_cells[0]
                if english.casefold() in {"english", "english name", "name"}:
                    continue

                chinese_cells = [
                    item for item in cells if item[0] < english_column and _looks_chinese_term(item[1])
                ]
                if not chinese_cells:
                    chinese_cells = [item for item in cells if _looks_chinese_term(item[1])]
                if not chinese_cells:
                    continue
                _chinese_column, chinese = chinese_cells[0]

                english = normalize_xlsx_term(english, active_group)
                chinese = normalize_xlsx_term(chinese, active_group)
                if english and chinese:
                    candidates[active_group][english].add(chinese)
    return _freeze_candidates(candidates)


def _candidate_values(candidates: CandidateMap, group: str, english: str) -> set[str]:
    direct = candidates.get(group)
    if direct is None:
        direct = next((values for key, values in candidates.items() if key.casefold() == group.casefold()), None)
    if direct is None:
        return set()
    return set(direct.get(english, set()))


def _xlsx_group_for(semantic_group: str) -> str | None:
    if semantic_group in LOCATION_GROUPS:
        return "locations"
    if semantic_group in {"species", "moves", "abilities", "items", "natures"}:
        return semantic_group
    return None


def select_expected_translation(
    english: str,
    semantic_group: str | None,
    csv_candidates: CandidateMap,
    xlsx_candidates: CandidateMap,
) -> str | None:
    """Select one context-qualified translation, with CSV-first precedence."""

    if semantic_group is None:
        return None
    normalized_group = semantic_group.casefold()
    csv_values = _candidate_values(csv_candidates, normalized_group, english)
    if csv_values:
        return next(iter(csv_values)) if len(csv_values) == 1 else None
    xlsx_group = _xlsx_group_for(normalized_group)
    if xlsx_group is None:
        return None
    xlsx_values = _candidate_values(xlsx_candidates, xlsx_group, english)
    return next(iter(xlsx_values)) if len(xlsx_values) == 1 else None


def _resolve_expected(
    english: str,
    semantic_group: str | None,
    csv_candidates: CandidateMap,
    xlsx_candidates: CandidateMap,
) -> tuple[str | None, str | None, str | None]:
    if semantic_group is None:
        return None, None, None
    group = semantic_group.casefold()
    csv_values = _candidate_values(csv_candidates, group, english)
    if len(csv_values) > 1:
        return None, None, f'ambiguous CSV candidates for {group} {english!r}: {sorted(csv_values)!r}'
    if len(csv_values) == 1:
        return next(iter(csv_values)), "csv", None
    xlsx_group = _xlsx_group_for(group)
    if xlsx_group is None:
        return None, None, None
    xlsx_values = _candidate_values(xlsx_candidates, xlsx_group, english)
    if len(xlsx_values) > 1:
        return None, None, f'ambiguous XLSX candidates for {xlsx_group} {english!r}: {sorted(xlsx_values)!r}'
    if len(xlsx_values) == 1:
        return next(iter(xlsx_values)), "xlsx", None
    return None, None, None


def _run_git(root: Path, arguments: Iterable[str]) -> subprocess.CompletedProcess[bytes]:
    return subprocess.run(
        ["git", "-C", os.fspath(root), *arguments],
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        check=False,
    )


def _baseline_lua_paths(root: Path, base_ref: str) -> list[str]:
    process = _run_git(root, ["ls-tree", "-r", "--name-only", "-z", base_ref])
    if process.returncode:
        message = process.stderr.decode("utf-8", errors="replace").strip()
        raise ValueError(f"cannot enumerate base ref {base_ref!r}: {message}")
    return sorted(
        path
        for path in process.stdout.decode("utf-8", errors="strict").split("\0")
        if path.casefold().endswith(".lua")
    )


def _baseline_source(root: Path, base_ref: str, relative_path: str) -> str:
    process = _run_git(root, ["show", f"{base_ref}:{relative_path}"])
    if process.returncode:
        message = process.stderr.decode("utf-8", errors="replace").strip()
        raise ValueError(f"cannot read {relative_path!r} at {base_ref!r}: {message}")
    return process.stdout.decode("utf-8-sig", errors="strict")


def _read_utf8(path: Path) -> tuple[str, bool]:
    data = path.read_bytes()
    has_bom = data.startswith(b"\xef\xbb\xbf")
    return data.decode("utf-8-sig", errors="strict"), has_bom


def _table_keys(tables: list[TableRange]) -> dict[tuple[str, int], TableRange]:
    counts: defaultdict[str, int] = defaultdict(int)
    keyed: dict[tuple[str, int], TableRange] = {}
    for table in tables:
        counts[table.name] += 1
        keyed[(table.name, counts[table.name])] = table
    return keyed


def _format_table_key(key: tuple[str, int]) -> str:
    name, occurrence = key
    return name if occurrence == 1 else f"{name}#{occurrence}"


def _fix_sort_key(fix: Fix) -> tuple[str, int, str, str, str]:
    return (fix.path.as_posix(), fix.line, fix.semantic_group, fix.english, fix.after)


def _analyze_file(
    state: _FileState,
    csv_candidates: CandidateMap,
    xlsx_candidates: CandidateMap,
    errors: list[str],
    warnings: set[str],
    replacements: list[_Replacement],
) -> bool:
    """Analyze one paired file and return whether safe rewriting is possible."""

    unsafe = False
    display_path = state.relative_path.as_posix()
    base_regions = _scan_lua_regions(state.base_source)
    current_regions = _scan_lua_regions(state.current_source)
    if any(region.kind == "unterminated_string" for region in base_regions):
        errors.append(f"{display_path}: unterminated short string in base source")
        unsafe = True
    if any(region.kind == "unterminated_string" for region in current_regions):
        errors.append(f"{display_path}: unterminated short string in current source")
        unsafe = True
    if any(region.kind in {"unterminated_long_string", "unterminated_long_comment"} for region in base_regions):
        errors.append(f"{display_path}: unterminated long-bracket region in base source")
        unsafe = True
    if any(
        region.kind in {"unterminated_long_string", "unterminated_long_comment"}
        for region in current_regions
    ):
        errors.append(f"{display_path}: unterminated long-bracket region in current source")
        unsafe = True

    base_tokens = [region.token for region in base_regions if region.token is not None and "string" in region.kind]
    current_tokens = [region.token for region in current_regions if region.token is not None and "string" in region.kind]
    if len(base_tokens) != len(current_tokens):
        errors.append(
            f"{display_path}: string-token count drift (base {len(base_tokens)}, current {len(current_tokens)})"
        )
        unsafe = True
    for index, (base_token, current_token) in enumerate(zip(base_tokens, current_tokens), start=1):
        if format_signature(base_token.value) != format_signature(current_token.value):
            line = state.current_source.count("\n", 0, current_token.start) + 1
            errors.append(
                f"{display_path}:{line}: placeholder/escape drift in string token {index} "
                f"({format_signature(base_token.value)!r} -> {format_signature(current_token.value)!r})"
            )
            unsafe = True

    if executable_skeleton(state.base_source) != executable_skeleton(state.current_source):
        errors.append(f"{display_path}: executable code-skeleton drift")
        unsafe = True

    base_tables = _table_keys(state.base_tables)
    current_tables = _table_keys(state.current_tables)
    for key in sorted(set(base_tables) | set(current_tables)):
        if key not in base_tables:
            errors.append(f"{display_path}: semantic table {_format_table_key(key)} added")
            unsafe = True
            continue
        if key not in current_tables:
            errors.append(f"{display_path}: semantic table {_format_table_key(key)} missing")
            unsafe = True
            continue
        base_table = base_tables[key]
        current_table = current_tables[key]
        if len(base_table.tokens) != len(current_table.tokens):
            errors.append(
                f"{display_path}: semantic-table length drift in {_format_table_key(key)} "
                f"(base {len(base_table.tokens)}, current {len(current_table.tokens)})"
            )
            unsafe = True
            continue
        if base_table.semantic_group != current_table.semantic_group:
            errors.append(
                f"{display_path}: semantic group drift in {_format_table_key(key)} "
                f"({base_table.semantic_group!r} -> {current_table.semantic_group!r})"
            )
            unsafe = True
            continue

        if base_table.semantic_group == "charMap":
            base_values = tuple(token.value for token in base_table.tokens)
            current_values = tuple(token.value for token in current_table.tokens)
            if base_values != current_values:
                errors.append(f"{display_path}: structural charMap data drift")
                unsafe = True
            continue
        if current_table.semantic_group is None:
            warnings.add(f"{display_path}: locationNamesList has no recognized semantic context")
            continue

        for base_token, current_token in zip(base_table.tokens, current_table.tokens):
            expected, source_name, ambiguity = _resolve_expected(
                base_token.value,
                current_table.semantic_group,
                csv_candidates,
                xlsx_candidates,
            )
            if ambiguity:
                warnings.add(ambiguity)
                continue
            if expected is None or source_name is None:
                continue
            encoded_expected = _escape_lua_content(expected, current_token.quote)
            if not _is_valid_lua_short_content(encoded_expected, current_token.quote):
                warnings.add(
                    f"invalid Lua short-string reference for {current_table.semantic_group} "
                    f"{base_token.value!r} from {source_name}"
                )
                continue
            if current_token.value == encoded_expected:
                continue
            if format_signature(base_token.value) != format_signature(encoded_expected):
                warnings.add(
                    f"reference signature mismatch for {current_table.semantic_group} "
                    f"{base_token.value!r} from {source_name}"
                )
                continue
            line = state.current_source.count("\n", 0, current_token.start) + 1
            fix = Fix(
                path=state.relative_path,
                line=line,
                semantic_group=current_table.semantic_group,
                english=base_token.value,
                before=current_token.value,
                after=encoded_expected,
                source=source_name,
            )
            replacements.append(
                _Replacement(fix=fix, start=current_token.start, end=current_token.end)
            )
    return unsafe


def _report_duplicate_divergence(states: Iterable[_FileState], errors: list[str]) -> bool:
    copies: defaultdict[
        tuple[str, tuple[str, ...]], list[tuple[Path, tuple[str, ...]]]
    ] = defaultdict(list)
    for state in states:
        base_tables = _table_keys(state.base_tables)
        current_tables = _table_keys(state.current_tables)
        for key, base_table in base_tables.items():
            current_table = current_tables.get(key)
            if current_table is None or len(base_table.tokens) != len(current_table.tokens):
                continue
            baseline_values = tuple(token.value for token in base_table.tokens)
            current_values = tuple(token.value for token in current_table.tokens)
            copies[(base_table.name, baseline_values)].append((state.relative_path, current_values))

    diverged = False
    for (table_name, _baseline_values), entries in sorted(
        copies.items(), key=lambda item: (item[0][0], item[1][0][0].as_posix())
    ):
        if len(entries) < 2:
            continue
        variants = {values for _path, values in entries}
        if len(variants) > 1:
            paths = ", ".join(path.as_posix() for path, _values in sorted(entries))
            errors.append(f"duplicated {table_name} tables diverge: {paths}")
            diverged = True
    return diverged


def _unchanged_english_warnings(states: Iterable[_FileState]) -> list[str]:
    warnings: list[str] = []
    for state in sorted(states, key=lambda item: item.relative_path.as_posix()):
        base_tokens = extract_lua_short_strings(state.base_source)
        current_tokens = extract_lua_short_strings(state.current_source)
        char_map_spans = [
            (table.start, table.end) for table in state.current_tables if table.semantic_group == "charMap"
        ]
        for base_token, current_token in zip(base_tokens, current_tokens):
            if base_token.value != current_token.value or not _ASCII_LETTER_RE.search(current_token.value):
                continue
            if any(start < current_token.start < end for start, end in char_map_spans):
                continue
            line = state.current_source.count("\n", 0, current_token.start) + 1
            warnings.append(
                f"{state.relative_path.as_posix()}:{line}: unchanged English {current_token.value!r}"
            )
    return warnings


def _collect_audit(
    root: str | Path,
    csv_path: str | Path,
    xlsx_path: str | Path,
    base_ref: str,
    *,
    report_unchanged_english: bool = False,
) -> _AuditDetails:
    repository = Path(root).resolve()
    errors: list[str] = []
    warnings: set[str] = set()
    replacements: list[_Replacement] = []
    states: dict[Path, _FileState] = {}
    unsafe = False

    try:
        csv_candidates = load_csv_candidates(csv_path)
    except (OSError, UnicodeError, csv.Error, ValueError) as error:
        errors.append(f"cannot load CSV reference {Path(csv_path)}: {error}")
        csv_candidates = {}
        unsafe = True
    try:
        xlsx_candidates = load_xlsx_candidates(xlsx_path)
    except (OSError, ET.ParseError, zipfile.BadZipFile, KeyError, ValueError) as error:
        errors.append(f"cannot load XLSX reference {Path(xlsx_path)}: {error}")
        xlsx_candidates = {}
        unsafe = True

    try:
        base_paths = _baseline_lua_paths(repository, base_ref)
    except (OSError, UnicodeError, ValueError) as error:
        errors.append(str(error))
        base_paths = []
        unsafe = True

    current_paths = sorted(
        path.relative_to(repository).as_posix()
        for path in repository.rglob("*.lua")
        if ".git" not in path.parts
    )
    for relative in sorted(set(base_paths) | set(current_paths)):
        relative_path = Path(relative)
        absolute_path = repository / relative_path
        if relative not in base_paths:
            errors.append(f"{relative}: Lua file has no counterpart at base ref {base_ref}")
            unsafe = True
            continue
        if relative not in current_paths or not absolute_path.is_file():
            errors.append(f"{relative}: Lua file from base ref is missing in working tree")
            unsafe = True
            continue
        try:
            base_source = _baseline_source(repository, base_ref, relative)
            current_source, has_bom = _read_utf8(absolute_path)
        except (OSError, UnicodeError, ValueError) as error:
            errors.append(f"{relative}: cannot read paired UTF-8 sources: {error}")
            unsafe = True
            continue
        state = _FileState(
            relative_path=relative_path,
            absolute_path=absolute_path,
            current_source=current_source,
            current_has_bom=has_bom,
            base_source=base_source,
            current_tables=find_semantic_tables(current_source, relative_path),
            base_tables=find_semantic_tables(base_source, relative_path),
        )
        states[relative_path] = state
        unsafe = _analyze_file(
            state,
            csv_candidates,
            xlsx_candidates,
            errors,
            warnings,
            replacements,
        ) or unsafe

    unsafe = _report_duplicate_divergence(states.values(), errors) or unsafe
    if report_unchanged_english:
        warnings.update(_unchanged_english_warnings(states.values()))

    replacements.sort(key=lambda replacement: _fix_sort_key(replacement.fix))
    result = AuditResult(
        fixes=[replacement.fix for replacement in replacements],
        errors=sorted(set(errors)),
        warnings=sorted(warnings),
    )
    return _AuditDetails(result=result, replacements=replacements, files=states, unsafe=unsafe)


def audit_repository(
    root: str | Path,
    csv_path: str | Path,
    xlsx_path: str | Path,
    base_ref: str = DEFAULT_BASE_REF,
) -> AuditResult:
    """Audit all Lua files against a Git baseline and the two references."""

    return _collect_audit(root, csv_path, xlsx_path, base_ref).result


def _escape_lua_content(value: str, quote: str) -> str:
    result: list[str] = []
    preceding_backslashes = 0
    for character in value:
        if character == quote and preceding_backslashes % 2 == 0:
            result.append("\\")
        result.append(character)
        if character == "\\":
            preceding_backslashes += 1
        else:
            preceding_backslashes = 0
    return "".join(result)


def _has_valid_lua_escapes(value: str) -> bool:
    """Validate escapes for a raw candidate without decoding its content."""

    index = 0
    while index < len(value):
        if value[index] != "\\":
            index += 1
            continue
        if index + 1 >= len(value):
            return False

        escaped = value[index + 1]
        if escaped in _LUA_SIMPLE_ESCAPES:
            index += 2
            continue
        if escaped in "\r\n":
            if index + 2 < len(value) and {escaped, value[index + 2]} == {"\r", "\n"}:
                index += 3
            else:
                index += 2
            continue
        if escaped == "z":
            index += 2
            while index < len(value) and value[index] in _LUA_WHITESPACE:
                index += 1
            continue
        if escaped.isascii() and escaped.isdigit():
            end = index + 1
            while (
                end < len(value)
                and end < index + 4
                and value[end].isascii()
                and value[end].isdigit()
            ):
                end += 1
            if int(value[index + 1 : end]) > 255:
                return False
            index = end
            continue
        if escaped == "x":
            digits = value[index + 2 : index + 4]
            if len(digits) != 2 or any(character not in _HEX_DIGITS for character in digits):
                return False
            index += 4
            continue
        if escaped == "u":
            if index + 2 >= len(value) or value[index + 2] != "{":
                return False
            close = value.find("}", index + 3)
            if close < 0:
                return False
            digits = value[index + 3 : close]
            if not digits or any(character not in _HEX_DIGITS for character in digits):
                return False
            codepoint = int(digits, 16)
            if codepoint > 0x10FFFF or 0xD800 <= codepoint <= 0xDFFF:
                return False
            index = close + 1
            continue
        return False
    return True


def _is_valid_lua_short_content(value: str, quote: str) -> bool:
    if not _has_valid_lua_escapes(value):
        return False
    wrapped = quote + value + quote
    regions = _scan_lua_regions(wrapped)
    if len(regions) != 1:
        return False
    region = regions[0]
    return (
        region.kind == "short_string"
        and region.start == 0
        and region.end == len(wrapped)
        and region.token is not None
        and region.token.value == value
    )


def _atomic_write_utf8(path: Path, source: str, has_bom: bool) -> None:
    encoded = source.encode("utf-8")
    if has_bom:
        encoded = b"\xef\xbb\xbf" + encoded
    descriptor, temporary_name = tempfile.mkstemp(prefix=f".{path.name}.", suffix=".tmp", dir=path.parent)
    temporary_path = Path(temporary_name)
    try:
        with os.fdopen(descriptor, "wb") as stream:
            stream.write(encoded)
            stream.flush()
            os.fsync(stream.fileno())
        os.replace(temporary_path, path)
    except BaseException:
        try:
            temporary_path.unlink()
        except FileNotFoundError:
            pass
        raise


def apply_reference_fixes(
    root: str | Path,
    csv_path: str | Path,
    xlsx_path: str | Path,
    base_ref: str = DEFAULT_BASE_REF,
) -> list[Fix]:
    """Apply unambiguous reference fixes to already-paired string contents."""

    details = _collect_audit(root, csv_path, xlsx_path, base_ref)
    if details.unsafe:
        raise RuntimeError("refusing to rewrite because structural or input errors were found")

    grouped: defaultdict[Path, list[_Replacement]] = defaultdict(list)
    for replacement in details.replacements:
        grouped[replacement.fix.path].append(replacement)

    for relative_path in sorted(grouped, key=lambda path: path.as_posix()):
        state = details.files[relative_path]
        latest_source, latest_has_bom = _read_utf8(state.absolute_path)
        if latest_source != state.current_source or latest_has_bom != state.current_has_bom:
            raise RuntimeError(f"{relative_path.as_posix()} changed during the audit; refusing to rewrite")
        source = latest_source
        prior_start = len(source) + 1
        for replacement in sorted(grouped[relative_path], key=lambda item: item.start, reverse=True):
            if replacement.end > prior_start:
                raise RuntimeError(f"overlapping replacements in {relative_path.as_posix()}")
            source = source[: replacement.start] + replacement.fix.after + source[replacement.end :]
            prior_start = replacement.start
        _atomic_write_utf8(state.absolute_path, source, state.current_has_bom)

    return [replacement.fix for replacement in details.replacements]


def _reference_path(root: Path, value: str) -> Path:
    path = Path(value)
    return path if path.is_absolute() else root / path


def _print_result(result: AuditResult) -> None:
    for error in result.errors:
        print(f"ERROR: {error}")
    for warning in result.warnings:
        print(f"WARNING: {warning}")
    for fix in result.fixes:
        print(
            f"FIX: {fix.path.as_posix()}:{fix.line} [{fix.semantic_group}] "
            f"{fix.english!r}: {fix.before!r} -> {fix.after!r} ({fix.source})"
        )
    print(
        f"Summary: {len(result.fixes)} fix(es), {len(result.errors)} error(s), "
        f"{len(result.warnings)} warning(s)"
    )


def _build_argument_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(description=__doc__)
    subparsers = parser.add_subparsers(dest="mode", required=True)
    for mode in ("check", "fix"):
        command = subparsers.add_parser(mode, help=f"{mode} reference-qualified translations")
        command.add_argument("--root", default=".", help="repository root (default: current directory)")
        command.add_argument("--csv", required=True, help="path to 汉化统一对照表.csv")
        command.add_argument("--xlsx", required=True, help="path to 宝可梦对照表.backup.xlsx")
        command.add_argument("--base-ref", default=DEFAULT_BASE_REF, help="immutable English Git ref")
        if mode == "check":
            command.add_argument(
                "--report-unchanged-english",
                action="store_true",
                help="list paired English strings that remain unchanged",
            )
            command.add_argument(
                "--verify-structure",
                action="store_true",
                help="explicitly request structural checks (these always run)",
            )
    return parser


def main(argv: list[str] | None = None) -> int:
    arguments = _build_argument_parser().parse_args(argv)
    root = Path(arguments.root).resolve()
    csv_path = _reference_path(root, arguments.csv)
    xlsx_path = _reference_path(root, arguments.xlsx)

    if arguments.mode == "check":
        details = _collect_audit(
            root,
            csv_path,
            xlsx_path,
            arguments.base_ref,
            report_unchanged_english=arguments.report_unchanged_english,
        )
        _print_result(details.result)
        return 0 if details.result.ok else 1

    try:
        applied = apply_reference_fixes(root, csv_path, xlsx_path, arguments.base_ref)
    except (OSError, RuntimeError, ValueError) as error:
        print(f"ERROR: {error}", file=sys.stderr)
        return 2
    for fix in applied:
        print(
            f"APPLIED: {fix.path.as_posix()}:{fix.line} [{fix.semantic_group}] "
            f"{fix.before!r} -> {fix.after!r} ({fix.source})"
        )
    remaining = audit_repository(root, csv_path, xlsx_path, arguments.base_ref)
    _print_result(remaining)
    return 0 if remaining.ok else 1


if __name__ == "__main__":
    raise SystemExit(main())
