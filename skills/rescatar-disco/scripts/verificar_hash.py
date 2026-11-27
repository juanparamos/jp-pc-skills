import hashlib, os, sys
pairs = [(r"D:\Users\Usuario\Desktop", r"C:\Users\PERSONAL\Archivos\_rescate-HP\Desktop"),
         (r"D:\Users\Usuario\Documents", r"C:\Users\PERSONAL\Archivos\_rescate-HP\Documents"),
         (r"D:\Users\Usuario\Pictures", r"C:\Users\PERSONAL\Archivos\_rescate-HP\Pictures"),
         (r"D:\Users\Usuario\Downloads", r"C:\Users\PERSONAL\Archivos\_rescate-HP\Downloads"),
         (r"D:\Users\Usuario\AppData\Roaming\Apple Computer\MobileSync\Backup", r"C:\Users\PERSONAL\Archivos\_rescate-HP\Respaldo iPhone 2024-01")]
def h(p):
    m = hashlib.blake2b(digest_size=16)
    with open(p, "rb") as f:
        for b in iter(lambda: f.read(8 << 20), b""): m.update(b)
    return m.hexdigest()
ok = bad = missing = 0; problems = []
for src, dst in pairs:
    for root, dirs, files in os.walk(src):
        for fn in files:
            if fn.lower() == "desktop.ini": continue
            s = os.path.join(root, fn); d = os.path.join(dst, os.path.relpath(s, src))
            if not os.path.exists(d): missing += 1; problems.append("FALTA " + d); continue
            try:
                if os.path.getsize(s) != os.path.getsize(d) or h(s) != h(d): bad += 1; problems.append("DISTINTO " + d)
                else: ok += 1
            except Exception as e:
                bad += 1; problems.append(f"ERROR {d}: {e}")
print(f"Idénticos: {ok} | Distintos: {bad} | Faltan: {missing}")
for p in problems[:30]: print(p)
