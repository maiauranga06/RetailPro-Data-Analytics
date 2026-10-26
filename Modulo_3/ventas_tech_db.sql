-- Motor utilizado: Microsoft SQL Server (T-SQL)
-- Módulo 3 - Checkpoint: Script SQL de Ingeniería de Datos
-- Proyecto RetailPro / base de referencia Ventas_Tech_DB (TechStore)
-- Continuidad con M1-M2: se mantienen clientes, categorias, productos y ventas.
-- La consigna M3 fija un modelo reducido de 4 tablas y 25 registros exactos:
-- territorios, segmento, costo, canal y total_venta del diseño de M2 no se implementan aquí.
-- Por eso este checkpoint no permite todavía el análisis regional ni por segmento de M1.

IF DB_ID(N'Ventas_Tech_DB') IS NULL
BEGIN
    CREATE DATABASE Ventas_Tech_DB;
END;
GO
USE Ventas_Tech_DB;
GO

-- ============================================================
-- SECCIÓN 1: DROP TABLES (orden inverso a dependencias)
-- ============================================================
DROP TABLE IF EXISTS dbo.ventas;
DROP TABLE IF EXISTS dbo.productos;
DROP TABLE IF EXISTS dbo.clientes;
DROP TABLE IF EXISTS dbo.categorias;
GO

-- ============================================================
-- SECCIÓN 2: CREATE TABLES (tablas y restricciones)
-- ============================================================
CREATE TABLE dbo.categorias (
    id_categoria INT PRIMARY KEY,
    nombre_categoria VARCHAR(50) NOT NULL,
    descripcion VARCHAR(200)
);

CREATE TABLE dbo.clientes (
    id_cliente INT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE,
    ciudad VARCHAR(50),
    fecha_registro DATE NOT NULL
);

CREATE TABLE dbo.productos (
    id_producto INT PRIMARY KEY,
    nombre_producto VARCHAR(100) NOT NULL,
    id_categoria INT,
    precio DECIMAL(10,2) NOT NULL,
    stock INT DEFAULT 0,
    activo BIT DEFAULT 1,
    CONSTRAINT FK_productos_categorias FOREIGN KEY (id_categoria)
        REFERENCES dbo.categorias(id_categoria)
);

CREATE TABLE dbo.ventas (
    id_venta INT PRIMARY KEY,
    id_cliente INT,
    id_producto INT,
    cantidad INT NOT NULL,
    precio_unitario DECIMAL(10,2) NOT NULL,
    fecha_venta DATE NOT NULL,
    CONSTRAINT FK_ventas_clientes FOREIGN KEY (id_cliente)
        REFERENCES dbo.clientes(id_cliente),
    CONSTRAINT FK_ventas_productos FOREIGN KEY (id_producto)
        REFERENCES dbo.productos(id_producto)
);
GO

-- ============================================================
-- SECCIÓN 3: INSERT DATA (25 registros exactos)
-- ============================================================
INSERT INTO dbo.categorias (id_categoria, nombre_categoria, descripcion) VALUES
    (1, 'Computación',    'Laptops, PCs y monitores'),
    (2, 'Accesorios',     'Periféricos y complementos'),
    (3, 'Audio',          'Auriculares y parlantes'),
    (4, 'Almacenamiento', 'Discos y memorias');

INSERT INTO dbo.clientes (id_cliente, nombre, email, ciudad, fecha_registro) VALUES
    (1, 'María López',   'maria@mail.com',  'Buenos Aires', '2024-01-05'),
    (2, 'Carlos Ruiz',   'carlos@mail.com', 'Córdoba',      '2024-01-10'),
    (3, 'Ana Gómez',     'ana@mail.com',    'Rosario',      '2024-02-01'),
    (4, 'Pedro Sanz',    'pedro@mail.com',  'Mendoza',      '2024-02-15'),
    (5, 'Laura Torres',  'laura@mail.com',  'Tucumán',      '2024-03-01');

INSERT INTO dbo.productos (id_producto, nombre_producto, id_categoria, precio, stock, activo) VALUES
    (1, 'Laptop Pro 15',      1, 1200.00, 15, 1),
    (2, 'Mouse Inalámbrico',  2,   28.00, 80, 1),
    (3, 'Monitor 4K 27',      1,  450.00, 12, 1),
    (4, 'Auriculares BT Pro', 3,  120.00, 35, 1),
    (5, 'SSD Externo 1TB',    4,  130.00, 18, 1),
    (6, 'Teclado Mecánico',   2,   95.00, 40, 1);

INSERT INTO dbo.ventas (id_venta, id_cliente, id_producto, cantidad, precio_unitario, fecha_venta) VALUES
    ( 1, 1, 1, 2, 1200.00, '2024-03-05'),
    ( 2, 2, 2, 5,   28.00, '2024-03-06'),
    ( 3, 3, 3, 1,  450.00, '2024-03-07'),
    ( 4, 1, 4, 2,  120.00, '2024-03-08'),
    ( 5, 4, 5, 3,  130.00, '2024-03-10'),
    ( 6, 2, 6, 4,   95.00, '2024-03-11'),
    ( 7, 5, 1, 1, 1200.00, '2024-03-12'),
    ( 8, 3, 2, 8,   28.00, '2024-03-13'),
    ( 9, 4, 4, 1,  120.00, '2024-03-14'),
    (10, 5, 3, 2,  450.00, '2024-03-15');
GO

-- ============================================================
-- SECCIÓN 4: VALIDACIÓN (4, 5, 6 y 10 filas esperadas)
-- ============================================================
SELECT * FROM dbo.categorias; -- esperado: 4 filas
SELECT * FROM dbo.clientes;   -- esperado: 5 filas
SELECT * FROM dbo.productos;  -- esperado: 6 filas
SELECT * FROM dbo.ventas;     -- esperado: 10 filas
