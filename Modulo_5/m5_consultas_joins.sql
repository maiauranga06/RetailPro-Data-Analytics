-- Motor utilizado: Microsoft SQL Server (T-SQL)
-- Modulo 5 - Pre-entrega: Consultas con JOINs para RetailPro
-- Base: Ventas_Tech_DB, creada en el Modulo 3 (4 tablas, 25 registros)
-- Continuidad M1-M4: analizamos clientes, productos, categorias y ventas.
-- La columna clientes.ciudad permite analizar y filtrar geograficamente,
-- sin modificar el esquema ni los registros exigidos en M3.
-- IMPORTANTE: los origenes de Consulta 4 son PERIODOS definidos para el ejercicio;
-- no representan canales comerciales reales (no hay columna canal en M3).

USE Ventas_Tech_DB;
GO

-- ============================================================
-- CONSULTA 1: Vista base del proyecto (INNER JOIN)
-- Proposito: integrar ventas con cliente, ciudad, producto y categoria
-- para analizar facturacion por fecha, producto y ubicacion en Power BI.
-- ============================================================
SELECT
    v.id_venta,
    v.fecha_venta AS fecha,
    c.id_cliente,
    c.nombre AS nombre_cliente,
    c.ciudad AS ciudad_cliente,
    p.id_producto,
    p.nombre_producto AS descripcion_producto,
    cat.nombre_categoria AS categoria_producto,
    v.cantidad,
    v.precio_unitario,
    CAST(v.cantidad * v.precio_unitario AS DECIMAL(12,2)) AS total_venta
FROM dbo.ventas AS v
INNER JOIN dbo.clientes AS c
    ON v.id_cliente = c.id_cliente
INNER JOIN dbo.productos AS p
    ON v.id_producto = p.id_producto
INNER JOIN dbo.categorias AS cat
    ON p.id_categoria = cat.id_categoria
ORDER BY v.fecha_venta, v.id_venta;
-- Hallazgo: las 10 ventas de marzo de 2024 suman 6444.00.
-- La vista permite desagregar esa facturacion por ciudad y categoria sin duplicar transacciones.
GO

-- ============================================================
-- CONSULTA 2: Clientes sin ventas (LEFT JOIN)
-- Proposito: detectar clientes sin compras para seguimiento del area CRM.
-- ============================================================
SELECT
    c.id_cliente,
    c.nombre AS nombre_cliente,
    c.email,
    c.fecha_registro
FROM dbo.clientes AS c
LEFT JOIN dbo.ventas AS v
    ON c.id_cliente = v.id_cliente
WHERE v.id_venta IS NULL
ORDER BY c.id_cliente;
-- Hallazgo: 0 de los 5 clientes registrados estan sin compras.
-- CRM no tiene clientes inactivos por primera compra en estos datos de ejemplo.
GO

-- ============================================================
-- CONSULTA 3: Productos sin ventas (LEFT JOIN)
-- Proposito: identificar productos sin movimiento para el area de producto.
-- ============================================================
SELECT
    p.id_producto,
    p.nombre_producto,
    cat.nombre_categoria AS categoria,
    p.precio
FROM dbo.productos AS p
INNER JOIN dbo.categorias AS cat
    ON p.id_categoria = cat.id_categoria
LEFT JOIN dbo.ventas AS v
    ON p.id_producto = v.id_producto
WHERE v.id_venta IS NULL
ORDER BY p.id_producto;
-- Hallazgo: 0 de los 6 productos del catalogo quedaron sin ventas.
-- El area de producto no detecta articulos sin movimiento en esta muestra.
GO

-- ============================================================
-- CONSULTA 4: Consolidado por origen (UNION ALL)
-- Proposito: comparar la facturacion de dos periodos disjuntos.
-- 'canal' es una etiqueta LITERAL del origen de cada SELECT,
-- no una columna existente ni un canal de venta real.
-- ============================================================
SELECT
    consolidado.canal,
    CAST(SUM(consolidado.total) AS DECIMAL(12,2)) AS total_canal
FROM (
    SELECT
        v.fecha_venta,
        CAST(v.cantidad * v.precio_unitario AS DECIMAL(12,2)) AS total,
        'Periodo 05-10 mar' AS canal
    FROM dbo.ventas AS v
    WHERE v.fecha_venta >= '20240305' AND v.fecha_venta < '20240311'

    UNION ALL

    SELECT
        v.fecha_venta,
        CAST(v.cantidad * v.precio_unitario AS DECIMAL(12,2)) AS total,
        'Periodo 11-15 mar' AS canal
    FROM dbo.ventas AS v
    WHERE v.fecha_venta >= '20240311' AND v.fecha_venta < '20240316'
) AS consolidado
GROUP BY consolidado.canal
ORDER BY consolidado.canal;
-- Hallazgo: el periodo del 05 al 10 de marzo facturo 3620.00;
-- el del 11 al 15, 2824.00. El primer periodo genero 796.00 mas.
-- Son periodos de ejemplo, no canales comerciales observados.
GO
