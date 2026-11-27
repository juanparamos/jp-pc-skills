import csv, re, zipfile, os, datetime
PLAN = r"C:\Users\PERSONAL\Archivos\_registro\plan-hp.csv"
A = r"C:\Users\PERSONAL\Archivos"
C = A + r"\01 Clientes MAT"
rows = list(csv.DictReader(open(PLAN, encoding="utf-8-sig")))

import sys as _s; _s.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
try:
    from reglas_contenido_local import KEYS
except ImportError:
    raise SystemExit('Falta reglas_contenido_local.py: copia reglas_contenido_ejemplo.py y ajustalo.')
def text_of(p):
    l = p.lower()
    try:
        if l.endswith(".pdf"):
            import fitz
            d = fitz.open(p); return " ".join(d[i].get_text() for i in range(min(3, len(d))))
        if l.endswith((".docx", ".pptx", ".xlsx")):
            with zipfile.ZipFile(p) as z:
                parts = [n for n in z.namelist() if re.match(r"(word/document|ppt/slides/slide\d+|xl/sharedStrings)\.xml", n)][:5]
                return " ".join(re.sub(r"<[^>]+>", " ", z.read(n).decode("utf8", "ignore")) for n in parts)
        if l.endswith((".csv", ".txt", ".html", ".htm", ".md")):
            return open(p, "rb").read(20000).decode("utf8", "ignore")
    except Exception:
        return ""
    return ""

n_text = n_year = 0
for r in rows:
    d = r["Destino"]
    if "98 Sin clasificar" not in d: continue
    p = r["Origen"]
    sub = d.split("98 Sin clasificar\\", 1)[1]
    if sub.startswith(("Documentos", "Datos y hojas", "PDFs con nombre")):
        t = text_of(p).lower()
        hit = next((dest for rx, dest in KEYS if re.search(rx, t)), None)
        if hit:
            r["Destino"] = hit; r["Motivo"] = "contenido"; n_text += 1; continue
    # por año (lo que no tiene cliente)
    try:
        y = datetime.datetime.fromtimestamp(os.path.getmtime(p)).year
        r["Destino"] = A + r"\98 Sin clasificar\Computador anterior (HP)" + "\\" + sub.split("\\")[0] + "\\" + str(y)
        n_year += 1
    except Exception:
        pass
with open(PLAN, "w", encoding="utf-8-sig", newline="") as f:
    w = csv.DictWriter(f, fieldnames=rows[0].keys()); w.writeheader(); w.writerows(rows)
print("Asignados por contenido:", n_text, "| ordenados por año:", n_year)
