-- ============================================================
--  PROYECTO INTEGRADOR · TRIP
--  ASIGNATURA: Bases de Datos para Negocios Digitales
--  CARPETA:    /Queries
--  ARCHIVO:    queries_kpis.sql
--  BASE DE DATOS: db_trip · MySQL 8.0
--  DESCRIPCIÓN: 10 Vistas SQL que calculan los KPIs de
--               monetización del videojuego TRIP.
-- ============================================================

USE db_trip;

-- ============================================================
-- KPI 01 · INGRESO TOTAL
-- ============================================================
-- Descripción : Suma de todos los montos de transacciones
--               con estatus 'Aprobado'. Incluye el total de
--               transacciones procesadas y usuarios pagadores.
-- Tablas      : transacciones, compras
-- Técnicas    : JOIN, WHERE, SUM(), COUNT(DISTINCT)
-- ============================================================

CREATE OR REPLACE VIEW kpi_01_ingreso_total AS
SELECT
    SUM(t.monto)                    AS ingreso_total_mxn,
    COUNT(DISTINCT t.id_transaccion) AS total_transacciones,
    COUNT(DISTINCT c.id_usuario)    AS usuarios_pagadores
FROM transacciones t
JOIN compras c ON c.id_compra = t.id_compra
WHERE t.estatus = 'Aprobado';


-- ============================================================
-- KPI 02 · ARPU (Average Revenue Per User)
-- ============================================================
-- Descripción : Ingreso promedio generado por cada usuario
--               que realizó al menos una compra aprobada.
--               ARPU = Ingreso Total / Usuarios únicos pagadores.
-- Tablas      : transacciones, compras
-- Técnicas    : JOIN, WHERE, SUM(), COUNT(DISTINCT), ROUND()
-- ============================================================

CREATE OR REPLACE VIEW kpi_02_arpu AS
SELECT
    ROUND(
        SUM(t.monto) / COUNT(DISTINCT c.id_usuario),
        2
    ) AS arpu_mxn
FROM transacciones t
JOIN compras c ON c.id_compra = t.id_compra
WHERE t.estatus = 'Aprobado';


-- ============================================================
-- KPI 03 · INGRESOS POR TIPO DE PRODUCTO
-- ============================================================
-- Descripción : Desglose del ingreso total agrupado por tipo
--               de producto (Skin, DLC, Merch). Incluye número
--               de compras y participación porcentual de cada
--               tipo sobre el ingreso total.
-- Tablas      : transacciones, compras, productos
-- Técnicas    : JOIN múltiple, GROUP BY, SUM(), subconsulta
--               escalar para calcular el porcentaje.
-- ============================================================

CREATE OR REPLACE VIEW kpi_03_ingresos_por_tipo AS
SELECT
    p.tipo                                          AS tipo_producto,
    COUNT(c.id_compra)                              AS num_compras,
    SUM(t.monto)                                    AS ingreso_mxn,
    ROUND(
        (SUM(t.monto) * 100.0) /
        (SELECT SUM(monto) FROM transacciones
         WHERE estatus = 'Aprobado'),
        2
    )                                               AS porcentaje
FROM transacciones t
JOIN compras   c ON c.id_compra  = t.id_compra
JOIN productos p ON p.id_producto = c.id_producto
WHERE t.estatus = 'Aprobado'
GROUP BY p.tipo
ORDER BY ingreso_mxn DESC;


-- ============================================================
-- KPI 04 · TOP 10 PRODUCTOS MÁS VENDIDOS
-- ============================================================
-- Descripción : Ranking de los 10 productos con mayor número
--               de compras aprobadas e ingreso generado.
--               Útil para identificar los SKUs estrella.
-- Tablas      : compras, productos, transacciones
-- Técnicas    : JOIN múltiple, GROUP BY, COUNT(), SUM(),
--               ORDER BY, LIMIT
-- ============================================================

CREATE OR REPLACE VIEW kpi_04_top_productos AS
SELECT
    p.id_producto,
    p.nombre,
    p.tipo,
    COUNT(c.id_compra)  AS veces_comprado,
    SUM(t.monto)        AS ingreso_generado_mxn
FROM compras      c
JOIN productos    p ON p.id_producto = c.id_producto
JOIN transacciones t ON t.id_compra  = c.id_compra
WHERE t.estatus = 'Aprobado'
GROUP BY p.id_producto, p.nombre, p.tipo
ORDER BY veces_comprado DESC
LIMIT 10;


-- ============================================================
-- KPI 05 · TASA DE APROBACIÓN DE PAGOS
-- ============================================================
-- Descripción : Distribución de transacciones por estatus
--               (Aprobado, Pendiente, No aprobado, Cancelado)
--               con su respectivo porcentaje del total.
-- Tablas      : transacciones
-- Técnicas    : GROUP BY, COUNT(), función de ventana
--               SUM() OVER () para calcular el porcentaje
--               sin subconsulta adicional.
-- ============================================================

