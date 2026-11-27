import os, re, sys, csv, shutil, posixpath
from pathlib import Path

ROOT = Path(r"C:\Users\PERSONAL\OneDrive\Desktop\ai-os-main\Mat web")
DRY = "--run" not in sys.argv
import datetime
LOG = Path(r"C:\Users\PERSONAL\Archivos\_registro") / f"organizacion-mat-web-{datetime.date.today():%Y-%m-%d}.csv"

import sys as _s; _s.path.insert(0, str(Path(__file__).parent))
try:
    from reglas_matweb_local import KEEP, KEEP_DIRS, RULES, DIR_INTO, KEYWORDS
except ImportError:
    raise SystemExit('Falta reglas_matweb_local.py: copia reglas_matweb_ejemplo.py y ajustalo.')

# Carpetas SUBIR-* -> _Para subir a la web (se mueven juntas)
def dest_for(name, is_dir):
    if is_dir:
        if name in KEEP_DIRS: return None
        if name.startswith("SUBIR-"): return "_Para subir a la web"
        if name in DIR_INTO: return DIR_INTO[name]
        return None  # carpetas de cliente existentes se quedan
    if name in KEEP: return None
    low = name.lower()
    for pat, d in RULES:
        if re.search(pat, low): return d
    # datos y logos sueltos por cliente
    for key, d in KEYWORDS:
        if key in low: return d
    return "_Sin clasificar"

# 1) plan de movimientos (solo primer nivel)
moves = {}  # old abs path -> new abs path
for e in ROOT.iterdir():
    d = dest_for(e.name, e.is_dir())
    if not d: continue
    tgt = ROOT / d / e.name
    n = 2
    while tgt.exists() or tgt in moves.values():
        tgt = ROOT / d / (f"{e.stem} ({n}){e.suffix}" if e.is_file() else f"{e.name} ({n})"); n += 1
    moves[e] = tgt

def new_location(p: Path) -> Path:
    """Ubicación final de una ruta (archivo o dentro de carpeta movida)."""
    for old, new in moves.items():
        try:
            rel = p.relative_to(old)
            return new / rel
        except ValueError:
            continue
    return p

# 2) reescritura de referencias relativas en todos los HTML/CSS/JS (fuera de node_modules)
REF = re.compile(r'''((?:src|href|poster|data-src)\s*=\s*["'])([^"'#?][^"']*)(["'])|(url\(\s*["']?)([^"')]+?)(["']?\s*\))''', re.I)
def is_rel(u):
    return not re.match(r'^(?:[a-z][a-z0-9+.-]*:|//|/|#|\{|\$|data:|mailto:|tel:|javascript:)', u, re.I)

changes = []
files = [p for p in ROOT.rglob("*") if p.suffix.lower() in (".html",".htm",".css") and "node_modules" not in p.parts]
for f in files:
    try: txt = f.read_text(encoding="utf-8")
    except Exception: continue
    f_new = new_location(f)
    cnt = 0
    def fix(m):
        global_cnt = None
        if m.group(2) is not None:
            pre, url, post = m.group(1), m.group(2), m.group(3)
        else:
            pre, url, post = m.group(4), m.group(5), m.group(6)
        if not is_rel(url): return m.group(0)
        clean = url.split("?")[0].split("#")[0]
        from urllib.parse import unquote
        target = (f.parent / unquote(clean)).resolve()
        if not target.exists(): return m.group(0)
        t_new = new_location(target)
        if f_new.parent == f.parent and t_new == target: return m.group(0)
        rel = os.path.relpath(t_new, f_new.parent).replace("\\","/")
        suffix = url[len(clean):]
        if url != clean and clean != unquote(clean):
            pass
        newurl = rel.replace(" ", "%20") if "%20" in url else rel
        newurl += suffix
        if newurl == url: return m.group(0)
        nonlocal_counter.append(1)
        return pre + newurl + post
    nonlocal_counter = []
    new_txt = REF.sub(fix, txt)
    if nonlocal_counter:
        changes.append((f, len(nonlocal_counter), new_txt))

# 3) resumen o ejecución
from collections import Counter
c = Counter(str(v.parent.relative_to(ROOT)) for v in moves.values())
print("Movimientos:", len(moves))
for k, v in sorted(c.items()): print(f"  {v:4}  {k}")
print("Archivos con rutas a corregir:", len(changes), "| referencias:", sum(n for _, n, _ in changes))
for f, n, _ in changes[:15]: print("   ", f.relative_to(ROOT), n)

if not DRY:
    for f, n, t in changes: f.write_text(t, encoding="utf-8")
    with open(LOG, "w", newline="", encoding="utf-8-sig") as fh:
        w = csv.writer(fh); w.writerow(["Origen","Destino"])
        for old, new in moves.items():
            new.parent.mkdir(parents=True, exist_ok=True)
            shutil.move(str(old), str(new)); w.writerow([str(old), str(new)])
    print("EJECUTADO")
