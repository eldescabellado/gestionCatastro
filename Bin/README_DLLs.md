# DLLs Requeridas para SIGIEP Catastro

## PostgreSQL Client Libraries

Para que FireDAC pueda conectarse a PostgreSQL, necesita las siguientes DLLs del cliente PostgreSQL.

### DLLs Requeridas

#### Para Win32 (32-bit):
Copiar a la carpeta `Bin/Win32/`:
- `libpq.dll`
- `libintl-9.dll`
- `libcrypto-1_1.dll`
- `libssl-1_1.dll`
- `libiconv-2.dll`

#### Para Win64 (64-bit):
Copiar a la carpeta `Bin/Win64/`:
- `libpq.dll`
- `libintl-9.dll`
- `libcrypto-1_1-x64.dll`
- `libssl-1_1-x64.dll`
- `libiconv-2.dll`

### Dónde Obtener las DLLs

#### Opción 1: Instalación de PostgreSQL
1. Descargar PostgreSQL desde: https://www.postgresql.org/download/windows/
2. Instalar PostgreSQL
3. Las DLLs se encuentran en: `C:\Program Files\PostgreSQL\{version}\bin\`

#### Opción 2: Descarga Directa (Solo binarios)
1. Ir a: https://www.enterprisedb.com/download-postgresql-binaries
2. Descargar el archivo ZIP para Windows
3. Extraer y copiar las DLLs de la carpeta `pgsql\bin\`

#### Opción 3: pgAdmin (incluye las DLLs)
Si tiene pgAdmin instalado, las DLLs están en:
- `C:\Program Files\pgAdmin 4\runtime\`

### Configuración en Delphi

#### Opción A: Copiar DLLs junto al ejecutable
Copiar las DLLs a la misma carpeta donde se genera el .exe de la aplicación.

#### Opción B: Agregar al PATH del sistema
Agregar la ruta de las DLLs a la variable de entorno PATH.

#### Opción C: Configurar en el proyecto Delphi
En las opciones del proyecto, configurar:
- Project > Options > Delphi Compiler > Search Path
- Agregar la ruta de las DLLs

### Verificación

Para verificar que las DLLs están correctamente configuradas:
1. Compilar y ejecutar la aplicación
2. Si aparece el error "Driver is not defined" o "libpq.dll not found", las DLLs no están en el PATH
3. Si la conexión funciona, las DLLs están correctamente configuradas

### Versiones Compatibles

- PostgreSQL 12.x - 16.x
- Las DLLs deben coincidir con la arquitectura del proyecto (Win32 o Win64)

### Notas Importantes

1. **No incluir DLLs en el repositorio Git** por temas de licencia y tamaño
2. Cada desarrollador debe obtener las DLLs de su instalación local de PostgreSQL
3. Para distribución, incluir las DLLs junto con el instalador de la aplicación
