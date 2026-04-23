# Test 5 — Generación de Envíos y Devoluciones para Productos Merch

| Campo | Detalle |
|---|---|
| **ID** | TEST-005 |
| **Nombre** | Validación de envíos y devoluciones en compras de tipo Merch |
| **Descripción** | Se verifica que el flujo de Merch funciona correctamente: las compras de productos tipo `'Merch'` con transacción `'Aprobado'` generan un registro en `envios`, y aproximadamente el 15% de los envíos con estatus `'Entregado'` tienen una devolución registrada en `devoluciones`. |
| **Objetivo** | Confirmar que la lógica de negocio de productos físicos (Merch) está correctamente implementada con su cadena completa: compra → envío → posible devolución. |

## Criterios de Aprobación

- [ ] Toda compra Merch Aprobada tiene un envío asociado
- [ ] Ninguna compra Skin o DLC tiene envío asociado
- [ ] Los envíos tienen número de rastreo con formato `TRIP-XXXXXXXXXX`
- [ ] Las devoluciones solo existen para envíos con estatus `'Entregado'`
- [ ] El `monto_reembolso` en devoluciones es menor o igual al `total` de la compra

## Estatus

✅ **APROBADO**

## Comandos de Prueba

```sql
-- Verificar que solo Merch Aprobado tiene envíos
SELECT 
    p.tipo,
    t.estatus AS estatus_transaccion,
    COUNT(c.id_compra) AS compras,
    COUNT(e.id_envio)  AS envios_generados
FROM compras c
JOIN productos     p ON p.id_producto = c.id_producto
JOIN transacciones t ON t.id_compra   = c.id_compra
LEFT JOIN envios   e ON e.id_compra   = c.id_compra
GROUP BY p.tipo, t.estatus
ORDER BY p.tipo, t.estatus;

-- Verificar que devoluciones solo existen para envíos Entregados
SELECT 
    e.estatus_envio,
    COUNT(d.id_devolucion) AS devoluciones
FROM devoluciones d
JOIN envios e ON e.id_envio = d.id_envio
GROUP BY e.estatus_envio;

-- Verificar formato de número de rastreo
SELECT numero_rastreo FROM envios
WHERE numero_rastreo NOT LIKE 'TRIP-'
LIMIT 5;

-- Verificar que monto_reembolso <= total de compra
SELECT d.id_devolucion, c.total, d.monto_reembolso,
       CASE WHEN d.monto_reembolso > c.total THEN 'ERROR' ELSE 'OK' END AS validacion
FROM devoluciones d
JOIN compras c ON c.id_compra = d.id_compra;
```

## Evidencia Esperada

![Test 01 -](https://github.com/Isacc-Mex/Proyecto_Trip/blob/main/SimulationTests/test%205/Test5.png)
![Test 01 -](https://github.com/Isacc-Mex/Proyecto_Trip/blob/main/SimulationTests/test%205/Test5_SELECT%20.png)
![Test 01 -](https://github.com/Isacc-Mex/Proyecto_Trip/blob/main/SimulationTests/test%205/Test5_SELECT%20FROM%20JOIN.png)
![Test 01 -](https://github.com/Isacc-Mex/Proyecto_Trip/blob/main/SimulationTests/test%205/Test5_SELECT%20WHERE.png)


