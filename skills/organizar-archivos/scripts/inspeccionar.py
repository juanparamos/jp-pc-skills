import csv, os, re, sys, zipfile, subprocess, html
from pathlib import Path

PLAN = r"C:\Users\PERSONAL\Archivos\_registro\plan.csv"
OUT = Path(sys.argv[1])
OUT.mkdir(parents=True, exist_ok=True)

rows = list(csv.DictReader(open(PLAN, encoding="utf-8-sig")))
sc = [r for r in rows if "98 Sin clasificar" in r["Destino"]]

def clean(t, n=260):
    t = re.sub(r"\s+", " ", t or "").strip()
    return t[:n]

def pdf_text(p):
    import fitz
    d = fitz.open(p)
    t = ""
    for i in range(min(2, len(d))):
        t += d[i].get_text()
        if len(t) > 400: break
    return t

def docx_text(p):
    with zipfile.ZipFile(p) as z:
        x = z.read("word/document.xml").decode("utf8", "ignore")
    return re.sub(r"<[^>]+>", " ", x)

def pptx_text(p):
    with zipfile.ZipFile(p) as z:
        names = sorted(n for n in z.namelist() if re.match(r"ppt/slides/slide\d+\.xml", n))[:2]
        return " ".join(re.sub(r"<[^>]+>", " ", z.read(n).decode("utf8", "ignore")) for n in names)

def xlsx_text(p):
    import openpyxl
    wb = openpyxl.load_workbook(p, read_only=True, data_only=True)
    out = []
    for ws in wb.worksheets[:2]:
        out.append(f"[{ws.title}]")
        for i, row in enumerate(ws.iter_rows(values_only=True)):
            out.append(" | ".join(str(c) for c in row if c is not None))
            if i >= 3: break
    return " ".join(out)

def text_file(p):
    raw = open(p, "rb").read(6000).decode("utf8", "ignore")
    if p.lower().endswith((".html", ".htm")):
        m = re.search(r"<title>(.*?)</title>", raw, re.S | re.I)
        body = re.sub(r"<script.*?</script>|<style.*?</style>", " ", raw, flags=re.S | re.I)
        return ("TITLE: " + m.group(1) + " || " if m else "") + html.unescape(re.sub(r"<[^>]+>", " ", body))
    return raw

lines, imgs, vids = [], [], []
for i, r in enumerate(sc):
    p, name = r["Origen"], r["Nombre"]
    low = name.lower()
    snip = ""
    try:
        if r["Tipo"] == "D":
            fs = []
            for root, _, files in os.walk(p):
                for f in files:
                    fs.append(f)
                    if len(fs) >= 10: break
                if len(fs) >= 10: break
            snip = "CONTIENE: " + "; ".join(fs)
        elif low.endswith(".pdf"): snip = pdf_text(p)
        elif low.endswith(".docx"): snip = docx_text(p)
        elif low.endswith(".pptx"): snip = pptx_text(p)
        elif low.endswith(".xlsx"): snip = xlsx_text(p)
        elif low.endswith((".csv", ".txt", ".md", ".html", ".htm", ".svg")): snip = text_file(p)
        elif low.endswith((".zip",)):
            with zipfile.ZipFile(p) as z: snip = "ZIP: " + "; ".join(z.namelist()[:10])
        elif low.endswith((".png", ".jpg", ".jpeg", ".webp", ".gif", ".heic")): imgs.append((i, p)); snip = "(imagen)"
        elif low.endswith((".mp4", ".mov")): vids.append((i, p)); snip = "(video)"
        else: snip = "(sin lector)"
    except Exception as e:
        snip = f"(error: {e.__class__.__name__})"
    lines.append(f"{i}\t{name}\t{clean(snip)}")

(OUT / "snippets.txt").write_text("\n".join(lines), encoding="utf-8")

# Hojas de miniaturas
from PIL import Image, ImageDraw
def sheet(items, tag):
    thumbs = []
    for i, src in items:
        try:
            im = Image.open(src); im.thumbnail((240, 240)); im = im.convert("RGB")
        except Exception:
            im = Image.new("RGB", (240, 240), "gray")
        canvas = Image.new("RGB", (250, 270), "white")
        canvas.paste(im, ((250 - im.width) // 2, 5))
        ImageDraw.Draw(canvas).text((5, 250), f"#{i}", fill="red")
        thumbs.append(canvas)
    per = 20
    for s in range(0, len(thumbs), per):
        chunk = thumbs[s:s + per]
        cols = 5; rws = (len(chunk) + cols - 1) // cols
        g = Image.new("RGB", (cols * 250, rws * 270), "white")
        for k, t in enumerate(chunk):
            g.paste(t, ((k % cols) * 250, (k // cols) * 270))
        g.save(OUT / f"{tag}_{s // per + 1}.jpg", quality=70)

sheet(imgs, "imagenes")
frames = []
for i, v in vids:
    fp = OUT / f"frame_{i}.jpg"
    subprocess.run(["ffmpeg", "-y", "-loglevel", "quiet", "-ss", "3", "-i", v, "-frames:v", "1", "-vf", "scale=320:-1", str(fp)])
    frames.append((i, str(fp)))
sheet(frames, "videos")
print(len(lines), "items |", len(imgs), "imagenes |", len(vids), "videos")
