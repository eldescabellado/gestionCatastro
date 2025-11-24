-- =====================================================
-- SIGIEP - Sistema Integral de Gestión de Entes Públicos
-- Módulo Catastro
-- Script: Corrección de estructura Venezuela
-- Versión: 1.1
-- Fecha: 2025
-- =====================================================

-- PROBLEMA: La tabla Municipios contiene ciudades, no municipios administrativos
-- SOLUCIÓN: Renombrar a Ciudades para reflejar correctamente los datos

-- Paso 1: Eliminar la vista existente
DROP VIEW IF EXISTS vw_municipios_estado;

-- Paso 2: Renombrar tabla Municipios a Ciudades
ALTER TABLE IF EXISTS Municipios RENAME TO Ciudades;

-- Paso 3: Renombrar columnas para consistencia
ALTER TABLE IF EXISTS Ciudades RENAME COLUMN MunicipioID TO CiudadID;

-- Paso 4: Renombrar secuencia si existe
ALTER SEQUENCE IF EXISTS municipios_municipioid_seq RENAME TO ciudades_ciudadid_seq;

-- Paso 5: Renombrar índices
ALTER INDEX IF EXISTS idx_municipios_estado RENAME TO idx_ciudades_estado;
ALTER INDEX IF EXISTS idx_municipios_nombre RENAME TO idx_ciudades_nombre;

-- Paso 6: Crear vista actualizada
CREATE OR REPLACE VIEW vw_ciudades_estado AS
SELECT
    c.CiudadID,
    c.Nombre AS Ciudad,
    e.Nombre AS Estado,
    c.EsCapital
FROM Ciudades c
INNER JOIN Estados e ON c.EstadoID = e.EstadoID
WHERE c.Activo = TRUE AND e.Activo = TRUE
ORDER BY e.Nombre, c.Nombre;

-- =====================================================
-- TABLA DE CONFIGURACIÓN DEL SISTEMA
-- =====================================================

-- Crear tabla de configuración si no existe
CREATE TABLE IF NOT EXISTS Configuracion (
    ConfiguracionID SERIAL PRIMARY KEY,
    Clave           VARCHAR(100) NOT NULL UNIQUE,
    Valor           VARCHAR(500),
    Descripcion     VARCHAR(500),
    Tipo            VARCHAR(50) DEFAULT 'TEXT', -- TEXT, NUMBER, BOOLEAN, SELECT
    Opciones        TEXT, -- Para tipo SELECT: opciones separadas por |
    Activo          BOOLEAN DEFAULT TRUE,
    FechaCreacion   TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FechaModificacion TIMESTAMP
);

-- Insertar configuraciones por defecto
INSERT INTO Configuracion (Clave, Valor, Descripcion, Tipo) VALUES
('ESTADO_FIJO', '', 'Estado fijo para el sistema (vacío = todos los estados)', 'SELECT'),
('CIUDAD_FIJA', '', 'Ciudad fija para el sistema (vacío = todas las ciudades)', 'SELECT'),
('FILTRAR_POR_UBICACION', 'FALSE', 'Si es TRUE, solo muestra datos de la ubicación configurada', 'BOOLEAN'),
('NOMBRE_ENTE', 'Alcaldía Municipal', 'Nombre del ente público', 'TEXT'),
('RIF_ENTE', '', 'RIF del ente público', 'TEXT'),
('DIRECCION_ENTE', '', 'Dirección del ente público', 'TEXT'),
('TELEFONO_ENTE', '', 'Teléfono del ente público', 'TEXT')
ON CONFLICT (Clave) DO NOTHING;

-- Mensaje de confirmación
DO $$
BEGIN
    RAISE NOTICE 'Estructura de Venezuela corregida: Municipios -> Ciudades';
    RAISE NOTICE 'Tabla de Configuración creada con parámetros de ubicación';
END $$;
