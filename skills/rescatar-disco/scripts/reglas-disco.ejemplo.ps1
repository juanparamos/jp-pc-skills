# Ejemplo de reglas para clasificar_hp.ps1 (disco de un computador anterior).
# Copiar como reglas-disco.local.ps1 (ignorado por Git) y ajustar. Mismas variables que reglas.ejemplo.ps1.
$keepDesk = 'desktop.ini'
$keepDocs = 'desktop.ini'
$R = @(
 @('^__MACOSX$|\.(exe|msi)$', "$PB\Otros", 0),
 @('matrimonio|boda', "$PE\Fotos", 0),
 @('n[oó]mina|liquidaci', "$PE\Contratos y nominas anteriores", 0),
 @('cliente-antiguo', "$C\Cliente Antiguo", 0)
)
