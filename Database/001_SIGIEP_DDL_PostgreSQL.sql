-- ============================================================================
-- SIGIEP - Sistema de Gestión Integral de Entes Públicos
-- Módulo: Catastro Municipal
-- Script DDL para PostgreSQL
-- Versión: 1.0
-- Fecha: 2025-01-01
-- ============================================================================

-- Extensiones necesarias
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- ============================================================================
-- ESQUEMA DE SEGURIDAD
-- ============================================================================

-- Tabla de Roles
CREATE TABLE Roles (
    RolID           SERIAL PRIMARY KEY,
    Nombre          VARCHAR(50) NOT NULL UNIQUE,
    Descripcion     VARCHAR(255),
    EsSuperUsuario  BOOLEAN DEFAULT FALSE,
    Activo          BOOLEAN DEFAULT TRUE,
    FechaCreacion   TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FechaModificacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Índice para búsqueda por nombre
CREATE INDEX idx_roles_nombre ON Roles(Nombre);

-- Tabla de Usuarios
CREATE TABLE Usuarios (
    UsuarioID       SERIAL PRIMARY KEY,
    Username        VARCHAR(50) NOT NULL UNIQUE,
    PasswordHash    VARCHAR(255) NOT NULL,
    Salt            VARCHAR(64) NOT NULL,
    Nombre          VARCHAR(100) NOT NULL,
    Apellido        VARCHAR(100) NOT NULL,
    Email           VARCHAR(150) UNIQUE,
    Telefono        VARCHAR(20),
    RolID           INTEGER NOT NULL REFERENCES Roles(RolID),
    EsInmutable     BOOLEAN DEFAULT FALSE,  -- Para el Super Usuario
    Activo          BOOLEAN DEFAULT TRUE,
    UltimoAcceso    TIMESTAMP,
    IntentosLogin   INTEGER DEFAULT 0,
    Bloqueado       BOOLEAN DEFAULT FALSE,
    FechaBloqueo    TIMESTAMP,
    FechaCreacion   TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FechaModificacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Índices para Usuarios
CREATE INDEX idx_usuarios_username ON Usuarios(Username);
CREATE INDEX idx_usuarios_email ON Usuarios(Email);
CREATE INDEX idx_usuarios_rol ON Usuarios(RolID);

-- Tabla de Permisos
CREATE TABLE Permisos (
    PermisoID       SERIAL PRIMARY KEY,
    Codigo          VARCHAR(50) NOT NULL UNIQUE,
    Nombre          VARCHAR(100) NOT NULL,
    Descripcion     VARCHAR(255),
    Modulo          VARCHAR(50) NOT NULL,
    RequiereAutorizacionRemota BOOLEAN DEFAULT FALSE,
    Activo          BOOLEAN DEFAULT TRUE,
    FechaCreacion   TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Índices para Permisos
CREATE INDEX idx_permisos_codigo ON Permisos(Codigo);
CREATE INDEX idx_permisos_modulo ON Permisos(Modulo);

-- Tabla de relación Roles-Permisos
CREATE TABLE RolesPermisos (
    RolPermisoID    SERIAL PRIMARY KEY,
    RolID           INTEGER NOT NULL REFERENCES Roles(RolID) ON DELETE CASCADE,
    PermisoID       INTEGER NOT NULL REFERENCES Permisos(PermisoID) ON DELETE CASCADE,
    FechaAsignacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(RolID, PermisoID)
);

-- Índices para RolesPermisos
CREATE INDEX idx_rolespermisos_rol ON RolesPermisos(RolID);
CREATE INDEX idx_rolespermisos_permiso ON RolesPermisos(PermisoID);

-- Tabla de Tokens de Autorización (para autorizaciones remotas)
CREATE TABLE TokensAutorizacion (
    TokenID         SERIAL PRIMARY KEY,
    Token           VARCHAR(64) NOT NULL UNIQUE,
    UsuarioSolicitante INTEGER NOT NULL REFERENCES Usuarios(UsuarioID),
    UsuarioAutorizador INTEGER REFERENCES Usuarios(UsuarioID),
    AccionCodigo    VARCHAR(50) NOT NULL,
    Descripcion     VARCHAR(255),
    Estado          VARCHAR(20) DEFAULT 'PENDIENTE' CHECK (Estado IN ('PENDIENTE', 'APROBADO', 'RECHAZADO', 'EXPIRADO', 'USADO')),
    DatosContexto   JSONB,  -- Datos adicionales de la acción
    FechaSolicitud  TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FechaExpiracion TIMESTAMP NOT NULL,
    FechaRespuesta  TIMESTAMP,
    IPSolicitante   VARCHAR(45),
    MacSolicitante  VARCHAR(17),
    Observaciones   TEXT
);

-- Índices para TokensAutorizacion
CREATE INDEX idx_tokens_token ON TokensAutorizacion(Token);
CREATE INDEX idx_tokens_estado ON TokensAutorizacion(Estado);
CREATE INDEX idx_tokens_usuario ON TokensAutorizacion(UsuarioSolicitante);
CREATE INDEX idx_tokens_fecha ON TokensAutorizacion(FechaSolicitud);

-- Tabla de Políticas de Seguridad
CREATE TABLE PoliticasSeguridad (
    PoliticaID      SERIAL PRIMARY KEY,
    Codigo          VARCHAR(50) NOT NULL UNIQUE,
    Nombre          VARCHAR(100) NOT NULL,
    Descripcion     TEXT,
    TiempoExpiracionToken INTEGER DEFAULT 300, -- Segundos
    RequiereQR      BOOLEAN DEFAULT FALSE,
    RequiereSMS     BOOLEAN DEFAULT FALSE,
    RequiereEmail   BOOLEAN DEFAULT FALSE,
    NivelAutorizacion INTEGER DEFAULT 1, -- 1=Supervisor, 2=Gerente, 3=Director
    Activo          BOOLEAN DEFAULT TRUE,
    FechaCreacion   TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FechaModificacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Índice para PoliticasSeguridad
CREATE INDEX idx_politicas_codigo ON PoliticasSeguridad(Codigo);

-- ============================================================================
-- ESQUEMA DE AUDITORÍA
-- ============================================================================

-- Tabla de Bitácora Global
CREATE TABLE BitacoraGlobal (
    BitacoraID      BIGSERIAL PRIMARY KEY,
    UsuarioID       INTEGER REFERENCES Usuarios(UsuarioID),
    Username        VARCHAR(50),
    FechaHora       TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    Accion          VARCHAR(50) NOT NULL,
    Modulo          VARCHAR(50) NOT NULL,
    Tabla           VARCHAR(50),
    RegistroID      INTEGER,
    DatosAnteriores JSONB,
    DatosNuevos     JSONB,
    IPCliente       VARCHAR(45),
    MACCliente      VARCHAR(17),
    NombreEquipo    VARCHAR(100),
    Resultado       VARCHAR(20) DEFAULT 'EXITO' CHECK (Resultado IN ('EXITO', 'ERROR', 'DENEGADO')),
    MensajeError    TEXT,
    Detalles        TEXT
);

-- Índices para BitacoraGlobal (Optimizados para consultas frecuentes)
CREATE INDEX idx_bitacora_fecha ON BitacoraGlobal(FechaHora DESC);
CREATE INDEX idx_bitacora_usuario ON BitacoraGlobal(UsuarioID);
CREATE INDEX idx_bitacora_accion ON BitacoraGlobal(Accion);
CREATE INDEX idx_bitacora_modulo ON BitacoraGlobal(Modulo);
CREATE INDEX idx_bitacora_tabla ON BitacoraGlobal(Tabla);
CREATE INDEX idx_bitacora_fecha_modulo ON BitacoraGlobal(FechaHora DESC, Modulo);

-- Particionado por fecha (opcional, para alto volumen)
-- CREATE TABLE BitacoraGlobal_2025 PARTITION OF BitacoraGlobal
--     FOR VALUES FROM ('2025-01-01') TO ('2026-01-01');

-- ============================================================================
-- ESQUEMA DE NEGOCIO - CONTRIBUYENTES
-- ============================================================================

-- Tabla de Contribuyentes
CREATE TABLE Contribuyentes (
    ContribuyenteID SERIAL PRIMARY KEY,
    TipoDocumento   VARCHAR(20) NOT NULL CHECK (TipoDocumento IN ('V', 'E', 'J', 'G', 'P')),
    NumeroDocumento VARCHAR(20) NOT NULL,
    RIF             VARCHAR(15) UNIQUE,
    RazonSocial     VARCHAR(200),
    Nombre          VARCHAR(100),
    Apellido        VARCHAR(100),
    FechaNacimiento DATE,
    Sexo            CHAR(1) CHECK (Sexo IN ('M', 'F')),
    EstadoCivil     VARCHAR(20),
    Nacionalidad    VARCHAR(50) DEFAULT 'Venezolana',

    -- Dirección Fiscal
    DireccionFiscal TEXT NOT NULL,
    Estado          VARCHAR(50),
    Municipio       VARCHAR(100),
    Parroquia       VARCHAR(100),
    Sector          VARCHAR(100),
    CodigoPostal    VARCHAR(10),

    -- Contacto
    TelefonoLocal   VARCHAR(20),
    TelefonoMovil   VARCHAR(20),
    Email           VARCHAR(150),

    -- Datos Fiscales
    ActividadEconomica VARCHAR(100),
    EsContribuyenteEspecial BOOLEAN DEFAULT FALSE,

    -- Control
    Activo          BOOLEAN DEFAULT TRUE,
    Observaciones   TEXT,
    FechaRegistro   TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FechaModificacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UsuarioCreacion INTEGER REFERENCES Usuarios(UsuarioID),
    UsuarioModificacion INTEGER REFERENCES Usuarios(UsuarioID),

    -- Restricción única para documento
    UNIQUE(TipoDocumento, NumeroDocumento)
);

-- Índices para Contribuyentes
CREATE INDEX idx_contribuyentes_documento ON Contribuyentes(TipoDocumento, NumeroDocumento);
CREATE INDEX idx_contribuyentes_rif ON Contribuyentes(RIF);
CREATE INDEX idx_contribuyentes_nombre ON Contribuyentes(Nombre, Apellido);
CREATE INDEX idx_contribuyentes_razon ON Contribuyentes(RazonSocial);

-- ============================================================================
-- ESQUEMA DE NEGOCIO - SOLICITUDES (Workflow)
-- ============================================================================

-- Tipos de Solicitud
CREATE TABLE TiposSolicitud (
    TipoSolicitudID SERIAL PRIMARY KEY,
    Codigo          VARCHAR(20) NOT NULL UNIQUE,
    Nombre          VARCHAR(100) NOT NULL,
    Descripcion     TEXT,
    DiasHabiles     INTEGER DEFAULT 15, -- Tiempo máximo de respuesta
    RequiereInspeccion BOOLEAN DEFAULT FALSE,
    Activo          BOOLEAN DEFAULT TRUE
);

-- Tabla de Solicitudes
CREATE TABLE Solicitudes (
    SolicitudID     SERIAL PRIMARY KEY,
    NumeroExpediente VARCHAR(20) NOT NULL UNIQUE,
    TipoSolicitudID INTEGER NOT NULL REFERENCES TiposSolicitud(TipoSolicitudID),
    ContribuyenteID INTEGER NOT NULL REFERENCES Contribuyentes(ContribuyenteID),
    FichaCatastralID INTEGER, -- Se llena después de crear la ficha

    -- Estado del Workflow
    Estado          VARCHAR(30) DEFAULT 'PENDIENTE'
                    CHECK (Estado IN ('PENDIENTE', 'EN_REVISION', 'INSPECCION',
                                     'PENDIENTE_APROBACION', 'APROBADO', 'RECHAZADO', 'ANULADO')),
    SubEstado       VARCHAR(50),

    -- Fechas del Workflow
    FechaSolicitud  TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FechaRecepcion  TIMESTAMP,
    FechaAsignacion TIMESTAMP,
    FechaInspeccion TIMESTAMP,
    FechaResolucion TIMESTAMP,
    FechaNotificacion TIMESTAMP,

    -- Asignaciones
    UsuarioReceptor INTEGER REFERENCES Usuarios(UsuarioID),
    UsuarioRevisor  INTEGER REFERENCES Usuarios(UsuarioID),
    UsuarioInspector INTEGER REFERENCES Usuarios(UsuarioID),
    UsuarioAprobador INTEGER REFERENCES Usuarios(UsuarioID),

    -- Documentación
    DocumentosEntregados TEXT[],
    DocumentosFaltantes TEXT[],

    -- Resolución
    MotivoRechazo   TEXT,
    Observaciones   TEXT,

    -- Prioridad
    Prioridad       INTEGER DEFAULT 3 CHECK (Prioridad BETWEEN 1 AND 5), -- 1=Urgente, 5=Normal

    -- Control
    FechaModificacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Índices para Solicitudes
CREATE INDEX idx_solicitudes_expediente ON Solicitudes(NumeroExpediente);
CREATE INDEX idx_solicitudes_estado ON Solicitudes(Estado);
CREATE INDEX idx_solicitudes_contribuyente ON Solicitudes(ContribuyenteID);
CREATE INDEX idx_solicitudes_fecha ON Solicitudes(FechaSolicitud DESC);
CREATE INDEX idx_solicitudes_tipo ON Solicitudes(TipoSolicitudID);
CREATE INDEX idx_solicitudes_revisor ON Solicitudes(UsuarioRevisor);

-- Historial de Estados de Solicitud
CREATE TABLE SolicitudesHistorial (
    HistorialID     SERIAL PRIMARY KEY,
    SolicitudID     INTEGER NOT NULL REFERENCES Solicitudes(SolicitudID) ON DELETE CASCADE,
    EstadoAnterior  VARCHAR(30),
    EstadoNuevo     VARCHAR(30) NOT NULL,
    UsuarioID       INTEGER REFERENCES Usuarios(UsuarioID),
    FechaCambio     TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    Observaciones   TEXT
);

-- Índice para Historial
CREATE INDEX idx_solicitudes_hist_solicitud ON SolicitudesHistorial(SolicitudID);

-- ============================================================================
-- ESQUEMA DE CATASTRO - VARIABLES DE CÁLCULO
-- ============================================================================

-- Categorías de Variables
CREATE TABLE CategoriasVariable (
    CategoriaID     SERIAL PRIMARY KEY,
    Codigo          VARCHAR(30) NOT NULL UNIQUE,
    Nombre          VARCHAR(100) NOT NULL,
    Descripcion     TEXT,
    Orden           INTEGER DEFAULT 0,
    Activo          BOOLEAN DEFAULT TRUE
);

-- Tabla de Variables de Cálculo
CREATE TABLE VariablesCalculo (
    VariableID      SERIAL PRIMARY KEY,
    CategoriaID     INTEGER REFERENCES CategoriasVariable(CategoriaID),
    Codigo          VARCHAR(50) NOT NULL UNIQUE,
    Nombre          VARCHAR(150) NOT NULL,
    Descripcion     TEXT,

    -- Valores
    ValorNumerico   DECIMAL(18,6),
    ValorTexto      VARCHAR(255),
    ValorPorcentaje DECIMAL(8,4),

    -- Unidades y Formato
    UnidadMedida    VARCHAR(20), -- Bs, %, m², UT, etc.
    TipoDato        VARCHAR(20) DEFAULT 'NUMERICO'
                    CHECK (TipoDato IN ('NUMERICO', 'PORCENTAJE', 'TEXTO', 'BOOLEANO')),

    -- Vigencia
    FechaInicioVigencia DATE DEFAULT CURRENT_DATE,
    FechaFinVigencia DATE,
    AnioFiscal      INTEGER DEFAULT EXTRACT(YEAR FROM CURRENT_DATE),

    -- Control
    Activo          BOOLEAN DEFAULT TRUE,
    FechaCreacion   TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FechaModificacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UsuarioModificacion INTEGER REFERENCES Usuarios(UsuarioID)
);

-- Índices para VariablesCalculo
CREATE INDEX idx_variables_codigo ON VariablesCalculo(Codigo);
CREATE INDEX idx_variables_categoria ON VariablesCalculo(CategoriaID);
CREATE INDEX idx_variables_vigencia ON VariablesCalculo(FechaInicioVigencia, FechaFinVigencia);
CREATE INDEX idx_variables_anio ON VariablesCalculo(AnioFiscal);

-- ============================================================================
-- ESQUEMA DE CATASTRO - FICHA CATASTRAL
-- ============================================================================

-- Tabla principal de Ficha Catastral
CREATE TABLE FichaCatastral (
    FichaID         SERIAL PRIMARY KEY,
    CodigoCatastral VARCHAR(30) NOT NULL UNIQUE, -- Código único del inmueble
    ContribuyenteID INTEGER NOT NULL REFERENCES Contribuyentes(ContribuyenteID),

    -- ========== DATOS DEL PREDIO ==========
    -- Ubicación Geográfica
    Estado          VARCHAR(50) NOT NULL,
    Municipio       VARCHAR(100) NOT NULL,
    Parroquia       VARCHAR(100) NOT NULL,
    Sector          VARCHAR(100),
    Urbanizacion    VARCHAR(100),
    Calle           VARCHAR(100),
    Avenida         VARCHAR(100),
    NumeroCasa      VARCHAR(20),
    Manzana         VARCHAR(20),
    Parcela         VARCHAR(20),

    -- Coordenadas (opcional)
    Latitud         DECIMAL(10, 8),
    Longitud        DECIMAL(11, 8),

    -- Linderos
    LinderoNorte    VARCHAR(200),
    LinderoSur      VARCHAR(200),
    LinderoEste     VARCHAR(200),
    LinderoOeste    VARCHAR(200),

    -- ========== CARACTERÍSTICAS DEL TERRENO ==========
    AreaTerreno     DECIMAL(12, 2) NOT NULL, -- m²
    AreaConstruccion DECIMAL(12, 2), -- m²
    Fachada         DECIMAL(8, 2), -- metros lineales
    Fondo           DECIMAL(8, 2), -- metros lineales

    -- Clasificación del Terreno
    UsoTerreno      VARCHAR(30) CHECK (UsoTerreno IN ('RESIDENCIAL', 'COMERCIAL', 'INDUSTRIAL',
                                                      'AGRICOLA', 'MIXTO', 'BALDIO', 'INSTITUCIONAL')),
    ClasificacionZona VARCHAR(30), -- ZR1, ZC2, ZI1, etc.
    TopografiaTerreno VARCHAR(30) CHECK (TopografiaTerreno IN ('PLANO', 'PENDIENTE_SUAVE',
                                                               'PENDIENTE_MEDIA', 'PENDIENTE_FUERTE', 'IRREGULAR')),
    FormaTerreno    VARCHAR(30) CHECK (FormaTerreno IN ('REGULAR', 'IRREGULAR', 'ESQUINERO')),

    -- Servicios Públicos
    TieneAgua       BOOLEAN DEFAULT FALSE,
    TieneElectricidad BOOLEAN DEFAULT FALSE,
    TieneCloacas    BOOLEAN DEFAULT FALSE,
    TieneAseo       BOOLEAN DEFAULT FALSE,
    TieneGas        BOOLEAN DEFAULT FALSE,
    TieneTelefono   BOOLEAN DEFAULT FALSE,
    TieneInternet   BOOLEAN DEFAULT FALSE,
    TieneAceras     BOOLEAN DEFAULT FALSE,
    TieneAlumbrado  BOOLEAN DEFAULT FALSE,
    TieneAsfalto    BOOLEAN DEFAULT FALSE,

    -- ========== CARACTERÍSTICAS DE LA CONSTRUCCIÓN ==========
    TipoConstruccion VARCHAR(30) CHECK (TipoConstruccion IN ('CASA', 'APARTAMENTO', 'TOWNHOUSE',
                                                             'LOCAL_COMERCIAL', 'GALPON', 'EDIFICIO',
                                                             'OTRO', 'SIN_CONSTRUCCION')),
    EstadoConstruccion VARCHAR(30) CHECK (EstadoConstruccion IN ('NUEVA', 'BUENA', 'REGULAR',
                                                                  'MALA', 'EN_CONSTRUCCION', 'RUINAS')),
    AnioConstruccion INTEGER,
    NumeroPlantas   INTEGER DEFAULT 1,
    NumeroHabitaciones INTEGER,
    NumeroBanos     INTEGER,
    NumeroEstacionamientos INTEGER,

    -- Materiales de Construcción
    MaterialEstructura VARCHAR(50), -- Concreto, Acero, Madera, etc.
    MaterialParedes VARCHAR(50), -- Bloque, Ladrillo, Adobe, etc.
    MaterialTecho   VARCHAR(50), -- Platabanda, Tejas, Zinc, etc.
    MaterialPiso    VARCHAR(50), -- Cerámica, Granito, Cemento, etc.

    -- Calidad de Acabados (1-5)
    CalidadAcabados INTEGER DEFAULT 3 CHECK (CalidadAcabados BETWEEN 1 AND 5),

    -- ========== DATOS LEGALES ==========
    NumeroDocumentoPropiedad VARCHAR(50),
    FechaDocumentoPropiedad DATE,
    Notaria         VARCHAR(100),
    Tomo            VARCHAR(20),
    Folio           VARCHAR(20),
    Protocolo       VARCHAR(20),

    -- ========== VALORES Y AVALÚO ==========
    -- Valores Base (antes de aplicar coeficientes)
    ValorTerrenoBase DECIMAL(18, 2),
    ValorConstruccionBase DECIMAL(18, 2),

    -- Coeficientes Aplicados (guardados para auditoría)
    CoeficienteZona DECIMAL(6, 4) DEFAULT 1.0000,
    CoeficienteUso  DECIMAL(6, 4) DEFAULT 1.0000,
    CoeficienteEstado DECIMAL(6, 4) DEFAULT 1.0000,
    CoeficienteServicios DECIMAL(6, 4) DEFAULT 1.0000,
    CoeficienteDepreciacion DECIMAL(6, 4) DEFAULT 1.0000,

    -- Valores Calculados
    ValorTerreno    DECIMAL(18, 2), -- ValorTerrenoBase * Coeficientes
    ValorConstruccion DECIMAL(18, 2), -- ValorConstruccionBase * Coeficientes
    ValorTotal      DECIMAL(18, 2), -- ValorTerreno + ValorConstruccion

    -- Impuesto
    BaseImponible   DECIMAL(18, 2),
    Alicuota        DECIMAL(8, 4), -- Porcentaje del impuesto
    MontoImpuestoAnual DECIMAL(18, 2),

    -- ========== EXONERACIONES ==========
    TieneExoneracion BOOLEAN DEFAULT FALSE,
    TipoExoneracion VARCHAR(50),
    PorcentajeExoneracion DECIMAL(5, 2) DEFAULT 0,
    MotivoExoneracion TEXT,
    FechaInicioExoneracion DATE,
    FechaFinExoneracion DATE,
    DocumentoExoneracion VARCHAR(100),

    -- ========== FOTOGRAFÍAS ==========
    RutaFotoPrincipal VARCHAR(500),
    RutaFotoFachada VARCHAR(500),
    RutaFotoInterior VARCHAR(500),
    RutaFotoAdicional1 VARCHAR(500),
    RutaFotoAdicional2 VARCHAR(500),
    -- También podríamos usar BYTEA para BLOBs si se prefiere

    -- ========== CONTROL Y AUDITORÍA ==========
    EstadoFicha     VARCHAR(20) DEFAULT 'ACTIVA' CHECK (EstadoFicha IN ('ACTIVA', 'INACTIVA', 'REVISION', 'ANULADA')),
    FechaCreacion   TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FechaModificacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FechaUltimoAvaluo TIMESTAMP,
    UsuarioCreacion INTEGER REFERENCES Usuarios(UsuarioID),
    UsuarioModificacion INTEGER REFERENCES Usuarios(UsuarioID),
    UsuarioUltimoAvaluo INTEGER REFERENCES Usuarios(UsuarioID),

    Observaciones   TEXT
);

-- Índices para FichaCatastral
CREATE INDEX idx_ficha_codigo ON FichaCatastral(CodigoCatastral);
CREATE INDEX idx_ficha_contribuyente ON FichaCatastral(ContribuyenteID);
CREATE INDEX idx_ficha_ubicacion ON FichaCatastral(Estado, Municipio, Parroquia);
CREATE INDEX idx_ficha_uso ON FichaCatastral(UsoTerreno);
CREATE INDEX idx_ficha_estado ON FichaCatastral(EstadoFicha);

-- Actualizar FK en Solicitudes
ALTER TABLE Solicitudes
ADD CONSTRAINT fk_solicitud_ficha
FOREIGN KEY (FichaCatastralID) REFERENCES FichaCatastral(FichaID);

-- ============================================================================
-- ESQUEMA DE CONFIGURACIÓN
-- ============================================================================

-- Configuración General del Sistema
CREATE TABLE ConfiguracionSistema (
    ConfigID        SERIAL PRIMARY KEY,
    Clave           VARCHAR(100) NOT NULL UNIQUE,
    Valor           TEXT,
    TipoDato        VARCHAR(20) DEFAULT 'TEXTO',
    Descripcion     TEXT,
    EsEncriptado    BOOLEAN DEFAULT FALSE,
    FechaModificacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Configuración de Notificaciones
CREATE TABLE ConfiguracionNotificaciones (
    ConfigNotifID   SERIAL PRIMARY KEY,
    Tipo            VARCHAR(20) NOT NULL CHECK (Tipo IN ('EMAIL', 'SMS')),
    Proveedor       VARCHAR(50),
    ServidorSMTP    VARCHAR(100),
    Puerto          INTEGER,
    Usuario         VARCHAR(100),
    Password        VARCHAR(255), -- Encriptado
    APIUrl          VARCHAR(500),
    APIKey          VARCHAR(255), -- Encriptado
    RemitentePorDefecto VARCHAR(100),
    Activo          BOOLEAN DEFAULT TRUE,
    FechaModificacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ============================================================================
-- DATOS INICIALES
-- ============================================================================

-- Insertar Rol Super Usuario
INSERT INTO Roles (Nombre, Descripcion, EsSuperUsuario, Activo)
VALUES ('SUPERADMIN', 'Administrador del Sistema con todos los privilegios', TRUE, TRUE);

-- Insertar Rol Administrador
INSERT INTO Roles (Nombre, Descripcion, EsSuperUsuario, Activo)
VALUES ('ADMINISTRADOR', 'Administrador con privilegios elevados', FALSE, TRUE);

-- Insertar Rol Supervisor
INSERT INTO Roles (Nombre, Descripcion, EsSuperUsuario, Activo)
VALUES ('SUPERVISOR', 'Supervisor de área con permisos de autorización', FALSE, TRUE);

-- Insertar Rol Analista
INSERT INTO Roles (Nombre, Descripcion, EsSuperUsuario, Activo)
VALUES ('ANALISTA', 'Analista de catastro', FALSE, TRUE);

-- Insertar Rol Receptor
INSERT INTO Roles (Nombre, Descripcion, EsSuperUsuario, Activo)
VALUES ('RECEPTOR', 'Recepción de documentos', FALSE, TRUE);

-- Insertar Rol Inspector
INSERT INTO Roles (Nombre, Descripcion, EsSuperUsuario, Activo)
VALUES ('INSPECTOR', 'Inspector de campo', FALSE, TRUE);

-- Insertar Rol Consulta
INSERT INTO Roles (Nombre, Descripcion, EsSuperUsuario, Activo)
VALUES ('CONSULTA', 'Solo consulta de información', FALSE, TRUE);

-- Insertar Super Usuario (Password: Admin123!)
-- Nota: En producción usar hash real con bcrypt
INSERT INTO Usuarios (Username, PasswordHash, Salt, Nombre, Apellido, Email, RolID, EsInmutable, Activo)
VALUES ('superadmin',
        'e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855', -- Hash SHA256 ejemplo
        'a1b2c3d4e5f6g7h8',
        'Super',
        'Administrador',
        'admin@sigiep.gob.ve',
        (SELECT RolID FROM Roles WHERE Nombre = 'SUPERADMIN'),
        TRUE,
        TRUE);

-- Insertar Categorías de Variables
INSERT INTO CategoriasVariable (Codigo, Nombre, Descripcion, Orden) VALUES
('ZONA', 'Valores por Zona', 'Coeficientes según ubicación geográfica', 1),
('TERRENO', 'Valores de Terreno', 'Precios base por metro cuadrado de terreno', 2),
('CONSTRUCCION', 'Valores de Construcción', 'Precios base por metro cuadrado construido', 3),
('USO', 'Coeficientes por Uso', 'Factores según uso del inmueble', 4),
('ESTADO', 'Coeficientes por Estado', 'Factores según estado de conservación', 5),
('DEPRECIACION', 'Depreciación', 'Factores de depreciación por antigüedad', 6),
('SERVICIOS', 'Coeficientes de Servicios', 'Factores por servicios públicos disponibles', 7),
('IMPUESTO', 'Tasas de Impuesto', 'Alícuotas y tasas impositivas', 8);

-- Insertar Variables de Cálculo Ejemplo
INSERT INTO VariablesCalculo (CategoriaID, Codigo, Nombre, ValorNumerico, UnidadMedida, TipoDato) VALUES
-- Valores de Zona
((SELECT CategoriaID FROM CategoriasVariable WHERE Codigo = 'ZONA'), 'ZONA_URBANA_PREMIUM', 'Zona Urbana Premium', 1.5000, 'COEF', 'NUMERICO'),
((SELECT CategoriaID FROM CategoriasVariable WHERE Codigo = 'ZONA'), 'ZONA_URBANA_A', 'Zona Urbana A', 1.3000, 'COEF', 'NUMERICO'),
((SELECT CategoriaID FROM CategoriasVariable WHERE Codigo = 'ZONA'), 'ZONA_URBANA_B', 'Zona Urbana B', 1.1000, 'COEF', 'NUMERICO'),
((SELECT CategoriaID FROM CategoriasVariable WHERE Codigo = 'ZONA'), 'ZONA_URBANA_C', 'Zona Urbana C', 1.0000, 'COEF', 'NUMERICO'),
((SELECT CategoriaID FROM CategoriasVariable WHERE Codigo = 'ZONA'), 'ZONA_RURAL', 'Zona Rural', 0.8000, 'COEF', 'NUMERICO'),

-- Valores Base de Terreno (Bs/m²)
((SELECT CategoriaID FROM CategoriasVariable WHERE Codigo = 'TERRENO'), 'TERRENO_RESIDENCIAL', 'Terreno Residencial', 150.00, 'Bs/m²', 'NUMERICO'),
((SELECT CategoriaID FROM CategoriasVariable WHERE Codigo = 'TERRENO'), 'TERRENO_COMERCIAL', 'Terreno Comercial', 250.00, 'Bs/m²', 'NUMERICO'),
((SELECT CategoriaID FROM CategoriasVariable WHERE Codigo = 'TERRENO'), 'TERRENO_INDUSTRIAL', 'Terreno Industrial', 180.00, 'Bs/m²', 'NUMERICO'),
((SELECT CategoriaID FROM CategoriasVariable WHERE Codigo = 'TERRENO'), 'TERRENO_AGRICOLA', 'Terreno Agrícola', 50.00, 'Bs/m²', 'NUMERICO'),

-- Valores Base de Construcción (Bs/m²)
((SELECT CategoriaID FROM CategoriasVariable WHERE Codigo = 'CONSTRUCCION'), 'CONST_LUJO', 'Construcción de Lujo', 800.00, 'Bs/m²', 'NUMERICO'),
((SELECT CategoriaID FROM CategoriasVariable WHERE Codigo = 'CONSTRUCCION'), 'CONST_PRIMERA', 'Construcción Primera', 500.00, 'Bs/m²', 'NUMERICO'),
((SELECT CategoriaID FROM CategoriasVariable WHERE Codigo = 'CONSTRUCCION'), 'CONST_SEGUNDA', 'Construcción Segunda', 350.00, 'Bs/m²', 'NUMERICO'),
((SELECT CategoriaID FROM CategoriasVariable WHERE Codigo = 'CONSTRUCCION'), 'CONST_TERCERA', 'Construcción Tercera', 200.00, 'Bs/m²', 'NUMERICO'),
((SELECT CategoriaID FROM CategoriasVariable WHERE Codigo = 'CONSTRUCCION'), 'CONST_ECONOMICA', 'Construcción Económica', 120.00, 'Bs/m²', 'NUMERICO'),

-- Coeficientes por Uso
((SELECT CategoriaID FROM CategoriasVariable WHERE Codigo = 'USO'), 'USO_RESIDENCIAL', 'Uso Residencial', 1.0000, 'COEF', 'NUMERICO'),
((SELECT CategoriaID FROM CategoriasVariable WHERE Codigo = 'USO'), 'USO_COMERCIAL', 'Uso Comercial', 1.2500, 'COEF', 'NUMERICO'),
((SELECT CategoriaID FROM CategoriasVariable WHERE Codigo = 'USO'), 'USO_INDUSTRIAL', 'Uso Industrial', 1.3000, 'COEF', 'NUMERICO'),
((SELECT CategoriaID FROM CategoriasVariable WHERE Codigo = 'USO'), 'USO_MIXTO', 'Uso Mixto', 1.1500, 'COEF', 'NUMERICO'),

-- Coeficientes por Estado de Conservación
((SELECT CategoriaID FROM CategoriasVariable WHERE Codigo = 'ESTADO'), 'ESTADO_NUEVA', 'Estado Nueva', 1.0000, 'COEF', 'NUMERICO'),
((SELECT CategoriaID FROM CategoriasVariable WHERE Codigo = 'ESTADO'), 'ESTADO_BUENA', 'Estado Buena', 0.9000, 'COEF', 'NUMERICO'),
((SELECT CategoriaID FROM CategoriasVariable WHERE Codigo = 'ESTADO'), 'ESTADO_REGULAR', 'Estado Regular', 0.7500, 'COEF', 'NUMERICO'),
((SELECT CategoriaID FROM CategoriasVariable WHERE Codigo = 'ESTADO'), 'ESTADO_MALA', 'Estado Mala', 0.5000, 'COEF', 'NUMERICO'),

-- Coeficientes de Depreciación por Antigüedad
((SELECT CategoriaID FROM CategoriasVariable WHERE Codigo = 'DEPRECIACION'), 'DEPREC_0_5', 'Depreciación 0-5 años', 1.0000, 'COEF', 'NUMERICO'),
((SELECT CategoriaID FROM CategoriasVariable WHERE Codigo = 'DEPRECIACION'), 'DEPREC_6_10', 'Depreciación 6-10 años', 0.9500, 'COEF', 'NUMERICO'),
((SELECT CategoriaID FROM CategoriasVariable WHERE Codigo = 'DEPRECIACION'), 'DEPREC_11_20', 'Depreciación 11-20 años', 0.8500, 'COEF', 'NUMERICO'),
((SELECT CategoriaID FROM CategoriasVariable WHERE Codigo = 'DEPRECIACION'), 'DEPREC_21_30', 'Depreciación 21-30 años', 0.7500, 'COEF', 'NUMERICO'),
((SELECT CategoriaID FROM CategoriasVariable WHERE Codigo = 'DEPRECIACION'), 'DEPREC_31_MAS', 'Depreciación 31+ años', 0.6000, 'COEF', 'NUMERICO'),

-- Coeficientes de Servicios
((SELECT CategoriaID FROM CategoriasVariable WHERE Codigo = 'SERVICIOS'), 'SERV_COMPLETOS', 'Servicios Completos', 1.2000, 'COEF', 'NUMERICO'),
((SELECT CategoriaID FROM CategoriasVariable WHERE Codigo = 'SERVICIOS'), 'SERV_BASICOS', 'Servicios Básicos', 1.0000, 'COEF', 'NUMERICO'),
((SELECT CategoriaID FROM CategoriasVariable WHERE Codigo = 'SERVICIOS'), 'SERV_PARCIALES', 'Servicios Parciales', 0.8500, 'COEF', 'NUMERICO'),
((SELECT CategoriaID FROM CategoriasVariable WHERE Codigo = 'SERVICIOS'), 'SERV_MINIMOS', 'Servicios Mínimos', 0.7000, 'COEF', 'NUMERICO'),

-- Tasas de Impuesto
((SELECT CategoriaID FROM CategoriasVariable WHERE Codigo = 'IMPUESTO'), 'ALICUOTA_RESIDENCIAL', 'Alícuota Residencial', 0.5000, '%', 'PORCENTAJE'),
((SELECT CategoriaID FROM CategoriasVariable WHERE Codigo = 'IMPUESTO'), 'ALICUOTA_COMERCIAL', 'Alícuota Comercial', 1.0000, '%', 'PORCENTAJE'),
((SELECT CategoriaID FROM CategoriasVariable WHERE Codigo = 'IMPUESTO'), 'ALICUOTA_INDUSTRIAL', 'Alícuota Industrial', 1.2500, '%', 'PORCENTAJE');

-- Insertar Permisos
INSERT INTO Permisos (Codigo, Nombre, Descripcion, Modulo, RequiereAutorizacionRemota) VALUES
-- Seguridad
('USUARIOS_VER', 'Ver Usuarios', 'Permite ver listado de usuarios', 'SEGURIDAD', FALSE),
('USUARIOS_CREAR', 'Crear Usuarios', 'Permite crear nuevos usuarios', 'SEGURIDAD', FALSE),
('USUARIOS_EDITAR', 'Editar Usuarios', 'Permite modificar usuarios', 'SEGURIDAD', FALSE),
('USUARIOS_ELIMINAR', 'Eliminar Usuarios', 'Permite desactivar usuarios', 'SEGURIDAD', TRUE),
('ROLES_GESTIONAR', 'Gestionar Roles', 'Permite administrar roles y permisos', 'SEGURIDAD', TRUE),

-- Contribuyentes
('CONTRIB_VER', 'Ver Contribuyentes', 'Permite ver contribuyentes', 'CONTRIBUYENTES', FALSE),
('CONTRIB_CREAR', 'Crear Contribuyentes', 'Permite registrar contribuyentes', 'CONTRIBUYENTES', FALSE),
('CONTRIB_EDITAR', 'Editar Contribuyentes', 'Permite modificar contribuyentes', 'CONTRIBUYENTES', FALSE),
('CONTRIB_ELIMINAR', 'Eliminar Contribuyentes', 'Permite desactivar contribuyentes', 'CONTRIBUYENTES', TRUE),

-- Solicitudes
('SOLIC_VER', 'Ver Solicitudes', 'Permite ver solicitudes', 'SOLICITUDES', FALSE),
('SOLIC_CREAR', 'Crear Solicitudes', 'Permite registrar solicitudes', 'SOLICITUDES', FALSE),
('SOLIC_ASIGNAR', 'Asignar Solicitudes', 'Permite asignar solicitudes a analistas', 'SOLICITUDES', FALSE),
('SOLIC_APROBAR', 'Aprobar Solicitudes', 'Permite aprobar/rechazar solicitudes', 'SOLICITUDES', TRUE),
('SOLIC_ANULAR', 'Anular Solicitudes', 'Permite anular solicitudes', 'SOLICITUDES', TRUE),

-- Fichas Catastrales
('FICHA_VER', 'Ver Fichas', 'Permite ver fichas catastrales', 'CATASTRO', FALSE),
('FICHA_CREAR', 'Crear Fichas', 'Permite crear fichas catastrales', 'CATASTRO', FALSE),
('FICHA_EDITAR', 'Editar Fichas', 'Permite modificar fichas catastrales', 'CATASTRO', FALSE),
('FICHA_CALCULAR', 'Calcular Avalúo', 'Permite ejecutar cálculo de avalúo', 'CATASTRO', FALSE),
('FICHA_APROBAR_EXONERACION', 'Aprobar Exoneración', 'Permite aprobar exoneraciones fiscales', 'CATASTRO', TRUE),
('FICHA_ELIMINAR', 'Eliminar Fichas', 'Permite anular fichas catastrales', 'CATASTRO', TRUE),

-- Variables
('VARIABLES_VER', 'Ver Variables', 'Permite ver variables de cálculo', 'CONFIGURACION', FALSE),
('VARIABLES_EDITAR', 'Editar Variables', 'Permite modificar variables de cálculo', 'CONFIGURACION', TRUE),

-- Reportes
('REPORTES_VER', 'Ver Reportes', 'Permite generar reportes', 'REPORTES', FALSE),
('REPORTES_EXPORTAR', 'Exportar Reportes', 'Permite exportar reportes', 'REPORTES', FALSE),

-- Auditoría
('AUDITORIA_VER', 'Ver Auditoría', 'Permite ver logs de auditoría', 'AUDITORIA', FALSE);

-- Asignar todos los permisos al Rol SUPERADMIN
INSERT INTO RolesPermisos (RolID, PermisoID)
SELECT
    (SELECT RolID FROM Roles WHERE Nombre = 'SUPERADMIN'),
    PermisoID
FROM Permisos;

-- Insertar Tipos de Solicitud
INSERT INTO TiposSolicitud (Codigo, Nombre, Descripcion, DiasHabiles, RequiereInspeccion) VALUES
('INSCRIPCION', 'Inscripción Catastral', 'Primera inscripción de inmueble en catastro', 15, TRUE),
('ACTUALIZACION', 'Actualización de Datos', 'Actualización de información catastral', 10, FALSE),
('AVALUO', 'Avalúo Catastral', 'Solicitud de avalúo oficial', 20, TRUE),
('CONSTANCIA', 'Constancia Catastral', 'Emisión de constancia catastral', 5, FALSE),
('EXONERACION', 'Solicitud de Exoneración', 'Solicitud de exoneración de impuesto', 15, FALSE),
('REVISION', 'Revisión de Avalúo', 'Solicitud de revisión de avalúo existente', 15, TRUE),
('DESMEMBRACION', 'Desmembración', 'División de parcela', 30, TRUE),
('UNIFICACION', 'Unificación', 'Unión de parcelas', 30, TRUE);

-- Insertar Políticas de Seguridad
INSERT INTO PoliticasSeguridad (Codigo, Nombre, Descripcion, TiempoExpiracionToken, RequiereQR, NivelAutorizacion) VALUES
('POL_EXONERACION', 'Autorización de Exoneración', 'Requiere autorización para aprobar exoneraciones', 300, TRUE, 2),
('POL_ANULACION', 'Autorización de Anulación', 'Requiere autorización para anular documentos', 300, TRUE, 2),
('POL_ELIMINACION', 'Autorización de Eliminación', 'Requiere autorización para eliminar registros', 180, FALSE, 3),
('POL_CAMBIO_VARIABLES', 'Cambio de Variables', 'Requiere autorización para modificar variables de cálculo', 600, TRUE, 3);

-- Insertar Configuración del Sistema
INSERT INTO ConfiguracionSistema (Clave, Valor, TipoDato, Descripcion) VALUES
('NOMBRE_MUNICIPIO', 'Municipio Ejemplo', 'TEXTO', 'Nombre del municipio'),
('RIF_ALCALDIA', 'G-20000000-0', 'TEXTO', 'RIF de la Alcaldía'),
('DIRECCION_ALCALDIA', 'Av. Principal, Edificio Municipal', 'TEXTO', 'Dirección de la Alcaldía'),
('TELEFONO_ALCALDIA', '0212-1234567', 'TEXTO', 'Teléfono principal'),
('ANIO_FISCAL_ACTUAL', '2025', 'NUMERO', 'Año fiscal vigente'),
('UNIDAD_TRIBUTARIA', '9.00', 'NUMERO', 'Valor de la Unidad Tributaria'),
('INTENTOS_LOGIN_MAX', '3', 'NUMERO', 'Intentos máximos de login antes de bloqueo'),
('TIEMPO_BLOQUEO_MIN', '30', 'NUMERO', 'Minutos de bloqueo por intentos fallidos'),
('RUTA_FOTOS', 'C:\SIGIEP\Fotos\', 'TEXTO', 'Ruta para almacenar fotografías'),
('RUTA_DOCUMENTOS', 'C:\SIGIEP\Documentos\', 'TEXTO', 'Ruta para almacenar documentos');

-- ============================================================================
-- FUNCIONES Y TRIGGERS
-- ============================================================================

-- Función para actualizar timestamp de modificación
CREATE OR REPLACE FUNCTION actualizar_fecha_modificacion()
RETURNS TRIGGER AS $$
BEGIN
    NEW.FechaModificacion = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Triggers para actualizar FechaModificacion
CREATE TRIGGER trg_usuarios_modificacion
    BEFORE UPDATE ON Usuarios
    FOR EACH ROW EXECUTE FUNCTION actualizar_fecha_modificacion();

CREATE TRIGGER trg_contribuyentes_modificacion
    BEFORE UPDATE ON Contribuyentes
    FOR EACH ROW EXECUTE FUNCTION actualizar_fecha_modificacion();

CREATE TRIGGER trg_solicitudes_modificacion
    BEFORE UPDATE ON Solicitudes
    FOR EACH ROW EXECUTE FUNCTION actualizar_fecha_modificacion();

CREATE TRIGGER trg_ficha_modificacion
    BEFORE UPDATE ON FichaCatastral
    FOR EACH ROW EXECUTE FUNCTION actualizar_fecha_modificacion();

CREATE TRIGGER trg_variables_modificacion
    BEFORE UPDATE ON VariablesCalculo
    FOR EACH ROW EXECUTE FUNCTION actualizar_fecha_modificacion();

-- Función para generar número de expediente
CREATE OR REPLACE FUNCTION generar_numero_expediente()
RETURNS TRIGGER AS $$
DECLARE
    v_secuencia INTEGER;
    v_anio VARCHAR(4);
BEGIN
    v_anio := EXTRACT(YEAR FROM CURRENT_DATE)::VARCHAR;

    SELECT COALESCE(MAX(CAST(SUBSTRING(NumeroExpediente FROM 5 FOR 6) AS INTEGER)), 0) + 1
    INTO v_secuencia
    FROM Solicitudes
    WHERE NumeroExpediente LIKE v_anio || '-%';

    NEW.NumeroExpediente := v_anio || '-' || LPAD(v_secuencia::VARCHAR, 6, '0');

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_solicitud_expediente
    BEFORE INSERT ON Solicitudes
    FOR EACH ROW
    WHEN (NEW.NumeroExpediente IS NULL)
    EXECUTE FUNCTION generar_numero_expediente();

-- Función para registrar historial de estados
CREATE OR REPLACE FUNCTION registrar_cambio_estado_solicitud()
RETURNS TRIGGER AS $$
BEGIN
    IF OLD.Estado IS DISTINCT FROM NEW.Estado THEN
        INSERT INTO SolicitudesHistorial (SolicitudID, EstadoAnterior, EstadoNuevo, UsuarioID, Observaciones)
        VALUES (NEW.SolicitudID, OLD.Estado, NEW.Estado, NEW.UsuarioRevisor, 'Cambio automático de estado');
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_solicitud_historial
    AFTER UPDATE ON Solicitudes
    FOR EACH ROW EXECUTE FUNCTION registrar_cambio_estado_solicitud();

-- ============================================================================
-- VISTAS ÚTILES
-- ============================================================================

-- Vista de Solicitudes Pendientes con Datos del Contribuyente
CREATE VIEW vw_solicitudes_pendientes AS
SELECT
    s.SolicitudID,
    s.NumeroExpediente,
    ts.Nombre AS TipoSolicitud,
    c.TipoDocumento || '-' || c.NumeroDocumento AS Documento,
    COALESCE(c.RazonSocial, c.Nombre || ' ' || c.Apellido) AS Contribuyente,
    s.Estado,
    s.Prioridad,
    s.FechaSolicitud,
    s.FechaSolicitud + (ts.DiasHabiles || ' days')::INTERVAL AS FechaLimite,
    u.Nombre || ' ' || u.Apellido AS Revisor
FROM Solicitudes s
INNER JOIN TiposSolicitud ts ON s.TipoSolicitudID = ts.TipoSolicitudID
INNER JOIN Contribuyentes c ON s.ContribuyenteID = c.ContribuyenteID
LEFT JOIN Usuarios u ON s.UsuarioRevisor = u.UsuarioID
WHERE s.Estado NOT IN ('APROBADO', 'RECHAZADO', 'ANULADO')
ORDER BY s.Prioridad ASC, s.FechaSolicitud ASC;

-- Vista de Resumen de Avalúos por Zona
CREATE VIEW vw_resumen_avaluos_zona AS
SELECT
    Municipio,
    Parroquia,
    UsoTerreno,
    COUNT(*) AS CantidadInmuebles,
    SUM(AreaTerreno) AS TotalAreaTerreno,
    SUM(AreaConstruccion) AS TotalAreaConstruccion,
    SUM(ValorTotal) AS ValorTotalZona,
    SUM(MontoImpuestoAnual) AS RecaudacionEstimada,
    AVG(ValorTotal) AS ValorPromedio
FROM FichaCatastral
WHERE EstadoFicha = 'ACTIVA'
GROUP BY Municipio, Parroquia, UsoTerreno
ORDER BY Municipio, Parroquia;

-- Vista de Actividad Reciente (Dashboard)
CREATE VIEW vw_actividad_reciente AS
SELECT
    BitacoraID,
    FechaHora,
    Username,
    Accion,
    Modulo,
    Tabla,
    Resultado,
    SUBSTRING(Detalles FROM 1 FOR 100) AS DetalleCorto
FROM BitacoraGlobal
ORDER BY FechaHora DESC
LIMIT 100;

-- ============================================================================
-- PERMISOS DE BASE DE DATOS
-- ============================================================================

-- Crear rol de aplicación (ajustar según necesidades)
-- CREATE ROLE sigiep_app LOGIN PASSWORD 'password_seguro';
-- GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public TO sigiep_app;
-- GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO sigiep_app;

-- ============================================================================
-- FIN DEL SCRIPT
-- ============================================================================
