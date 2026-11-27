---
name: respaldar
description: Respalda C:\Users\PERSONAL\Archivos y Mat web en el disco externo "Disco JP" con robocopy (aditivo, con log y fecha del último respaldo), solo cuando JP da "go". Usa cuando JP diga "go del respaldo", "respalda", "haz la copia en el disco", "respaldar ahora", "cuándo fue el último respaldo" o /respaldar.
---

# /respaldar

JP decidió (27-nov-2026) que sus archivos viven **solo en el PC** hasta que él dé "go". Nada de respaldos en OneDrive.

## Reglas
1. **Solo se ejecuta con "go" explícito de JP** en ese momento. Preguntar "¿cuándo fue el último respaldo?" no es un "go": leer `<disco>:\Respaldo JP\ULTIMO-RESPALDO.txt` y responder.
2. Por defecto es **aditivo** (`/E`): nunca borra nada del disco. El modo espejo (`-Espejo`, `/MIR`) borra del disco lo que ya no existe en el PC: usarlo solo si JP lo pide, explicándole que un archivo borrado por error en el PC también desaparecería del respaldo.
3. No copiar `node_modules`, `.next` ni `dist` (se regeneran) y no seguir junctions (`/XJ`).

## Flujo
1. JP conecta el disco. Confirmar que aparece con etiqueta "Disco JP" (`Get-Volume`). Si no aparece, revisar `Get-Disk` y asignar letra; **nunca formatear**.
2. Comparar el tamaño de origen (~146 GB a nov-2026) con el espacio libre del disco (238 GB). Si no cabe, avisar antes de empezar.
3. Correr en segundo plano: `powershell -NoProfile -ExecutionPolicy Bypass -File "$HOME\.claude\skills\respaldar\scripts\respaldar.ps1"`. La primera vez tarda (cerca de una hora por USB); las siguientes solo copian lo nuevo o cambiado.
4. Reportar: código de robocopy de cada carpeta (0–7 = OK), GB libres que quedan y ruta del log (`<disco>:\Respaldo JP\_registro\respaldo-<fecha>.log`).
5. **Primera vez:** crear en el Escritorio el acceso directo "Respaldar ahora" que ejecute el script (WScript.Shell → `.CreateShortcut`, destino `powershell.exe`, argumentos `-NoProfile -ExecutionPolicy Bypass -NoExit -File "<ruta del script>"`).
6. Expulsar el disco al terminar (ver paso 7 de `/rescatar-disco`) y actualizar `reference_organizacion_archivos.md` con la fecha del respaldo.
