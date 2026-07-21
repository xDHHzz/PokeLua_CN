import csv
from pathlib import Path
import subprocess
import tempfile
import unittest
import zipfile

from tools.translation_audit import (
    _FileState,
    _analyze_file,
    _baseline_source,
    _collect_audit,
    _escape_lua_content,
    _is_valid_lua_short_content,
    _report_duplicate_divergence,
    _scan_lua_regions,
    apply_reference_fixes,
    audit_repository,
    extract_lua_short_strings,
    find_semantic_tables,
    format_signature,
    load_csv_candidates,
    load_xlsx_candidates,
    normalize_xlsx_term,
    select_expected_translation,
)


ROOT = Path(__file__).resolve().parents[1]
CSV_PATH = ROOT / "汉化统一对照表.csv"
XLSX_PATH = ROOT / "宝可梦对照表.backup.xlsx"
BASE_REF = "e8d381e69a8480193ebf0419382df6025255dd56"


class TranslationAuditTests(unittest.TestCase):
    def paired_semantic_entries(self, table_name):
        entries = []
        for path in sorted(ROOT.rglob("*.lua")):
            relative_path = path.relative_to(ROOT)
            base_source = _baseline_source(ROOT, BASE_REF, relative_path.as_posix())
            current_source = path.read_text(encoding="utf-8")
            base_tables = [
                table
                for table in find_semantic_tables(base_source, relative_path)
                if table.name == table_name
            ]
            current_tables = [
                table
                for table in find_semantic_tables(current_source, relative_path)
                if table.name == table_name
            ]
            self.assertEqual(len(current_tables), len(base_tables), relative_path.as_posix())
            for base_table, current_table in zip(base_tables, current_tables):
                self.assertEqual(len(current_table.tokens), len(base_table.tokens))
                for index, (base_token, current_token) in enumerate(
                    zip(base_table.tokens, current_table.tokens)
                ):
                    entries.append(
                        (
                            relative_path,
                            base_table.semantic_group,
                            index,
                            base_token.value,
                            current_token.value,
                        )
                    )
        return entries

    def audit_unchanged_literal(self, value):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            lua_path = root / "Gen 3" / "mGBA" / "RS_RNG_mGBA.lua"
            lua_path.parent.mkdir(parents=True)
            lua_path.write_text(f'local label = "{value}"\n', encoding="utf-8", newline="")
            subprocess.run(
                ["git", "init", "-q", str(root)],
                check=True,
                stdout=subprocess.PIPE,
                stderr=subprocess.PIPE,
            )
            subprocess.run(
                ["git", "-C", str(root), "add", "--", lua_path.relative_to(root).as_posix()],
                check=True,
                stdout=subprocess.PIPE,
                stderr=subprocess.PIPE,
            )
            subprocess.run(
                [
                    "git",
                    "-C",
                    str(root),
                    "-c",
                    "user.name=Codex",
                    "-c",
                    "user.email=codex@local",
                    "commit",
                    "-q",
                    "-m",
                    "baseline",
                ],
                check=True,
                stdout=subprocess.PIPE,
                stderr=subprocess.PIPE,
            )
            base_ref = subprocess.run(
                ["git", "-C", str(root), "rev-parse", "HEAD"],
                check=True,
                stdout=subprocess.PIPE,
                stderr=subprocess.PIPE,
                text=True,
            ).stdout.strip()
            return _collect_audit(
                root,
                CSV_PATH,
                XLSX_PATH,
                base_ref,
                report_unchanged_english=True,
            ).result

    def audit_readme_variants(self, variants):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            lua_path = root / "Synthetic" / "fixture.lua"
            lua_path.parent.mkdir(parents=True)
            lua_path.write_text("local value = 1\n", encoding="utf-8", newline="")
            readme_path = root / "README.md"
            approved = (ROOT / "README.md").read_text(encoding="utf-8")
            readme_path.write_text(approved, encoding="utf-8", newline="")
            subprocess.run(
                ["git", "init", "-q", str(root)],
                check=True,
                stdout=subprocess.PIPE,
                stderr=subprocess.PIPE,
            )
            subprocess.run(
                ["git", "-C", str(root), "add", "--", "Synthetic/fixture.lua", "README.md"],
                check=True,
                stdout=subprocess.PIPE,
                stderr=subprocess.PIPE,
            )
            subprocess.run(
                [
                    "git",
                    "-C",
                    str(root),
                    "-c",
                    "user.name=Codex",
                    "-c",
                    "user.email=codex@local",
                    "commit",
                    "-q",
                    "-m",
                    "baseline",
                ],
                check=True,
                stdout=subprocess.PIPE,
                stderr=subprocess.PIPE,
            )
            base_ref = subprocess.run(
                ["git", "-C", str(root), "rev-parse", "HEAD"],
                check=True,
                stdout=subprocess.PIPE,
                stderr=subprocess.PIPE,
                text=True,
            ).stdout.strip()
            results = {}
            for name, source in variants.items():
                if source is None:
                    readme_path.unlink(missing_ok=True)
                elif isinstance(source, bytes):
                    readme_path.write_bytes(source)
                else:
                    readme_path.write_text(source, encoding="utf-8", newline="")
                results[name] = _collect_audit(
                    root,
                    CSV_PATH,
                    XLSX_PATH,
                    base_ref,
                    report_unchanged_english=True,
                ).result
            return results

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

    def test_csv_candidate_for_gram_1_wins_before_xlsx_exclusion(self):
        expected = select_expected_translation(
            english="Gram 1",
            semantic_group="items",
            csv_candidates={"items": {"Gram 1": {"配送物品１"}}},
            xlsx_candidates={"items": {"Gram 1": {"配送物品"}}},
        )
        self.assertEqual(expected, "配送物品１")

    def test_public_selector_applies_only_narrow_curated_context_after_csv(self):
        ambiguous_xlsx = {
            "items": {"Pass": {"定期月票", "磁浮列车自由票"}},
            "locations": {"Victory Road": {"冠军之路", "冠军之路（黑２／白２）"}},
        }
        self.assertEqual(
            select_expected_translation(
                "Pass",
                "items",
                {"items": {"Pass": {"CSV 规范票"}}},
                ambiguous_xlsx,
                table_name="itemNamesList",
                entry_index=480,
            ),
            "CSV 规范票",
        )
        self.assertEqual(
            select_expected_translation(
                "Pass",
                "items",
                {},
                ambiguous_xlsx,
                table_name="itemNamesList",
                entry_index=480,
            ),
            "磁浮列车自由票",
        )
        self.assertIsNone(
            select_expected_translation(
                "Pass",
                "items",
                {},
                ambiguous_xlsx,
                table_name="itemNamesList",
                entry_index=479,
            )
        )
        self.assertIsNone(
            select_expected_translation(
                "Pass",
                "items",
                {},
                ambiguous_xlsx,
                table_name="locationNamesList",
                entry_index=480,
            )
        )
        self.assertIsNone(
            select_expected_translation(
                "Pass",
                "moves",
                {},
                ambiguous_xlsx,
                table_name="itemNamesList",
                entry_index=480,
            )
        )
        self.assertEqual(
            select_expected_translation(
                "Victory Road",
                "dppt",
                {},
                ambiguous_xlsx,
                table_name="locationNamesList",
                entry_index=0,
            ),
            "冠军之路",
        )
        self.assertEqual(
            select_expected_translation(
                "Victory Road",
                "bw",
                {"bw": {"Victory Road": {"冠军之路"}}},
                ambiguous_xlsx,
                table_name="locationNamesList",
                entry_index=0,
            ),
            "冠军之路",
        )

    def test_repository_semantic_slots_use_curated_pass_and_victory_road_values(self):
        item_entries = [
            entry for entry in self.paired_semantic_entries("itemNamesList") if entry[3] == "Pass"
        ]
        self.assertEqual(len(item_entries), 10)
        self.assertEqual({entry[2] for entry in item_entries}, {480})
        self.assertEqual({entry[4] for entry in item_entries}, {"磁浮列车自由票"})

        victory_entries = [
            entry
            for entry in self.paired_semantic_entries("locationNamesList")
            if entry[3] == "Victory Road"
        ]
        dppt_entries = [entry for entry in victory_entries if entry[1] == "dppt"]
        bw_entries = [entry for entry in victory_entries if entry[1] == "bw"]
        self.assertEqual(len(dppt_entries), 24)
        self.assertEqual({entry[4] for entry in dppt_entries}, {"冠军之路"})
        self.assertEqual(len(bw_entries), 30)
        self.assertEqual({entry[4] for entry in bw_entries}, {"冠军之路"})

    def test_checksums_script_has_fully_translated_display_values(self):
        path = ROOT / "Gen 3" / "mGBA" / "RS_RNG_Checksums_mGBA.lua"
        source = path.read_text(encoding="utf-8")
        self.assertIn('--Checksums = console:createBuffer("校验和")', source)
        self.assertNotIn('console:createBuffer("Checksums")', source)
        self.assertIn('local playerGenderSymbols = {"男", "女"}', source)
        self.assertIn('local battleStyleOptions = {"替换", "连战"}', source)
        for english, chinese in (
            (r"Zigzagoon seen? %s\n", r"已遇见蛇纹熊？%s\n"),
            (r"Wurmple seen? %s\n", r"已遇见刺尾虫？%s\n"),
            (r"Wingull seen? %s\n", r"已遇见长翅鸥？%s\n"),
        ):
            self.assertNotIn(english, source)
            self.assertIn(chinese, source)
        self.assertIn("function getChecksumsList()", source)

    def test_gen5_version_values_are_consistent_without_global_digit_normalization(self):
        files = [
            ROOT / "Gen 5" / emulator / script
            for emulator in ("BizHawk", "DeSmuMe")
            for script in ("B2W2_RNG_" + emulator + ".lua", "BW_RNG_" + emulator + ".lua")
        ]
        sources = {path: path.read_text(encoding="utf-8") for path in files}
        combined = "".join(sources.values())
        self.assertNotIn("黑２", combined)
        self.assertNotIn("白２", combined)
        self.assertEqual(combined.count('"黑2"'), 6)
        self.assertEqual(combined.count('"白2"'), 8)
        self.assertEqual(combined.count("请改用黑2／白2"), 2)
        for ordinal in ("配送物品１", "配送物品２", "配送物品３"):
            self.assertEqual(combined.count(ordinal), 4)

    def test_no_curated_traditional_or_readme_alt_text_omissions_remain(self):
        for path in sorted(ROOT.rglob("*.lua")):
            source = path.read_text(encoding="utf-8")
            self.assertNotIn("冠軍之路（黑／白） 冠軍之路（黑２／白２）", source)
            self.assertNotIn("軍", source)
        readme = (ROOT / "README.md").read_text(encoding="utf-8")
        image_url = "https://github.com/Real96/PokeLua/assets/20956021/e6a21f63-ba96-4cc6-82fa-e9fba93537c6"
        self.assertNotIn(f"![image]({image_url})", readme)
        self.assertIn(f"![DeSmuMe 最终文件夹示例]({image_url})", readme)

    def test_unchanged_english_report_rejects_unapproved_prose(self):
        result = self.audit_unchanged_literal("Actionable sentence")
        self.assertFalse(result.ok)
        self.assertTrue(
            any(
                "unapproved unchanged English 'Actionable sentence'" in error
                for error in result.errors
            )
        )

    def test_allowlisted_lua_values_require_an_approved_context(self):
        for value in ("orange", "red", "clear", "reset", "frame"):
            with self.subTest(value=value):
                result = self.audit_unchanged_literal(value)
                self.assertFalse(result.ok)
                self.assertTrue(
                    any(
                        "unapproved unchanged English context" in error
                        and repr(value) in error
                        for error in result.errors
                    )
                )

    def test_real_lua_contexts_retain_classified_colors_and_runtime_values(self):
        reported = _collect_audit(
            ROOT,
            CSV_PATH,
            XLSX_PATH,
            BASE_REF,
            report_unchanged_english=True,
        ).result
        for value, reason in (
            ("orange", "emulator API color literal"),
            ("red", "emulator API color literal"),
            ("clear", "emulator setting value"),
            ("reset", "emulator callback event"),
            ("frame", "emulator callback event"),
        ):
            with self.subTest(value=value):
                self.assertTrue(
                    any(
                        f"retained unchanged English {value!r}" in warning
                        and reason in warning
                        and not warning.startswith("README.md")
                        for warning in reported.warnings
                    )
                )

    def test_readme_visible_markdown_is_audited_but_link_destinations_are_excluded(self):
        approved = (ROOT / "README.md").read_text(encoding="utf-8")
        variants = {
            "approved": approved,
            "url_destination": approved.replace(
                "https://github.com/Real96/PokeLua",
                "https://example.invalid/UnapprovedDestination",
                1,
            ),
            "heading": approved + "\n# UnapprovedHeading\n",
            "body": approved + "\nUnapprovedBody\n",
            "link_label": approved + "\n[UnapprovedLink](https://example.invalid/path)\n",
            "image_alt": approved + "\n![UnapprovedAlt](https://example.invalid/image.png)\n",
            "inline_code": approved + "\n`UnapprovedCode`\n",
            "missing": None,
            "balanced_destination": (
                approved
                + "\n[链接](https://example.invalid/a_(UnapprovedBalancedDestination))\n"
            ),
            "autolink_destination": (
                approved + "\n<https://example.invalid/UnapprovedAutolinkDestination>\n"
            ),
            "escaped_visible": approved + "\n测试\\](UnapprovedEscapedVisible)\n",
            "orphan_visible": approved + "\n测试](UnapprovedOrphan)\n",
            "inline_link_like": approved + "\n`测试](UnapprovedInlineCode)`\n",
            "fenced_link_like": (
                approved + "\n```\n测试](UnapprovedFencedCode)\n```\n"
            ),
        }
        results = self.audit_readme_variants(variants)
        self.assertEqual(results["approved"].errors, [])
        self.assertEqual(results["url_destination"].errors, [])
        self.assertEqual(results["balanced_destination"].errors, [])
        self.assertEqual(results["autolink_destination"].errors, [])
        for name in ("heading", "body", "link_label", "image_alt", "inline_code"):
            with self.subTest(name=name):
                self.assertFalse(results[name].ok)
                self.assertTrue(
                    any(
                        "README.md" in error and "unapproved visible English" in error
                        for error in results[name].errors
                    )
                )
        self.assertFalse(results["missing"].ok)
        self.assertTrue(
            any(
                "README.md" in error and "missing" in error
                for error in results["missing"].errors
            )
        )
        for name in (
            "escaped_visible",
            "orphan_visible",
            "inline_link_like",
            "fenced_link_like",
        ):
            with self.subTest(name=name):
                self.assertFalse(results[name].ok)
                self.assertTrue(
                    any(
                        "README.md" in error and "unapproved visible English" in error
                        for error in results[name].errors
                    )
                )

    def test_readme_invalid_utf8_and_bom_are_report_errors(self):
        approved = (ROOT / "README.md").read_bytes()
        results = self.audit_readme_variants(
            {
                "bom": b"\xef\xbb\xbf" + approved,
                "invalid_utf8": approved + b"\n\xff\n",
            }
        )
        self.assertTrue(
            any("README.md: unexpected UTF-8 BOM" in error for error in results["bom"].errors)
        )
        self.assertTrue(
            any(
                "README.md: cannot scan visible UTF-8 text" in error
                for error in results["invalid_utf8"].errors
            )
        )

    def test_real_readme_retained_english_has_specific_reasons(self):
        reported = _collect_audit(
            ROOT,
            CSV_PATH,
            XLSX_PATH,
            BASE_REF,
            report_unchanged_english=True,
        ).result
        for value, reason in (
            ("PokeLua", "project/product name"),
            ("RBG/Y", "game/version abbreviation"),
            ("Shift", "external UI/keyboard text"),
        ):
            with self.subTest(value=value):
                self.assertTrue(
                    any(
                        warning.startswith("README.md")
                        and f"retained unchanged English {value!r}" in warning
                        and reason in warning
                        for warning in reported.warnings
                    )
                )

    def test_repository_audits_are_clean_and_residual_inventory_is_classified(self):
        normal = _collect_audit(ROOT, CSV_PATH, XLSX_PATH, BASE_REF).result
        self.assertEqual(normal.fixes, [])
        self.assertEqual(normal.errors, [])
        self.assertEqual(normal.warnings, [])

        reported = _collect_audit(
            ROOT,
            CSV_PATH,
            XLSX_PATH,
            BASE_REF,
            report_unchanged_english=True,
        ).result
        self.assertEqual(reported.fixes, [])
        self.assertEqual(reported.errors, [])
        self.assertTrue(reported.warnings)
        self.assertTrue(
            all("retained unchanged English" in warning for warning in reported.warnings)
        )

    def test_xlsx_fallback_rejects_gram_1_without_disabling_safe_locations(self):
        path = Path("Gen 5") / "BizHawk" / "BW_RNG_BizHawk.lua"
        ordinal_item = "\u914d\u9001\u7269\u54c1\uff11"
        unqualified_item = "\u914d\u9001\u7269\u54c1"
        old_location = "\u65e7\u5730\u70b9"
        dreamyard = "\u68a6\u7684\u9057\u5740"
        baseline = (
            'local itemNamesList = {"Gram 1"}\n'
            'local locationNamesList = {"Dreamyard"}\n'
        )
        current = (
            f'local itemNamesList = {{"{ordinal_item}"}}\n'
            f'local locationNamesList = {{"{old_location}"}}\n'
        )
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
            {},
            {
                "items": {"Gram 1": {unqualified_item}},
                "locations": {"Dreamyard": {dreamyard}},
            },
            errors,
            warnings,
            replacements,
        )

        self.assertFalse(unsafe)
        self.assertEqual(errors, [])
        self.assertEqual(warnings, set())
        self.assertEqual(
            [(replacement.fix.english, replacement.fix.after) for replacement in replacements],
            [("Dreamyard", dreamyard)],
        )

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

    def test_invalid_lua_escape_reference_is_not_scheduled(self):
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
            {"species": {"English": {r"Bad\q"}}},
            {},
            errors,
            warnings,
            replacements,
        )
        self.assertFalse(unsafe)
        self.assertEqual(errors, [])
        self.assertEqual(replacements, [])
        self.assertTrue(any("invalid Lua short-string" in warning for warning in warnings))

    def test_invalid_lua_escapes_in_source_tokens_are_structural_errors(self):
        path = Path("Gen 3") / "RS_RNG_mGBA.lua"
        baseline = (
            'local first = "English"\n'
            'local label = "Base\\q"\n'
            'local speciesNamesList = {"Species"}\n'
        )
        current = (
            'local first = "中文"\n'
            'local label = "Current\\y"\n'
            'local speciesNamesList = {"宝可梦"}\n'
        )
        self.assertEqual(format_signature(r"Base\q"), ())
        self.assertEqual(format_signature(r"Current\y"), ())
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

        unsafe = _analyze_file(state, {}, {}, errors, warnings, replacements)

        self.assertTrue(unsafe)
        self.assertEqual(
            errors,
            [
                "Gen 3/RS_RNG_mGBA.lua:2: invalid Lua escape in base short-string token 2",
                "Gen 3/RS_RNG_mGBA.lua:2: invalid Lua escape in current short-string token 2",
            ],
        )
        self.assertEqual(warnings, set())
        self.assertEqual(replacements, [])

    def test_unterminated_source_token_does_not_add_invalid_escape_error(self):
        path = Path("Gen 3") / "RS_RNG_mGBA.lua"
        baseline = 'local speciesNamesList = {"English"}'
        current = 'local speciesNamesList = {"Bad\\'
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

        unsafe = _analyze_file(state, {}, {}, errors, warnings, replacements)

        self.assertTrue(unsafe)
        self.assertTrue(any("unterminated short string" in error for error in errors))
        self.assertFalse(any("invalid Lua escape" in error for error in errors))
        self.assertEqual(warnings, set())
        self.assertEqual(replacements, [])

    def test_lua_escape_candidate_grammar(self):
        valid = (
            r"plain",
            r"\a\b\f\n\r\t\v\\\"\'",
            r"\0\7\42\255\1234",
            r"\x00\xAf",
            r"\u{0}\u{10FFFF}",
            "\\\n",
            "\\\r\n",
            "\\z \t\r\nrest",
        )
        invalid = (
            r"\q",
            "trailing\\",
            r"\x",
            r"\x0",
            r"\xGG",
            r"\u",
            r"\u{}",
            r"\u{XYZ}",
            r"\u{110000}",
            r"\256",
            r"\400",
        )
        for value in valid:
            with self.subTest(value=value, expected="valid"):
                self.assertTrue(_is_valid_lua_short_content(value, '"'))
        for value in invalid:
            with self.subTest(value=value, expected="invalid"):
                self.assertFalse(_is_valid_lua_short_content(value, '"'))

    def test_public_audit_and_fix_cycle_preserves_reference_files(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            lua_path = root / "Gen 3" / "mGBA" / "RS_RNG_mGBA.lua"
            lua_path.parent.mkdir(parents=True)
            baseline = (
                'local speciesNamesList = {"Porygon2", "Blue"}\n'
                'local moveNamesList = {"Cut"}\n'
            )
            current = (
                'local speciesNamesList = {"多边兽Ⅱ", "蓝"}\n'
                'local moveNamesList = {"居合斩"}\n'
            )
            lua_path.write_text(baseline, encoding="utf-8", newline="")
            subprocess.run(
                ["git", "init", "-q", str(root)],
                check=True,
                stdout=subprocess.PIPE,
                stderr=subprocess.PIPE,
            )
            subprocess.run(
                ["git", "-C", str(root), "add", "--", lua_path.relative_to(root).as_posix()],
                check=True,
                stdout=subprocess.PIPE,
                stderr=subprocess.PIPE,
            )
            subprocess.run(
                [
                    "git",
                    "-C",
                    str(root),
                    "-c",
                    "user.name=Codex",
                    "-c",
                    "user.email=codex@local",
                    "commit",
                    "-q",
                    "-m",
                    "baseline",
                ],
                check=True,
                stdout=subprocess.PIPE,
                stderr=subprocess.PIPE,
            )
            base_ref = subprocess.run(
                ["git", "-C", str(root), "rev-parse", "HEAD"],
                check=True,
                stdout=subprocess.PIPE,
                stderr=subprocess.PIPE,
                text=True,
            ).stdout.strip()
            lua_path.write_text(current, encoding="utf-8", newline="")

            csv_path = root / "reference.csv"
            with csv_path.open("w", encoding="utf-8-sig", newline="") as stream:
                writer = csv.DictWriter(
                    stream,
                    fieldnames=["分组", "英文原文", "统一中文建议"],
                )
                writer.writeheader()
                writer.writerow(
                    {"分组": "species", "英文原文": "Porygon2", "统一中文建议": "多边兽2型"}
                )
                writer.writerow(
                    {"分组": "forms", "英文原文": "Blue", "统一中文建议": "蓝条纹"}
                )

            xlsx_path = root / "reference.xlsx"
            workbook = (
                '<workbook xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main" '
                'xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships">'
                '<sheets><sheet name="Terms" sheetId="1" r:id="rId1"/></sheets></workbook>'
            )
            relationships = (
                '<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">'
                '<Relationship Id="rId1" Target="worksheets/sheet1.xml"/></Relationships>'
            )
            worksheet = (
                '<worksheet xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main">'
                '<sheetData>'
                '<row r="1"><c r="A1" t="inlineStr"><is><t>宝可梦</t></is></c></row>'
                '<row r="2"><c r="A2" t="inlineStr"><is><t>多边兽Ⅱ</t></is></c>'
                '<c r="B2" t="inlineStr"><is><t>Porygon2</t></is></c></row>'
                '<row r="3"><c r="A3" t="inlineStr"><is><t>招式</t></is></c></row>'
                '<row r="4"><c r="A4" t="inlineStr"><is><t>居合劈</t></is></c>'
                '<c r="B4" t="inlineStr"><is><t>Cut</t></is></c></row>'
                '</sheetData></worksheet>'
            )
            with zipfile.ZipFile(xlsx_path, "w") as archive:
                archive.writestr("xl/workbook.xml", workbook)
                archive.writestr("xl/_rels/workbook.xml.rels", relationships)
                archive.writestr("xl/worksheets/sheet1.xml", worksheet)

            csv_before = csv_path.read_bytes()
            xlsx_before = xlsx_path.read_bytes()
            csv_mtime_before = csv_path.stat().st_mtime_ns
            xlsx_mtime_before = xlsx_path.stat().st_mtime_ns
            csv_candidates = load_csv_candidates(csv_path)
            xlsx_candidates = load_xlsx_candidates(xlsx_path)
            self.assertEqual(csv_candidates["species"]["Porygon2"], {"多边兽2型"})
            self.assertEqual(xlsx_candidates["moves"]["Cut"], {"居合劈"})

            before = audit_repository(root, csv_path, xlsx_path, base_ref)
            self.assertEqual(before.errors, [])
            self.assertEqual(
                [(fix.english, fix.after, fix.source) for fix in before.fixes],
                [("Porygon2", "多边兽2型", "csv"), ("Cut", "居合劈", "xlsx")],
            )
            applied = apply_reference_fixes(root, csv_path, xlsx_path, base_ref)
            self.assertEqual(applied, before.fixes)
            after = audit_repository(root, csv_path, xlsx_path, base_ref)
            self.assertTrue(after.ok)
            self.assertEqual(after.warnings, [])
            self.assertEqual(
                lua_path.read_text(encoding="utf-8"),
                (
                    'local speciesNamesList = {"多边兽2型", "蓝"}\n'
                    'local moveNamesList = {"居合劈"}\n'
                ),
            )
            self.assertEqual(csv_path.read_bytes(), csv_before)
            self.assertEqual(xlsx_path.read_bytes(), xlsx_before)
            self.assertEqual(csv_path.stat().st_mtime_ns, csv_mtime_before)
            self.assertEqual(xlsx_path.stat().st_mtime_ns, xlsx_mtime_before)
            status = subprocess.run(
                ["git", "-C", str(root), "status", "--short", "--", "reference.csv", "reference.xlsx"],
                check=True,
                stdout=subprocess.PIPE,
                stderr=subprocess.PIPE,
                text=True,
            ).stdout.splitlines()
            self.assertEqual(set(status), {"?? reference.csv", "?? reference.xlsx"})
