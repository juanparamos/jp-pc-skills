---
name: optimizar-pc
description: Diagnostica y acelera el PC Windows de JP: apps de inicio, TEMP, OneDrive pegado (código dentro de OneDrive), íconos del escritorio que no aparecen, carpetas que no cargan, RAM, energía para dejar a Claude trabajando y estado del antivirus. Usa cuando JP diga "el computador está lento", "acelera el PC", "optimiza el computador", "no aparecen los íconos", "las carpetas no cargan", "OneDrive está pegado", "se apaga la pantalla cuando te dejo trabajando", "quedamos protegidos de virus?" o /optimizar-pc.
---

# /optimizar-pc

PC: Windows 11 Pro, usuario `C:\Users\PERSONAL`, 19 GB de RAM, sin admin por defecto (lo que pida admin se lanza con `Start-Process -Verb RunAs` y JP acepta el UAC).

## Reglas
1. **Primero diagnosticar, después tocar.** Correr `scripts/diagnostico.ps1` (solo lectura) y mostrarle a JP los números de antes.
2. Nunca desactivar Windows Defender, el firewall ni las actualizaciones. Nunca desinstalar programas sin preguntar.
3. Al terminar, volver a correr el diagnóstico y reportar **antes → después** (RAM libre, CPU de OneDrive, apps de inicio, GB liberados).
4. Responder en español, corto. Si algo solo se puede hacer a mano (tapa del portátil, protección contra alteraciones), decirle a JP exactamente dónde hacer clic.

## Recetas (lo que funcionó el 26-27 nov 2026)

**Apps de inicio.** JP solo quiere OneDrive y WhatsApp al arrancar.
- Programas clásicos: en `HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\StartupApproved\Run`, poner el valor binario del programa con primer byte `03` (= deshabilitado, igual que el Administrador de tareas). Ejemplo: `Set-ItemProperty -Path $k -Name 'Teams' -Value ([byte[]](3,0,0,0,0,0,0,0,0,0,0,0))`.
- Apps de la Tienda: `HKCU:\Software\Classes\Local Settings\Software\Microsoft\Windows\CurrentVersion\AppModel\SystemAppData\<paquete>\<tarea>`, poner `State = 1`.

**TEMP.** Borrar contenido de `$env:TEMP` saltando lo que esté en uso (`-ErrorAction SilentlyContinue`). **Nunca** borrar `$env:TEMP\claude` (es el scratchpad de las sesiones de Claude).

**OneDrive al 99 % de CPU.** Casi siempre es código sincronizándose. Dejar los proyectos donde están (JP los quiere en el Escritorio) pero sacar `node_modules` de OneDrive:
1. Mover `<proyecto>\node_modules` a `C:\Users\PERSONAL\.dev-cache\<proyecto>\node_modules`.
2. `cmd /c mklink /J "<proyecto>\node_modules" "C:\Users\PERSONAL\.dev-cache\<proyecto>\node_modules"`.
Ya hechos: MAT-Video-Editor y Mat web. El diagnóstico lista los que falten.

**Escritorio sin íconos / carpetas que no cargan.** Reiniciar OneDrive (`Stop-Process -Name OneDrive -Force; Start-Process "$env:LOCALAPPDATA\Microsoft\OneDrive\OneDrive.exe"`) y luego el Explorador (`Stop-Process -Name explorer -Force`; se reabre solo).

**Energía para dejar a Claude trabajando.** La pantalla se apaga pronto, el PC no se suspende enchufado:
- `powercfg /change monitor-timeout-ac 3` y `monitor-timeout-dc 2`
- `powercfg /change standby-timeout-ac 0` (nunca, enchufado) y `standby-timeout-dc 60`
- Acceso directo "Apagar pantalla" en el Escritorio → `C:\Users\PERSONAL\.dev-cache\herramientas\apagar-pantalla.ps1` (apaga la pantalla al instante sin suspender).
- La acción de la tapa está oculta y pide admin: decirle a JP que la ponga en "No hacer nada" en Panel de control > Opciones de energía > Elegir el comportamiento al cerrar la tapa.

**Antivirus.** `Get-MpComputerStatus` (servicio, tiempo real, firmas, protección contra alteraciones) y `Update-MpSignature` si las firmas tienen más de un día. Optimizar no desprotege: lo que se apaga son apps de inicio, no seguridad.

**Papelera.** Vaciar solo si JP lo pide: `Clear-RecycleBin -Force`.

**Reinicio.** Al final, sugerir reiniciar cuando a JP le convenga (no forzarlo).
