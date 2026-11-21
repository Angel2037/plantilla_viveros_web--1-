
-- =====================================================
-- PROYECTO: VIVERO Smart
-- Base de datos: vivero_inteligente
-- Motor: Microsoft SQL Server Express
-- =====================================================

IF DB_ID(N'vivero_smart') IS NULL
    CREATE DATABASE vivero_smart;
GO

USE vivero_smart;
GO
SET NOCOUNT ON;
GO

-- =====================================================
-- 1. TABLA DE USUARIOS Y ROLES
-- IMPORTANTE: guardar contrasenas usando hash seguro desde PHP; nunca texto plano.
-- =====================================================

CREATE TABLE dbo.usuarios (
    id INT IDENTITY(1,1) PRIMARY KEY,
    nombre VARCHAR(120) NOT NULL,
    correo VARCHAR(150) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    rol NVARCHAR(13)
        NOT NULL DEFAULT 'usuario' CHECK (rol IN (N'administrador', N'trabajador', N'usuario')),
    telefono VARCHAR(20),
    estado NVARCHAR(10) DEFAULT 'activo' CHECK (estado IN (N'activo', N'inactivo')),
    fecha_registro DATETIME2(0) NOT NULL DEFAULT SYSDATETIME()
);
GO

-- =====================================================
-- 2. TABLA DE CONTACTOS
-- CLIENTES Y PROVEEDORES
-- =====================================================

CREATE TABLE dbo.contactos (
    id INT IDENTITY(1,1) PRIMARY KEY,
    tipo_contacto NVARCHAR(10)
        NOT NULL CHECK (tipo_contacto IN (N'cliente', N'proveedor', N'ambos')),
    tipo_persona NVARCHAR(10)
        DEFAULT 'natural' CHECK (tipo_persona IN (N'natural', N'juridica')),
    identificacion VARCHAR(30) UNIQUE,
    nombre VARCHAR(150) NOT NULL,
    persona_contacto VARCHAR(120),
    telefono VARCHAR(20) NOT NULL,
    correo VARCHAR(150),
    departamento VARCHAR(100),
    municipio VARCHAR(100),
    direccion VARCHAR(200),
    estado NVARCHAR(10) DEFAULT 'activo' CHECK (estado IN (N'activo', N'inactivo')),
    observaciones NVARCHAR(MAX),
    fecha_registro DATETIME2(0) NOT NULL DEFAULT SYSDATETIME()
);
GO

-- =====================================================
-- 3. TABLA DE VIVEROS
-- =====================================================

CREATE TABLE dbo.viveros (
    id INT IDENTITY(1,1) PRIMARY KEY,
    nombre VARCHAR(150) NOT NULL,
    nit VARCHAR(30),
    propietario VARCHAR(150) NOT NULL,
    propietario_contacto_id INT NULL,
    departamento VARCHAR(100) DEFAULT N'Boyacá',
    municipio VARCHAR(100) DEFAULT 'Duitama',
    direccion VARCHAR(200),
    telefono VARCHAR(20) NOT NULL,
    correo VARCHAR(150),
    area DECIMAL(12,2),
    capacidad_productiva INT,
    especie_principal VARCHAR(100),
    estado NVARCHAR(13)
        DEFAULT 'activo' CHECK (estado IN (N'activo', N'inactivo', N'en desarrollo')),
    fecha_registro DATETIME2(0) NOT NULL DEFAULT SYSDATETIME(),
    creado_por INT NULL,

    FOREIGN KEY (propietario_contacto_id)
        REFERENCES contactos(id)
        ON DELETE SET NULL,

    FOREIGN KEY (creado_por)
        REFERENCES usuarios(id)
        ON DELETE SET NULL
);
GO

-- =====================================================
-- 4. TABLA DE ESPECIES
-- =====================================================

