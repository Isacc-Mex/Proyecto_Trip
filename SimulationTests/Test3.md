# Test 3 — Funcionamiento de Triggers en Bitácora

| Campo | Detalle |
|---|---|
| **ID** | TEST-003 |
| **Nombre** | Validación de triggers INSERT / UPDATE / DELETE en bitácora |
| **Descripción** | Se realizan operaciones de INSERT, UPDATE y DELETE sobre las tablas `compras`, `usuarios` y `productos` para verificar que los triggers correspondientes registran automáticamente cada operación en la tabla `bitacora` con la información correcta. |
| **Objetivo** | Confirmar que la bitácora captura todos los eventos de modificación de datos de forma automática, sin intervención manual. |

## Criterios de Aprobación

- [ ] Cada INSERT en `compras` genera 1 registro en `bitacora` con `operacion = 'INSERT'`
- [ ] Cada UPDATE genera 1 registro con `operacion = 'UPDATE'`
- [ ] Cada DELETE genera 1 registro con `operacion = 'DELETE'`
- [ ] El campo `descripcion` de bitácora contiene información relevante del registro afectado
- [ ] El campo `fecha` en bitácora coincide aproximadamente con el momento de la operación

## Estatus

✅ **APROBADO**

## Comandos de Prueba

```sql
-- Contar registros en bitácora antes
SELECT COUNT(*) AS bitacora_antes FROM bitacora;

-- INSERT → debe generar trigger
INSERT INTO usuarios (nombre, email, contraseña, fecha_registro)
VALUES ('TestUser999', 'test999@gmail.com', 'abc123hash', NOW());

-- UPDATE → debe generar trigger
UPDATE usuarios SET email = 'test999_nuevo@gmail.com'
WHERE nombre = 'TestUser999';

-- DELETE → debe generar trigger
DELETE FROM usuarios WHERE nombre = 'TestUser999';

-- Verificar los 3 registros en bitácora
SELECT tabla, operacion, id_registro, descripcion, fecha
FROM bitacora
ORDER BY id_bitacora DESC
LIMIT 5;

```

## Evidencia Esperada
![Test 03](https://github.com/Isacc-Mex/Proyecto_Trip/blob/main/SimulationTests/test%203/Test3.png)
![Test 03](https://github.com/Isacc-Mex/Proyecto_Trip/blob/main/SimulationTests/test%203/Test3_DELETE.png)
![Test 03](https://github.com/Isacc-Mex/Proyecto_Trip/blob/main/SimulationTests/test%203/Test3_INSERT.png)
![Test 03](https://github.com/Isacc-Mex/Proyecto_Trip/blob/main/SimulationTests/test%203/Test3_SELECT%20GROUP%20BY.png)
![Test 03](https://github.com/Isacc-Mex/Proyecto_Trip/blob/main/SimulationTests/test%203/Test3_UPDATE.png
)
