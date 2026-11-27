import csv
A=r"C:\Users\PERSONAL\Archivos"; PB=r"C:\Users\PERSONAL\Para borrar"
base={"CL":A+r"\01 Clientes MAT","MI":A+r"\02 MAT Interno","PR":A+r"\03 Proyectos propios","FR":A+r"\04 Formacion y recursos","PE":A+r"\05 Personal","PB":PB}
plan=A+r"\_registro\plan.csv"
rows=list(csv.DictReader(open(plan,encoding="utf-8-sig")))
ov={}
for l in open("overrides.txt",encoding="utf-8"):
    l=l.strip()
    if not l: continue
    i,v=l.split(" ",1); ov[int(i)]=v
sc=[r for r in rows if "98 Sin clasificar" in r["Destino"]]
n=0
for i,r in enumerate(sc):
    v=ov.get(i)
    if not v or v=="SC": continue
    k,sub=v.split(":",1); r["Destino"]=base[k]+"\\"+sub; r["Motivo"]="contenido"; n+=1
with open(plan,"w",encoding="utf-8-sig",newline="") as f:
    w=csv.DictWriter(f,fieldnames=rows[0].keys()); w.writeheader(); w.writerows(rows)
print("reasignados:",n)
