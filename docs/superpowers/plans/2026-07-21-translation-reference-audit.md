# PokeLua_CN Text Reference Audit Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Correct every applicable PokeLua_CN user-facing translation against the locally supplied comparison files, then prove that no applicable reference mismatch, omitted display translation, placeholder error, or accidental Lua logic change remains.

**Architecture:** Add a standard-library-only Python audit utility that pairs each current Lua short-string token with the same token in the pre-translation parent commit, assigns strings to semantic tables such as species, moves, abilities, items, and generation-specific locations, and resolves expected Chinese from the CSV first and the XLSX OOXML data second. Use the same resolver for a deterministic bulk correction pass, then run broader checks for untranslated display strings, Simplified Chinese, format/escape preservation, UTF-8 validity, and code-skeleton equivalence.

**Tech Stack:** Python 3 standard library (`argparse`, `csv`, `zipfile`, `xml.etree.ElementTree`, `subprocess`, `unittest`), Git, PowerShell/.NET for a read-only Traditional-to-Simplified diagnostic, Lua source files.

## Global Constraints

- `汉化统一对照表.csv` column `统一中文建议` is the primary authority, but only when the English source is matched in the correct semantic group/context; homonyms such as `Blue`, `Red`, `Psychic`, and `Metronome` must not be globally replaced.
- `宝可梦对照表.backup.xlsx` is a fallback authority for domain terms absent from the CSV; trailing reference annotations such as `*` are metadata, not part of a Pokémon name.
- Preserve the two user-added reference files byte-for-byte and leave their Git tracking state unchanged.
- Preserve Lua string-token count and order, format placeholders, escape sequences, table indexes, and executable code outside comments/string contents.
- Preserve the Gen 3 checksum script's `charMap` exactly; its non-Chinese glyphs and replacement characters are game encoding data, not translation defects.
- Use Simplified Chinese for user-visible prose and domain terms, while retaining technical identifiers, emulator key names, color names, paths, file-format keys, region/language codes used as program data, `C-Gear`, `MissingNo.`, and event/product names where translation would change semantics.
- Do not add dependencies, alter RNG logic, reorder tables, commit the two reference files, or push changes.

---

### Task 1: Build the deterministic translation audit utility

**Files:**
- Create: `tools/translation_audit.py`
- Create: `tests/test_translation_audit.py`

**Interfaces:**
- Consumes: repository root, `--csv`, `--xlsx`, and `--base-ref` (default `e8d381e69a8480193ebf0419382df6025255dd56`, the immutable pre-translation source commit).
- Produces: `audit_repository(root, csv_path, xlsx_path, base_ref) -> AuditResult`, `apply_reference_fixes(...) -> list[Fix]`, and CLI modes `check` and `fix`.

- [ ] **Step 1: Write failing parser and policy tests**

```python
from pathlib import Path
import tempfile
import unittest

from tools.translation_audit import (
    audit_repository,
    extract_lua_short_strings,
    format_signature,
    normalize_xlsx_term,
    select_expected_translation,
)


ROOT = Path(__file__).resolve().parents[1]
CSV_PATH = ROOT / "汉化统一对照表.csv"
XLSX_PATH = ROOT / "宝可梦对照表.backup.xlsx"
BASE_REF = "e8d381e69a8480193ebf0419382df6025255dd56"


class TranslationAuditTests(unittest.TestCase):
    def test_extracts_quoted_strings_without_losing_escapes(self):
        source = 'local values = {"Porygon2", "Seed: %08X\\n"}'
        self.assertEqual(
            [token.value for token in extract_lua_short_strings(source)],
            ["Porygon2", "Seed: %08X\\n"],
        )

    def test_format_signature_preserves_printf_and_lua_escapes(self):
        self.assertEqual(
            format_signature("Seed: %08X\\n"),
            format_signature("种子：%08X\\n"),
        )

    def test_xlsx_annotation_is_not_part_of_species_name(self):
        self.assertEqual(normalize_xlsx_term("皮皮*", "species"), "皮皮")

    def test_csv_group_wins_over_xlsx_fallback(self):
        expected = select_expected_translation(
            english="Stark Mountain",
            semantic_group="dppt",
            csv_candidates={"dppt": {"Stark Mountain": {"严酷山（入口）"}}},
            xlsx_candidates={"locations": {"Stark Mountain": {"严酷山"}}},
        )
        self.assertEqual(expected, "严酷山（入口）")

    def test_homonym_without_matching_group_is_not_replaced(self):
        expected = select_expected_translation(
            english="Blue",
            semantic_group=None,
            csv_candidates={"forms": {"Blue": {"蓝条纹"}}},
            xlsx_candidates={},
        )
        self.assertIsNone(expected)
```

