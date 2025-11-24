-- =====================================================
-- SIGIEP - Sistema Integral de Gestión de Entes Públicos
-- Módulo Catastro
-- Script: Estructura Geográfica Correcta de Venezuela
-- Versión: 2.0
-- Fecha: 2025
-- =====================================================

-- Estructura correcta: Estado → Municipio → Parroquia → Ciudad → Sector

-- =====================================================
-- PASO 1: ELIMINAR ESTRUCTURA INCORRECTA
-- =====================================================

DROP VIEW IF EXISTS vw_ciudades_estado;
DROP VIEW IF EXISTS vw_municipios_estado;
DROP TABLE IF EXISTS Ciudades CASCADE;
DROP TABLE IF EXISTS Sectores CASCADE;

-- =====================================================
-- PASO 2: CREAR ESTRUCTURA CORRECTA
-- =====================================================

-- Tabla de Municipios (división administrativa dentro del Estado)
CREATE TABLE IF NOT EXISTS Municipios (
    MunicipioID     SERIAL PRIMARY KEY,
    EstadoID        INTEGER NOT NULL REFERENCES Estados(EstadoID),
    Nombre          VARCHAR(200) NOT NULL,
    CodigoMunicipio VARCHAR(10),
    Activo          BOOLEAN DEFAULT TRUE,
    UNIQUE(EstadoID, Nombre)
);

-- Tabla de Parroquias (división administrativa dentro del Municipio)
CREATE TABLE IF NOT EXISTS Parroquias (
    ParroquiaID     SERIAL PRIMARY KEY,
    MunicipioID     INTEGER NOT NULL REFERENCES Municipios(MunicipioID),
    Nombre          VARCHAR(200) NOT NULL,
    EsCapital       BOOLEAN DEFAULT FALSE,
    Activo          BOOLEAN DEFAULT TRUE,
    UNIQUE(MunicipioID, Nombre)
);

-- Tabla de Ciudades (centros poblados dentro de la Parroquia)
CREATE TABLE IF NOT EXISTS Ciudades (
    CiudadID        SERIAL PRIMARY KEY,
    ParroquiaID     INTEGER NOT NULL REFERENCES Parroquias(ParroquiaID),
    Nombre          VARCHAR(200) NOT NULL,
    EsCapital       BOOLEAN DEFAULT FALSE,
    CodigoPostal    VARCHAR(10),
    Activo          BOOLEAN DEFAULT TRUE,
    UNIQUE(ParroquiaID, Nombre)
);

-- Tabla de Sectores (barrios/urbanizaciones dentro de la Ciudad)
CREATE TABLE IF NOT EXISTS Sectores (
    SectorID        SERIAL PRIMARY KEY,
    CiudadID        INTEGER NOT NULL REFERENCES Ciudades(CiudadID),
    Nombre          VARCHAR(200) NOT NULL,
    Tipo            VARCHAR(50), -- URBANIZACION, BARRIO, SECTOR, CASERIO
    Activo          BOOLEAN DEFAULT TRUE,
    UNIQUE(CiudadID, Nombre)
);

-- Índices para mejor rendimiento
CREATE INDEX IF NOT EXISTS idx_municipios_estado ON Municipios(EstadoID);
CREATE INDEX IF NOT EXISTS idx_parroquias_municipio ON Parroquias(MunicipioID);
CREATE INDEX IF NOT EXISTS idx_ciudades_parroquia ON Ciudades(ParroquiaID);
CREATE INDEX IF NOT EXISTS idx_sectores_ciudad ON Sectores(CiudadID);

-- =====================================================
-- PASO 3: DATOS DE ANZOÁTEGUI (EstadoID = 2)
-- =====================================================

-- Municipios del Estado Anzoátegui
INSERT INTO Municipios (MunicipioID, EstadoID, Nombre, CodigoMunicipio) VALUES
(1, 2, 'Anaco', 'ANZ-01'),
(2, 2, 'Aragua', 'ANZ-02'),
(3, 2, 'Diego Bautista Urbaneja', 'ANZ-03'),
(4, 2, 'Fernando de Peñalver', 'ANZ-04'),
(5, 2, 'Francisco del Carmen Carvajal', 'ANZ-05'),
(6, 2, 'Francisco de Miranda', 'ANZ-06'),
(7, 2, 'Guanta', 'ANZ-07'),
(8, 2, 'Independencia', 'ANZ-08'),
(9, 2, 'Juan Antonio Sotillo', 'ANZ-09'),
(10, 2, 'Juan Manuel Cajigal', 'ANZ-10'),
(11, 2, 'José Gregorio Monagas', 'ANZ-11'),
(12, 2, 'Libertad', 'ANZ-12'),
(13, 2, 'Manuel Ezequiel Bruzual', 'ANZ-13'),
(14, 2, 'Pedro María Freites', 'ANZ-14'),
(15, 2, 'Píritu', 'ANZ-15'),
(16, 2, 'San José de Guanipa', 'ANZ-16'),
(17, 2, 'San Juan de Capistrano', 'ANZ-17'),
(18, 2, 'Santa Ana', 'ANZ-18'),
(19, 2, 'Simón Bolívar', 'ANZ-19'),
(20, 2, 'Simón Rodríguez', 'ANZ-20'),
(21, 2, 'Sir Arthur McGregor', 'ANZ-21')
ON CONFLICT (EstadoID, Nombre) DO NOTHING;

