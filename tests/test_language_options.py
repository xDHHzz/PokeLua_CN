"""Run: python -m unittest discover -s tests -v (lupa is optional for compile checks)."""
from pathlib import Path
import re
import json
import subprocess
import collections
import unittest
ROOT=Path(__file__).resolve().parents[1]
SCRIPTS=list(ROOT.glob('Gen */**/*.lua'))
class LanguageOptionTests(unittest.TestCase):
 def test_all_scripts_offer_english_and_simplified_chinese(self):
  self.assertEqual(len(SCRIPTS),25)
  for path in SCRIPTS:
   code=path.read_text(encoding="utf-8")
   self.assertIn('local POKELUA_LANGUAGE = "en"',code,str(path))
   self.assertIn('POKELUA_LANGUAGE == "zh-Hans"',code,str(path))
 def test_language_selection_and_english_fallback(self):
  try:from lupa.lua54 import LuaRuntime
  except ImportError:self.skipTest('Install lupa for executable Lua checks')
  lua=LuaRuntime(unpack_returned_tuples=True)
  for path in SCRIPTS:
   code=path.read_text(encoding="utf-8"); self.assertIn('-- END POKELUA LOCALIZATION',code,str(path))
   header=code.split('-- END POKELUA LOCALIZATION',1)[0]
   for language,expected in [('en','Pikachu'),('zh-Hans','皮卡丘'),('unknown','Pikachu')]:
    selected=header.replace('local POKELUA_LANGUAGE = "en"',f'local POKELUA_LANGUAGE = "{language}"')
    self.assertEqual(lua.execute(selected+'\nreturn _pokeluaText("Pikachu", "皮卡丘")'),expected)
 def test_all_scripts_compile(self):
  try:from lupa.lua54 import LuaRuntime
  except ImportError:self.skipTest('Install lupa for executable Lua checks')
  lua=LuaRuntime(unpack_returned_tuples=True)
  compile_only=lua.eval('function(s) local f,e=load(s); return f ~= nil,e end')
  for path in SCRIPTS:
   ok,error=compile_only(path.read_text(encoding="utf-8")); self.assertTrue(ok,f'{path}: {error}')
class UpstreamPreservationTests(unittest.TestCase):
 def test_english_expansion_matches_entire_upstream_source(self):
  upstream=json.loads((ROOT/'localization/manifest.json').read_text(encoding="utf-8"))['upstream_commit']
  pattern=re.compile(r"_pokeluaText\((\"(?:\\.|[^\"\\])*\"|'(?:\\.|[^'\\])*'), (\"(?:\\.|[^\"\\])*\")\)",re.S)
  for path in SCRIPTS:
   body=re.sub(r'-- Optional display language:.*?-- END POKELUA LOCALIZATION\n\n','',path.read_text(encoding="utf-8"),count=1,flags=re.S)
   english=pattern.sub(lambda m:m.group(1),body)
   english=english.replace('(userdata.get("advances") or userdata.get("推进数"))','userdata.get("advances")')
   original=subprocess.check_output(['git','show',upstream+':'+path.relative_to(ROOT).as_posix()],cwd=ROOT).decode().replace('\r\n','\n')
   self.assertEqual(english,original,path.name)
 def test_game_identity_is_not_localized_for_state_file_names(self):
  for path in SCRIPTS:
   self.assertIsNone(re.search(r'\b(?:gameVersion|gameLanguage)\s*=\s*_pokeluaText\(',path.read_text(encoding="utf-8")),path.name)
 def test_format_specifiers_are_preserved(self):
  pattern=r'%(?:[-+ #0]*\d*(?:\.\d+)?[cdiouxXeEfgGqs]|%)'
  for context,en,zh in json.loads((ROOT/'localization/zh-Hans.json').read_text(encoding="utf-8")):
   self.assertEqual(collections.Counter(re.findall(pattern,en)),collections.Counter(re.findall(pattern,zh)),(context,en,zh))
 def test_legacy_emulator_scripts_compile_with_lua51(self):
  try:from lupa.lua51 import LuaRuntime
  except ImportError:self.skipTest('Install lupa for Lua 5.1 checks')
  lua=LuaRuntime(unpack_returned_tuples=True)
  compile_only=lua.eval('function(s) local f,e=loadstring(s); return f ~= nil,e end')
  for path in SCRIPTS:
   original=subprocess.check_output(['git','show','b76caf669872897295db5304eebbdf5e53125efb:'+path.relative_to(ROOT).as_posix()],cwd=ROOT).decode()
   if not compile_only(original)[0]:continue
   ok,error=compile_only(path.read_text(encoding="utf-8"));self.assertTrue(ok,f'{path}: {error}')

class InternalKeyAndConfigTests(unittest.TestCase):
 def test_persistent_and_structure_keys_stay_in_english(self):
  for path in SCRIPTS:
   self.assertIsNone(re.search(r'_pokeluaText\("(?:advances|growth|attack|year|month|day|hour|minute|second)"',path.read_text(encoding='utf-8')),path.name)
 def test_legacy_chinese_saved_advances_can_still_be_loaded(self):
  try:from lupa.lua54 import LuaRuntime
  except ImportError:self.skipTest('Install lupa')
  path=ROOT/'Gen 4/BizHawk/HGSS_RNG_BizHawk.lua'
  code=path.read_text(encoding='utf-8')
  # Locate the load-state assignment, not arithmetic updates.
  expression=next(line.split(' = ',1)[1] for line in code.splitlines() if line.startswith(' advances = ') and 'userdata.get' in line)
  lua=LuaRuntime(unpack_returned_tuples=True)
  lua.execute('userdata={get=function(k) if k=="推进数" then return 123 end end}')
  self.assertEqual(lua.eval(expression),123)
 def test_bot_target_configuration_line_numbers_are_preserved(self):
  for name in ['E_RNG_mGBA.lua','FRLG_RNG_mGBA.lua']:
   path=ROOT/'Gen 3/mGBA'/name
   original=subprocess.check_output(['git','show','b76caf669872897295db5304eebbdf5e53125efb:'+path.relative_to(ROOT).as_posix()],cwd=ROOT).decode().splitlines()
   current=path.read_text(encoding='utf-8').splitlines()
   count=2 if name.startswith('FRLG') else 1
   self.assertEqual(current[:count],original[:count])
if __name__=='__main__':unittest.main()
