# Ejemplo de reglas para clasificar.ps1. Copiar como reglas.local.ps1 (ignorado por Git) y ajustar.
# Variables disponibles: $A (Archivos), $PB (Para borrar), $C (01 Clientes), $M (02 Interno),
# $P (03 Proyectos), $F (04 Formacion), $PE (05 Personal), $SC (98 Sin clasificar).

# Carpetas/archivos de primer nivel que NO se mueven
$keepDesk = 'mi-proyecto-de-codigo','desktop.ini'
$keepDocs = 'Adobe','Zoom','desktop.ini'

# Reglas en orden (gana la primera que coincide): @(patron regex, destino, caseSensitive 0/1)
$R = @(
 @('^~\$|\.tmp$|\.(exe|msi|msix)$', "$PB\Instaladores y temporales", 0),
 @('^C[eé]dula|Pasaporte', "$PE\Identidad", 0),
 @('extracto|declaraci[oó]n de renta', "$PE\Bancos e impuestos", 0),
 @('cliente-uno|clienteuno', "$C\Cliente Uno", 0),
 @('cliente-dos', "$C\Cliente Dos", 0),
 @('contrato|NDA', "$M\Contratos", 0),
 @('factura|cuenta de cobro', "$M\Facturacion y pagos", 0),
 @('curso|webinar|clase', "$F\Cursos y material", 0)
)
