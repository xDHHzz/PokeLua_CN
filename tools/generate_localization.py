"""Generate standalone optional-Chinese scripts from an exact upstream commit.
Requires Python 3 and lupa. No game files or emulator APIs are executed.
"""
from pathlib import Path
import hashlib
import json
import re
import subprocess
from lua_tokens import annotated
from lupa.lua54 import LuaRuntime
ROOT=Path(__file__).resolve().parents[1]
UPSTREAM='b76caf669872897295db5304eebbdf5e53125efb'
HEADER='''-- Optional display language: "en" or "zh-Hans". Reload after changing.
-- 可选显示语言：英文 "en"／简体中文 "zh-Hans"。修改后重新加载脚本。
local POKELUA_LANGUAGE = "en"
local function _pokeluaText(english, chinese)
 if POKELUA_LANGUAGE == "zh-Hans" then return chinese end
 return english
end
-- END POKELUA LOCALIZATION

'''
def main():
 lua=LuaRuntime(unpack_returned_tuples=True)
 catalog={(ctx,en):zh for ctx,en,zh in json.loads((ROOT/'localization/zh-Hans.json').read_text(encoding="utf-8"))}
 files=subprocess.check_output(['git','ls-tree','-r','--name-only',UPSTREAM],cwd=ROOT,text=True).splitlines()
 report=[]
 # Game identity is also used in state-file paths: keep it stable across locales.
 internal={'advances','growth','attack','year','month','day','hour','minute','second'}
 for name in files:
  if name.endswith('.lua'):
   text=subprocess.check_output(['git','show',UPSTREAM+':'+name],cwd=ROOT).decode()
   internal.update(re.findall(r'\b(?:gameVersion|gameLanguage)\s*=\s*"([^"]*)"',text))
 for name in files:
  if not name.endswith('.lua'):continue
  raw=subprocess.check_output(['git','show',UPSTREAM+':'+name],cwd=ROOT)
  original=raw.decode().replace('\r\n','\n');pieces=[];cursor=0;count=0
  for a,b,literal,is_string,context in annotated(original):
   if not is_string:continue
   en=lua.eval(literal);zh=catalog.get((context,en))
   if zh is None or zh==en or (context is None and en in internal):continue
   pieces.extend([original[cursor:a],'_pokeluaText('+literal+', '+json.dumps(zh,ensure_ascii=False)+')']);cursor=b;count+=1
  pieces.append(original[cursor:])
  body=''.join(pieces)
  # Backward-compatible read for the former translated BizHawk userdata key.
  body=body.replace('userdata.get("advances")','(userdata.get("advances") or userdata.get("推进数"))')
  config=re.match(r'(?:local botTarget[^\n]*\n)+',body)
  split=config.end() if config else 0
  (ROOT/name).write_text(body[:split]+HEADER+body[split:],encoding="utf-8",newline="\n")
  report.append({'path':name,'upstream_sha256':hashlib.sha256(raw).hexdigest(),'translated_literals':count})
 (ROOT/'localization/manifest.json').write_text(json.dumps({'upstream_commit':UPSTREAM,'default_language':'en','languages':['en','zh-Hans'],'files':report},ensure_ascii=False,indent=2)+'\n',encoding="utf-8",newline="\n")
 print('Generated',len(report),'scripts;',sum(x['translated_literals'] for x in report),'localized literal occurrences')
if __name__=='__main__':main()