CREATE OR REPLACE VIEW kpi_05_tasa_aprobacion AS
SELECT
    estatus,
    COUNT(*)  AS cantidad,
    ROUND(
        (COUNT(*) * 100.0) / SUM(COUNT(*)) OVER (),
        2
    )         AS porcentaje
FROM transacciones
GROUP BY estatus
ORDER BY cantidad DESC;


-- ============================================================
-- KPI 06 · INGRESOS POR DIVISA
-- ============================================================
-- Descripción : Ingreso total agrupado por divisa utilizada
--               en el pago. Muestra el monto en MXN (base)
--               y el monto original en la divisa del usuario.
-- Tablas      : transacciones, divisas
-- Técnicas    : JOIN, WHERE, GROUP BY, SUM(), COUNT()
-- ============================================================

CREATE OR REPLACE VIEW kpi_06_ingresos_por_divisa AS
SELECT
    d.codigo                        AS codigo,
    d.nombre                        AS divisa,
    d.simbolo                       AS simbolo,
    COUNT(t.id_transaccion)         AS transacciones,
    SUM(t.monto)                    AS monto_base_mxn,
    SUM(t.monto_divisa)             AS monto_en_divisa
FROM transacciones t
JOIN divisas d ON d.id_divisa = t.id_divisa
WHERE t.estatus = 'Aprobado'
GROUP BY d.id_divisa, d.codigo, d.nombre, d.simbolo
ORDER BY monto_base_mxn DESC;


-- ============================================================
-- KPI 07 · TOP 10 USUARIOS CON MAYOR GASTO (Top Spenders)
-- ============================================================
-- Descripción : Lista de los 10 usuarios que más han gastado
--               en compras aprobadas. Incluye número de compras
--               y segmento calculado por función almacenada.
-- Tablas      : usuarios, compras, transacciones
-- Técnicas    : JOIN múltiple, GROUP BY, COUNT(DISTINCT),
--               SUM(), función fn_clasificar_usuario(),
--               ORDER BY, LIMIT
-- ============================================================

CREATE OR REPLACE VIEW kpi_07_top_spenders AS
SELECT
    u.id_usuario,
    u.nombre,
    u.email,
    COUNT(DISTINCT c.id_compra)     AS total_compras,
    SUM(t.monto)                    AS gasto_total_mxn,
    fn_clasificar_usuario(u.id_usuario) AS segmento
FROM usuarios u
JOIN compras      c ON c.id_usuario = u.id_usuario
JOIN transacciones t ON t.id_compra = c.id_compra
WHERE t.estatus = 'Aprobado'
GROUP BY u.id_usuario, u.nombre, u.email
ORDER BY gasto_total_mxn DESC
LIMIT 10;


-- ============================================================
-- KPI 08 · MÉTODOS DE PAGO PREFERIDOS
-- ============================================================
-- Descripción : Uso de métodos de pago agrupado por red
--               bancaria y tipo de cuenta. Incluye monto
--               total procesado y porcentaje de uso sobre
--               el total de transacciones aprobadas.
-- Tablas      : transacciones, metodo_pago
-- Técnicas    : JOIN, WHERE, GROUP BY, COUNT(), SUM(),
--               subconsulta escalar para porcentaje, ROUND()
-- ============================================================

CREATE OR REPLACE VIEW kpi_08_metodos_pago AS
SELECT
    mp.tipo_red_bancaria                                    AS red,
    mp.tipo_cuenta                                          AS tipo_cuenta,
    COUNT(t.id_transaccion)                                 AS total_usos,
    SUM(t.monto)                                            AS monto_procesado_mxn,
    ROUND(
        (COUNT(t.id_transaccion) * 100.0) /
        (SELECT COUNT(*) FROM transacciones
         WHERE estatus = 'Aprobado'),
        2
    )                                                       AS pct_uso
FROM transacciones t
JOIN metodo_pago mp ON mp.id_metodo_pago = t.id_metodo_pago
WHERE t.estatus = 'Aprobado'
GROUP BY mp.tipo_red_bancaria, mp.tipo_cuenta
ORDER BY total_usos DESC;


-- ============================================================
-- KPI 09 · INGRESOS MENSUALES
-- ============================================================
-- Descripción : Evolución del ingreso mes a mes. Muestra
--               número de transacciones, ingreso total y
--               usuarios activos por período.
-- Tablas      : transacciones, compras
-- Técnicas    : JOIN, WHERE, GROUP BY, DATE_FORMAT(),
--               SUM(), COUNT(), COUNT(DISTINCT)
-- ============================================================

