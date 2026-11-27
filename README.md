# jp-pc-skills

Skills de Claude Code para mantener el PC con Windows: acelerarlo, ordenar los archivos por cliente, ordenar la carpeta de entregables web, rescatar discos viejos y hacer respaldos en un disco externo.

| Skill | Para qué |
|---|---|
| `/optimizar-pc` | Diagnóstico de solo lectura y luego: apps de inicio, TEMP, OneDrive pegado (`node_modules` fuera de OneDrive con junctions), íconos que no aparecen, energía para dejar a Claude trabajando, estado de Defender |
| `/organizar-archivos` | Escritorio, Descargas y Documentos → `Archivos\<área>\<cliente>`, con plan revisable, clasificación por nombre y por contenido, duplicados por hash, registro y DESHACER |
| `/organizar-mat-web` | Entregables HTML en una carpeta por cliente, reescribiendo rutas relativas para no romper imágenes ni CSS |
| `/rescatar-disco` | Copia con robocopy, verificación byte a byte (blake2b), mezcla en Archivos y formateo con chequeos de seguridad, solo con autorización |
| `/respaldar` | Copia aditiva de Archivos + entregables al disco externo "Disco JP", solo con "go" |

## Instalar

```powershell
git clone <url-del-repo> C:\dev\jp-pc-skills
powershell -ExecutionPolicy Bypass -File C:\dev\jp-pc-skills\instalar.ps1
```

`instalar.ps1` crea una junction por skill en `~/.claude/skills` y copia los archivos `*ejemplo*` como reglas locales.

## Reglas personales (no están en el repo)

Los clasificadores leen sus reglas de archivos locales que Git ignora, porque tienen nombres de clientes, del equipo y de documentos personales:

| Script | Regla local | Ejemplo en el repo |
|---|---|---|
| `organizar-archivos/scripts/clasificar.ps1` | `reglas.local.ps1` | `reglas.ejemplo.ps1` |
| `organizar-archivos/scripts/contenido_hp.py` | `reglas_contenido_local.py` | `reglas_contenido_ejemplo.py` |
| `organizar-mat-web/scripts/org_matweb.py` | `reglas_matweb_local.py` | `reglas_matweb_ejemplo.py` |
| `rescatar-disco/scripts/clasificar_hp.ps1` | `reglas-disco.local.ps1` | `reglas-disco.ejemplo.ps1` |

**Las reglas locales no se respaldan con Git.** Al cambiar de PC, copiarlas a mano junto con el repo.

## Requisitos

Windows 10/11, PowerShell 5.1, Python 3 con `PyMuPDF`, `openpyxl` y `Pillow` (para clasificar por contenido) y `ffmpeg` (fotogramas de video).

Los scripts guardados en PowerShell con tildes deben quedar en **UTF-8 con BOM**.
