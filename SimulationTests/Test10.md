# Test 10 — Prueba de Volumen y Coherencia General del Sistema

| Campo | Detalle |
|---|---|
| **ID** | TEST-010 |
| **Nombre** | Simulación de volumen alto y verificación de coherencia general |
| **Descripción** | Se ejecutan los tres procedimientos de generación en secuencia (`generar_usuarios(10000)`, `generar_partidas(10000)`, `generar_compras(10000)`) para alcanzar un volumen representativo de datos y verificar que el sistema mantiene coherencia, rendimiento aceptable e integridad en todos los niveles. |
| **Objetivo** | Demostrar que la base de datos soporta un volumen de datos realista para un videojuego indie con cientos de usuarios activos, generando datos variados y sin degradar la integridad. |

## Criterios de Aprobación

- [ ] Los 3 procedimientos se ejecutan sin errores con volumen alto
- [ ] Total de usuarios ≥ 300 tras la ejecución
- [ ] Al menos el 60% de las transacciones tienen estatus `'Aprobado'`
- [ ] Existe variedad en divisas usadas (al menos 3 divisas distintas en transacciones)
- [ ] La distribución de tipos de producto en compras es variada (Skin, DLC y Merch presentes)
- [ ] La `vista_resumen_ejecutivo` devuelve todos los KPIs sin NULL

## Estatus

✅ **APROBADO**

## Comandos de Prueba

```sql
-- Generar volumen alto
CALL generar_usuarios(10000);
CALL generar_partidas(10000);
CALL generar_compras(10000);

-- Resumen general del sistema
SELECT 
    (SELECT COUNT(*) FROM usuarios)      AS total_usuarios,
    (SELECT COUNT(*) FROM partidas)      AS total_partidas,
    (SELECT COUNT(*) FROM compras)       AS total_compras,
    (SELECT COUNT(*) FROM transacciones) AS total_transacciones,
    (SELECT COUNT(*) FROM envios)        AS total_envios,
    (SELECT COUNT(*) FROM devoluciones)  AS total_devoluciones,
    (SELECT COUNT(*) FROM metodo_pago)   AS total_metodos_pago;

-- Verificar variedad de divisas
SELECT d.codigo, COUNT(t.id_transaccion) AS usos
FROM transacciones t
JOIN divisas d ON d.id_divisa = t.id_divisa
GROUP BY d.codigo
ORDER BY usos DESC;

-- Verificar distribución de tipos de producto
SELECT p.tipo, COUNT(c.id_compra) AS compras
FROM compras c
JOIN productos p ON p.id_producto = c.id_producto
GROUP BY p.tipo;

-- Verificar porcentaje de aprobación
SELECT 
    estatus,
    COUNT(*) AS cantidad,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM transacciones), 2) AS porcentaje
FROM transacciones
GROUP BY estatus;

-- Verificar resumen ejecutivo sin NULLs
SELECT * FROM vista_resumen_ejecutivo;

```

## Evidencia Esperada
![Test 10 -](https://github.com/Isacc-Mex/Proyecto_Trip/blob/main/SimulationTests/test%2010/Test10.png)
![Test 10 -](https://github.com/Isacc-Mex/Proyecto_Trip/blob/main/SimulationTests/test%2010/Test10_SELECT%20COUNT.png)
![Test 10 -](https://github.com/Isacc-Mex/Proyecto_Trip/blob/main/SimulationTests/test%2010/Test10_SELECT%20FROM%20JOIN.png)
![Test 10 -](https://github.com/Isacc-Mex/Proyecto_Trip/blob/main/SimulationTests/test%2010/Test10_SELECT%20FROM.png)
![Test 10 -](https://github.com/Isacc-Mex/Proyecto_Trip/blob/main/SimulationTests/test%2010/Test10_SELECT%20GROUP.png)
![Test 10 -](https://github.com/Isacc-Mex/Proyecto_Trip/blob/main/SimulationTests/test%2010/Test10_VISTA%20RESUMEN%20EJECUTIVO%20.png)
