# Ejemplo de reglas para org_matweb.py. Copiar como reglas_matweb_local.py (ignorado por Git) y ajustar.

# Archivos y carpetas que se quedan en la raíz (código de la web, despliegues, dashboards con cron)
KEEP = {"package.json", "package-lock.json", "styles.css", "index.html"}
KEEP_DIRS = {"dist", "img", "node_modules", "uploads"}

# Regex sobre el nombre en minúsculas -> carpeta destino (gana la primera)
RULES = [
    (r"^cliente-uno", "Cliente Uno"),
    (r"^cliente-dos", "Cliente Dos"),
    (r"^lead-magnet", "_MAT Interno/Lead magnets"),
]

# Carpetas sueltas que entran completas en la carpeta de un cliente
DIR_INTO = {"cliente-uno-pauta": "Cliente Uno"}

# Palabra contenida en el nombre -> carpeta (para datos/logos sueltos)
KEYWORDS = [("clienteuno", "Cliente Uno")]
