# Test 8 — Validación de KPIs mediante Vistas SQL

| Campo | Detalle |
|---|---|
| **ID** | TEST-008 |
| **Nombre** | Ejecución y validación de las 11 vistas KPI |
| **Descripción** | Se consultan las 11 vistas KPI definidas en la base de datos para verificar que devuelven resultados no vacíos, con tipos de dato correctos y valores dentro de rangos lógicos para el contexto del videojuego. |
| **Objetivo** | Confirmar que todas las vistas KPI funcionan correctamente, sin errores de SQL y con datos coherentes con el modelo de monetización del videojuego TRIP. |

## Criterios de Aprobación

- [ ] Las 11 vistas se ejecutan sin errores
- [ ] `kpi_01_ingreso_total` devuelve `ingreso_total_mxn > 0`
- [ ] `kpi_02_arpu` devuelve un valor mayor a 0
- [ ] `kpi_03_ingresos_por_tipo` muestra los 3 tipos: Skin, DLC, Merch
- [ ] `kpi_05_tasa_aprobacion` muestra porcentajes que suman 100%
- [ ] `kpi_09_ingresos_mensuales` muestra al menos 2 meses distintos

## Estatus

**APROBADO**

## Comandos de Prueba

```sql
SELECT * FROM kpi_01_ingreso_total;
SELECT * FROM kpi_02_arpu;
SELECT * FROM kpi_03_ingresos_por_tipo;
SELECT * FROM kpi_04_top_productos;
SELECT * FROM kpi_05_tasa_aprobacion;
SELECT * FROM kpi_06_ingresos_por_divisa;
SELECT * FROM kpi_07_top_spenders;
SELECT * FROM kpi_08_metodos_pago;
SELECT * FROM kpi_09_ingresos_mensuales;
SELECT * FROM kpi_10_retencion_usuarios;
SELECT * FROM kpi_11_devoluciones;

-- Vista resumen ejecutivo (todos los KPIs en una fila)
SELECT * FROM vista_resumen_ejecutivo;


```

## Evidencia Esperada
![Test 08 - ](https://github.com/Isacc-Mex/Proyecto_Trip/blob/main/SimulationTests/test%208/Test8_ARPU.png)
![Test 08 - ](https://github.com/Isacc-Mex/Proyecto_Trip/blob/main/SimulationTests/test%208/Test8_DEVOLUCIONES.png)
![Test 08 - ](https://github.com/Isacc-Mex/Proyecto_Trip/blob/main/SimulationTests/test%208/Test8_INGRESO%20TOTAL.png)
![Test 08 - ](https://github.com/Isacc-Mex/Proyecto_Trip/blob/main/SimulationTests/test%208/Test8_INGRESOS%20MENSUALES.png)
![Test 08 - ](https://github.com/Isacc-Mex/Proyecto_Trip/blob/main/SimulationTests/test%208/Test8_INGRESOS%20POR%20DIVISA.png)
![Test 08 - ](https://github.com/Isacc-Mex/Proyecto_Trip/blob/main/SimulationTests/test%208/Test8_INGRESOS%20POR%20TIPO.png)
![Test 08 - ](https://github.com/Isacc-Mex/Proyecto_Trip/blob/main/SimulationTests/test%208/Test8_METODOS%20DE%20PAGO.png)
![Test 08 - ](https://github.com/Isacc-Mex/Proyecto_Trip/blob/main/SimulationTests/test%208/Test8_RETENCION%20DE%20USUARIOS.png)
![Test 08 - ](https://github.com/Isacc-Mex/Proyecto_Trip/blob/main/SimulationTests/test%208/Test8_TAZA%20DE%20APROBACION%20.png)
![Test 08 - ](https://github.com/Isacc-Mex/Proyecto_Trip/blob/main/SimulationTests/test%208/Test8_TOP%20PRODUCTOS.png)
![Test 08 - ](https://github.com/Isacc-Mex/Proyecto_Trip/blob/main/SimulationTests/test%208/Test8_TOP%20SPENDER.png)
![Test 08 - ](https://github.com/Isacc-Mex/Proyecto_Trip/blob/main/SimulationTests/test%208/Test8_VISTA%20RESUMEN%20EJECU.png)
