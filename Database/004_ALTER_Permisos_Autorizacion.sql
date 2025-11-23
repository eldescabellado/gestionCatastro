-- =====================================================
-- SIGIEP - Sistema Integral de Gestión de Entes Públicos
-- Módulo Catastro
-- Script: ALTER TABLE para Permisos de Autorización
-- Versión: 1.0
-- Fecha: 2025
-- =====================================================

-- Este script agrega el permiso para autorizar aprobación de carta catastral

-- Insertar nuevo permiso de autorización de carta catastral
INSERT INTO Permisos (Codigo, Nombre, Descripcion, Modulo, RequiereAutorizacionRemota, Activo)
SELECT 'AUTORIZA_CARTA_CATASTRAL',
       'Autoriza Aprobación Carta Catastral',
       'Permite autorizar la aprobación de cartas catastrales y cédulas catastrales. Este permiso debe asignarse a usuarios supervisores o gerenciales.',
       'CATASTRO',
       FALSE,
       TRUE
WHERE NOT EXISTS (
    SELECT 1 FROM Permisos WHERE Codigo = 'AUTORIZA_CARTA_CATASTRAL'
);

-- Asignar el permiso al rol SUPERADMIN si no está asignado
INSERT INTO RolesPermisos (RolID, PermisoID)
SELECT
    (SELECT RolID FROM Roles WHERE Nombre = 'SUPERADMIN'),
    (SELECT PermisoID FROM Permisos WHERE Codigo = 'AUTORIZA_CARTA_CATASTRAL')
WHERE NOT EXISTS (
    SELECT 1 FROM RolesPermisos rp
    INNER JOIN Roles r ON rp.RolID = r.RolID
    INNER JOIN Permisos p ON rp.PermisoID = p.PermisoID
    WHERE r.Nombre = 'SUPERADMIN' AND p.Codigo = 'AUTORIZA_CARTA_CATASTRAL'
);

-- Asignar el permiso al rol SUPERVISOR si no está asignado
INSERT INTO RolesPermisos (RolID, PermisoID)
SELECT
    (SELECT RolID FROM Roles WHERE Nombre = 'SUPERVISOR'),
    (SELECT PermisoID FROM Permisos WHERE Codigo = 'AUTORIZA_CARTA_CATASTRAL')
WHERE NOT EXISTS (
    SELECT 1 FROM RolesPermisos rp
    INNER JOIN Roles r ON rp.RolID = r.RolID
    INNER JOIN Permisos p ON rp.PermisoID = p.PermisoID
    WHERE r.Nombre = 'SUPERVISOR' AND p.Codigo = 'AUTORIZA_CARTA_CATASTRAL'
);

-- Asignar el permiso al rol ADMINISTRADOR si no está asignado
INSERT INTO RolesPermisos (RolID, PermisoID)
SELECT
    (SELECT RolID FROM Roles WHERE Nombre = 'ADMINISTRADOR'),
    (SELECT PermisoID FROM Permisos WHERE Codigo = 'AUTORIZA_CARTA_CATASTRAL')
WHERE NOT EXISTS (
    SELECT 1 FROM RolesPermisos rp
    INNER JOIN Roles r ON rp.RolID = r.RolID
    INNER JOIN Permisos p ON rp.PermisoID = p.PermisoID
    WHERE r.Nombre = 'ADMINISTRADOR' AND p.Codigo = 'AUTORIZA_CARTA_CATASTRAL'
);

-- También asegurar que exista el permiso SOLIC_APROBAR
INSERT INTO Permisos (Codigo, Nombre, Descripcion, Modulo, RequiereAutorizacionRemota, Activo)
SELECT 'SOLIC_APROBAR',
       'Aprobar Solicitudes',
       'Permite aprobar o rechazar solicitudes de catastro',
       'SOLICITUDES',
       TRUE,
       TRUE
WHERE NOT EXISTS (
    SELECT 1 FROM Permisos WHERE Codigo = 'SOLIC_APROBAR'
);

-- Mensaje de confirmación
DO $$
BEGIN
    RAISE NOTICE 'Permisos de autorización agregados exitosamente';
END $$;

-- =====================================================
-- CONSULTAS ÚTILES
-- =====================================================

-- Ver usuarios con permiso de autorización
-- SELECT u.Username, u.Nombre || ' ' || u.Apellido AS NombreCompleto, r.Nombre AS Rol
-- FROM Usuarios u
-- INNER JOIN Roles r ON u.RolID = r.RolID
-- LEFT JOIN RolesPermisos rp ON r.RolID = rp.RolID
-- LEFT JOIN Permisos p ON rp.PermisoID = p.PermisoID
-- WHERE r.EsSuperUsuario = TRUE
--    OR p.Codigo IN ('AUTORIZA_CARTA_CATASTRAL', 'SOLIC_APROBAR')
-- GROUP BY u.UsuarioID, u.Username, u.Nombre, u.Apellido, r.Nombre;

-- Asignar permiso a un usuario específico (por rol)
-- UPDATE para asignar al rol del usuario
-- INSERT INTO RolesPermisos (RolID, PermisoID)
-- VALUES (
--     (SELECT RolID FROM Usuarios WHERE Username = 'nombre_usuario'),
--     (SELECT PermisoID FROM Permisos WHERE Codigo = 'AUTORIZA_CARTA_CATASTRAL')
-- );
