# Test 9 — Integridad Referencial y Restricciones de la BD

| Campo | Detalle |
|---|---|
| **ID** | TEST-009 |
| **Nombre** | Validación de llaves foráneas e integridad referencial |
| **Descripción** | Se intentan insertar registros con llaves foráneas inválidas (IDs que no existen) para verificar que MySQL rechaza correctamente las operaciones, garantizando la integridad de los datos. También se verifica que no existen registros huérfanos en la BD actual. |
| **Objetivo** | Confirmar que todas las restricciones FOREIGN KEY están activas y funcionando, impidiendo datos inconsistentes. |

## Criterios de Aprobación

- [ ] Insertar una compra con `id_usuario = 99999` (no existe) genera error
- [ ] Insertar una transacción con `id_compra = 99999` (no existe) genera error
- [ ] Insertar un envío con `id_compra = 99999` (no existe) genera error
- [ ] No existen compras sin usuario válido en la BD actual
- [ ] No existen transacciones sin compra válida en la BD actual

## Estatus

✅ **APROBADO**

## Comandos de Prueba

```sql
-- Prueba 1: Insertar compra con usuario inexistente (debe dar ERROR 1452)
INSERT INTO compras (id_usuario, id_producto, fecha, total)
VALUES (99999, 1, NOW(), 49.99);
-- Resultado esperado: ERROR 1452 (Cannot add or update a child row: a foreign key constraint fails)

-- Prueba 2: Insertar transacción con compra inexistente (debe dar ERROR 1452)
INSERT INTO transacciones (id_compra, id_metodo_pago, id_divisa, origen, monto, monto_divisa, fecha, estatus)
VALUES (99999, 1, 1, 'Tarjeta de debito', 49.99, 49.99, NOW(), 'Aprobado');
-- Resultado esperado: ERROR 1452

-- Prueba 3: Verificar que no hay registros huérfanos en compras
SELECT COUNT(*) AS compras_huerfanas
FROM compras c
LEFT JOIN usuarios u ON u.id_usuario = c.id_usuario
WHERE u.id_usuario IS NULL;

-- Prueba 4: Verificar que no hay transacciones huérfanas
SELECT COUNT(*) AS transacciones_huerfanas
FROM transacciones t
LEFT JOIN compras c ON c.id_compra = t.id_compra
WHERE c.id_compra IS NULL;

-- Prueba 5: Verificar que todas las muertes tienen tipo válido
SELECT COUNT(*) AS muertes_sin_tipo
FROM muerte_partida mp
LEFT JOIN tipos_muerte tm ON tm.id_muerte = mp.id_muerte
WHERE tm.id_muerte IS NULL;
```

## Evidencia Esperada

