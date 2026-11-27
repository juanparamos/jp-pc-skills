# Ejemplo de reglas para contenido_hp.py: regex sobre el TEXTO del documento -> carpeta destino.
# Copiar como reglas_contenido_local.py (ignorado por Git) y ajustar.
A = r"C:\Users\PERSONAL\Archivos"
C = A + r"\01 Clientes MAT"
KEYS = [
    (r"cliente uno|clienteuno", C + r"\Cliente Uno"),
    (r"cuenta de cobro|factura", A + r"\02 MAT Interno\Facturacion y pagos"),
    (r"declaraci[oó]n de renta|extracto", A + r"\05 Personal\Bancos e impuestos"),
]
