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
import hashlib
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

# The XLSX row for Gram 1 contains both 配送物品 and 配送物品１.  Selecting its
# first Chinese-looking cell would erase the ordinal and break the adjacent
# Gram 1/2/3 sequence, so only this context-qualified XLSX fallback is rejected.
XLSX_FALLBACK_EXCLUSIONS = frozenset({("items", "Gram 1")})

# These decisions need more context than a reference row's English spelling.
# The item index is zero-based here and equals the in-game item ID; ``None`` is
# an intentional wildcard only after both semantic group and table name match.
CURATED_CONTEXT_TRANSLATIONS = {
    ("items", "itemNamesList", 480, "Pass"): "磁浮列车自由票",
    ("dppt", "locationNamesList", None, "Victory Road"): "冠军之路",
}

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

# Exact unchanged Lua-string values retained after a full display-text review.
# Every entry has a concrete runtime or product reason; values absent here are
# not silently treated as technical just because they happen to contain ASCII.
UNCHANGED_ENGLISH_ALLOWLIST = {
    **{
        value: "format/parse template"
        for value in (
            "%02d",
            "%02X",
            r"%02X%02X\n",
            "%08X",
            "%08X %08X %08X %d %d",
            "%08X %08X %08X %d %d %08X %d %s",
            r"%08X %08X %08X %d %d %08X %d %s\n",
            r"%08X %08X %08X %d %d\n",
            "%08X %08X %d",
            "%08X %08X %d %d %d %s %08X %s",
            r"%08X %08X %d %d %d %s %08X %s\n",
            r"%08X %08X %d\n",
            "%08X %d",
            r"%08X %d\n",
            "%08X%s",
            "%s %02d",
            "%S+",
            r"%s\n%s",
        )
    },
    **{value: "layout escape sequence" for value in (r"\n", r"\n\n", r"\t")},
    **{
        value: "userdata persistence key"
        for value in (
            "battleStartJumpFlag",
            "cgearSeed",
            "hitDate",
            "hitDelay",
            "initialSeed",
            "initialSeedHigh",
            "initialSeedLow",
            "lastCurrentSeedBeforeBattle",
            "mtCounter",
            "tempCurrentSeed",
            "tempCurrentSeedLow",
        )
    },
    "frame": "emulator callback event",
    "reset": "emulator callback event",
    "misc": "offset-map lookup key",
    "H": "hidden-ability marker",
    "L=A": "emulator control mapping value",
    "LR": "emulator control mapping value",
    "XX": "unknown-clock placeholder",
    **{
        value: "emulator API color literal"
        for value in ("#0000007F", "gray", "green", "limegreen", "orange", "red")
    },
    **{
        value: "ROM language/region code"
        for value in ("EUR", "EUR/USA", "FRE", "GER", "ITA", "JPN", "KOR", "SPA", "USA")
    },
    **{f"F{index}": "emulator API key name" for index in range(1, 11)},
    **{f"Keypad{index}": "emulator API key name" for index in range(1, 9)},
    **{f"Number{index}": "emulator API key name" for index in range(1, 9)},
    **{f"numpad{index}": "emulator API key name" for index in range(1, 9)},
    "shift": "emulator API key name",
    "clear": "emulator setting value",
    "gens": "emulator setting value",
    r"D:\\Desktop\\mGBA\\battery\\Pokemon - Ruby Version (USA, Europe) (Rev 2).sav": (
        "example ROM save path"
    ),
    r"00000000 00000000 0 0 0 2000/01/01 00:00:00 00000000 false\n": (
        "serialized state record"
    ),
    r"00000000 00000000 00000000 0 0 00000000 0 2000/01/01 00:00:00\n": (
        "serialized state record"
    ),
    r"00000000 00000000 00000000 0 0 00000000\n": "serialized state record",
    r"00000000 00000000 0\n": "serialized state record",
    r"00000000 0\n": "serialized state record",
    "20%s/%s/%s": "serialized date template",
    r"2000/01/01\n00:00:00": "serialized date placeholder",
    "states/%s_%s_states_values.txt": "state-file path template",
    "r": "file access mode",
    "rb": "file access mode",
    "w": "file access mode",
    "false": "serialized Boolean value",
    "mkdir states": "state-directory command",
    "10ANNIV / Aura Mew": "official event name",
    "C-Gear": "official product/system name",
    "MissingNo.": "official glitch name",
}

