# SIGIEP - Sistema de Gestión Integral de Entes Públicos
## Módulo: Catastro Municipal

Sistema de gestión catastral desarrollado en Delphi Rio (VCL) con PostgreSQL y SQLite.

## Características Principales

### Seguridad
- Sistema de autenticación robusto con hash SHA256
- Super Usuario inmutable
- Gestión de Roles y Permisos granular
- Sistema de autorización remota con tokens/QR para acciones críticas
- Bitácora global de auditoría

### Catastro
- Gestión completa de Fichas Catastrales
- Cálculo automático de avalúos con variables configurables
- Workflow de solicitudes con máquina de estados
- Gestión de contribuyentes

### Tecnología
- **IDE:** Delphi Rio (VCL Application)
- **Base de Datos Principal:** PostgreSQL
- **Base de Datos en Memoria:** SQLite (cálculos rápidos)
- **Conectividad:** FireDAC
- **Reportes:** FastReport VCL

## Estructura del Proyecto

```
gestionCatastro/
├── Database/
│   └── 001_SIGIEP_DDL_PostgreSQL.sql    # Script de creación de BD
├── Source/
│   ├── DataModules/
│   │   └── uDmMain.pas                   # DataModule principal
│   ├── Forms/
│   │   ├── uFrmLogin.pas                 # Formulario de Login
│   │   ├── uFrmDashboard.pas             # Dashboard principal
│   │   └── uFrmFicha.pas                 # Ficha Catastral
│   ├── Units/
│   │   ├── uAuthManager.pas              # Gestión de autorizaciones
│   │   ├── uCalculoCatastral.pas         # Cálculos de avalúo
│   │   └── uNotificaciones.pas           # Sistema SMS/Email
│   ├── SIGIEP_Catastro.dpr               # Archivo principal
│   └── SIGIEP_Catastro.dproj             # Proyecto Delphi
├── Config/
│   └── database.ini.example              # Ejemplo de configuración
├── Output/                                # Ejecutables compilados
├── Reports/                               # Plantillas FastReport
├── Recursos/                              # Imágenes de referencia
└── Documentacion/                         # Documentación técnica
```

## Instalación

### 1. Base de Datos
1. Crear base de datos en PostgreSQL:
   ```sql
   CREATE DATABASE sigiep_catastro;
   ```
2. Ejecutar el script `Database/001_SIGIEP_DDL_PostgreSQL.sql`

### 2. Configuración
1. Copiar `Config/database.ini.example` a `Config/database.ini`
2. Configurar los parámetros de conexión:
   ```ini
   [PostgreSQL]
   Server=localhost
   Port=5432
   Database=sigiep_catastro
   Username=postgres
   Password=tu_password
   ```

### 3. Compilación
1. Abrir `Source/SIGIEP_Catastro.dproj` en Delphi Rio
2. Compilar el proyecto (Ctrl+F9)
3. El ejecutable se genera en la carpeta `Output/`

## Usuario por Defecto

- **Usuario:** superadmin
- **Contraseña:** Admin123!
- **Rol:** SUPERADMIN (todos los permisos)

**Nota:** Cambiar la contraseña inmediatamente después del primer acceso.

## Módulos del Sistema

### Dashboard
- Contadores en tiempo real (solicitudes, fichas, contribuyentes)
- Gráficos de solicitudes por estado
- Gráfico de recaudación mensual
- Actividad reciente del sistema
- Solicitudes pendientes

### Fichas Catastrales
- Datos del predio (ubicación, linderos)
- Características del terreno (área, uso, servicios)
- Datos de construcción (materiales, estado)
- Documentos legales
- Cálculo automático de avalúo
- Gestión de fotografías

### Variables de Cálculo
Coeficientes configurables por categoría:
- Zonas (Urbana Premium, A, B, C, Rural)
- Valores de terreno por uso
- Valores de construcción por calidad
- Depreciación por antigüedad
- Servicios públicos
- Alícuotas de impuesto

### Workflow de Solicitudes
Estados: Pendiente → En Revisión → Inspección → Aprobado/Rechazado

### Sistema de Notificaciones
- **Email:** Usando SMTP con soporte SSL/TLS
- **SMS:** API REST configurable

## Autorización Remota

Para acciones críticas (exoneraciones, anulaciones):
1. El sistema genera un token criptográfico
2. Se muestra QR o código para autorización
3. Un supervisor aprueba desde otro dispositivo
4. La acción se ejecuta o rechaza

## Seguridad

- Contraseñas hasheadas con SHA256 + Salt
- Bloqueo por intentos fallidos
- Auditoría completa de acciones
- Permisos granulares por rol

## Licencia

Propiedad de la Alcaldía Municipal. Uso exclusivo interno.

## Soporte

Para soporte técnico, contactar al Departamento de Sistemas.
