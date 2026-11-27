import re, os
from pathlib import Path
from urllib.parse import unquote
ROOT=Path(r"C:\Users\PERSONAL\OneDrive\Desktop\ai-os-main\Mat web")
REF=re.compile(r'''(?:src|href|poster)\s*=\s*["']([^"'#?][^"']*)["']|url\(\s*["']?([^"')]+?)["']?\s*\)''',re.I)
bad=[]; checked=0
for f in ROOT.rglob("*.html"):
    if "node_modules" in f.parts: continue
    t=f.read_text(encoding="utf-8",errors="ignore")
    for m in REF.finditer(t):
        u=m.group(1) or m.group(2)
        if re.match(r'^(?:[a-z][a-z0-9+.-]*:|//|/|#|\{|\$|data:)',u,re.I): continue
        if not re.search(r'\.(png|jpe?g|webp|svg|gif|css|js|pdf|mp4|woff2?|ttf|html)$',u.split('?')[0],re.I): continue
        checked+=1
        if not (f.parent/unquote(u.split('?')[0])).exists(): bad.append((str(f.relative_to(ROOT)),u))
print("refs locales revisadas:",checked,"| rotas:",len(bad))
for b in bad[:40]: print(" ",b)
