# Copia Archivos + Mat web al disco externo "Disco JP". Aditivo: nunca borra nada en el disco.
param([switch]$Espejo)  # -Espejo: borra en el disco lo que ya no existe en el PC (solo si JP lo pide)
$vol = Get-Volume | Where-Object { $_.FileSystemLabel -eq 'Disco JP' -and $_.DriveLetter }
if (-not $vol) { 'ABORTADO: no encuentro el disco "Disco JP" conectado.'; exit 1 }
$D = "$($vol.DriveLetter):\Respaldo JP"
$fecha = Get-Date -Format 'yyyy-MM-dd_HHmm'
New-Item -ItemType Directory -Force "$D\_registro" | Out-Null
$modo = if ($Espejo) { '/MIR' } else { '/E' }
$pares = @(
  @('C:\Users\PERSONAL\Archivos', "$D\Archivos", @()),
  @('C:\Users\PERSONAL\OneDrive\Desktop\ai-os-main\Mat web', "$D\Mat web", @('node_modules','.next','dist'))
)
$need = 0; foreach ($p in $pares) { $need += (Get-ChildItem $p[0] -Recurse -File -Force -ErrorAction SilentlyContinue | Measure-Object Length -Sum).Sum }
"Origen: $([math]::Round($need/1GB,1)) GB | libre en disco: $([math]::Round($vol.SizeRemaining/1GB,1)) GB"
foreach ($p in $pares) {
  $xd = @(); foreach ($x in $p[2]) { $xd += '/XD'; $xd += $x }
  # /XJ: no seguir junctions (node_modules apunta a .dev-cache)
  robocopy $p[0] $p[1] $modo /COPY:DAT /DCOPY:T /MT:8 /R:1 /W:1 /XJ /NP /NFL /NDL /LOG+:"$D\_registro\respaldo-$fecha.log" @xd | Out-Null
  $c = $LASTEXITCODE
  "$(Split-Path $p[0] -Leaf): robocopy $c $(if ($c -lt 8) { 'OK' } else { 'CON ERRORES (ver log)' })"
}
$v2 = Get-Volume -DriveLetter $vol.DriveLetter
"Listo $fecha | libre en disco: $([math]::Round($v2.SizeRemaining/1GB,1)) GB | log: $D\_registro\respaldo-$fecha.log"
"Ultimo respaldo: $fecha" | Set-Content "$D\ULTIMO-RESPALDO.txt" -Encoding UTF8
