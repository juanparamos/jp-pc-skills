# Instala las skills en Claude Code: crea una junction por skill en ~/.claude/skills
# y copia las reglas de ejemplo como reglas locales si todavía no existen.
$repo = Join-Path $PSScriptRoot 'skills'
$dest = Join-Path $env:USERPROFILE '.claude\skills'
New-Item -ItemType Directory -Force $dest | Out-Null
foreach ($s in Get-ChildItem $repo -Directory) {
  $link = Join-Path $dest $s.Name
  if (Test-Path $link) { "Ya existe: $link (no se toca)"; continue }
  cmd /c mklink /J "$link" "$($s.FullName)" | Out-Null
  "Instalada: /$($s.Name)"
}
$pares = @(
  @('organizar-archivos\scripts\reglas.ejemplo.ps1', 'reglas.local.ps1'),
  @('organizar-archivos\scripts\reglas_contenido_ejemplo.py', 'reglas_contenido_local.py'),
  @('organizar-mat-web\scripts\reglas_matweb_ejemplo.py', 'reglas_matweb_local.py'),
  @('rescatar-disco\scripts\reglas-disco.ejemplo.ps1', 'reglas-disco.local.ps1')
)
foreach ($p in $pares) {
  $src = Join-Path $repo $p[0]; $dst = Join-Path (Split-Path $src) $p[1]
  if (-not (Test-Path $dst)) { Copy-Item $src $dst; "Creada regla local de ejemplo: $dst (ajustala)" }
}
