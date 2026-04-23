-- ============================================================
--  Base de Datos: db_trip  |  Videojuego con Monetización
--  Archivo     : transacciones.sql
--  Descripción : Procedimientos que usan START TRANSACTION /
--                COMMIT / ROLLBACK para garantizar atomicidad
--                en operaciones críticas de compra.
--  Procedimientos:
--    · txn_registrar_compra  → registra compra + transacción
--    · txn_cancelar_compra   → cancela transacción y borra envío
-- ============================================================

USE db_trip;

-- ============================================================
--  txn_registrar_compra
--  Registra una compra y su transacción en una sola operación
--  atómica. Si cualquier INSERT falla, hace ROLLBACK completo.
--
--  Parámetros:
--    p_id_usuario     INT          → ID del jugador
--    p_id_producto    INT          → ID del producto (Skin/DLC/Merch)
--    p_id_metodo_pago INT UNSIGNED → ID del método de pago
--    p_id_divisa      INT UNSIGNED → ID de la divisa destino
--    p_origen         VARCHAR(50)  → 'Tarjeta de debito' | etc.
--
--  Uso:
--    CALL txn_registrar_compra(1, 3, 2, 1, 'Tarjeta de debito');
-- ============================================================
DROP PROCEDURE IF EXISTS txn_registrar_compra;
DELIMITER $$
CREATE PROCEDURE txn_registrar_compra(
    IN p_id_usuario     INT,
    IN p_id_producto    INT,
    IN p_id_metodo_pago INT UNSIGNED,
    IN p_id_divisa      INT UNSIGNED,
    IN p_origen         VARCHAR(50)
)
BEGIN
    DECLARE v_precio    DECIMAL(10,2) DEFAULT 0;
    DECLARE v_compra_id INT           DEFAULT 0;
    DECLARE v_tasa      DECIMAL(10,4) DEFAULT 1.0;

    -- Si ocurre cualquier error SQL: revertir todo y lanzar aviso
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Error al registrar compra: transaccion revertida';
    END;

    START TRANSACTION;

        -- Obtener precio del producto y tipo de cambio de la divisa
        SELECT precio       INTO v_precio FROM productos WHERE id_producto = p_id_producto;
        SELECT tipo_cambio  INTO v_tasa   FROM divisas   WHERE id_divisa   = p_id_divisa;

        -- Insertar la compra
        INSERT INTO compras (id_usuario, id_producto, fecha, total)
        VALUES (p_id_usuario, p_id_producto, NOW(), v_precio);
        SET v_compra_id = LAST_INSERT_ID();

        -- Insertar la transacción vinculada
        INSERT INTO transacciones
            (id_compra, id_metodo_pago, id_divisa, origen, monto, monto_divisa, fecha, estatus)
        VALUES
            (v_compra_id, p_id_metodo_pago, p_id_divisa, p_origen,
             v_precio, ROUND(v_precio * v_tasa, 4), NOW(), 'Aprobado');

    COMMIT;
END$$
DELIMITER ;


-- ============================================================
--  txn_cancelar_compra
--  Cancela la transacción asociada a una compra y elimina
--  el envío si existía. Operación atómica con ROLLBACK.
--
--  Parámetros:
--    p_id_compra INT → ID de la compra a cancelar
--
--  Uso:
--    CALL txn_cancelar_compra(10);
-- ============================================================
DROP PROCEDURE IF EXISTS txn_cancelar_compra;
DELIMITER $$
CREATE PROCEDURE txn_cancelar_compra(
    IN p_id_compra INT
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Error al cancelar compra';
    END;

    START TRANSACTION;

        -- Marcar la transacción como Cancelada
        UPDATE transacciones
        SET estatus = 'Cancelado'
        WHERE id_compra = p_id_compra;

        -- Eliminar el envío si la compra tenía uno generado
        DELETE FROM envios
        WHERE id_compra = p_id_compra;

    COMMIT;
END$$
DELIMITER ;


-- ============================================================
-- EJEMPLOS DE USO
-- ============================================================
-- -- Registrar una compra manual (usuario 1, producto 2, método 1, divisa MXN):
-- CALL txn_registrar_compra(1, 2, 1, 1, 'Tarjeta de debito');
--
-- -- Cancelar la compra con id_compra = 10:
-- CALL txn_cancelar_compra(10);
--
-- -- Ver el resultado en bitácora:
-- SELECT * FROM bitacora ORDER BY fecha DESC LIMIT 10;
-- ============================================================