CREATE TABLE dbo.especies (
    id INT IDENTITY(1,1) PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL UNIQUE,
    descripcion NVARCHAR(MAX),
    estado NVARCHAR(19) CHECK (estado IN (N'activo', N'inactivo', N'activo', N'Arándano', N'Cultivo de arándano')),
('Fresa', 'Cultivo de fresa'),
('Mora', 'Cultivo de mora'),
('Frambuesa', 'Cultivo de frambuesa'),
('Manzana', 'Cultivo de manzana'),
('Durazno', 'Cultivo de durazno'),
('Otro', 'Otras especies frutales');
GO

-- =====================================================
-- 5. TABLA DE VARIEDADES
-- =====================================================

CREATE TABLE dbo.variedades (
    id INT IDENTITY(1,1) PRIMARY KEY,
    especie_id INT NOT NULL,
    nombre VARCHAR(100) NOT NULL,
    descripcion NVARCHAR(MAX),

    FOREIGN KEY (especie_id)
        REFERENCES especies(id)
        ON DELETE NO ACTION,

    UNIQUE (especie_id, nombre)
);
GO

-- =====================================================
-- 6. TABLA DE LOTES
-- =====================================================

CREATE TABLE dbo.lotes (
    id INT IDENTITY(1,1) PRIMARY KEY,
    vivero_id INT NOT NULL,
    codigo_lote VARCHAR(50) NOT NULL UNIQUE,
    nombre_lote VARCHAR(120),
    especie_id INT NOT NULL,
    variedad_id INT NULL,
    cantidad_inicial INT NOT NULL,
    cantidad_actual INT NOT NULL,
    cantidad_perdida INT DEFAULT 0,
    unidad VARCHAR(30) DEFAULT 'Plantas',
    fecha_establecimiento DATE NOT NULL,
    fecha_finalizacion DATE,
    ubicacion VARCHAR(150),
    responsable VARCHAR(120),
    estado NVARCHAR(16) DEFAULT 'en crecimiento' CHECK (estado IN (N'en produccion', N'en crecimiento', N'listo para venta', N'finalizado')),
    descripcion NVARCHAR(MAX),
    codigo_qr VARCHAR(255) UNIQUE,
    fecha_registro DATETIME2(0) NOT NULL DEFAULT SYSDATETIME(),

    FOREIGN KEY (vivero_id)
        REFERENCES viveros(id)
        ON DELETE NO ACTION,

    FOREIGN KEY (especie_id)
        REFERENCES especies(id)
        ON DELETE NO ACTION,

    FOREIGN KEY (variedad_id)
        REFERENCES variedades(id)
        ON DELETE SET NULL,

    CHECK (cantidad_inicial >= 0),
    CHECK (cantidad_actual >= 0),
    CHECK (cantidad_perdida >= 0)
);
GO

-- =====================================================
-- 7. TABLA DE INSUMOS
-- =====================================================

CREATE TABLE dbo.insumos (
    id INT IDENTITY(1,1) PRIMARY KEY,
    codigo VARCHAR(50) NOT NULL UNIQUE,
    nombre VARCHAR(150) NOT NULL,
    categoria NVARCHAR(24) NOT NULL CHECK (categoria IN (N'fertilizantes', N'abonos', N'sustratos', N'herramientas', N'semillas', N'bolsas y bandejas', N'productos fitosanitarios', N'otros')),
    unidad VARCHAR(40) NOT NULL,
    descripcion NVARCHAR(MAX),
    cantidad DECIMAL(12,2) DEFAULT 0,
    stock_minimo DECIMAL(12,2) DEFAULT 0,
    precio DECIMAL(12,2) DEFAULT 0,
    fecha_ingreso DATE,
    proveedor_id INT NULL,
    ubicacion VARCHAR(150),
    estado NVARCHAR(10) DEFAULT 'activo' CHECK (estado IN (N'activo', N'inactivo')),
    fecha_registro DATETIME2(0) NOT NULL DEFAULT SYSDATETIME(),

    FOREIGN KEY (proveedor_id)
        REFERENCES contactos(id)
        ON DELETE SET NULL,

    CHECK (cantidad >= 0),
    CHECK (stock_minimo >= 0),
    CHECK (precio >= 0)
);
GO

-- =====================================================
-- 8. TABLA DE ACTIVIDADES
-- =====================================================

CREATE TABLE dbo.actividades (
    id INT IDENTITY(1,1) PRIMARY KEY,
    nombre_actividad VARCHAR(150) NOT NULL,
    tipo_actividad NVARCHAR(17) NOT NULL CHECK (tipo_actividad IN (N'riego', N'fertilizacion', N'poda', N'fumigacion', N'siembra', N'trasplante', N'control de plagas', N'mantenimiento', N'otra')),
    lote_id INT NOT NULL,
    fecha DATE NOT NULL,
    hora TIME,
    responsable VARCHAR(120) NOT NULL,
    usuario_id INT NULL,
    estado NVARCHAR(12) DEFAULT 'programada' CHECK (estado IN (N'programada', N'en ejecucion', N'finalizada', N'cancelada')),
    duracion DECIMAL(8,2),
    observaciones NVARCHAR(MAX),
    fecha_registro DATETIME2(0) NOT NULL DEFAULT SYSDATETIME(),

    FOREIGN KEY (lote_id)
        REFERENCES lotes(id)
        ON DELETE NO ACTION,

    FOREIGN KEY (usuario_id)
        REFERENCES usuarios(id)
        ON DELETE SET NULL
);
GO

-- =====================================================
-- 9. MOVIMIENTOS DE INSUMOS
-- ENTRADAS, SALIDAS Y AJUSTES
-- =====================================================

CREATE TABLE dbo.movimientos_insumos (
    id INT IDENTITY(1,1) PRIMARY KEY,
    insumo_id INT NOT NULL,
    actividad_id INT NULL,
    usuario_id INT NULL,
    tipo NVARCHAR(10) NOT NULL CHECK (tipo IN (N'entrada', N'salida', N'ajuste')),
    cantidad DECIMAL(12,2) NOT NULL,
    costo_unitario DECIMAL(12,2) DEFAULT 0,
    fecha DATE NOT NULL,
    observaciones NVARCHAR(MAX),
    fecha_registro DATETIME2(0) NOT NULL DEFAULT SYSDATETIME(),

    FOREIGN KEY (insumo_id)
        REFERENCES insumos(id)
        ON DELETE NO ACTION,

    FOREIGN KEY (actividad_id)
        REFERENCES actividades(id)
        ON DELETE SET NULL,

    FOREIGN KEY (usuario_id)
        REFERENCES usuarios(id)
        ON DELETE SET NULL,

    CHECK (cantidad > 0),
    CHECK (costo_unitario >= 0)
);
GO

-- =====================================================
-- 10. TABLA DE VENTAS
-- =====================================================

CREATE TABLE dbo.ventas (
    id INT IDENTITY(1,1) PRIMARY KEY,
    numero_venta VARCHAR(50) NOT NULL UNIQUE,
    cliente_id INT NOT NULL,
    fecha_venta DATE NOT NULL,
    subtotal DECIMAL(14,2) DEFAULT 0,
    descuento DECIMAL(14,2) DEFAULT 0,
    total DECIMAL(14,2) DEFAULT 0,
    metodo_pago NVARCHAR(22) NOT NULL CHECK (metodo_pago IN (N'efectivo', N'transferencia bancaria', N'consignacion', N'otro')),
    estado_pago NVARCHAR(10) DEFAULT 'pendiente' CHECK (estado_pago IN (N'pagado', N'pendiente', N'abono')),
    observaciones NVARCHAR(MAX),
    registrado_por INT NULL,
    estado NVARCHAR(10)
        DEFAULT 'registrada' CHECK (estado IN (N'registrada', N'anulada')),
    fecha_registro DATETIME2(0) NOT NULL DEFAULT SYSDATETIME(),

    FOREIGN KEY (cliente_id)
        REFERENCES contactos(id)
        ON DELETE NO ACTION,

    FOREIGN KEY (registrado_por)
        REFERENCES usuarios(id)
        ON DELETE SET NULL,

    CHECK (subtotal >= 0),
    CHECK (descuento >= 0),
    CHECK (total >= 0)
);
GO

-- =====================================================
-- 11. DETALLES DE VENTAS
-- PERMITE VARIOS LOTES EN UNA MISMA VENTA
-- =====================================================

CREATE TABLE dbo.detalle_ventas (
    id INT IDENTITY(1,1) PRIMARY KEY,
    venta_id INT NOT NULL,
    lote_id INT NOT NULL,
    cantidad INT NOT NULL,
    precio_unitario DECIMAL(12,2) NOT NULL,
    subtotal AS (cantidad * precio_unitario) PERSISTED,

    FOREIGN KEY (venta_id)
        REFERENCES ventas(id)
        ON DELETE NO ACTION,

    FOREIGN KEY (lote_id)
        REFERENCES lotes(id)
        ON DELETE NO ACTION,

    CHECK (cantidad > 0),
    CHECK (precio_unitario >= 0)
);
GO

-- =====================================================
-- 12. HISTORIAL Y TRAZABILIDAD DE LOTES
-- =====================================================

CREATE TABLE dbo.historial_lotes (
    id INT IDENTITY(1,1) PRIMARY KEY,
    lote_id INT NOT NULL,
    usuario_id INT NULL,
    tipo_evento NVARCHAR(13) NOT NULL CHECK (tipo_evento IN (N'registro', N'actividad', N'entrada', N'salida', N'perdida', N'venta', N'actualizacion', N'otro')),
    fecha_evento DATETIME2(0) NOT NULL DEFAULT SYSDATETIME(),
    descripcion NVARCHAR(MAX),
    cantidad INT,
    observaciones NVARCHAR(MAX),

    FOREIGN KEY (lote_id)
        REFERENCES lotes(id)
        ON DELETE NO ACTION,

    FOREIGN KEY (usuario_id)
        REFERENCES usuarios(id)
        ON DELETE SET NULL
);
GO

-- =====================================================
-- 13. TABLA DE ALERTAS INTELIGENTES
-- =====================================================

CREATE TABLE dbo.alertas (
    id INT IDENTITY(1,1) PRIMARY KEY,
    tipo NVARCHAR(10) NOT NULL CHECK (tipo IN (N'inventario', N'produccion', N'perdidas', N'ventas', N'demanda', N'otro')),
    titulo VARCHAR(150) NOT NULL,
    mensaje NVARCHAR(MAX) NOT NULL,
    nivel NVARCHAR(10)
        DEFAULT 'medio' CHECK (nivel IN (N'bajo', N'medio', N'alto', N'critico')),
    lote_id INT NULL,
    insumo_id INT NULL,
    estado NVARCHAR(10)
        DEFAULT 'pendiente' CHECK (estado IN (N'pendiente', N'atendida', N'descartada')),
    fecha_alerta DATETIME2(0) NOT NULL DEFAULT SYSDATETIME(),
    atendida_por INT NULL,

    FOREIGN KEY (lote_id)
        REFERENCES lotes(id)
        ON DELETE SET NULL,

    FOREIGN KEY (insumo_id)
        REFERENCES insumos(id)
        ON DELETE SET NULL,

    FOREIGN KEY (atendida_por)
        REFERENCES usuarios(id)
        ON DELETE SET NULL
);
GO

-- =====================================================
-- 14. TABLA DE PAGOS Y ABONOS
-- =====================================================

CREATE TABLE dbo.pagos (
    id INT IDENTITY(1,1) PRIMARY KEY,
    venta_id INT NOT NULL,
    fecha_pago DATE NOT NULL,
    valor DECIMAL(14,2) NOT NULL,
    metodo_pago NVARCHAR(22) NOT NULL CHECK (metodo_pago IN (N'efectivo', N'transferencia bancaria', N'consignacion', N'otro')),
    referencia VARCHAR(100),
    observaciones NVARCHAR(MAX),
    registrado_por INT NULL,

    FOREIGN KEY (venta_id)
        REFERENCES ventas(id)
        ON DELETE NO ACTION,

    FOREIGN KEY (registrado_por)
        REFERENCES usuarios(id)
        ON DELETE SET NULL,

    CHECK (valor > 0)
);
GO


-- =====================================================
-- INDICES PARA OPTIMIZAR CONSULTAS
-- =====================================================
CREATE INDEX idx_lotes_vivero ON dbo.lotes (vivero_id);
GO
CREATE INDEX idx_lotes_estado ON dbo.lotes (estado);
GO
CREATE INDEX idx_insumos_nombre ON dbo.insumos (nombre);
GO
CREATE INDEX idx_actividades_fecha ON dbo.actividades (fecha);
GO
CREATE INDEX idx_actividades_lote ON dbo.actividades (lote_id);
GO
CREATE INDEX idx_movimientos_insumo ON dbo.movimientos_insumos (insumo_id);
GO
CREATE INDEX idx_movimientos_fecha ON dbo.movimientos_insumos (fecha);
GO
CREATE INDEX idx_ventas_fecha ON dbo.ventas (fecha_venta);
GO
CREATE INDEX idx_ventas_cliente ON dbo.ventas (cliente_id);
GO
CREATE INDEX idx_detalle_venta ON dbo.detalle_ventas (venta_id);
GO
CREATE INDEX idx_detalle_lote ON dbo.detalle_ventas (lote_id);
GO
CREATE INDEX idx_historial_lote ON dbo.historial_lotes (lote_id);
GO
CREATE INDEX idx_historial_fecha ON dbo.historial_lotes (fecha_evento);
GO
CREATE INDEX idx_alertas_estado ON dbo.alertas (estado);
GO
CREATE INDEX idx_alertas_nivel ON dbo.alertas (nivel);
GO

-- =====================================================
-- 15. CONSULTAS PARA VERIFICAR LA BASE DE DATOS
-- =====================================================

SELECT name AS nombre_tabla FROM sys.tables ORDER BY name;

-- Consultar usuarios
SELECT id, nombre, correo, rol, estado
FROM usuarios;

-- Consultar viveros
SELECT * FROM viveros;

-- Consultar lotes y sus viveros
SELECT
    l.codigo_lote,
    l.nombre_lote,
    v.nombre AS vivero,
    e.nombre AS especie,
    l.cantidad_actual,
    l.estado
FROM lotes l
INNER JOIN viveros v ON l.vivero_id = v.id
INNER JOIN especies e ON l.especie_id = e.id;

-- Consultar inventario
SELECT
    codigo,
    nombre,
    cantidad,
    stock_minimo,
    CASE
        WHEN cantidad <= stock_minimo
        THEN 'STOCK BAJO'
        ELSE 'STOCK NORMAL'
    END AS estado_inventario
FROM insumos;

-- Consultar ventas
SELECT
    v.numero_venta,
    c.nombre AS cliente,
    v.fecha_venta,
    v.total,
    v.estado_pago
FROM ventas v
INNER JOIN contactos c ON v.cliente_id = c.id;

-- Consultar historial de trazabilidad
SELECT
    l.codigo_lote,
    h.tipo_evento,
    h.fecha_evento,
    h.descripcion
FROM historial_lotes h
INNER JOIN lotes l ON h.lote_id = l.id
ORDER BY h.fecha_evento DESC;
