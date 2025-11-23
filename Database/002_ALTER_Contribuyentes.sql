-- =====================================================
-- SIGIEP - Sistema Integral de Gestión de Entes Públicos
-- Módulo Catastro
-- Script: ALTER TABLE para Contribuyentes
-- Versión: 1.1
-- Fecha: 2024
-- =====================================================

-- Este script agrega campos adicionales a la tabla Contribuyentes
-- si no existen en la estructura original

-- Verificar y agregar campo Celular si no existe
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

-- Verificar y agregar campo CodigoPostal si no existe
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

-- Verificar y agregar campo Estado si no existe
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns
        WHERE table_name = 'contribuyentes' AND column_name = 'estado'
    ) THEN
        ALTER TABLE Contribuyentes ADD COLUMN Estado VARCHAR(50);
        COMMENT ON COLUMN Contribuyentes.Estado IS 'Estado del domicilio';
    END IF;
END $$;

-- Verificar y agregar campo Municipio si no existe
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns
        WHERE table_name = 'contribuyentes' AND column_name = 'municipio'
    ) THEN
        ALTER TABLE Contribuyentes ADD COLUMN Municipio VARCHAR(100);
        COMMENT ON COLUMN Contribuyentes.Municipio IS 'Municipio del domicilio';
    END IF;
END $$;

-- Verificar y agregar campo Parroquia si no existe
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns
        WHERE table_name = 'contribuyentes' AND column_name = 'parroquia'
    ) THEN
        ALTER TABLE Contribuyentes ADD COLUMN Parroquia VARCHAR(100);
        COMMENT ON COLUMN Contribuyentes.Parroquia IS 'Parroquia del domicilio';
    END IF;
END $$;

-- Crear índices para mejorar búsquedas
CREATE INDEX IF NOT EXISTS idx_contribuyentes_celular ON Contribuyentes(Celular);
CREATE INDEX IF NOT EXISTS idx_contribuyentes_estado ON Contribuyentes(Estado);
CREATE INDEX IF NOT EXISTS idx_contribuyentes_municipio ON Contribuyentes(Municipio);

-- Mensaje de confirmación
DO $$
BEGIN
    RAISE NOTICE 'ALTER TABLE Contribuyentes completado exitosamente';
END $$;
