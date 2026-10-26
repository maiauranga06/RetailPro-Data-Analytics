-- Motor utilizado: Microsoft SQL Server (T-SQL)
-- Módulo 4 - Pre-entrega: Consultas SQL de negocio
-- Proyecto RetailPro | Base de datos Ventas_Tech_DB (creada en M3)
-- Continuidad M1-M3: análisis de ventas, productos y clientes con el modelo disponible.
-- Este módulo consulta únicamente dbo.ventas, sin JOIN ni modificaciones de datos.
-- Nota: las 10 ventas cargadas en M3 corresponden a marzo de 2024.

USE Ventas_Tech_DB;
GO

-- =============================================================
-- CONSULTA 1: RESUMEN EJECUTIVO MENSUAL
-- Total facturado = SUM(cantidad * precio_unitario)
-- Pedidos = COUNT(*) | Ticket promedio = facturacion / pedidos
-- Se incluye anio para no mezclar el mismo mes de distintos anios.
-- =============================================================
SELECT
    YEAR(fecha_venta) AS anio,
    MONTH(fecha_venta) AS mes,
    SUM(cantidad * precio_unitario) AS total_facturado,
    COUNT(*) AS cantidad_pedidos,
    CAST(SUM(cantidad * precio_unitario) / COUNT(*) AS DECIMAL(12,2)) AS ticket_promedio
FROM dbo.ventas
GROUP BY YEAR(fecha_venta), MONTH(fecha_venta)
ORDER BY anio, mes;
GO

-- =============================================================
-- CONSULTA 2: RANKING TOP 5 DE PRODUCTOS POR FACTURACION
-- Se trabaja con IDs, como exige M4; nombres de producto en M5.
-- =============================================================
SELECT TOP 5
    id_producto,
    SUM(cantidad) AS unidades_vendidas,
    SUM(cantidad * precio_unitario) AS total_facturado
FROM dbo.ventas
GROUP BY id_producto
ORDER BY total_facturado DESC, id_producto ASC;
GO

-- =============================================================
-- CONSULTA 3: CLIENTES RECURRENTES (MAS DE UN PEDIDO)
-- =============================================================
SELECT
    id_cliente,
    COUNT(*) AS cantidad_pedidos,
    SUM(cantidad * precio_unitario) AS total_gastado
FROM dbo.ventas
GROUP BY id_cliente
HAVING COUNT(*) > 1
ORDER BY total_gastado DESC, id_cliente ASC;
GO

-- =============================================================
-- CONSULTA 4: FACTURACION MENSUAL VS. PROMEDIO MENSUAL GENERAL
-- El promedio se calcula a partir de los totales de cada mes,
-- no de los importes de cada venta individual.
-- Si un mes coincide exactamente con el promedio, se informa
-- 'Igual al promedio' para no clasificarlo incorrectamente.
-- =============================================================
WITH facturacion_mensual AS (
    SELECT
        YEAR(fecha_venta) AS anio,
        MONTH(fecha_venta) AS mes,
        SUM(cantidad * precio_unitario) AS total_facturado
    FROM dbo.ventas
    GROUP BY YEAR(fecha_venta), MONTH(fecha_venta)
),
comparacion AS (
    SELECT
        anio,
        mes,
        total_facturado,
        AVG(total_facturado) OVER () AS promedio_mensual_general
    FROM facturacion_mensual
)
SELECT
    anio,
    mes,
    total_facturado,
    promedio_mensual_general,
    CASE
        WHEN total_facturado > promedio_mensual_general THEN 'Por encima'
        WHEN total_facturado < promedio_mensual_general THEN 'Por debajo'
        ELSE 'Igual al promedio'
    END AS comparacion_con_promedio
FROM comparacion
ORDER BY anio, mes;
GO

-- =============================================================
-- TRES HALLAZGOS CONCRETOS DE LOS DATOS DEL MODULO 3
-- =============================================================
-- 1. En marzo de 2024 se registraron 10 pedidos, con una facturacion
--    total de 6444,00 y un ticket promedio de 644,40 por pedido.
-- 2. El producto con ID 1 lidera la facturacion: 3600,00, generados
--    por 3 unidades; representa aproximadamente el 55,87 % del total.
-- 3. Los cinco clientes (IDs 1 a 5) registraron 2 pedidos cada uno.
--    El cliente ID 1 gasto mas que los demas: un total de 2640,00.
-- Nota interpretativa: al haber datos de un solo mes, marzo de 2024
-- resulta 'Igual al promedio'. No hay otros meses para comparar.
