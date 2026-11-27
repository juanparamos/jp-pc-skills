---
name: rescatar-disco
description: Rescata la información de un disco viejo o externo (de un computador anterior) al PC, la verifica byte a byte, la mezcla en C:\Users\PERSONAL\Archivos por cliente y, solo con autorización explícita, formatea el disco. También resuelve "No se puede obtener acceso a D: función incorrecta". Usa cuando JP diga "conecté un disco", "rescata lo del disco viejo", "pasa lo del disco al PC", "formatea el disco", "puedo desconectar el disco?" o /rescatar-disco.
---

# /rescatar-disco

## Reglas
1. **Formatear borra todo y no tiene vuelta atrás.** Solo se formatea cuando: (a) la copia está verificada con 0 diferencias y (b) JP lo autoriza explícitamente en ese momento.
2. Nunca escribir en el disco de origen mientras se rescata.
3. Antes de cualquier operación de disco, identificarlo por modelo, bus USB y tamaño (`Get-Disk`), nunca solo por letra.
4. Darle a JP el espacio con números reales (`Get-PSDrive C`, `Get-Volume`), sin estimar a ojo.

## Flujo
1. **Identificar.** `Get-Disk | Select Number,FriendlyName,BusType,Size,PartitionStyle` y `Get-Partition`. Si Windows dice "función incorrecta" o el disco aparece sin letra, suele ser un disco de sistema de otro PC: asignar letra a la partición de datos (`Set-Partition -NewDriveLetter`) en vez de formatear.
2. **Inventariar.** Carpetas de usuario del disco viejo (`D:\Users\<usuario>\{Desktop, Documents, Downloads, Pictures}`), respaldo de iPhone (`AppData\Roaming\Apple Computer\MobileSync\Backup`), marcadores de Chrome (`AppData\Local\Google\Chrome\User Data\*\Bookmarks`). Decirle a JP cuántos GB son y cuánto espacio queda en C:.
3. **Copiar a una carpeta de rescate** `Archivos\_rescate-<origen>\`:
   `robocopy <origen> <destino> /E /COPY:DAT /DCOPY:T /MT:8 /R:1 /W:1 /XJ /LOG:"Archivos\_registro\rescate-<origen>-<carpeta>.log"`. Códigos 0–7 = OK; 8 o más = errores, revisar el log. Correrlo en segundo plano.
4. **Verificar.** `python scripts/verificar_hash.py` (ajustar `pairs`): compara blake2b de cada archivo. Debe dar `Distintos: 0 | Faltan: 0`.
5. **Mezclar en Archivos.** Usar el flujo de `/organizar-archivos` con `scripts/clasificar_hp.ps1` como base (reglas en `scripts/reglas-disco.local.ps1`, fuera de Git; reglas del disco viejo + índice de lo que ya existe en Archivos por tamaño + MD5, para no duplicar). Lo no atribuible va a `98 Sin clasificar\Computador anterior (<nombre>)\<tipo>\<año>`. Plan → aprobación de JP → `ejecutar.ps1`.
6. **Formatear (solo con OK).** Usar `scripts/formatear_externo.ps1` como plantilla: aborta si no encuentra **exactamente un** disco USB con el modelo y tamaño esperados que no sea de arranque ni de sistema. Requiere admin:
   `Start-Process powershell -Verb RunAs -ArgumentList '-NoProfile -ExecutionPolicy Bypass -File "<script>"' -Wait` y leer el resultado en `Archivos\_registro\formateo-disco-externo.txt`. Etiqueta por defecto: "Disco JP", NTFS.
7. **Desconectar.** Comprobar que nada lo esté usando (robocopy/python) e intentar expulsar con `(New-Object -ComObject Shell.Application).Namespace(17).ParseName('D:\').InvokeVerb('Eject')`. Si sigue montado, indicarle a JP: flecha ^ de la barra de tareas > ícono USB > Expulsar.
8. **Memoria.** Registrar en `reference_organizacion_archivos.md` qué se rescató, a dónde y el estado del disco.

## Contexto
El disco del HP viejo (SSD 238 GB, carcasa Realtek RTL9210) ya se rescató el 27-nov-2026 y quedó formateado vacío como "Disco JP". Ahora es el disco de respaldo: ver `/respaldar`.