-- Resetear secuencia
SELECT setval('municipios_municipioid_seq', (SELECT COALESCE(MAX(MunicipioID), 0) FROM Municipios));

-- =====================================================
-- PASO 4: PARROQUIAS DE SIMÓN RODRÍGUEZ (MunicipioID = 20)
-- =====================================================

INSERT INTO Parroquias (ParroquiaID, MunicipioID, Nombre, EsCapital) VALUES
-- Parroquias del Municipio Simón Rodríguez
(1, 20, 'El Tigre', TRUE),
(2, 20, 'Edmundo Barrios', FALSE),
(3, 20, 'Miguel Otero Silva', FALSE)
ON CONFLICT (MunicipioID, Nombre) DO NOTHING;

-- Parroquias de otros municipios importantes
INSERT INTO Parroquias (ParroquiaID, MunicipioID, Nombre, EsCapital) VALUES
-- Barcelona (Simón Bolívar - MunicipioID = 19)
(4, 19, 'Barcelona', TRUE),
(5, 19, 'San Cristóbal', FALSE),
-- Puerto La Cruz (Juan Antonio Sotillo - MunicipioID = 9)
(6, 9, 'Puerto La Cruz', TRUE),
(7, 9, 'Pozuelos', FALSE)
ON CONFLICT (MunicipioID, Nombre) DO NOTHING;

SELECT setval('parroquias_parroquiaid_seq', (SELECT COALESCE(MAX(ParroquiaID), 0) FROM Parroquias));

-- =====================================================
-- PASO 5: CIUDADES DEL MUNICIPIO SIMÓN RODRÍGUEZ
-- =====================================================

INSERT INTO Ciudades (CiudadID, ParroquiaID, Nombre, EsCapital, CodigoPostal) VALUES
-- Ciudades de El Tigre (ParroquiaID = 1)
(1, 1, 'El Tigre', TRUE, '6050'),
(2, 1, 'San Tomé', FALSE, '6051'),
-- Ciudades de Edmundo Barrios (ParroquiaID = 2)
(3, 2, 'El Tigrito', FALSE, '6052'),
-- Ciudades de Miguel Otero Silva (ParroquiaID = 3)
(4, 3, 'Oficina', FALSE, '6053')
ON CONFLICT (ParroquiaID, Nombre) DO NOTHING;

-- Ciudades de otros municipios
INSERT INTO Ciudades (CiudadID, ParroquiaID, Nombre, EsCapital, CodigoPostal) VALUES
-- Barcelona
(5, 4, 'Barcelona', TRUE, '6001'),
-- Puerto La Cruz
(6, 6, 'Puerto La Cruz', TRUE, '6023')
ON CONFLICT (ParroquiaID, Nombre) DO NOTHING;

SELECT setval('ciudades_ciudadid_seq', (SELECT COALESCE(MAX(CiudadID), 0) FROM Ciudades));

-- =====================================================
-- PASO 6: SECTORES DE EL TIGRE
-- =====================================================

INSERT INTO Sectores (SectorID, CiudadID, Nombre, Tipo) VALUES
-- Sectores de El Tigre (CiudadID = 1)
(1, 1, 'Centro', 'SECTOR'),
(2, 1, 'Pueblo Nuevo Norte', 'BARRIO'),
(3, 1, 'Pueblo Nuevo Sur', 'BARRIO'),
(4, 1, 'Campo Sur', 'URBANIZACION'),
(5, 1, 'El Country', 'URBANIZACION'),
(6, 1, 'San Rafael', 'URBANIZACION'),
(7, 1, 'Barrio Obrero', 'BARRIO'),
(8, 1, 'La Florida', 'URBANIZACION'),
(9, 1, 'Las Garzas', 'URBANIZACION'),
(10, 1, 'Guaraguao', 'BARRIO')
ON CONFLICT (CiudadID, Nombre) DO NOTHING;

