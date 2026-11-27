---
name: organizar-mat-web
description: Ordena la carpeta Mat web (entregables HTML de MAT en ai-os-main\Mat web) en una subcarpeta por cliente, reescribiendo las rutas relativas de imágenes, CSS y links para que ningún deck se rompa, y verifica referencias rotas. Usa cuando JP diga "organiza Mat web", "hay archivos sueltos en Mat web", "mueve los decks a la carpeta del cliente", "se rompieron las imágenes del deck" o /organizar-mat-web.
---

# /organizar-mat-web

Carpeta: `C:\Users\PERSONAL\OneDrive\Desktop\ai-os-main\Mat web`. Es **la única** Mat web desde el 27-nov-2026.

## Estructura
- Una subcarpeta por cliente (mismo nombre que en `Archivos\01 Clientes MAT` cuando exista).
- `_MAT Interno` (con `Lead magnets` y `Capacitaciones`), `_Marca personal JP`, `_Noboru - Iqna`, `_Personal JP`, `_Para subir a la web` (carpetas `SUBIR-*`), `radar-prospectos`, `_Sin clasificar`.
- **En la raíz solo queda el código de la web MAT y lo desplegado:** `package.json`, `*.jsx`, `styles.css`, `components.css`, `MAT - Landing*.html`, `dist`, `img`, `uploads`, `node_modules` (junction a `.dev-cache`), las carpetas `*-dashboard` y `mat-reportes` (tienen cron y despliegue: no moverlos), `creativos`.

## Flujo
1. `python scripts/org_matweb.py` (sin flags = simulacro): muestra cuántos archivos van a cada carpeta y cuántas referencias se reescribirán. Las reglas viven en `scripts/reglas_matweb_local.py` (fuera de Git). Antes, agregar a `RULES` los prefijos de clientes nuevos (`^cliente` → carpeta) y a `KEEP`/`KEEP_DIRS` lo que deba quedarse en la raíz.
2. Mostrarle a JP el resumen; con su OK, `python scripts/org_matweb.py --run`. Registra en `Archivos\_registro\organizacion-mat-web-<fecha>.csv` (cambiar la constante `LOG` a la fecha del día).
3. `python scripts/verificar_refs.py`: debe dar **0 rotas**. Si hay, corregirlas a mano.
4. Renderizar con Chrome headless 1–2 decks movidos que usen imágenes de `uploads/` y mirarlos antes de decir que quedó.

## Reglas al producir nuevos entregables
- Todo deck nuevo va directo a `Mat web\<cliente>\`, nunca suelto en la raíz.
- Imágenes compartidas: referenciarlas como `../uploads/...` desde la carpeta del cliente.
- Si hay dos versiones del mismo deck, preguntar a JP cuál vale y borrar la otra solo con su OK.
