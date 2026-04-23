# Test 2 — Generación de Compras con Transacciones y Métodos de Pago

| Campo | Detalle |
|---|---|
| **ID** | TEST-002 |
| **Nombre** | Generación de compras con `generar_compras` |
| **Descripción** | Se ejecuta el procedimiento `generar_compras(5000)` para validar que por cada compra generada se crea automáticamente: un método de pago vinculado al usuario, una transacción con divisa aleatoria, y en caso de producto Merch aprobado, un envío. |
| **Objetivo** | Verificar la cadena completa `compras → metodo_pago → transacciones` y que la lógica de Merch activa `envios` correctamente. |

## Criterios de Aprobación

- [ ] Se generan 5000 registros nuevos en `compras`
- [ ] Cada compra tiene exactamente 1 transacción asociada
- [ ] Cada transacción tiene un `id_metodo_pago` válido (existe en `metodo_pago`)
- [ ] Las compras de Merch Aprobadas tienen al menos 1 envío asociado
- [ ] Los estados de transacción están dentro del ENUM válido

## Estatus

✅ **APROBADO**

## Comandos de Prueba

```sql
-- Ejecutar el procedimiento
CALL generar_compras(5000);

-- Verificar que cada compra tiene su transacción
SELECT 
    COUNT(c.id_compra)          AS total_compras,
    COUNT(t.id_transaccion)     AS total_transacciones,
    COUNT(c.id_compra) - COUNT(t.id_transaccion) AS sin_transaccion
FROM compras c
LEFT JOIN transacciones t ON t.id_compra = c.id_compra;

-- Verificar distribución de estatus de transacciones
SELECT estatus, COUNT(*) AS cantidad
FROM transacciones
GROUP BY estatus;

-- Verificar que compras Merch Aprobadas tienen envío
SELECT 
    p.tipo,
    t.estatus,
    COUNT(c.id_compra)  AS compras,
    COUNT(e.id_envio)   AS con_envio
FROM compras c
JOIN productos     p ON p.id_producto = c.id_producto
JOIN transacciones t ON t.id_compra   = c.id_compra
LEFT JOIN envios   e ON e.id_compra   = c.id_compra
WHERE p.tipo = 'Merch'
GROUP BY p.tipo, t.estatus;
```

## Evidencia Esperada