# The approved corpus is bound to the immutable English base token ordinal as
# well as its value/reason.  A value that is technical in one place (for example
# ``orange`` as a GUI color) is not thereby approved in an arbitrary label.
LUA_UNCHANGED_CONTEXT_MANIFEST = {
    "Gen 1/BizHawk/RBGY_Bot_BizHawk.lua": "4014538751a846edc1b267d0e516e68e796581807623c104c40427be3e755753",
    "Gen 1/VBA/RBGY_Bot_VBA.lua": "cdc0af7bd5b8bfc9751da4ca429aae348633de018c0222522306746802e3243e",
    "Gen 3/Dolphin/Ageto_Celebi_RNG_Dolphin.lua": "ca707b1a5299287f5c1b65a489501d65cf9288beabc136e7ce73052ca81b8734",
    "Gen 3/Dolphin/Channel_RNG_Dolphin.lua": "51efd6aa7c750682a56138f70deae01de9deb17f1c963527384f3e7dcfcfe793",
    "Gen 3/Dolphin/Colo_Pikachu_RNG_Dolphin.lua": "ca707b1a5299287f5c1b65a489501d65cf9288beabc136e7ce73052ca81b8734",
    "Gen 3/Dolphin/Colosseum_Light_RNG_Dolphin.lua": "e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855",
    "Gen 3/Dolphin/Colosseum_RNG_Dolphin.lua": "f44881df73610c504e79960e000ba201db8d5db5b593edc15623352e757b1fdd",
    "Gen 3/Dolphin/XD_RNG_Dolphin.lua": "f44881df73610c504e79960e000ba201db8d5db5b593edc15623352e757b1fdd",
    "Gen 3/mGBA/E_RNG_mGBA.lua": "e629681510e9dd7c67bab7be11a4ea1b593ec2459937ae6750f3777bcb36b369",
    "Gen 3/mGBA/FRLG_RNG_mGBA.lua": "1af8f37c65df2596ab0b3fdfbdd0d20fe3fa1360751e4191181e2f3e254f770d",
    "Gen 3/mGBA/RS_RNG_Checksums_mGBA.lua": "ef669b72ac4189fedfa8cd0db46eb691d15553e5badac55079f10a60d0c1da5b",
    "Gen 3/mGBA/RS_RNG_mGBA.lua": "712dafa40f8c2c7f81809adab1d524b11b71b235cde70f0933e8926bbcbb6929",
    "Gen 4/BizHawk/DP_RNG_BizHawk.lua": "31675129c06f47a442614bc04b515e308683ea4671ea9b8b94dc719e52512076",
    "Gen 4/BizHawk/HGSS_RNG_BizHawk.lua": "b61b89825ff47493c78da1129f31ec3677eb2f0b6c0176b6a64cf587a5ff6584",
    "Gen 4/BizHawk/Pt_RNG_BizHawk.lua": "b86df88def10db6cb535ce743fe8ce88b748aa2def2827a542a8d22a49647d0b",
    "Gen 4/DeSmuMe/DP_RNG_DeSmuMe.lua": "0f24301746b03d739c0fcc30cac1fd4e5fa3d89548be663000c99fc5b1d8f23b",
    "Gen 4/DeSmuMe/HGSS_RNG_DeSmuMe.lua": "46aaf6a4c705a697954c653e2724ce9b79494239ab3a92a2bb3b97828a351f8e",
    "Gen 4/DeSmuMe/Pt_RNG_DeSmuMe.lua": "b07b5f7662c664ce72fdd697f4a35d5490aee51c0e9902aad3479cc07a0e8743",
    "Gen 5/BizHawk/B2W2_RNG_BizHawk.lua": "74c244a4f4a9f93f39242f0fd62438a918fab11f4434ae626d3f048127e06867",
    "Gen 5/BizHawk/BW_RNG_BizHawk.lua": "e430c06b3e5f8dc6ac152e7b55e510f0091fe3e25aff5345d06e45eef9fe0a90",
    "Gen 5/DeSmuMe/B2W2_RNG_DeSmuMe.lua": "9132dbc082745ee7b24721c92f382b2565792f79df85288385c3204d62a4288d",
    "Gen 5/DeSmuMe/BW_RNG_DeSmuMe.lua": "58cd39da7ced1a63c0f52e938596a28d1f5ecbf9d5b47fe822101aacc71ae5cd",
}