- [ ] **Step 2: Run the tests and verify RED**

Run: `python -m unittest tests.test_translation_audit -v`

Expected: FAIL with `ModuleNotFoundError: No module named 'tools.translation_audit'`.

- [ ] **Step 3: Implement Lua tokenization, CSV/XLSX loading, semantic table ranges, reference precedence, audit results, and CLI**

```python
@dataclass(frozen=True)
class StringToken:
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
```

The implementation must use a quote/escape-aware Lua short-string scanner, ignore comments while finding balanced table braces, map `speciesNamesList`, `starterPokemonNames`, `moveNamesList`, `abilityNamesList`, `itemNamesList`, `natureNamesList`, and generation-specific `locationNamesList`, parse XLSX directly from OOXML, reject ambiguous candidates, and rewrite only the content span of an already paired string token. It must also report string-token count drift, placeholder/escape drift, executable code-skeleton drift, semantic-table length drift, and divergence between duplicated generation/emulator tables. The `charMap` table must be excluded from translation policy checks but included in structural preservation checks.

- [ ] **Step 4: Run the unit tests and verify GREEN**

Run: `python -m unittest tests.test_translation_audit -v`

Expected: all five tests pass with no warnings or errors.

- [ ] **Step 5: Commit the audit utility**

```powershell
git add -- tools/translation_audit.py tests/test_translation_audit.py
git commit -m "test: add translation reference audit"
```

### Task 2: Apply CSV-first and XLSX-fallback domain corrections

**Files:**
- Modify: every affected `Gen */**/*.lua` domain table identified by the audit
- Test: `tests/test_translation_audit.py`

**Interfaces:**
- Consumes: Task 1 CLI and the two local reference files.
- Produces: zero unambiguous domain-reference mismatches while keeping the reference files untouched.

- [ ] **Step 1: Run the integration audit and verify RED on current data**

Run:

```powershell
python tools/translation_audit.py check --csv '.\汉化统一对照表.csv' --xlsx '.\宝可梦对照表.backup.xlsx' --base-ref 'e8d381e69a8480193ebf0419382df6025255dd56'
```

Expected: non-zero exit with mismatches including `Porygon2`, `Guillotine`, `Spell Tag`, `Cursed Body`, and incorrectly translated locations.

- [ ] **Step 2: Apply only unambiguous, context-qualified reference fixes**

Run:

```powershell
python tools/translation_audit.py fix --csv '.\汉化统一对照表.csv' --xlsx '.\宝可梦对照表.backup.xlsx' --base-ref 'e8d381e69a8480193ebf0419382df6025255dd56'
```

Expected: a fix summary grouped by file and semantic group; no edit to either reference file.

- [ ] **Step 3: Run the integration audit and verify GREEN**

Run the Task 2 Step 1 command again.

Expected: exit 0, zero unambiguous domain-reference mismatches, zero token-count errors, zero placeholder/escape errors.

- [ ] **Step 4: Verify reference files are byte-identical and untracked**

```powershell
git status --short
git hash-object -- '.\汉化统一对照表.csv' '.\宝可梦对照表.backup.xlsx'
```

Expected: both files remain `??`; their hashes match the pre-edit hashes recorded in the task report.

- [ ] **Step 5: Commit only Lua domain corrections**

```powershell
git add -- 'Gen 1' 'Gen 3' 'Gen 4' 'Gen 5'
git commit -m "fix: align domain terms with Chinese references"
```

### Task 3: Correct omissions and residual Simplified-Chinese errors

**Files:**
- Modify: affected `Gen */**/*.lua`
- Modify if evidence requires: `README.md`
- Modify: `tests/test_translation_audit.py`

**Interfaces:**
- Consumes: Task 1 token pairing and the Task 2 clean reference audit.
- Produces: an explicit whitelist of intentional English technical strings and assertions for residual user-visible text.

- [ ] **Step 1: Add failing regression tests for known omissions and residual errors**

