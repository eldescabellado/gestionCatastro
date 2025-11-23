-- =====================================================
-- SIGIEP - Sistema Integral de Gestión de Entes Públicos
-- Módulo Catastro
-- Script: ALTER TABLE para Contribuyentes
-- Versión: 1.2
-- Fecha: 2025
-- =====================================================

-- Este script agrega campos adicionales a la tabla Contribuyentes
-- para compatibilidad con el formulario de gestión

-- Agregar campo Cedula (separado del NumeroDocumento)
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns
        WHERE table_name = 'contribuyentes' AND column_name = 'cedula'
    ) THEN
        ALTER TABLE Contribuyentes ADD COLUMN Cedula VARCHAR(20);
        COMMENT ON COLUMN Contribuyentes.Cedula IS 'Número de cédula de identidad';
    END IF;
END $$;

-- Agregar campo TipoPersona (NATURAL/JURIDICA)
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns
        WHERE table_name = 'contribuyentes' AND column_name = 'tipopersona'
    ) THEN
        ALTER TABLE Contribuyentes ADD COLUMN TipoPersona VARCHAR(20) DEFAULT 'NATURAL';
        ALTER TABLE Contribuyentes ADD CONSTRAINT chk_tipo_persona
            CHECK (TipoPersona IN ('NATURAL', 'JURIDICA'));
        COMMENT ON COLUMN Contribuyentes.TipoPersona IS 'Tipo de persona: NATURAL o JURIDICA';
    END IF;
END $$;

-- Agregar campo Telefono (alias para TelefonoLocal)
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns
        WHERE table_name = 'contribuyentes' AND column_name = 'telefono'
    ) THEN
        ALTER TABLE Contribuyentes ADD COLUMN Telefono VARCHAR(20);
        COMMENT ON COLUMN Contribuyentes.Telefono IS 'Número de teléfono fijo';
    END IF;
END $$;

-- Agregar campo Celular
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns
        WHERE table_name = 'contribuyentes' AND column_name = 'celular'
    ) THEN
        ALTER TABLE Contribuyentes ADD COLUMN Celular VARCHAR(20);
        COMMENT ON COLUMN Contribuyentes.Celular IS 'Número de teléfono celular';
    END IF;
END $$;

-- Agregar campo Direccion (simplificado)
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns
        WHERE table_name = 'contribuyentes' AND column_name = 'direccion'
    ) THEN
        ALTER TABLE Contribuyentes ADD COLUMN Direccion TEXT;
        COMMENT ON COLUMN Contribuyentes.Direccion IS 'Dirección completa del contribuyente';
    END IF;
END $$;

-- Agregar campo CodigoPostal si no existe
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns
        WHERE table_name = 'contribuyentes' AND column_name = 'codigopostal'
    ) THEN
        ALTER TABLE Contribuyentes ADD COLUMN CodigoPostal VARCHAR(10);
        COMMENT ON COLUMN Contribuyentes.CodigoPostal IS 'Código postal del domicilio';
    END IF;
END $$;

-- Crear índices para mejorar búsquedas
CREATE INDEX IF NOT EXISTS idx_contribuyentes_cedula ON Contribuyentes(Cedula);
CREATE INDEX IF NOT EXISTS idx_contribuyentes_celular ON Contribuyentes(Celular);
CREATE INDEX IF NOT EXISTS idx_contribuyentes_tipopersona ON Contribuyentes(TipoPersona);

-- Actualizar datos existentes para mapear TipoDocumento a TipoPersona
UPDATE Contribuyentes
SET TipoPersona = CASE
    WHEN TipoDocumento = 'J' THEN 'JURIDICA'
    ELSE 'NATURAL'
END
WHERE TipoPersona IS NULL;

-- Copiar NumeroDocumento a Cedula para personas naturales
UPDATE Contribuyentes
SET Cedula = NumeroDocumento
WHERE Cedula IS NULL AND TipoDocumento IN ('V', 'E');

-- Copiar TelefonoLocal a Telefono si existe
DO $$
BEGIN
    IF EXISTS (
        SELECT 1 FROM information_schema.columns
        WHERE table_name = 'contribuyentes' AND column_name = 'telefonolocal'
    ) THEN
        UPDATE Contribuyentes SET Telefono = TelefonoLocal WHERE Telefono IS NULL;
    END IF;
END $$;

-- Copiar TelefonoMovil a Celular si existe
DO $$
BEGIN
    IF EXISTS (
        SELECT 1 FROM information_schema.columns
        WHERE table_name = 'contribuyentes' AND column_name = 'telefonomovil'
    ) THEN
        UPDATE Contribuyentes SET Celular = TelefonoMovil WHERE Celular IS NULL;
    END IF;
END $$;

-- Copiar DireccionFiscal a Direccion si existe
DO $$
BEGIN
    IF EXISTS (
        SELECT 1 FROM information_schema.columns
        WHERE table_name = 'contribuyentes' AND column_name = 'direccionfiscal'
    ) THEN
        UPDATE Contribuyentes SET Direccion = DireccionFiscal WHERE Direccion IS NULL;
    END IF;
END $$;

-- Mensaje de confirmación
DO $$
BEGIN
    RAISE NOTICE 'ALTER TABLE Contribuyentes completado exitosamente - Columnas Cedula, TipoPersona, Telefono, Celular, Direccion agregadas';
END $$;