# This second manifest covers every current non-charMap short-string token that
# contains an ASCII letter, including already translated mixed-language text.
# Binding the complete value to its ordinal prevents newly inserted, moved, or
# edited ASCII-bearing tokens from bypassing the unchanged-English classifier.
LUA_CURRENT_ASCII_CONTEXT_MANIFEST = {
    "Gen 1/BizHawk/RBGY_Bot_BizHawk.lua": "6fb6e3b73a397fb27ee4324b6a9d5796a2278359d4497753ee0727ba7baad980",
    "Gen 1/VBA/RBGY_Bot_VBA.lua": "541523eaab05077b613acab2679e3871f26894333594d1d6384e11ada632ee3e",
    "Gen 3/Dolphin/Ageto_Celebi_RNG_Dolphin.lua": "dc076b75bfb11a583d0184a1be75eacbef5f6dce407ec493812f10a1bb51e269",
    "Gen 3/Dolphin/Channel_RNG_Dolphin.lua": "d68223b1d588fe9cff072f87d198d2b57c3b5f1b2af3a6ad773a1932b236ab86",
    "Gen 3/Dolphin/Colo_Pikachu_RNG_Dolphin.lua": "0b63037bc69145fcef482edc7140b59a923fdebbd4cabf75bbe37531780fe958",
    "Gen 3/Dolphin/Colosseum_Light_RNG_Dolphin.lua": "8cf082f97de99a74bc5ee8fb9fee586628c8d6d0bbb2c22cde2dd7a39a3216d6",
    "Gen 3/Dolphin/Colosseum_RNG_Dolphin.lua": "2b4ba78ae736da5a27afb040c6290bde2601784c98514417d1637bc9e3eb76e4",
    "Gen 3/Dolphin/XD_RNG_Dolphin.lua": "2b4ba78ae736da5a27afb040c6290bde2601784c98514417d1637bc9e3eb76e4",
    "Gen 3/mGBA/E_RNG_mGBA.lua": "6064674ac41f0e32f20359407b7341b7c7871e148f66f4bcf089764cb07a8793",
    "Gen 3/mGBA/FRLG_RNG_mGBA.lua": "3c4bd74e7e0d0cdfd3809cefa4d016c6c48df862773644107aa206f55ae29fd0",
    "Gen 3/mGBA/RS_RNG_Checksums_mGBA.lua": "09bade14a2d244009254b5f78b50d73d338cee64c885cd487630eff7141f5235",
    "Gen 3/mGBA/RS_RNG_mGBA.lua": "13a50c3a7509a94ca3eaae11365aa7f640f910400f36f8101153f8dd4e33566e",
    "Gen 4/BizHawk/DP_RNG_BizHawk.lua": "f646f9347df9ca1b962b8b2025262779d23355ba8b84ade07e27d409a4f7a9bb",
    "Gen 4/BizHawk/HGSS_RNG_BizHawk.lua": "ca15e8532002e502f242373515da8dfaee92f0d9038bcd6acdd42a6df312e311",
    "Gen 4/BizHawk/Pt_RNG_BizHawk.lua": "25ea980f4b56ce1032fd45352f2e774dad86c085b8798c428debd6120af03cf7",
    "Gen 4/DeSmuMe/DP_RNG_DeSmuMe.lua": "3853d0eba7657bfc0f115711488eb430039376cc50f0bcd8536ed2f75684616e",
    "Gen 4/DeSmuMe/HGSS_RNG_DeSmuMe.lua": "ecd38565bfd88938db372e98009a87c0f05df7c97527604b2006ac6d1c68e114",
    "Gen 4/DeSmuMe/Pt_RNG_DeSmuMe.lua": "580b0b98afefe0a01731c170812b29de1aa784fd919d6b3f0649e03c5040951c",
    "Gen 5/BizHawk/B2W2_RNG_BizHawk.lua": "ed9810436a282ad54e0e9189d5839bc4348d3e51212920a13a129274ff100d8b",
    "Gen 5/BizHawk/BW_RNG_BizHawk.lua": "6910677d95a55fad5879f98158e2bf5dfe1a0e204b7a9f786f543c5bcb8ff975",
    "Gen 5/DeSmuMe/B2W2_RNG_DeSmuMe.lua": "ff125aebdf6c4acd92e7c6fa280f806a5677b0b594f797d6da01e955b34050a5",
    "Gen 5/DeSmuMe/BW_RNG_DeSmuMe.lua": "42c5464033b36458693fd33ec750662868ac21916bfb9da2757fb72e67697d78",
}

