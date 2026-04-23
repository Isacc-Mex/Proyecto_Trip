CREATE DEFINER=`root`@`localhost` PROCEDURE `generar_compras`(IN cantidad INT)
BEGIN
    DECLARE i               INT            DEFAULT 1;
    DECLARE usuario_id      INT;
    DECLARE producto_id     INT;
    DECLARE tipo_producto   VARCHAR(10);
    DECLARE precio_producto DECIMAL(10,2);
    DECLARE compra_id       INT;
    DECLARE metodo_id       INT UNSIGNED;
    DECLARE divisa_id       INT UNSIGNED;
    DECLARE tipo_cambio_val DECIMAL(10,4);
    DECLARE fecha_aleatoria DATETIME;
    DECLARE rand_val        DECIMAL(5,4);
    DECLARE estatus_txn     VARCHAR(20);
    -- Variables para envio
    DECLARE envio_id        INT UNSIGNED;
    DECLARE costo_env       DECIMAL(10,2);
    DECLARE metodo_env      VARCHAR(20);
    DECLARE dias_entrega    INT;
    DECLARE estatus_env     VARCHAR(20);

    IF (SELECT COUNT(*) FROM usuarios) = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No hay usuarios';
    END IF;
    IF (SELECT COUNT(*) FROM productos) = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No hay productos';
    END IF;

    loop_compras: WHILE i <= cantidad DO

        SELECT id_usuario INTO usuario_id
        FROM usuarios ORDER BY RAND() LIMIT 1;

        IF usuario_id IS NULL THEN
            SET i = i + 1;
            ITERATE loop_compras;
        END IF;

        -- Obtener producto con su tipo
        SELECT id_producto, precio, tipo
        INTO producto_id, precio_producto, tipo_producto
        FROM productos ORDER BY RAND() LIMIT 1;

        IF producto_id IS NULL THEN
            SET i = i + 1;
            ITERATE loop_compras;
        END IF;

        SET fecha_aleatoria = DATE_ADD(
            '2025-01-01 00:00:00',
            INTERVAL FLOOR(RAND() * TIMESTAMPDIFF(SECOND, '2025-01-01', NOW())) SECOND
        );

        -- Crear metodo de pago aleatorio para el usuario
        INSERT INTO metodo_pago (id_usuario, titular, numero_tarjeta, tipo_red_bancaria, tipo_cuenta, estatus)
        VALUES (
            usuario_id,
            (SELECT nombre FROM usuarios WHERE id_usuario = usuario_id),
            LPAD(FLOOR(RAND() * 9000000000000000) + 1000000000000000, 16, '0'),
            ELT(FLOOR(1 + RAND()*3), 'Visa', 'Mastercard', 'American express'),
            ELT(FLOOR(1 + RAND()*4), 'Nomina', 'Debito', 'Ahorro', 'Digital'),
            ELT(FLOOR(1 + RAND()*3), 'Vigente', 'Vigente', 'Expirada')
        );
        SET metodo_id = LAST_INSERT_ID();

        INSERT INTO compras (id_usuario, id_producto, fecha, total)
        VALUES (usuario_id, producto_id, fecha_aleatoria, precio_producto);

        SET compra_id = LAST_INSERT_ID();
        SET rand_val  = RAND();

        -- Seleccionar divisa aleatoria activa
        SELECT id_divisa, tipo_cambio INTO divisa_id, tipo_cambio_val
        FROM divisas WHERE activa = 1 ORDER BY RAND() LIMIT 1;

        SET estatus_txn = CASE
            WHEN rand_val < 0.70 THEN 'Aprobado'
            WHEN rand_val < 0.85 THEN 'Pendiente'
            WHEN rand_val < 0.95 THEN 'No aprobado'
            ELSE 'Cancelado'
        END;

        INSERT INTO transacciones (id_compra, id_metodo_pago, id_divisa, origen, monto, monto_divisa, fecha, estatus)
        VALUES (
            compra_id, metodo_id, divisa_id,
            ELT(FLOOR(1 + RAND()*3), 'Tarjeta de debito', 'Tarjeta de credito', 'Tarjeta de regalo'),
            precio_producto,
            ROUND(precio_producto * tipo_cambio_val, 4),
            fecha_aleatoria,
            estatus_txn
        );

        -- ── Si es Merch Y la transacción fue Aprobada → generar envio ──────────
        IF tipo_producto = 'Merch' AND estatus_txn = 'Aprobado' THEN

            -- Costo y método de envío aleatorio
            SET metodo_env = ELT(FLOOR(1 + RAND()*3), 'Estándar', 'Express', 'Internacional');
            SET costo_env  = CASE metodo_env
                WHEN 'Estándar'      THEN ROUND(50  + RAND()*50,  2)
                WHEN 'Express'       THEN ROUND(120 + RAND()*80,  2)
                WHEN 'Internacional' THEN ROUND(250 + RAND()*150, 2)
            END;
            SET dias_entrega = CASE metodo_env
                WHEN 'Estándar'      THEN FLOOR(5  + RAND()*10)
                WHEN 'Express'       THEN FLOOR(2  + RAND()*3)
                WHEN 'Internacional' THEN FLOOR(10 + RAND()*20)
            END;
            -- Estatus del envio proporcional al tiempo transcurrido
            SET estatus_env = ELT(FLOOR(1 + RAND()*4), 'Pendiente', 'En camino', 'Entregado', 'Entregado');

            INSERT INTO envios (
                id_compra, direccion, ciudad, pais, codigo_postal,
                metodo_envio, costo_envio, estatus_envio,
                fecha_estimada, fecha_entrega, numero_rastreo
            ) VALUES (
                compra_id,
                CONCAT('Calle ', FLOOR(1+RAND()*999), ' #', FLOOR(1+RAND()*200)),
                ELT(FLOOR(1+RAND()*8),
                    'Ciudad de México','Guadalajara','Monterrey',
                    'Puebla','Querétaro','Tijuana','Mérida','León'),
                ELT(FLOOR(1+RAND()*3), 'México','México','México'),
                LPAD(FLOOR(RAND()*99999), 5, '0'),
                metodo_env,
                costo_env,
                estatus_env,
                DATE_ADD(DATE(fecha_aleatoria), INTERVAL dias_entrega DAY),
                IF(estatus_env = 'Entregado',
                   DATE_ADD(fecha_aleatoria, INTERVAL dias_entrega DAY), NULL),
                CONCAT('TRIP-', UPPER(SUBSTRING(MD5(RAND()), 1, 10)))
            );

            SET envio_id = LAST_INSERT_ID();

            -- ── 15% de probabilidad de devolucion en compras Merch entregadas ──
            IF estatus_env = 'Entregado' AND RAND() < 0.15 THEN
                INSERT INTO devoluciones (
                    id_compra, id_envio, motivo, descripcion,
                    estatus, monto_reembolso, fecha_solicitud, fecha_resolucion
                ) VALUES (
                    compra_id,
                    envio_id,
                    ELT(FLOOR(1+RAND()*5),
                        'Producto dañado','Producto incorrecto',
                        'No llegó','Cambio de opinión','Defecto de fábrica'),
                    'Solicitud generada automáticamente por simulación',
                    ELT(FLOOR(1+RAND()*5),
                        'Solicitada','En revisión','Aprobada','Rechazada','Reembolsada'),
                    ROUND(precio_producto * (0.5 + RAND()*0.5), 2),
                    DATE_ADD(fecha_aleatoria, INTERVAL (dias_entrega + FLOOR(1+RAND()*7)) DAY),
                    IF(RAND() > 0.4,
                       DATE_ADD(fecha_aleatoria, INTERVAL (dias_entrega + FLOOR(8+RAND()*14)) DAY),
                       NULL)
                );
            END IF;

        END IF;
        -- ── Fin bloque Merch ────────────────────────────────────────────────────

        SET i = i + 1;
    END WHILE loop_compras;
