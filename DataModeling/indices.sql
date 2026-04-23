-- ============================================================
--  Base de Datos: db_trip  |  Videojuego con Monetización
--  Archivo     : indices.sql
--  Descripción : Índices secundarios definidos sobre las tablas
--                principales. Mejoran el rendimiento de consultas
--                de KPIs, filtros por estatus, fecha y relaciones
--                entre tablas.
--  Nota        : Los índices de llave foránea (fk_*) y de llave
--                primaria (PK) ya se crean en el script principal
--                de la BD. Este archivo documenta únicamente los
--                índices de rendimiento (idx_*) y los únicos (uk_*).
-- ============================================================

USE db_trip;

-- ============================================================
--  TABLA: compras
-- ============================================================

-- Búsquedas y agrupaciones por fecha de compra (KPI de ingresos por período)
CREATE INDEX IF NOT EXISTS idx_compras_fecha
    ON compras (fecha);

-- Filtros y conteos por producto comprado
CREATE INDEX IF NOT EXISTS idx_compras_producto
    ON compras (id_producto);


-- ============================================================
--  TABLA: devoluciones
-- ============================================================

-- Filtrar devoluciones por estatus (Solicitada, Aprobada, Reembolsada…)
CREATE INDEX IF NOT EXISTS idx_dev_estatus
    ON devoluciones (estatus);

-- Agrupar y contar devoluciones por motivo
CREATE INDEX IF NOT EXISTS idx_dev_motivo
    ON devoluciones (motivo);


-- ============================================================
--  TABLA: divisas
-- ============================================================

-- Código ISO único para evitar divisas duplicadas (ej. MXN, USD, EUR)
CREATE UNIQUE INDEX IF NOT EXISTS uk_codigo
    ON divisas (codigo);


-- ============================================================
--  TABLA: envios
-- ============================================================

-- Filtrar envíos por su estado (Pendiente, En camino, Entregado, Cancelado)
CREATE INDEX IF NOT EXISTS idx_envios_estatus
    ON envios (estatus_envio);


-- ============================================================
--  TABLA: metodo_pago
-- ============================================================

-- Buscar métodos de pago activos / expirados de un usuario
CREATE INDEX IF NOT EXISTS idx_mp_estatus
    ON metodo_pago (estatus);


-- ============================================================
--  TABLA: muerte_partida
-- ============================================================

-- Análisis de causas de muerte más frecuentes en partidas
CREATE INDEX IF NOT EXISTS idx_muerte_tipo
    ON muerte_partida (tipo_muerte);


-- ============================================================
--  TABLA: partidas
-- ============================================================

-- Consultas de partidas de un usuario específico
CREATE INDEX IF NOT EXISTS idx_partidas_usuario
    ON partidas (id_usuario);

-- Filtrar partidas por resultado (ganó / perdió / abandonó)
CREATE INDEX IF NOT EXISTS idx_partidas_estado
    ON partidas (estado_final);

-- Ordenar o filtrar partidas por nivel alcanzado
CREATE INDEX IF NOT EXISTS idx_partidas_nivel
    ON partidas (nivel_alcanzado);


-- ============================================================
--  TABLA: transacciones
-- ============================================================

-- KPIs de tasa de aprobación y filtros por estatus de pago
CREATE INDEX IF NOT EXISTS idx_trans_estatus
    ON transacciones (estatus);

-- Análisis de transacciones por divisa utilizada
CREATE INDEX IF NOT EXISTS idx_trans_divisa
    ON transacciones (id_divisa);

-- Consultas y agrupaciones de transacciones por fecha
CREATE INDEX IF NOT EXISTS idx_trans_fecha
    ON transacciones (fecha);


-- ============================================================
--  TABLA: usuarios
-- ============================================================

-- Búsqueda de usuario por email (login / validación de duplicados)
CREATE INDEX IF NOT EXISTS idx_usuarios_email
    ON usuarios (email);

-- Segmentación de usuarios por fecha de registro (cohortes)
CREATE INDEX IF NOT EXISTS idx_usuarios_fecha
    ON usuarios (fecha_registro);


-- ============================================================
-- VERIFICAR ÍNDICES CREADOS
-- ============================================================
-- SHOW INDEX FROM compras;
-- SHOW INDEX FROM transacciones;
-- SHOW INDEX FROM usuarios;
-- SELECT TABLE_NAME, INDEX_NAME, COLUMN_NAME
--   FROM information_schema.STATISTICS
--  WHERE TABLE_SCHEMA = 'db_trip'
--  ORDER BY TABLE_NAME, INDEX_NAME;
-- ============================================================