README_VISIBLE_ENGLISH_ALLOWLIST = {
    **{
        value: "project/product name"
        for value in (
            "PokeLua",
            "Real96/PokeLua",
            "Pokemon",
            "PokemonRNG",
            "Devon",
            "Studios",
            "Discord",
            "BizHawk",
            "C-Gear",
            "DeSmuMe",
            "Dolphin",
            "Lua",
            "mGBA",
            "PokeFinder",
            "VBA-ReRecording",
        )
    },
    **{
        value: "game/version abbreviation"
        for value in (
            "BW",
            "BW/B2W2",
            "C/XD",
            "DP/Pt/HGSS",
            "FRLG",
            "FRLG/E",
            "GS/C",
            "RBG/Y",
            "RS",
            "RS/FRLG/E",
        )
    },
    **{
        value: "external UI/keyboard text"
        for value in ("F", "F1", "Loaded", "Restart", "Saved", "Shift", "State", "n")
    },
    **{
        value: "version/file name"
        for value in ("0.9.11_x86_dev+", "lua5.1.dll", "lua51.dll")
    },
    "RNG": "technical abbreviation",
    "TID": "technical abbreviation",
    **{
        value: "contributor/community identifier"
        for value in (
            "Admiral_Fish",
            "Bond697",
            "EzPzStreamz",
            "Kaphotics",
            "Lincoln-LM",
            "MKDasher",
            "OmegaDonut",
            "SciresM",
            "Shao",
            "StarfBerry",
            "SwareJonge",
            "Zari",
            "amab",
            "bumba",
            "wwwwwwzx",
            "xDHHzz",
            "zaksabeast",
            "zep715",
        )
    },
}

README_VISIBLE_CONTEXT_DIGEST = "36c805bd4bea99d8aef43f39e85519c8f422f83898a265ce4643870d5c1513a4"
_MARKDOWN_VISIBLE_ASCII_TOKEN_RE = re.compile(r"[A-Za-z0-9]+(?:[._/+:-][A-Za-z0-9]+)*\+?")
_MARKDOWN_HTML_BLOCK_TAGS = frozenset(
    {
        "address",
        "article",
        "aside",
        "base",
        "basefont",
        "blockquote",
        "body",
        "caption",
        "center",
        "col",
        "colgroup",
        "dd",
        "details",
        "dialog",
        "dir",
        "div",
        "dl",
        "dt",
        "fieldset",
        "figcaption",
        "figure",
        "footer",
        "form",
        "frame",
        "frameset",
        "h1",
        "h2",
        "h3",
        "h4",
        "h5",
        "h6",
        "head",
        "header",
        "hr",
        "html",
        "iframe",
        "legend",
        "li",
        "link",
        "main",
        "menu",
        "menuitem",
        "nav",
        "noframes",
        "ol",
        "optgroup",
        "option",
        "p",
        "param",
        "search",
        "section",
        "summary",
        "table",
        "tbody",
        "td",
        "tfoot",
        "th",
        "thead",
        "title",
        "tr",
        "track",
        "ul",
    }
)
_MARKDOWN_RAW_HTML_TAGS = frozenset({"pre", "script", "style", "textarea"})


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
    *,
    table_name: str | None = None,
    entry_index: int | None = None,
) -> str | None:
    """Select one context-qualified translation, with CSV-first precedence."""

    expected, _source, _ambiguity = _resolve_expected(
        english,
        semantic_group,
        csv_candidates,
        xlsx_candidates,
        table_name=table_name,
        entry_index=entry_index,
    )
    return expected


def _curated_context_translation(
    english: str,
    semantic_group: str,
    table_name: str | None,
    entry_index: int | None,
) -> str | None:
    if table_name is None:
        return None
    exact_key = (semantic_group, table_name, entry_index, english)
    wildcard_key = (semantic_group, table_name, None, english)
    return CURATED_CONTEXT_TRANSLATIONS.get(
        exact_key,
        CURATED_CONTEXT_TRANSLATIONS.get(wildcard_key),
    )


