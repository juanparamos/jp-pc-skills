---
name: organizar-archivos
description: Organiza los archivos sueltos de JP (Escritorio, Descargas, Documentos) dentro de C:\Users\PERSONAL\Archivos por cliente y tema, con plan revisable, clasificación por nombre y por contenido, detección de duplicados por hash, registro de movimientos y script para deshacer. Usa cuando JP diga "organiza mis archivos", "ordena las descargas", "el escritorio está lleno", "clasifica lo de sin clasificar", "dónde quedó tal archivo" o /organizar-archivos.
---

# /organizar-archivos

Todo vive **local** en `C:\Users\PERSONAL\Archivos`. Nada a OneDrive (JP no tiene espacio y no quiere respaldo ahí).

## Estructura (no inventar carpetas de primer nivel nuevas)
```
01 Clientes MAT\<cliente>              clientes, ex-clientes y prospectos; _Otros prospectos y propuestas
02 MAT Interno\{Contratos, Facturacion y pagos, Legal y certificados, Equipo y contratistas,
                Marca y comercial, Credenciales, Notas de reuniones, Capacitaciones, Bases de datos, ...}
03 Proyectos propios\{Noboru - Iqna, Marca personal JP}
04 Formacion y recursos\{Cursos y material, Skills y herramientas IA, Imagenes y videos IA, Memes y referencias, Fuentes}
05 Personal\{Identidad, Bancos e impuestos, Salud y hogar, Viajes, Musica, Fotos, Privado, ...}
98 Sin clasificar\<tipo>
_registro\                              planes, logs de movimientos y DESHACER
```

## No mover nunca
- Las carpetas de código y de trabajo de `$keepDesk` (Escritorio) y `$keepDocs` (Documentos) en `scripts/reglas.local.ps1`, y los accesos directos `.lnk`.
- `Archivos\05 Personal\Fondo de pantalla.png` (es el fondo de pantalla).
- Los chats exportados de clientes van en `01 Clientes MAT\<cliente>\Chats` y se usan seguido: no archivarlos.

## Flujo
1. **Plan, no movimientos.** `scripts/clasificar.ps1 -Out <ruta plan.csv>` arma el plan (Origen, Destino, Nombre, Tipo, MB, Motivo) aplicando las reglas regex por nombre de `scripts/reglas.local.ps1` (fuera de Git; si no existe, copiar `reglas.ejemplo.ps1`). Antes de correrlo, revisar que las reglas de clientes estén al día con la memoria (clientes nuevos → agregar regla arriba de las genéricas). El script debe guardarse en **UTF-8 con BOM** o PowerShell 5.1 rompe las tildes de los regex. Ojo: en PowerShell `$s` y `$S` son la misma variable.
2. **Duplicados y descartables a `C:\Users\PERSONAL\Para borrar`**, nunca borrar directo: duplicados exactos (mismo tamaño + mismo MD5 que el original), zips cuya carpeta ya existe descomprimida, instaladores (.exe/.msi) y temporales (`~$`, `.tmp`).
3. **Lo que caiga en 98 Sin clasificar, clasificarlo por contenido:** `scripts/inspeccionar.py <carpeta>` extrae texto de PDF/docx/pptx/xlsx (PyMuPDF, zip XML, openpyxl) y hace hojas de contacto de imágenes/videos (PIL + ffmpeg); con eso se escribe `overrides.txt` (`<índice> CL:<cliente>` / `MI:` / `PR:` / `FR:` / `PE:` / `PB:` / `SC`) y `scripts/aplicar.py` lo aplica al plan. `scripts/contenido_hp.py` es la versión por palabras clave (y lo no atribuible lo ordena por año).
4. **Mostrarle a JP el resumen del plan** (cuántos elementos van a cada carpeta, qué va a Para borrar y ejemplos dudosos) y esperar su aprobación.
5. **Ejecutar:** `scripts/ejecutar.ps1 -Plan <plan.csv> -Etiqueta <yyyy-mm-dd>`. Mueve, renombra con " (2)" si choca, escribe `_registro\movimientos-<etiqueta>.csv` y un `...-DESHACER.ps1`.
6. **Para borrar:** se vacía solo con autorización de JP. Si JP pregunta por un archivo que vio ahí, comprobar por hash que el original sigue en su carpeta de cliente antes de responder.
7. **Actualizar memoria:** rutas citadas en memorias que cambiaron → corregirlas; registrar la operación en `reference_organizacion_archivos.md`.

## Buscar dónde quedó algo
Buscar el nombre en `Archivos\_registro\movimientos-*.csv` (columnas Origen → Destino).

## Avisos de privacidad que vale la pena repetir
Si aparecen fotos de tarjetas de crédito o capturas con API keys, recomendar borrarlas o rotar las llaves; no subirlas a ningún lado.
