# Diagnóstico de solo lectura: no cambia nada.
$ErrorActionPreference = 'SilentlyContinue'
$os = Get-CimInstance Win32_OperatingSystem
"== Memoria: libre $([math]::Round($os.FreePhysicalMemory/1MB,1)) GB de $([math]::Round($os.TotalVisibleMemorySize/1MB,1)) GB"
"== Disco C: libre $([math]::Round((Get-PSDrive C).Free/1GB,1)) GB"
"== Top 10 procesos por CPU acumulada / memoria"
Get-Process | Sort-Object CPU -Descending | Select-Object -First 10 Name, @{n='CPU_s';e={[int]$_.CPU}}, @{n='RAM_MB';e={[int]($_.WorkingSet64/1MB)}} | Format-Table -AutoSize | Out-String -Width 200
"== Inicio (HKCU Run + StartupApproved; byte 03 = deshabilitado)"
$ap = Get-ItemProperty 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\StartupApproved\Run'
(Get-ItemProperty 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Run').PSObject.Properties | Where-Object { $_.Name -notlike 'PS*' } | ForEach-Object {
  $b = $ap.($_.Name); $st = if ($b -and $b[0] -eq 3) { 'OFF' } else { 'ON' }; "  [$st] $($_.Name)" }
"== Apps de la Tienda con tarea de inicio (State 2 = ON; 0 o 1 = OFF)"
Get-ChildItem 'HKCU:\Software\Classes\Local Settings\Software\Microsoft\Windows\CurrentVersion\AppModel\SystemAppData' | ForEach-Object {
  Get-ChildItem $_.PSPath | Where-Object { (Get-ItemProperty $_.PSPath).State -ne $null } | ForEach-Object { "  [State $((Get-ItemProperty $_.PSPath).State)] $($_.PSPath.Split('\')[-2])" } }
"== TEMP: $([math]::Round(((Get-ChildItem $env:TEMP -Recurse -File -Force | Measure-Object Length -Sum).Sum)/1GB,2)) GB"
"== Papelera: $([math]::Round(((Get-ChildItem 'C:\$Recycle.Bin' -Recurse -File -Force | Measure-Object Length -Sum).Sum)/1GB,2)) GB"
"== Carpetas de código dentro de OneDrive (node_modules / .git / .venv que no sean junction)"
Get-ChildItem "$env:USERPROFILE\OneDrive" -Directory -Recurse -Force -Depth 4 | Where-Object { $_.Name -in 'node_modules','.venv','venv','.next' -and -not ($_.Attributes -band [IO.FileAttributes]::ReparsePoint) } | ForEach-Object { "  $($_.FullName)" }
"== OneDrive: $(if (Get-Process OneDrive) { 'corriendo, CPU ' + [int](Get-Process OneDrive | Measure-Object CPU -Sum).Sum + ' s' } else { 'NO está corriendo' })"
"== Energía (minutos; 0 = nunca)"
foreach ($q in @(@('SUB_VIDEO','VIDEOIDLE','pantalla'),@('SUB_SLEEP','STANDBYIDLE','suspension'))) {
  $h = @(powercfg /query SCHEME_CURRENT $q[0] $q[1] | Select-String '0x[0-9a-f]{8}' | ForEach-Object { [int]('0x' + ($_.Line -replace '.*0x','')) })
  if ($h.Count -ge 2) { "  $($q[2]): enchufado $([int]($h[-2]/60)) min | bateria $([int]($h[-1]/60)) min" } }
"== Defender"
Get-MpComputerStatus | Select-Object AMServiceEnabled, RealTimeProtectionEnabled, IsTamperProtected, AntivirusSignatureLastUpdated, QuickScanAge | Format-List | Out-String
