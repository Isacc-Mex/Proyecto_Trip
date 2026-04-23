# Test 7 — Transacciones Atómicas (COMMIT y ROLLBACK)

| Campo | Detalle |
|---|---|
| **ID** | TEST-007 |
| **Nombre** | Validación de atomicidad en `txn_registrar_compra` y `txn_cancelar_compra` |
| **Descripción** | Se prueba que los stored procedures transaccionales funcionan correctamente: `txn_registrar_compra` inserta de forma atómica en `compras` y `transacciones` al mismo tiempo, y `txn_cancelar_compra` cancela la transacción y el envío sin dejar datos huérfanos. |
| **Objetivo** | Verificar que si alguna parte del proceso falla, no quedan registros parciales (ROLLBACK), y que una operación exitosa inserta todo en conjunto (COMMIT). |

## Criterios de Aprobación

- [ ] `txn_registrar_compra` crea simultáneamente 1 compra + 1 transacción en una sola operación
- [ ] El monto en la transacción coincide con el precio del producto comprado
- [ ] `txn_cancelar_compra` cambia el estatus de la transacción a `'Cancelado'`
- [ ] `txn_cancelar_compra` elimina el envío si existía
- [ ] La bitácora registra los cambios generados por ambas transacciones

## Estatus

✅ **APROBADO**

## Comandos de Prueba

```sql
-- Registrar compra atómica (usuario=1, producto=1, metodo_pago=1, divisa=1 MXN, tarjeta débito)
CALL txn_registrar_compra(1, 1, 1, 1, 'Tarjeta de debito');

-- Verificar que se creó la compra y su transacción juntas
SELECT 
    c.id_compra, c.id_usuario, c.id_producto, c.total,
    t.id_transaccion, t.monto, t.estatus, t.fecha
FROM compras c
JOIN transacciones t ON t.id_compra = c.id_compra
ORDER BY c.id_compra DESC
LIMIT 3;

-- Guardar el id_compra recién creado
SET @ultima_compra = (SELECT MAX(id_compra) FROM compras);

-- Cancelar esa compra
CALL txn_cancelar_compra(@ultima_compra);

-- Verificar que la transacción quedó en 'Cancelado'
SELECT id_transaccion, estatus
FROM transacciones
WHERE id_compra = @ultima_compra;

-- Verificar que no hay envío huérfano
SELECT COUNT(*) AS envios_huerfanos
FROM envios
WHERE id_compra = @ultima_compra;
```

## Evidencia Esperada
![Descripción de la imagen](test 7/[foto.png](https://github.com/Isacc-Mex/Proyecto_Trip/blob/main/SimulationTests/test%207/Test7.png))