SELECT setval('sectores_sectorid_seq', (SELECT COALESCE(MAX(SectorID), 0) FROM Sectores));

-- =====================================================
-- PASO 7: ACTUALIZAR CONFIGURACIÓN
-- =====================================================

-- Fijar Estado Anzoátegui y Municipio Simón Rodríguez
UPDATE Configuracion SET Valor = '2' WHERE Clave = 'ESTADO_FIJO';
UPDATE Configuracion SET Valor = '20' WHERE Clave = 'CIUDAD_FIJA'; -- Usar para MunicipioID

-- Agregar nuevas configuraciones
INSERT INTO Configuracion (Clave, Valor, Descripcion, Tipo) VALUES
('MUNICIPIO_FIJO', '20', 'ID del Municipio fijo (Simón Rodríguez)', 'NUMBER'),
('PARROQUIA_FIJA', '', 'ID de la Parroquia fija (vacío = todas)', 'NUMBER'),
('CIUDAD_FIJA_ID', '', 'ID de la Ciudad fija (vacío = todas)', 'NUMBER'),
('MOSTRAR_SELECTOR_ESTADO', 'FALSE', 'Mostrar selector de Estado (FALSE si está fijo)', 'BOOLEAN'),
('MOSTRAR_SELECTOR_MUNICIPIO', 'FALSE', 'Mostrar selector de Municipio (FALSE si está fijo)', 'BOOLEAN')
ON CONFLICT (Clave) DO UPDATE SET Valor = EXCLUDED.Valor;

-- =====================================================
-- PASO 8: VISTAS ÚTILES
-- =====================================================

-- Vista completa de ubicaciones
CREATE OR REPLACE VIEW vw_ubicacion_completa AS
SELECT
    e.EstadoID,
    e.Nombre AS Estado,
    m.MunicipioID,
    m.Nombre AS Municipio,
    p.ParroquiaID,
    p.Nombre AS Parroquia,
    c.CiudadID,
    c.Nombre AS Ciudad,
    c.CodigoPostal,
    s.SectorID,
    s.Nombre AS Sector,
    s.Tipo AS TipoSector
FROM Estados e
INNER JOIN Municipios m ON e.EstadoID = m.EstadoID
INNER JOIN Parroquias p ON m.MunicipioID = p.MunicipioID
INNER JOIN Ciudades c ON p.ParroquiaID = c.ParroquiaID
LEFT JOIN Sectores s ON c.CiudadID = s.CiudadID
WHERE e.Activo = TRUE
  AND m.Activo = TRUE
  AND p.Activo = TRUE
  AND c.Activo = TRUE
  AND (s.Activo = TRUE OR s.SectorID IS NULL)
ORDER BY e.Nombre, m.Nombre, p.Nombre, c.Nombre, s.Nombre;

-- =====================================================
-- PASO 9: ACTUALIZAR TABLA CONTRIBUYENTES
-- =====================================================

-- Agregar columnas de ID para ubicación
ALTER TABLE Contribuyentes ADD COLUMN IF NOT EXISTS EstadoID INTEGER REFERENCES Estados(EstadoID);
ALTER TABLE Contribuyentes ADD COLUMN IF NOT EXISTS MunicipioID INTEGER REFERENCES Municipios(MunicipioID);
ALTER TABLE Contribuyentes ADD COLUMN IF NOT EXISTS ParroquiaID INTEGER REFERENCES Parroquias(ParroquiaID);
ALTER TABLE Contribuyentes ADD COLUMN IF NOT EXISTS CiudadID INTEGER REFERENCES Ciudades(CiudadID);
ALTER TABLE Contribuyentes ADD COLUMN IF NOT EXISTS SectorID INTEGER REFERENCES Sectores(SectorID);

-- Crear índices
CREATE INDEX IF NOT EXISTS idx_contribuyentes_estado ON Contribuyentes(EstadoID);
CREATE INDEX IF NOT EXISTS idx_contribuyentes_municipio ON Contribuyentes(MunicipioID);
CREATE INDEX IF NOT EXISTS idx_contribuyentes_ciudad ON Contribuyentes(CiudadID);

-- Mensaje de confirmación
DO $$
BEGIN
    RAISE NOTICE 'Estructura geográfica correcta creada:';
    RAISE NOTICE '  Estado → Municipio → Parroquia → Ciudad → Sector';
    RAISE NOTICE 'Estado fijo: Anzoátegui (ID=2)';
    RAISE NOTICE 'Municipio fijo: Simón Rodríguez (ID=20)';
END $$;
