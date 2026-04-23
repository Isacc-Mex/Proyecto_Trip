-- ============================================================
--  Base de Datos: db_trip  |  Videojuego con Monetización
--  Archivo     : triggers.sql
--  Descripción : 17 Triggers AFTER (INSERT / UPDATE / DELETE)
--                sobre 6 tablas. Registran automáticamente
--                cada operación en la tabla `bitacora`.
--  Tablas monitoreadas:
--    compras · devoluciones · envios
--    productos · transacciones · usuarios
-- ============================================================

USE db_trip;

-- ============================================================
--  TABLA: compras  (3 triggers)
-- ============================================================

DROP TRIGGER IF EXISTS trg_compras_after_insert;
DELIMITER $$
CREATE TRIGGER trg_compras_after_insert
AFTER INSERT ON compras
FOR EACH ROW
BEGIN
    INSERT INTO bitacora (tabla, operacion, id_registro, descripcion)
    VALUES ('compras', 'INSERT', NEW.id_compra,
        CONCAT('Nueva compra: usuario=', NEW.id_usuario,
               ', producto=', NEW.id_producto,
               ', total=', NEW.total));
END$$
DELIMITER ;

-- ------------------------------------------------------------
DROP TRIGGER IF EXISTS trg_compras_after_update;
DELIMITER $$
CREATE TRIGGER trg_compras_after_update
AFTER UPDATE ON compras
FOR EACH ROW
BEGIN
    INSERT INTO bitacora (tabla, operacion, id_registro, descripcion)
    VALUES ('compras', 'UPDATE', NEW.id_compra,
        CONCAT('Compra actualizada: total ', OLD.total, ' → ', NEW.total,
               ', producto ', OLD.id_producto, ' → ', NEW.id_producto));
END$$
DELIMITER ;

-- ------------------------------------------------------------
DROP TRIGGER IF EXISTS trg_compras_after_delete;
DELIMITER $$
CREATE TRIGGER trg_compras_after_delete
AFTER DELETE ON compras
FOR EACH ROW
BEGIN
    INSERT INTO bitacora (tabla, operacion, id_registro, descripcion)
    VALUES ('compras', 'DELETE', OLD.id_compra,
        CONCAT('Compra eliminada: usuario=', OLD.id_usuario,
               ', total=', OLD.total));
END$$
DELIMITER ;


-- ============================================================
--  TABLA: devoluciones  (2 triggers)
-- ============================================================

DROP TRIGGER IF EXISTS trg_devoluciones_after_insert;
DELIMITER $$
CREATE TRIGGER trg_devoluciones_after_insert
AFTER INSERT ON devoluciones
FOR EACH ROW
BEGIN
    INSERT INTO bitacora (tabla, operacion, id_registro, descripcion)
    VALUES ('devoluciones', 'INSERT', NEW.id_devolucion,
        CONCAT('Nueva devolucion: compra=', NEW.id_compra,
               ', motivo=', NEW.motivo,
               ', estatus=', NEW.estatus));
END$$
DELIMITER ;

-- ------------------------------------------------------------
DROP TRIGGER IF EXISTS trg_devoluciones_after_update;
DELIMITER $$
CREATE TRIGGER trg_devoluciones_after_update
AFTER UPDATE ON devoluciones
FOR EACH ROW
BEGIN
    INSERT INTO bitacora (tabla, operacion, id_registro, descripcion)
    VALUES ('devoluciones', 'UPDATE', NEW.id_devolucion,
        CONCAT('Devolucion actualizada: estatus ', OLD.estatus, ' -> ', NEW.estatus,
               ', reembolso=', IFNULL(NEW.monto_reembolso, 'N/A')));
END$$
DELIMITER ;


-- ============================================================
--  TABLA: envios  (3 triggers)
-- ============================================================

DROP TRIGGER IF EXISTS trg_envios_after_insert;
DELIMITER $$
CREATE TRIGGER trg_envios_after_insert
AFTER INSERT ON envios
FOR EACH ROW
BEGIN
    INSERT INTO bitacora (tabla, operacion, id_registro, descripcion)
    VALUES ('envios', 'INSERT', NEW.id_envio,
        CONCAT('Nuevo envio: compra=', NEW.id_compra,
               ', destino=', NEW.ciudad,
               ', método=', NEW.metodo_envio));
END$$
DELIMITER ;

-- ------------------------------------------------------------
DROP TRIGGER IF EXISTS trg_envios_after_update;
DELIMITER $$
CREATE TRIGGER trg_envios_after_update
AFTER UPDATE ON envios
FOR EACH ROW
BEGIN
    INSERT INTO bitacora (tabla, operacion, id_registro, descripcion)
    VALUES ('envios', 'UPDATE', NEW.id_envio,
        CONCAT('Envio actualizado: estatus ', OLD.estatus_envio, ' → ', NEW.estatus_envio));
END$$
DELIMITER ;

-- ------------------------------------------------------------
DROP TRIGGER IF EXISTS trg_envios_after_delete;
DELIMITER $$
CREATE TRIGGER trg_envios_after_delete
AFTER DELETE ON envios
FOR EACH ROW
BEGIN
    INSERT INTO bitacora (tabla, operacion, id_registro, descripcion)
    VALUES ('envios', 'DELETE', OLD.id_envio,
        CONCAT('Envio eliminado: compra=', OLD.id_compra,
               ', rastreo=', IFNULL(OLD.numero_rastreo, 'N/A')));
END$$
DELIMITER ;


-- ============================================================
--  TABLA: productos  (3 triggers)
-- ============================================================

