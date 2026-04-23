# Test 1 — Generación Masiva de Usuarios

| Campo | Detalle |
|---|---|
| **ID** | TEST-001 |
| **Nombre** | Generación masiva de usuarios con `generar_usuarios` |
| **Descripción** | Se ejecuta el procedimiento almacenado `generar_usuarios` con un parámetro de 1000 registros para validar que genera usuarios con datos coherentes: nombre de gamertag, email con dominio válido, contraseña hasheada y fecha de registro dentro del rango esperado. |
| **Objetivo** | Verificar que el procedimiento `generar_usuarios` inserta el número correcto de registros en la tabla `usuarios` con todos los campos poblados y sin violar restricciones de integridad. |

## Criterios de Aprobación

- [ ] Se insertan exactamente 1000 nuevos registros en `usuarios`
- [ ] Ningún campo `nombre`, `email` o `fecha_registro` es NULL
- [ ] Los emails tienen formato `texto@dominio.com`
- [ ] Las fechas de registro están entre `2025-01-01` y la fecha actual
- [ ] No se generan errores de constraint (PK duplicada, etc.)

## Estatus

✅ **APROBADO**

## Comandos de Prueba

```sql
-- Ejecutar el procedimiento
CALL generar_usuarios(1000);

-- Verificar cantidad insertada
SELECT COUNT(*) AS total_usuarios FROM usuarios;

-- Verificar que no hay NULLs en campos críticos
SELECT COUNT(*) AS registros_incompletos
FROM usuarios
WHERE nombre IS NULL OR email IS NULL OR fecha_registro IS NULL;

-- Verificar formato de email
SELECT nombre, email, fecha_registro
FROM usuarios
ORDER BY id_usuario DESC
LIMIT 10;

-- Verificar rango de fechas
SELECT 
    MIN(fecha_registro) AS fecha_mas_antigua,
    MAX(fecha_registro) AS fecha_mas_reciente
FROM usuarios;
```

## Evidencia Esperada
![Test 01 - ](https://github.com/Isacc-Mex/Proyecto_Trip/blob/main/SimulationTests/test%201/Test1.png)
![Test 01 - ](https://github.com/Isacc-Mex/Proyecto_Trip/blob/main/SimulationTests/test%201/Test1_SELECT%20COUNT.png)
![Test 01 - ](https://github.com/Isacc-Mex/Proyecto_Trip/blob/main/SimulationTests/test%201/Test1_SELECT%20FROM%20FECHAS.png)
![Test 01 - ](https://github.com/Isacc-Mex/Proyecto_Trip/blob/main/SimulationTests/test%201/Test1_SELECT%20ORDER%20BY%20.png)




