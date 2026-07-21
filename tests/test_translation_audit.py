from pathlib import Path
import tempfile
import unittest

from tools.translation_audit import (
    _FileState,
    _analyze_file,
    _escape_lua_content,
    _report_duplicate_divergence,
    _scan_lua_regions,
    audit_repository,
    extract_lua_short_strings,
    find_semantic_tables,
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

    def test_fix_encoding_preserves_raw_escapes_and_escapes_only_delimiter(self):
        self.assertEqual(_escape_lua_content(r"X\n\123", '"'), r"X\n\123")
        self.assertEqual(
            _escape_lua_content('A "B" C \\"D\\"', '"'),
            'A \\"B\\" C \\"D\\"',
        )

    def test_unterminated_long_brackets_are_classified_as_errors(self):
        cases = {
            "[[unterminated": "unterminated_long_string",
            "[=[unterminated": "unterminated_long_string",
            "--[[unterminated": "unterminated_long_comment",
            "--[=[unterminated": "unterminated_long_comment",
        }
        for source, expected_kind in cases.items():
            with self.subTest(source=source):
                self.assertEqual(_scan_lua_regions(source)[0].kind, expected_kind)

    def test_unescaped_newline_in_short_string_is_unterminated(self):
        self.assertEqual(
            _scan_lua_regions('"first\nsecond"')[0].kind,
            "unterminated_string",
        )
        self.assertEqual(_scan_lua_regions('"first\\\nsecond"')[0].kind, "short_string")
        self.assertEqual(
            _scan_lua_regions('"first\\\r\nsecond"')[0].kind,
            "short_string",
        )
        self.assertEqual(
            _scan_lua_regions('"first\\z \n second"')[0].kind,
            "short_string",
        )

    def test_duplicate_table_divergence_is_unsafe(self):
        baseline = 'local speciesNamesList = {"Porygon2"}'
        states = []
        for filename, translated in (("DP.lua", "多边兽2型"), ("Pt.lua", "多边兽Ⅱ")):
            path = Path("Gen 4") / filename
            current = f'local speciesNamesList = {{"{translated}"}}'
            states.append(
                _FileState(
                    relative_path=path,
                    absolute_path=Path("unused"),
                    current_source=current,
                    current_has_bom=False,
                    base_source=baseline,
                    current_tables=find_semantic_tables(current, path),
                    base_tables=find_semantic_tables(baseline, path),
                )
            )
        errors = []
        self.assertTrue(_report_duplicate_divergence(states, errors))
        self.assertEqual(len(errors), 1)

    def test_delimiter_escape_fix_is_idempotent(self):
        path = Path("Gen 3") / "RS_RNG_mGBA.lua"
        baseline = 'local speciesNamesList = {"English \\"name\\""}'
        current = 'local speciesNamesList = {"旧 \\"名称\\""}'
        csv_candidates = {
            "species": {r'English \"name\"': {'中文"名称"'}},
        }

        def analyze(source):
            state = _FileState(
                relative_path=path,
                absolute_path=Path("unused"),
                current_source=source,
                current_has_bom=False,
                base_source=baseline,
                current_tables=find_semantic_tables(source, path),
                base_tables=find_semantic_tables(baseline, path),
            )
            errors, warnings, replacements = [], set(), []
            unsafe = _analyze_file(
                state,
                csv_candidates,
                {},
                errors,
                warnings,
                replacements,
            )
            return unsafe, errors, replacements

        unsafe, errors, replacements = analyze(current)
        self.assertFalse(unsafe)
        self.assertEqual(errors, [])
        self.assertEqual(len(replacements), 1)
        replacement = replacements[0]
        rewritten = (
            current[: replacement.start]
            + replacement.fix.after
            + current[replacement.end :]
        )
        unsafe, errors, replacements = analyze(rewritten)
        self.assertFalse(unsafe)
        self.assertEqual(errors, [])
        self.assertEqual(replacements, [])

    def test_malformed_reference_content_is_not_scheduled(self):
        path = Path("Gen 3") / "RS_RNG_mGBA.lua"
        baseline = 'local speciesNamesList = {"English"}'
        current = 'local speciesNamesList = {"旧名称"}'
        state = _FileState(
            relative_path=path,
            absolute_path=Path("unused"),
            current_source=current,
            current_has_bom=False,
            base_source=baseline,
            current_tables=find_semantic_tables(current, path),
            base_tables=find_semantic_tables(baseline, path),
        )
        errors, warnings, replacements = [], set(), []
        unsafe = _analyze_file(
            state,
            {"species": {"English": {"中文\n名称"}}},
            {},
            errors,
            warnings,
            replacements,
        )
        self.assertFalse(unsafe)
        self.assertEqual(errors, [])
        self.assertEqual(replacements, [])
        self.assertTrue(any("invalid Lua short-string" in warning for warning in warnings))