DROP TRIGGER IF EXISTS trg_productos_after_insert;
DELIMITER $$
CREATE TRIGGER trg_productos_after_insert
AFTER INSERT ON productos
FOR EACH ROW
BEGIN
    INSERT INTO bitacora (tabla, operacion, id_registro, descripcion)
    VALUES ('productos', 'INSERT', NEW.id_producto,
        CONCAT('Nuevo producto: ', NEW.nombre,
               ' tipo=', NEW.tipo,
               ' precio=', NEW.precio));
END$$
DELIMITER ;

-- ------------------------------------------------------------
DROP TRIGGER IF EXISTS trg_productos_after_update;
DELIMITER $$
CREATE TRIGGER trg_productos_after_update
AFTER UPDATE ON productos
FOR EACH ROW
BEGIN
    INSERT INTO bitacora (tabla, operacion, id_registro, descripcion)
    VALUES ('productos', 'UPDATE', NEW.id_producto,
        CONCAT('Producto actualizado: precio ', OLD.precio, ' → ', NEW.precio,
               ', nombre ', OLD.nombre, ' → ', NEW.nombre));
END$$
DELIMITER ;

-- ------------------------------------------------------------
DROP TRIGGER IF EXISTS trg_productos_after_delete;
DELIMITER $$
CREATE TRIGGER trg_productos_after_delete
AFTER DELETE ON productos
FOR EACH ROW
BEGIN
    INSERT INTO bitacora (tabla, operacion, id_registro, descripcion)
    VALUES ('productos', 'DELETE', OLD.id_producto,
        CONCAT('Producto eliminado: ', OLD.nombre, ' tipo=', OLD.tipo));
END$$
DELIMITER ;


-- ============================================================
--  TABLA: transacciones  (3 triggers)
-- ============================================================

DROP TRIGGER IF EXISTS trg_transacciones_after_insert;
DELIMITER $$
CREATE TRIGGER trg_transacciones_after_insert
AFTER INSERT ON transacciones
FOR EACH ROW
BEGIN
    INSERT INTO bitacora (tabla, operacion, id_registro, descripcion)
    VALUES ('transacciones', 'INSERT', NEW.id_transaccion,
        CONCAT('Nueva transacción: compra=', NEW.id_compra,
               ', monto=', NEW.monto,
               ', divisa=', NEW.id_divisa,
               ', estatus=', NEW.estatus));
END$$
DELIMITER ;

-- ------------------------------------------------------------
DROP TRIGGER IF EXISTS trg_transacciones_after_update;
DELIMITER $$
CREATE TRIGGER trg_transacciones_after_update
AFTER UPDATE ON transacciones
FOR EACH ROW
BEGIN
    INSERT INTO bitacora (tabla, operacion, id_registro, descripcion)
    VALUES ('transacciones', 'UPDATE', NEW.id_transaccion,
        CONCAT('Transacción actualizada: estatus ', OLD.estatus, ' → ', NEW.estatus,
               ', monto ', OLD.monto, ' → ', NEW.monto));
END$$
DELIMITER ;

-- ------------------------------------------------------------
DROP TRIGGER IF EXISTS trg_transacciones_after_delete;
DELIMITER $$
CREATE TRIGGER trg_transacciones_after_delete
AFTER DELETE ON transacciones
FOR EACH ROW
BEGIN
    INSERT INTO bitacora (tabla, operacion, id_registro, descripcion)
    VALUES ('transacciones', 'DELETE', OLD.id_transaccion,
        CONCAT('Transacción eliminada: compra=', OLD.id_compra,
               ', monto=', OLD.monto));
END$$
DELIMITER ;


-- ============================================================
--  TABLA: usuarios  (3 triggers)
-- ============================================================

DROP TRIGGER IF EXISTS trg_usuarios_after_insert;
DELIMITER $$
CREATE TRIGGER trg_usuarios_after_insert
AFTER INSERT ON usuarios
FOR EACH ROW
BEGIN
    INSERT INTO bitacora (tabla, operacion, id_registro, descripcion)
    VALUES ('usuarios', 'INSERT', NEW.id_usuario,
        CONCAT('Nuevo usuario: ', NEW.nombre, ' (', NEW.email, ')'));
END$$
DELIMITER ;

-- ------------------------------------------------------------
DROP TRIGGER IF EXISTS trg_usuarios_after_update;
DELIMITER $$
CREATE TRIGGER trg_usuarios_after_update
AFTER UPDATE ON usuarios
FOR EACH ROW
BEGIN
    INSERT INTO bitacora (tabla, operacion, id_registro, descripcion)
    VALUES ('usuarios', 'UPDATE', NEW.id_usuario,
        CONCAT('Usuario actualizado: nombre ', OLD.nombre, ' → ', NEW.nombre,
               ', email ', OLD.email, ' → ', NEW.email));
END$$
DELIMITER ;

-- ------------------------------------------------------------
DROP TRIGGER IF EXISTS trg_usuarios_after_delete;
DELIMITER $$
CREATE TRIGGER trg_usuarios_after_delete
AFTER DELETE ON usuarios
FOR EACH ROW
BEGIN
    INSERT INTO bitacora (tabla, operacion, id_registro, descripcion)
    VALUES ('usuarios', 'DELETE', OLD.id_usuario,
        CONCAT('Usuario eliminado: ', OLD.nombre, ' (', OLD.email, ')'));
END$$
DELIMITER ;


-- ============================================================
-- VERIFICAR TRIGGERS CREADOS
-- ============================================================
-- SHOW TRIGGERS FROM db_trip;
-- SELECT * FROM bitacora ORDER BY fecha DESC LIMIT 20;
-- ============================================================
