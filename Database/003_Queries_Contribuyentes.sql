-- =====================================================
-- SIGIEP - Sistema Integral de Gestión de Entes Públicos
-- Módulo Catastro
-- Script: Queries para Contribuyentes
-- Versión: 1.0
-- Fecha: 2024
-- =====================================================

-- =====================================================
-- CONSULTAS DE LISTADO
-- =====================================================

-- Listado general de contribuyentes
SELECT
    ContribuyenteID,
    RIF,
    Cedula,
    TipoPersona,
    CASE
        WHEN TipoPersona = 'JURIDICA' THEN RazonSocial
        ELSE Nombre || ' ' || Apellido
    END AS NombreCompleto,
    Celular,
    Telefono,
    Email,
    Activo
FROM Contribuyentes
ORDER BY NombreCompleto
LIMIT 500;

-- Búsqueda por RIF
SELECT
    ContribuyenteID, RIF, Cedula, TipoPersona,
    CASE WHEN TipoPersona = 'JURIDICA' THEN RazonSocial
         ELSE Nombre || ' ' || Apellido END AS NombreCompleto,
    Celular, Telefono, Email, Activo
FROM Contribuyentes
WHERE RIF ILIKE '%V12345678%'
ORDER BY NombreCompleto;

-- Búsqueda por Cédula
SELECT
    ContribuyenteID, RIF, Cedula, TipoPersona,
    CASE WHEN TipoPersona = 'JURIDICA' THEN RazonSocial
         ELSE Nombre || ' ' || Apellido END AS NombreCompleto,
    Celular, Telefono, Email, Activo
FROM Contribuyentes
WHERE Cedula ILIKE '%12345678%'
ORDER BY NombreCompleto;

-- Búsqueda por Nombre/Razón Social
SELECT
    ContribuyenteID, RIF, Cedula, TipoPersona,
    CASE WHEN TipoPersona = 'JURIDICA' THEN RazonSocial
         ELSE Nombre || ' ' || Apellido END AS NombreCompleto,
    Celular, Telefono, Email, Activo
FROM Contribuyentes
WHERE (Nombre ILIKE '%Juan%' OR Apellido ILIKE '%Juan%' OR RazonSocial ILIKE '%Juan%')
ORDER BY NombreCompleto;

-- =====================================================
-- CONSULTA DETALLE
-- =====================================================

-- Obtener contribuyente por ID
SELECT * FROM Contribuyentes WHERE ContribuyenteID = :ID;

-- =====================================================
-- INSERCIÓN
-- =====================================================

-- Insertar nuevo contribuyente (Persona Natural)
INSERT INTO Contribuyentes (
    RIF, Cedula, TipoPersona, Nombre, Apellido, RazonSocial,
    Telefono, Celular, Email, Direccion, Estado, Municipio,
    Parroquia, CodigoPostal, Activo, UsuarioCreacion
)
VALUES (
    'V123456789',           -- RIF
    '12345678',             -- Cedula
    'NATURAL',              -- TipoPersona
    'Juan',                 -- Nombre
    'Pérez',                -- Apellido
    NULL,                   -- RazonSocial (NULL para personas naturales)
    '0212-1234567',         -- Telefono
    '0414-1234567',         -- Celular
    'juan.perez@email.com', -- Email
    'Av. Principal, Edificio Centro, Piso 3, Oficina 301', -- Direccion
    'Miranda',              -- Estado
    'Baruta',               -- Municipio
    'El Cafetal',           -- Parroquia
    '1080',                 -- CodigoPostal
    TRUE,                   -- Activo
    1                       -- UsuarioCreacion (ID del usuario)
)
RETURNING ContribuyenteID;

-- Insertar nuevo contribuyente (Persona Jurídica)
INSERT INTO Contribuyentes (
    RIF, Cedula, TipoPersona, Nombre, Apellido, RazonSocial,
    Telefono, Celular, Email, Direccion, Estado, Municipio,
    Parroquia, CodigoPostal, Activo, UsuarioCreacion
)
VALUES (
    'J123456789',           -- RIF
    NULL,                   -- Cedula (NULL para jurídicas)
    'JURIDICA',             -- TipoPersona
    NULL,                   -- Nombre (NULL para jurídicas)
    NULL,                   -- Apellido (NULL para jurídicas)
    'Empresa ABC, C.A.',    -- RazonSocial
    '0212-9876543',         -- Telefono
    '0424-9876543',         -- Celular
    'info@empresaabc.com',  -- Email
    'Zona Industrial, Galpón 15', -- Direccion
    'Carabobo',             -- Estado
    'Valencia',             -- Municipio
    'San José',             -- Parroquia
    '2001',                 -- CodigoPostal
    TRUE,                   -- Activo
    1                       -- UsuarioCreacion
)
RETURNING ContribuyenteID;

-- =====================================================
-- ACTUALIZACIÓN
-- =====================================================

-- Actualizar contribuyente
UPDATE Contribuyentes SET
    RIF = :RIF,
    Cedula = :Cedula,
    TipoPersona = :TipoPersona,
    Nombre = :Nombre,
    Apellido = :Apellido,
    RazonSocial = :RazonSocial,
    Telefono = :Telefono,
    Celular = :Celular,
    Email = :Email,
    Direccion = :Direccion,
    Estado = :Estado,
    Municipio = :Municipio,
    Parroquia = :Parroquia,
    CodigoPostal = :CodigoPostal,
    Activo = :Activo,
    UsuarioModificacion = :UsuarioModificacion,
    FechaModificacion = CURRENT_TIMESTAMP
WHERE ContribuyenteID = :ContribuyenteID;

-- =====================================================
-- ELIMINACIÓN (LÓGICA)
-- =====================================================

