# Test 6 — Validación de Funciones SQL

| Campo | Detalle |
|---|---|
| **ID** | TEST-006 |
| **Nombre** | Prueba de las 5 funciones personalizadas de la BD |
| **Descripción** | Se ejecutan las 5 funciones definidas en la base de datos: `fn_convertir_divisa`, `fn_total_gastado_usuario`, `fn_tasa_conversion_usuario`, `fn_nivel_promedio_usuario` y `fn_clasificar_usuario`, verificando que devuelven resultados correctos y consistentes con los datos existentes. |
| **Objetivo** | Confirmar que cada función retorna el tipo de dato correcto, maneja casos borde (usuario sin compras, divisa inexistente) y sus resultados son coherentes entre sí. |

## Criterios de Aprobación

- [ ] `fn_convertir_divisa` devuelve el monto correctamente convertido usando el tipo de cambio de `divisas`
- [ ] `fn_total_gastado_usuario` devuelve 0 para un usuario sin compras aprobadas
- [ ] `fn_tasa_conversion_usuario` devuelve un valor entre 0 y 100
- [ ] `fn_nivel_promedio_usuario` devuelve un valor entre 1 y 10
- [ ] `fn_clasificar_usuario` devuelve únicamente 'Alto', 'Medio' o 'Bajo'

## Estatus

✅ **APROBADO**

## Comandos de Prueba

```sql
-- FN 1: Convertir 100 MXN a USD (id_divisa=2, tipo_cambio=0.05)
-- Resultado esperado: 5.0000
SELECT fn_convertir_divisa(100.00, 2) AS mxn_a_usd;

-- FN 1: Convertir 100 MXN a EUR (id_divisa=3, tipo_cambio=0.046)
SELECT fn_convertir_divisa(100.00, 3) AS mxn_a_eur;

-- FN 2: Total gastado del usuario 1
SELECT 
    id_usuario,
    nombre,
    fn_total_gastado_usuario(id_usuario) AS total_gastado_mxn
FROM usuarios
WHERE id_usuario IN (1, 2, 3, 4, 5);

-- FN 3: Tasa de conversión (debe estar entre 0 y 100)
SELECT 
    id_usuario,
    fn_tasa_conversion_usuario(id_usuario) AS tasa_pct
FROM usuarios
WHERE id_usuario IN (1, 2, 3)
ORDER BY id_usuario;

-- FN 4: Nivel promedio de los primeros 5 usuarios
SELECT 
    u.id_usuario,
    u.nombre,
    fn_nivel_promedio_usuario(u.id_usuario) AS nivel_promedio
FROM usuarios u
LIMIT 5;

-- FN 5: Clasificación de usuarios
SELECT 
    id_usuario,
    nombre,
    fn_total_gastado_usuario(id_usuario) AS gasto,
    fn_clasificar_usuario(id_usuario)    AS segmento
FROM usuarios
ORDER BY gasto DESC
LIMIT 10;
```

## Evidencia Esperada

![Test 06 -](https://github.com/Isacc-Mex/Proyecto_Trip/blob/main/SimulationTests/test%206/Test6.png)
![Test 06 -](https://github.com/Isacc-Mex/Proyecto_Trip/blob/main/SimulationTests/test%206/Test6_SELECT%20AS.png)
![Test 06 -](https://github.com/Isacc-Mex/Proyecto_Trip/blob/main/SimulationTests/test%206/Test6_SELECT%20FROM%20GROUP.png)
![Test 06 -](https://github.com/Isacc-Mex/Proyecto_Trip/blob/main/SimulationTests/test%206/Test6_SELECT%20FROM.png)
![Test 06 -](https://github.com/Isacc-Mex/Proyecto_Trip/blob/main/SimulationTests/test%206/Test6_SELECT%20WHERE.png)
