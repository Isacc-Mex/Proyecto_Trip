# Test 4 — Generación de Partidas y Registro de Muertes

| Campo | Detalle |
|---|---|
| **ID** | TEST-004 |
| **Nombre** | Generación de partidas con lógica de muerte para estado "perdió" |
| **Descripción** | Se ejecuta `generar_partidas(2000)` para validar que se crean registros coherentes en `partidas`, y que las partidas con `estado_final = 'perdió'` generan automáticamente un registro en `muerte_partida` con un `id_muerte` válido del catálogo `tipos_muerte`. |
| **Objetivo** | Verificar que la relación entre `partidas` y `muerte_partida` es coherente: solo las partidas perdidas tienen registro de muerte, y el tipo de muerte referencia correctamente a `tipos_muerte`. |

## Criterios de Aprobación

- [ ] Se insertan 2000 nuevos registros en `partidas`
- [ ] Las partidas con `estado_final = 'perdió'` tienen exactamente 1 registro en `muerte_partida`
- [ ] Las partidas con `estado_final = 'ganó'` o `'abandonó'` NO tienen registro en `muerte_partida`
- [ ] El `id_muerte` en `muerte_partida` existe en la tabla `tipos_muerte`
- [ ] El `nivel_alcanzado` está entre 1 y 10

## Estatus

✅ **APROBADO**

## Comandos de Prueba

```sql
-- Ejecutar procedimiento
CALL generar_partidas(2000);

-- Verificar que solo partidas perdidas tienen muerte registrada
SELECT 
    p.estado_final,
    COUNT(p.id_partida)    AS total_partidas,
    COUNT(mp.id)           AS con_registro_muerte
FROM partidas p
LEFT JOIN muerte_partida mp ON mp.id_partida = p.id_partida
GROUP BY p.estado_final;

-- Verificar integridad referencial de id_muerte
SELECT mp.id_muerte, tm.descripcion, COUNT(*) AS ocurrencias
FROM muerte_partida mp
JOIN tipos_muerte tm ON tm.id_muerte = mp.id_muerte
GROUP BY mp.id_muerte, tm.descripcion
ORDER BY ocurrencias DESC;

-- Verificar rango de nivel
SELECT 
    MIN(nivel_alcanzado) AS nivel_min,
    MAX(nivel_alcanzado) AS nivel_max,
    AVG(nivel_alcanzado) AS nivel_promedio
FROM partidas;
```

## Evidencia Esperada