-- Desactivar contribuyente (eliminación lógica)
UPDATE Contribuyentes
SET Activo = FALSE,
    UsuarioModificacion = :UsuarioID,
    FechaModificacion = CURRENT_TIMESTAMP
WHERE ContribuyenteID = :ContribuyenteID;

-- =====================================================
-- CONSULTAS RELACIONADAS
-- =====================================================

-- Fichas catastrales de un contribuyente
SELECT
    f.FichaID,
    f.CodigoCatastral,
    f.Estado,
    f.Municipio,
    f.Parroquia,
    f.Direccion,
    f.ValorTotal,
    f.MontoImpuestoAnual,
    f.EstadoFicha,
    f.FechaCreacion
FROM FichaCatastral f
WHERE f.ContribuyenteID = :ContribuyenteID
ORDER BY f.FechaCreacion DESC;

-- Solicitudes de un contribuyente
SELECT
    s.SolicitudID,
    s.NumeroExpediente,
    ts.Nombre AS TipoSolicitud,
    s.Estado,
    s.FechaSolicitud,
    s.Prioridad,
    s.Observaciones
FROM Solicitudes s
INNER JOIN TiposSolicitud ts ON s.TipoSolicitudID = ts.TipoSolicitudID
WHERE s.ContribuyenteID = :ContribuyenteID
ORDER BY s.FechaSolicitud DESC;

-- =====================================================
-- ESTADÍSTICAS
-- =====================================================

-- Contar contribuyentes por tipo
SELECT
    TipoPersona,
    COUNT(*) AS Total
FROM Contribuyentes
WHERE Activo = TRUE
GROUP BY TipoPersona;

-- Contribuyentes por estado
SELECT
    Estado,
    COUNT(*) AS Total
FROM Contribuyentes
WHERE Activo = TRUE
GROUP BY Estado
ORDER BY Total DESC;

-- Total de propiedades y monto por contribuyente
SELECT
    c.ContribuyenteID,
    CASE WHEN c.TipoPersona = 'JURIDICA' THEN c.RazonSocial
         ELSE c.Nombre || ' ' || c.Apellido END AS Contribuyente,
    c.RIF,
    COUNT(f.FichaID) AS TotalFichas,
    COALESCE(SUM(f.ValorTotal), 0) AS ValorTotalPropiedades,
    COALESCE(SUM(f.MontoImpuestoAnual), 0) AS TotalImpuestoAnual
FROM Contribuyentes c
LEFT JOIN FichaCatastral f ON c.ContribuyenteID = f.ContribuyenteID AND f.EstadoFicha = 'ACTIVA'
WHERE c.Activo = TRUE
GROUP BY c.ContribuyenteID, c.TipoPersona, c.RazonSocial, c.Nombre, c.Apellido, c.RIF
ORDER BY TotalImpuestoAnual DESC;

-- =====================================================
-- VALIDACIONES
-- =====================================================

-- Verificar RIF duplicado (antes de insertar)
SELECT COUNT(*) AS Existe
FROM Contribuyentes
WHERE RIF = :RIF AND ContribuyenteID != COALESCE(:ContribuyenteID, 0);

-- Verificar Cédula duplicada (antes de insertar)
SELECT COUNT(*) AS Existe
FROM Contribuyentes
WHERE Cedula = :Cedula AND Cedula IS NOT NULL AND ContribuyenteID != COALESCE(:ContribuyenteID, 0);

-- =====================================================
-- DATOS DE EJEMPLO
-- =====================================================

-- Insertar contribuyentes de ejemplo
INSERT INTO Contribuyentes (RIF, Cedula, TipoPersona, Nombre, Apellido, Telefono, Celular, Email, Direccion, Estado, Municipio, Parroquia, Activo, UsuarioCreacion)
VALUES
('V12345678', '12345678', 'NATURAL', 'María', 'González', '0212-5551234', '0414-5551234', 'maria.gonzalez@email.com', 'Calle 10, Casa 25, Urbanización Los Pinos', 'Miranda', 'Chacao', 'Chacao', TRUE, 1),
('V23456789', '23456789', 'NATURAL', 'Carlos', 'Rodríguez', '0212-5552345', '0424-5552345', 'carlos.rodriguez@email.com', 'Av. Principal, Residencias El Sol, Apto 4-B', 'Miranda', 'Baruta', 'El Cafetal', TRUE, 1),
('J30123456', NULL, 'JURIDICA', NULL, NULL, '0212-5553456', '0412-5553456', 'contacto@comercialabc.com', 'Zona Industrial, Galpón 7', 'Carabobo', 'Valencia', 'San José', TRUE, 1);

-- =====================================================
-- NOTAS DE IMPLEMENTACIÓN
-- =====================================================

/*
CAMPOS PRINCIPALES DE CONTRIBUYENTES:
- ContribuyenteID: ID único autoincremental
- RIF: Registro de Información Fiscal (requerido)
- Cedula: Cédula de identidad (para personas naturales)
- TipoPersona: 'NATURAL' o 'JURIDICA'
- Nombre: Primer nombre (personas naturales)
- Apellido: Apellido (personas naturales)
- RazonSocial: Nombre de la empresa (personas jurídicas)
- Telefono: Teléfono fijo
- Celular: Teléfono móvil
- Email: Correo electrónico
- Direccion: Dirección completa
- Estado: Estado del domicilio
- Municipio: Municipio del domicilio
- Parroquia: Parroquia del domicilio
- CodigoPostal: Código postal
- Activo: Estado del registro (TRUE/FALSE)
- FechaRegistro: Fecha de creación
- UsuarioCreacion: ID del usuario que creó
- FechaModificacion: Fecha de última modificación
- UsuarioModificacion: ID del usuario que modificó
*/
