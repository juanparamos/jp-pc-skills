# Ejecuta un plan.csv (Origen, Destino, Tipo D/F) moviendo cada elemento, con registro y DESHACER.
param(
  [string]$Plan = 'C:\Users\PERSONAL\Archivos\_registro\plan.csv',
  [string]$Etiqueta = (Get-Date -Format 'yyyy-MM-dd')
)
$reg = 'C:\Users\PERSONAL\Archivos\_registro'
$logPath = "$reg\movimientos-$Etiqueta.csv"
if (Test-Path $logPath) { $logPath = "$reg\movimientos-$Etiqueta-$(Get-Date -Format HHmm).csv" }
$plan = Import-Csv $Plan
$log = New-Object System.Collections.Generic.List[object]
$ok = 0; $err = 0
foreach ($r in $plan) {
  $src = $r.Origen
  if (-not (Test-Path -LiteralPath $src)) { $log.Add([pscustomobject]@{Origen=$src; Destino=''; Estado='no existe'}); $err++; continue }
  if (-not (Test-Path -LiteralPath $r.Destino)) { New-Item -ItemType Directory -Force -Path $r.Destino | Out-Null }
  $name = Split-Path $src -Leaf
  $target = Join-Path $r.Destino $name
  $n = 2
  while (Test-Path -LiteralPath $target) {
    if ($r.Tipo -eq 'D') { $target = Join-Path $r.Destino "$name ($n)" }
    else { $b=[IO.Path]::GetFileNameWithoutExtension($name); $e=[IO.Path]::GetExtension($name); $target = Join-Path $r.Destino "$b ($n)$e" }
    $n++
  }
  try {
    Move-Item -LiteralPath $src -Destination $target -ErrorAction Stop
    $log.Add([pscustomobject]@{Origen=$src; Destino=$target; Estado='movido'}); $ok++
  } catch {
    $log.Add([pscustomobject]@{Origen=$src; Destino=$target; Estado="error: $($_.Exception.Message)"}); $err++
  }
}
$log | Export-Csv $logPath -NoTypeInformation -Encoding UTF8
$undo = $logPath -replace '\.csv$', '-DESHACER.ps1'
@"
`$log = Import-Csv '$logPath' | Where-Object Estado -eq 'movido'
foreach (`$m in `$log) { if (Test-Path -LiteralPath `$m.Destino) { `$p = Split-Path `$m.Origen; if (-not (Test-Path -LiteralPath `$p)) { New-Item -ItemType Directory -Force `$p | Out-Null }; Move-Item -LiteralPath `$m.Destino -Destination `$m.Origen } }
'Deshecho'
"@ | Set-Content $undo -Encoding UTF8
"Movidos: $ok | Con problema: $err"
"Registro: $logPath"
"Deshacer: $undo"
$log | Where-Object Estado -ne 'movido' | Format-Table -AutoSize | Out-String -Width 300
