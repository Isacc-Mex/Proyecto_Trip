-- ============================================================
--  Base de Datos: db_trip  |  Videojuego con Monetización
--  Archivo     : funciones.sql
--  Descripción : Funciones escalares para consultar métricas
--                individuales de cada usuario.
--  Requiere    : tablas usuarios, compras, transacciones,
--                partidas, divisas
-- ============================================================

USE db_trip;

-- ────────────────────────────────────────────────────────────
-- DEPENDENCIA: fn_total_gastado_usuario debe crearse PRIMERO
-- porque fn_clasificar_usuario la llama internamente.
-- ────────────────────────────────────────────────────────────

-- ------------------------------------------------------------
-- fn_total_gastado_usuario
-- Devuelve el total en MXN gastado por un usuario considerando
-- únicamente transacciones con estatus 'Aprobado'.
-- Uso: SELECT fn_total_gastado_usuario(1);
-- ------------------------------------------------------------
DROP FUNCTION IF EXISTS fn_total_gastado_usuario;
DELIMITER $$
CREATE FUNCTION fn_total_gastado_usuario(
    p_id_usuario INT
) RETURNS DECIMAL(10,2)
    READS SQL DATA
BEGIN
    DECLARE total DECIMAL(10,2) DEFAULT 0;
    SELECT COALESCE(SUM(t.monto), 0)
    INTO total
    FROM transacciones t
    JOIN compras c ON c.id_compra = t.id_compra
    WHERE c.id_usuario = p_id_usuario
      AND t.estatus = 'Aprobado';
    RETURN total;
END$$
DELIMITER ;


-- ------------------------------------------------------------
-- fn_clasificar_usuario
-- Clasifica al usuario según su gasto total en MXN:
--   >= 200  → 'Alto'
--   >= 50   → 'Medio'
--   < 50    → 'Bajo'
-- Uso: SELECT fn_clasificar_usuario(1);
-- ------------------------------------------------------------
DROP FUNCTION IF EXISTS fn_clasificar_usuario;
DELIMITER $$
CREATE FUNCTION fn_clasificar_usuario(
    p_id_usuario INT
) RETURNS VARCHAR(10) CHARSET utf8mb4
    READS SQL DATA
BEGIN
    DECLARE gasto DECIMAL(10,2);
    SET gasto = fn_total_gastado_usuario(p_id_usuario);
    RETURN CASE
        WHEN gasto >= 200 THEN 'Alto'
        WHEN gasto >=  50 THEN 'Medio'
        ELSE 'Bajo'
    END;
END$$
DELIMITER ;


-- ------------------------------------------------------------
-- fn_convertir_divisa
-- Convierte un monto en MXN a la divisa indicada usando el
-- tipo de cambio almacenado en la tabla `divisas`.
-- Uso: SELECT fn_convertir_divisa(500.00, 2);  -- → USD
-- ------------------------------------------------------------
DROP FUNCTION IF EXISTS fn_convertir_divisa;
DELIMITER $$
CREATE FUNCTION fn_convertir_divisa(
    monto_mxn   DECIMAL(10,2),
    p_id_divisa INT UNSIGNED
) RETURNS DECIMAL(10,4)
    DETERMINISTIC
BEGIN
    DECLARE tasa DECIMAL(10,4) DEFAULT 1.0;
    SELECT tipo_cambio INTO tasa
    FROM divisas
    WHERE id_divisa = p_id_divisa
    LIMIT 1;
    RETURN ROUND(monto_mxn * tasa, 4);
END$$
DELIMITER ;


-- ------------------------------------------------------------
-- fn_nivel_promedio_usuario
-- Retorna el promedio de nivel_alcanzado en todas las partidas
-- jugadas por el usuario indicado.
-- Uso: SELECT fn_nivel_promedio_usuario(1);
-- ------------------------------------------------------------
DROP FUNCTION IF EXISTS fn_nivel_promedio_usuario;
DELIMITER $$
CREATE FUNCTION fn_nivel_promedio_usuario(
    p_id_usuario INT
) RETURNS DECIMAL(5,2)
    READS SQL DATA
BEGIN
    DECLARE promedio DECIMAL(5,2) DEFAULT 0;
    SELECT COALESCE(AVG(nivel_alcanzado), 0)
    INTO promedio
    FROM partidas
    WHERE id_usuario = p_id_usuario;
    RETURN ROUND(promedio, 2);
END$$
DELIMITER ;


-- ------------------------------------------------------------
-- fn_tasa_conversion_usuario
-- Calcula el porcentaje de transacciones aprobadas sobre el
-- total de transacciones del usuario.
-- Retorna un valor entre 0.00 y 100.00.
-- Uso: SELECT fn_tasa_conversion_usuario(1);
-- ------------------------------------------------------------
DROP FUNCTION IF EXISTS fn_tasa_conversion_usuario;
DELIMITER $$
CREATE FUNCTION fn_tasa_conversion_usuario(
    p_id_usuario INT
) RETURNS DECIMAL(5,2)
    READS SQL DATA
BEGIN
    DECLARE total_t   INT DEFAULT 0;
    DECLARE aprobadas INT DEFAULT 0;

    SELECT COUNT(*) INTO total_t
    FROM transacciones t
    JOIN compras c ON c.id_compra = t.id_compra
    WHERE c.id_usuario = p_id_usuario;

    SELECT COUNT(*) INTO aprobadas
    FROM transacciones t
    JOIN compras c ON c.id_compra = t.id_compra
    WHERE c.id_usuario = p_id_usuario
      AND t.estatus = 'Aprobado';

    IF total_t = 0 THEN RETURN 0; END IF;
    RETURN ROUND((aprobadas / total_t) * 100, 2);
END$$
DELIMITER ;


-- ============================================================
-- EJEMPLOS DE USO
-- ============================================================
-- SELECT fn_total_gastado_usuario(1);
-- SELECT fn_clasificar_usuario(1);
-- SELECT fn_convertir_divisa(1000.00, 2);   -- MXN → USD
-- SELECT fn_nivel_promedio_usuario(1);
-- SELECT fn_tasa_conversion_usuario(1);
-- ============================================================