def _resolve_expected(
    english: str,
    semantic_group: str | None,
    csv_candidates: CandidateMap,
    xlsx_candidates: CandidateMap,
    *,
    table_name: str | None = None,
    entry_index: int | None = None,
) -> tuple[str | None, str | None, str | None]:
    if semantic_group is None:
        return None, None, None
    group = semantic_group.casefold()
    csv_values = _candidate_values(csv_candidates, group, english)
    if len(csv_values) > 1:
        return None, None, f'ambiguous CSV candidates for {group} {english!r}: {sorted(csv_values)!r}'
    if len(csv_values) == 1:
        return next(iter(csv_values)), "csv", None
    curated = _curated_context_translation(english, group, table_name, entry_index)
    if curated is not None:
        return curated, "curated", None
    xlsx_group = _xlsx_group_for(group)
    if xlsx_group is None:
        return None, None, None
    if (xlsx_group, english) in XLSX_FALLBACK_EXCLUSIONS:
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

    base_token_regions = [
        region for region in base_regions if region.token is not None and "string" in region.kind
    ]
    current_token_regions = [
        region for region in current_regions if region.token is not None and "string" in region.kind
    ]
    for source_name, source, token_regions in (
        ("base", state.base_source, base_token_regions),
        ("current", state.current_source, current_token_regions),
    ):
        for index, region in enumerate(token_regions, start=1):
            if region.kind != "short_string" or _has_valid_lua_escapes(region.token.value):
                continue
            line = source.count("\n", 0, region.token.start) + 1
            errors.append(
                f"{display_path}:{line}: invalid Lua escape in {source_name} "
                f"short-string token {index}"
            )
            unsafe = True

    base_tokens = [region.token for region in base_token_regions]
    current_tokens = [region.token for region in current_token_regions]
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

        for entry_index, (base_token, current_token) in enumerate(
            zip(base_table.tokens, current_table.tokens)
        ):
            expected, source_name, ambiguity = _resolve_expected(
                base_token.value,
                current_table.semantic_group,
                csv_candidates,
                xlsx_candidates,
                table_name=current_table.name,
                entry_index=entry_index,
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


def _stable_context_digest(entries: Iterable[tuple[int, str, str]]) -> str:
    digest = hashlib.sha256()
    for ordinal, value, reason in entries:
        for field in (str(ordinal), value, reason):
            encoded = field.encode("utf-8")
            digest.update(len(encoded).to_bytes(8, "big"))
            digest.update(encoded)
    return digest.hexdigest()


def _unchanged_english_findings(
    states: Iterable[_FileState],
) -> tuple[list[str], list[str]]:
    errors: list[str] = []
    warnings: list[str] = []
    for state in sorted(states, key=lambda item: item.relative_path.as_posix()):
        base_tokens = extract_lua_short_strings(state.base_source)
        current_tokens = extract_lua_short_strings(state.current_source)
        char_map_spans = [
            (table.start, table.end) for table in state.current_tables if table.semantic_group == "charMap"
        ]
        path = state.relative_path.as_posix()
        current_ascii = [
            (ordinal, current_token.value, "current ASCII literal")
            for ordinal, current_token in enumerate(current_tokens)
            if _ASCII_LETTER_RE.search(current_token.value)
            and not any(
                start < current_token.start < end for start, end in char_map_spans
            )
        ]
        current_ascii_digest = _stable_context_digest(current_ascii)
        expected_current_ascii_digest = LUA_CURRENT_ASCII_CONTEXT_MANIFEST.get(path)
        if (
            expected_current_ascii_digest != current_ascii_digest
            and (current_ascii or expected_current_ascii_digest is not None)
        ):
            errors.append(
                f"{path}: unapproved current ASCII context inventory "
                f"({len(current_ascii)} token(s); expected "
                f"{expected_current_ascii_digest or 'no manifest'}, got "
                f"{current_ascii_digest})"
            )

        approved: list[tuple[int, str, str, str]] = []
        for ordinal, (base_token, current_token) in enumerate(zip(base_tokens, current_tokens)):
            if base_token.value != current_token.value or not _ASCII_LETTER_RE.search(current_token.value):
                continue
            if any(start < current_token.start < end for start, end in char_map_spans):
                continue
            line = state.current_source.count("\n", 0, current_token.start) + 1
            location = f"{state.relative_path.as_posix()}:{line}"
            reason = UNCHANGED_ENGLISH_ALLOWLIST.get(current_token.value)
            if reason is None:
                errors.append(
                    f"{location}: unapproved unchanged English {current_token.value!r}"
                )
            else:
                approved.append((ordinal, current_token.value, reason, location))

        actual_digest = _stable_context_digest(
            (ordinal, value, reason) for ordinal, value, reason, _location in approved
        )
        expected_digest = LUA_UNCHANGED_CONTEXT_MANIFEST.get(path)
        context_matches = expected_digest == actual_digest and expected_digest is not None
        if not context_matches and (approved or expected_digest is not None):
            values = sorted({value for _ordinal, value, _reason, _location in approved})
            errors.append(
                f"{path}: unapproved unchanged English context inventory {values!r} "
                f"(expected {expected_digest or 'no manifest'}, got {actual_digest})"
            )
            continue
        for _ordinal, value, reason, location in approved:
            warnings.append(
                f"{location}: retained unchanged English {value!r} ({reason})"
            )
    return errors, warnings


def _mask_markdown_destinations(source: str) -> str:
    masked = list(source)

    def mask(start: int, end: int) -> None:
        for position in range(start, end):
            if masked[position] not in "\r\n":
                masked[position] = " "

    def is_escaped(position: int) -> bool:
        backslashes = 0
        position -= 1
        while position >= 0 and source[position] == "\\":
            backslashes += 1
            position -= 1
        return backslashes % 2 == 1

    def marker_run(position: int, marker: str) -> int:
        end = position
        while end < len(source) and source[end] == marker:
            end += 1
        return end - position

    def is_fence_indent(position: int) -> bool:
        line_start = source.rfind("\n", 0, position) + 1
        prefix = source[line_start:position]
        return len(prefix) <= 3 and not prefix.strip(" ")

    def is_blank_line_end(position: int) -> bool:
        if source[position] != "\n":
            return False
        line_start = source.rfind("\n", 0, position) + 1
        return not source[line_start:position].strip(" \t\r")

    def is_markdown_block_start(position: int) -> bool:
        if position > 0 and source[position - 1] != "\n":
            return False
        line_end = source.find("\n", position)
        if line_end < 0:
            line_end = len(source)
        line = source[position:line_end].rstrip("\r")

        cursor = 0
        indentation = 0
        while cursor < len(line) and line[cursor] in " \t":
            if line[cursor] == " ":
                indentation += 1
            else:
                indentation += 4 - indentation % 4
            cursor += 1
            if indentation >= 4:
                return True

        content = line[cursor:]
        if not content:
            return False
        if re.match(r"#{1,6}(?:[ \t]+|$)", content):
            return True
        if re.fullmatch(r"[=-]+[ \t]*", content):
            return True

        compact = content.replace(" ", "").replace("\t", "")
        if (
            len(compact) >= 3
            and compact[0] in "*-_"
            and compact == compact[0] * len(compact)
        ):
            return True
        if content.startswith(">"):
            return True
        if re.match(r"[*+-](?:[ \t]+|$)", content):
            return True
        if re.match(r"\d{1,9}[.)](?:[ \t]+|$)", content):
            return True
        if re.match(r"\[(?:\\.|[^\[\]\\])+\]:[ \t]*(?:\S|$)", content):
            return True

        if content.startswith(("<!--", "<?", "<![CDATA[")):
            return True
        if re.match(r"<![A-Z]", content):
            return True
        html_tag = re.match(
            r"</?([A-Za-z][A-Za-z0-9-]*)(?=[ \t/>]|$)", content
        )
        return bool(
            html_tag
            and html_tag.group(1).casefold()
            in (_MARKDOWN_RAW_HTML_TAGS | _MARKDOWN_HTML_BLOCK_TAGS)
        )

    def is_fence_close(position: int, marker: str, minimum: int) -> int:
        if source[position] != marker or is_escaped(position) or not is_fence_indent(position):
            return 0
        length = marker_run(position, marker)
        if length < minimum:
            return 0
        line_end = source.find("\n", position + length)
        if line_end < 0:
            line_end = len(source)
        return length if not source[position + length : line_end].strip(" \t\r") else 0

    def destination_end(open_parenthesis: int) -> int | None:
        cursor = open_parenthesis + 1
        depth = 1
        while cursor < len(source):
            if source[cursor] == "\\" and cursor + 1 < len(source):
                cursor += 2
                continue
            if source[cursor] == "(":
                depth += 1
            elif source[cursor] == ")":
                depth -= 1
                if depth == 0:
                    return cursor + 1
            cursor += 1
        return None

    index = 0
    bracket_stack: list[int] = []
    inline_code_ticks: int | None = None
    fence_marker: str | None = None
    fence_length = 0
    while index < len(source):
        character = source[index]

        if is_blank_line_end(index):
            bracket_stack.clear()

        if fence_marker is not None:
            closing_length = is_fence_close(index, fence_marker, fence_length)
            if closing_length:
                fence_marker = None
                fence_length = 0
                index += closing_length
            else:
                index += 1
            continue

        if inline_code_ticks is not None:
            if character == "`" and not is_escaped(index):
                length = marker_run(index, "`")
                if length == inline_code_ticks:
                    inline_code_ticks = None
                index += length
            else:
                index += 1
            continue

        if is_markdown_block_start(index):
            bracket_stack.clear()

        if character in "`~" and not is_escaped(index) and is_fence_indent(index):
            length = marker_run(index, character)
            if length >= 3:
                bracket_stack.clear()
                fence_marker = character
                fence_length = length
                index += length
                continue

        if character == "`" and not is_escaped(index):
            inline_code_ticks = marker_run(index, "`")
            index += inline_code_ticks
            continue

        if (
            not is_escaped(index)
            and (source.startswith("<http://", index) or source.startswith("<https://", index))
        ):
            close = source.find(">", index + 1)
            destination = source[index + 1 : close] if close >= 0 else ""
            if close >= 0 and destination and not any(
                character.isspace() or character in "<>" for character in destination
            ):
                mask(index, close + 1)
                index = close + 1
                continue

        if character == "[" and not is_escaped(index):
            bracket_stack.append(index)
        elif character == "]" and not is_escaped(index):
            opener = bracket_stack.pop() if bracket_stack else None
            if opener is not None and index + 1 < len(source) and source[index + 1] == "(":
                end = destination_end(index + 1)
                if end is not None:
                    mask(index + 1, end)
                    index = end
                    continue
        index += 1
    return "".join(masked)


def _readme_english_findings(source: str) -> tuple[list[str], list[str]]:
    errors: list[str] = []
    warnings: list[str] = []
    visible = _mask_markdown_destinations(source)
    matches = [
        match
        for match in _MARKDOWN_VISIBLE_ASCII_TOKEN_RE.finditer(visible)
        if _ASCII_LETTER_RE.search(match.group())
    ]
    approved: list[tuple[int, str, str, int]] = []
    for ordinal, match in enumerate(matches):
        value = match.group()
        line = visible.count("\n", 0, match.start()) + 1
        reason = README_VISIBLE_ENGLISH_ALLOWLIST.get(value)
        if reason is None:
            errors.append(f"README.md:{line}: unapproved visible English {value!r}")
        else:
            approved.append((ordinal, value, reason, line))

    actual_digest = _stable_context_digest(
        (ordinal, value, reason) for ordinal, value, reason, _line in approved
    )
    if actual_digest != README_VISIBLE_CONTEXT_DIGEST:
        values = sorted({value for _ordinal, value, _reason, _line in approved})
        errors.append(
            f"README.md: unapproved visible English context inventory {values!r} "
            f"(expected {README_VISIBLE_CONTEXT_DIGEST}, got {actual_digest})"
        )
        return errors, warnings

    for _ordinal, value, reason, line in approved:
        warnings.append(
            f"README.md:{line}: retained unchanged English {value!r} ({reason})"
        )
    return errors, warnings


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
        unchanged_errors, unchanged_warnings = _unchanged_english_findings(states.values())
        errors.extend(unchanged_errors)
        warnings.update(unchanged_warnings)
        readme_path = repository / "README.md"
        if not readme_path.is_file():
            errors.append("README.md: missing from residual-English audit scope")
        else:
            try:
                readme_source, readme_has_bom = _read_utf8(readme_path)
            except (OSError, UnicodeError) as error:
                errors.append(f"README.md: cannot scan visible UTF-8 text: {error}")
            else:
                if readme_has_bom:
                    errors.append("README.md: unexpected UTF-8 BOM")
                readme_errors, readme_warnings = _readme_english_findings(readme_source)
                errors.extend(readme_errors)
                warnings.update(readme_warnings)

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
                help="enforce and classify retained visible English in Lua and README",
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