CREATE OR REPLACE VIEW kpi_09_ingresos_mensuales AS
SELECT
    DATE_FORMAT(t.fecha, '%Y-%m')       AS mes,
    COUNT(t.id_transaccion)             AS transacciones,
    SUM(t.monto)                        AS ingreso_mxn,
    COUNT(DISTINCT c.id_usuario)        AS usuarios_activos
FROM transacciones t
JOIN compras c ON c.id_compra = t.id_compra
WHERE t.estatus = 'Aprobado'
GROUP BY DATE_FORMAT(t.fecha, '%Y-%m')
ORDER BY mes;


-- ============================================================
-- KPI 10 · RETENCIÓN Y SEGMENTACIÓN DE USUARIOS
-- ============================================================
-- Descripción : Clasifica a los usuarios según su número de
--               compras aprobadas: Único (1), Repetidor (2)
--               o Recurrente (3+). Permite evaluar la
--               fidelización de la base de jugadores.
-- Tablas      : usuarios, compras, transacciones
-- Técnicas    : Subconsulta con CASE WHEN para segmentación,
--               JOIN múltiple, GROUP BY anidado, COUNT()
-- ============================================================

CREATE OR REPLACE VIEW kpi_10_retencion_usuarios AS
SELECT
    sub.segmento,
    COUNT(*) AS cantidad_usuarios
FROM (
    SELECT
        u.id_usuario,
        CASE
            WHEN COUNT(c.id_compra) >= 3 THEN 'Recurrente (3+)'
            WHEN COUNT(c.id_compra) =  2 THEN 'Repetidor (2)'
            ELSE                              'Unico (1)'
        END AS segmento
    FROM usuarios u
    JOIN compras       c ON c.id_usuario = u.id_usuario
    JOIN transacciones t ON t.id_compra  = c.id_compra
    WHERE t.estatus = 'Aprobado'
    GROUP BY u.id_usuario
) sub
GROUP BY sub.segmento
ORDER BY cantidad_usuarios DESC;


-- ============================================================
-- VISTA EJECUTIVA · RESUMEN DE KPIs
-- ============================================================
-- Descripción : Vista consolidada que combina los principales
--               KPIs en una sola consulta para reportes
--               ejecutivos rápidos. Usa subconsultas escalares
--               que consultan las vistas anteriores.
-- Técnicas    : Subconsultas escalares, referencias a vistas,
--               filtros WHERE sobre vistas ya definidas.
-- ============================================================

CREATE OR REPLACE VIEW vista_resumen_ejecutivo AS
SELECT
    -- KPI 1: Ingreso Total
    (SELECT ingreso_total_mxn
     FROM kpi_01_ingreso_total)                              AS kpi1_ingreso_total_mxn,

    -- KPI 2: ARPU
    (SELECT arpu_mxn
     FROM kpi_02_arpu)                                       AS kpi2_arpu_mxn,

    -- KPI 3: Ingreso por tipo de producto
    (SELECT SUM(ingreso_mxn) FROM kpi_03_ingresos_por_tipo
     WHERE tipo_producto = 'Skin')                           AS kpi3_ingreso_skins,

    (SELECT SUM(ingreso_mxn) FROM kpi_03_ingresos_por_tipo
     WHERE tipo_producto = 'DLC')                            AS kpi3_ingreso_dlc,

    (SELECT SUM(ingreso_mxn) FROM kpi_03_ingresos_por_tipo
     WHERE tipo_producto = 'Merch')                          AS kpi3_ingreso_merch,

    -- KPI 5: Tasa de aprobación
    (SELECT porcentaje FROM kpi_05_tasa_aprobacion
     WHERE estatus = 'Aprobado')                             AS kpi5_pct_aprobado,

    -- KPI 10: Usuarios recurrentes
    (SELECT COUNT(*) FROM kpi_10_retencion_usuarios
     WHERE segmento LIKE 'Recurrente%')                      AS kpi10_usuarios_recurrentes;


-- ============================================================
-- CONSULTAS DE PRUEBA (ejecutar después de crear las vistas)
-- ============================================================

-- SELECT * FROM kpi_01_ingreso_total;
-- SELECT * FROM kpi_02_arpu;
-- SELECT * FROM kpi_03_ingresos_por_tipo;
-- SELECT * FROM kpi_04_top_productos;
-- SELECT * FROM kpi_05_tasa_aprobacion;
-- SELECT * FROM kpi_06_ingresos_por_divisa;
-- SELECT * FROM kpi_07_top_spenders;
-- SELECT * FROM kpi_08_metodos_pago;
-- SELECT * FROM kpi_09_ingresos_mensuales;
-- SELECT * FROM kpi_10_retencion_usuarios;
-- SELECT * FROM vista_resumen_ejecutivo;
