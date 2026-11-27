param([string]$Out = "C:\Users\PERSONAL\Archivos\_registro\plan.csv")
$ErrorActionPreference = 'SilentlyContinue'
$A   = 'C:\Users\PERSONAL\Archivos'
$PB  = 'C:\Users\PERSONAL\Para borrar'
$C   = "$A\01 Clientes MAT"
$M   = "$A\02 MAT Interno"
$P   = "$A\03 Proyectos propios"
$F   = "$A\04 Formacion y recursos"
$PE  = "$A\05 Personal"
$SC  = "$A\98 Sin clasificar"
$Desk = "$env:USERPROFILE\OneDrive\Desktop"
$Docs = "$env:USERPROFILE\OneDrive\Documentos"
$Dl   = "$env:USERPROFILE\Downloads"

# Reglas personales (no van a Git): $keepDesk, $keepDocs y $R = @(@(patron, destino, caseSensitive), ...)
$reglas = Join-Path $PSScriptRoot 'reglas-disco.local.ps1'
if (-not (Test-Path $reglas)) { "Falta $reglas. Copia reglas-disco.ejemplo.ps1 como reglas-disco.local.ps1 y ajustalo."; exit 1 }
. $reglas

function Get-Dest($name, $isDir) {
  foreach ($r in $R) {
    $ok = if ($r[2]) { $name -cmatch $r[0] } else { $name -match $r[0] }
    if ($ok) { return $r[1] }
  }
  if ($isDir) { return "$SC\Carpetas" }
  switch -regex ($name) {
    '\.(mp4|mov)$' { return "$SC\Videos" }
    '\.(png|jpe?g|webp|gif|heic)$' { return "$SC\Imagenes" }
    '\.(mp3|ogg|wav|mpeg)$' { return "$SC\Audios" }
    '\.(csv|xlsx?)$' { return "$SC\Datos y hojas" }
    '\.(zip|7z|rar|gz)$' { return "$SC\Comprimidos" }
    default { return "$SC\Documentos" }
  }
}

$existing = @{}
Get-ChildItem 'C:\Users\PERSONAL\Archivos' -Recurse -File -Force -ErrorAction SilentlyContinue | Where-Object { $_.FullName -notlike '*\_rescate-HP\*' -and $_.FullName -notlike '*\_registro\*' -and $_.Length -gt 0 } | ForEach-Object { if(-not $existing.ContainsKey($_.Length)){ $existing[$_.Length]=New-Object System.Collections.Generic.List[string] }; $existing[$_.Length].Add($_.FullName) }
$plan = New-Object System.Collections.Generic.List[object]
$sources = @(@{Root='C:\Users\PERSONAL\Archivos\_rescate-HP\Desktop';Keep=@()}, @{Root='C:\Users\PERSONAL\Archivos\_rescate-HP\Documents';Keep=@()}, @{Root='C:\Users\PERSONAL\Archivos\_rescate-HP\Pictures';Keep=@()}, @{Root='C:\Users\PERSONAL\Archivos\_rescate-HP\Downloads';Keep=@()}, @{Root='C:\Users\PERSONAL\Archivos\_rescate-HP';Keep=@('Desktop','Documents','Pictures','Downloads')})
foreach ($src in $sources) {
  $items = Get-ChildItem $src.Root -Force
  $dirNames = @($items | Where-Object PSIsContainer | ForEach-Object Name)
  foreach ($it in $items) {
    if ($src.Keep -contains $it.Name -or $it.Extension -eq '.lnk') { continue }
    $dest = $null; $motivo = 'regla'
    if (-not $it.PSIsContainer) {
      if ($it.Extension -match '^\.(zip|7z)$' -and $dirNames -contains $it.BaseName) { $dest = "$PB\Zips ya descomprimidos"; $motivo='zip con carpeta' }
      elseif ($it.Name -match '^(.*?) ?\(\d+\)(\.[^.]+)$') {
        $base = Join-Path $src.Root ($Matches[1].TrimEnd() + $Matches[2])
        if ((Test-Path -LiteralPath $base) -and (Get-Item -LiteralPath $base).Length -eq $it.Length) {
          if ((Get-FileHash -LiteralPath $base -Algorithm MD5).Hash -eq (Get-FileHash -LiteralPath $it.FullName -Algorithm MD5).Hash) { $dest = "$PB\Duplicados exactos"; $motivo='duplicado' }
        }
      }
    }
    if (-not $dest -and -not $it.PSIsContainer -and $existing.ContainsKey($it.Length)) {
      $hh = (Get-FileHash -LiteralPath $it.FullName -Algorithm MD5).Hash
      foreach ($e in $existing[$it.Length]) { if ((Get-FileHash -LiteralPath $e -Algorithm MD5).Hash -eq $hh) { $dest = "$PB\Ya existe en Archivos"; $motivo = "igual a $e"; break } }
    }
    if (-not $dest) { $dest = Get-Dest $it.Name $it.PSIsContainer }
    $size = if ($it.PSIsContainer) { (Get-ChildItem -LiteralPath $it.FullName -Recurse -File -Force | Measure-Object Length -Sum).Sum } else { $it.Length }
    $plan.Add([pscustomobject]@{Origen=$it.FullName; Destino=$dest; Nombre=$it.Name; Tipo=$(if($it.PSIsContainer){'D'}else{'F'}); MB=[math]::Round($size/1MB,2); Motivo=$motivo})
  }
}
$plan | Export-Csv $Out -NoTypeInformation -Encoding UTF8
"Elementos en el plan: $($plan.Count)"