```python
    def test_checksum_display_lines_are_translated(self):
        text = (ROOT / "Gen 3/mGBA/RS_RNG_Checksums_mGBA.lua").read_text(encoding="utf-8")
        self.assertNotIn("Checksums", text)
        self.assertNotIn("Zigzagoon seen?", text)
        self.assertNotIn("Wurmple seen?", text)
        self.assertNotIn("Wingull seen?", text)

    def test_reference_audit_has_no_actionable_findings(self):
        result = audit_repository(ROOT, CSV_PATH, XLSX_PATH, BASE_REF)
        self.assertEqual(result.errors, [])
        self.assertEqual(result.fixes, [])

    def test_current_translation_preserves_all_format_signatures(self):
        result = audit_repository(ROOT, CSV_PATH, XLSX_PATH, BASE_REF)
        self.assertFalse([e for e in result.errors if "format signature" in e])
```

- [ ] **Step 2: Run the tests and verify RED**

Run: `python -m unittest tests.test_translation_audit -v`

Expected: failures identify the four untranslated checksum display strings and any residual actionable audit findings.

- [ ] **Step 3: Translate the checksum display strings and simplify remaining user-visible CJK text**

Use these exact display translations:

```text
Checksums -> 校验和
Zigzagoon seen? %s\n -> 已遇见蛇纹熊？%s\n
Wurmple seen? %s\n -> 已遇见刺尾虫？%s\n
Wingull seen? %s\n -> 已遇见长翅鸥？%s\n
```

Apply character simplification only to user-visible prose/comments and semantic name tables. Do not alter `charMap`, technical keys, paths, emulator button names, color names, state serialization field names, language/region codes, `C-Gear`, `MissingNo.`, or event names.

- [ ] **Step 4: Run the tests and verify GREEN**

Run: `python -m unittest tests.test_translation_audit -v`

Expected: all tests pass; no reference mismatch, omission regression, token count, placeholder, or escape failure remains.

- [ ] **Step 5: Commit residual text corrections and regression tests**

```powershell
git add -- 'Gen 1' 'Gen 3' 'Gen 4' 'Gen 5' README.md tests/test_translation_audit.py
git commit -m "fix: complete Simplified Chinese text cleanup"
```

### Task 4: Perform the full completion audit

**Files:**
- Inspect: all tracked `*.lua`, `README.md`, `tools/translation_audit.py`, and `tests/test_translation_audit.py`
- Preserve: `汉化统一对照表.csv`, `宝可梦对照表.backup.xlsx`

**Interfaces:**
- Consumes: the completed Task 1-3 branch.
- Produces: fresh verification evidence for every explicit requirement.

- [ ] **Step 1: Run the full unit and integration checks**

```powershell
python -m unittest discover -s tests -v
python tools/translation_audit.py check --csv '.\汉化统一对照表.csv' --xlsx '.\宝可梦对照表.backup.xlsx' --base-ref 'e8d381e69a8480193ebf0419382df6025255dd56'
```

Expected: all tests pass and the audit exits 0 with zero actionable findings.

- [ ] **Step 2: Check whitespace, encoding, and Git scope**

```powershell
git diff --check origin/main...HEAD
git status --short
git diff --stat origin/main...HEAD
```

Expected: no whitespace errors; only planned code/test/document files are tracked changes; both reference files remain untracked.

- [ ] **Step 3: Review all remaining unchanged English strings against the documented technical whitelist**

Run: `python tools/translation_audit.py check --csv '.\汉化统一对照表.csv' --xlsx '.\宝可梦对照表.backup.xlsx' --base-ref 'e8d381e69a8480193ebf0419382df6025255dd56' --report-unchanged-english`

Expected: every remaining item is an emulator key/color, technical identifier/path/serialization key, language or region code, official retained product term, glitch species name, event name, or raw character-map data; no user-facing English sentence remains.

- [ ] **Step 4: Verify source structure against the pre-translation commit**

Run: `python tools/translation_audit.py check --csv '.\汉化统一对照表.csv' --xlsx '.\宝可梦对照表.backup.xlsx' --base-ref 'e8d381e69a8480193ebf0419382df6025255dd56' --verify-structure`

Expected: each Lua file has the same paired string count, placeholder and escape signatures, and executable token skeleton as the pre-translation source.

- [ ] **Step 5: Obtain final independent review and address every Critical/Important finding**

Provide the plan, implementation report, and full branch diff package to a fresh reviewer. Repeat fixes and targeted verification until both spec compliance and code quality are approved.

- [ ] **Step 6: Record final evidence**

Record exact counts for corrected occurrences, affected files, reference coverage, remaining intentionally retained English strings, tests passed, and Git status in `.superpowers/sdd/progress.md` before handoff.