END



CREATE DEFINER=`root`@`localhost` PROCEDURE `generar_partidas`(IN cantidad INT)
BEGIN
    DECLARE i INT DEFAULT 1;
    DECLARE usuario_random INT;
    DECLARE fecha_reg DATETIME;
    DECLARE fecha_ini DATETIME;
    DECLARE dur INT;
    DECLARE estado VARCHAR(20);
    DECLARE id_partida_insertada INT;
    DECLARE tipo_muerte_id INT;

    WHILE i <= cantidad DO

        SELECT id_usuario, fecha_registro INTO usuario_random, fecha_reg
        FROM usuarios ORDER BY RAND() LIMIT 1;

        SET fecha_ini = DATE_ADD(fecha_reg, INTERVAL FLOOR(RAND()*30*24*60) MINUTE);
        SET dur       = FLOOR(1 + RAND()*20);
        SET estado    = ELT(FLOOR(1 + RAND()*3), 'ganó', 'perdió', 'abandonó');

        INSERT INTO partidas (id_usuario, fecha_inicio, fecha_fin, duracion, nivel_alcanzado, estado_final)
        VALUES (
            usuario_random, fecha_ini,
            DATE_ADD(fecha_ini, INTERVAL dur*60 SECOND),
            dur*60, FLOOR(1 + RAND()*10), estado
        );

        SET id_partida_insertada = LAST_INSERT_ID();

        IF estado = 'perdió' THEN
            -- Seleccionar un tipo de muerte real del catálogo
            SELECT id_muerte INTO tipo_muerte_id
            FROM tipos_muerte ORDER BY RAND() LIMIT 1;

            INSERT INTO muerte_partida (id_partida, id_muerte, tipo_muerte)
            SELECT
                id_partida_insertada,
                id_muerte,
                descripcion
            FROM tipos_muerte WHERE id_muerte = tipo_muerte_id;
        END IF;

        SET i = i + 1;
    END WHILE;
END



CREATE DEFINER=`root`@`localhost` PROCEDURE `generar_usuarios`(IN cantidad INT)
BEGIN
    DECLARE i INT DEFAULT 1;

    WHILE i <= cantidad DO
        INSERT INTO usuarios (nombre, email, contraseña, fecha_registro)
        VALUES (
            CONCAT(
                ELT(FLOOR(1+RAND()*15),'Shadow','Dark','Ghost','Neo','Zero','Void','Xeno','Cyber','Night','Pixel','Omega','Nova','Rogue','Phantom','Echo'),
                ELT(FLOOR(1+RAND()*15),'Hunter','Killer','Runner','Player','Soul','Drift','Core','Storm','Blade','Byte','Sniper','Rider','Walker','Breaker','Striker'),
                ELT(FLOOR(1+RAND()*10),'X','Z','V','Q','XR','MK','EX','LX','PR','ZX'),
                FLOOR(RAND()*999)
            ),
            CONCAT(LOWER(SUBSTRING(MD5(RAND()),1,6)),FLOOR(RAND()*1000),'@',
                ELT(FLOOR(1+RAND()*8),'gmail.com','hotmail.com','outlook.com','yahoo.com','proton.me','icloud.com','live.com','mail.com')
            ),
            SUBSTRING(MD5(RAND()),1,10),
            DATE_ADD(DATE_ADD('2025-01-01', INTERVAL FLOOR(RAND()*DATEDIFF(NOW(),'2025-01-01')) DAY),
                INTERVAL FLOOR(RAND()*86400) SECOND)
        );
        SET i = i + 1;
    END WHILE;
END