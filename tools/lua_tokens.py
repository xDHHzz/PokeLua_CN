import re
# Match comments before strings, including long-bracket forms, then ordinary tokens.
TOKEN=re.compile(r'--\[(=*)\[.*?\]\1\]|--[^\n]*|\[(=*)\[.*?\]\2\]|"(?:\\.|[^"\\])*"|\'(?:\\.|[^\'\\])*\'|[A-Za-z_][A-Za-z_0-9]*|\d+(?:\.\d+)?|\S',re.S)
def tokens(text):
 for m in TOKEN.finditer(text):
  value=m.group()
  if value.startswith('--'):continue
  yield m.start(),m.end(),value, value[0] in '\"\'' or bool(re.match(r'\[=*\[',value))
def annotated(text):
 ts=list(tokens(text));stack=[]
 for i,t in enumerate(ts):
  if t[2]=='{':
   name=ts[i-2][2] if i>=2 and ts[i-1][2]=='=' else (stack[-1] if stack else None)
   stack.append(name)
  yield (*t,stack[-1] if stack else None)
  if t[2]=='}' and stack:stack.pop()
