
-- =====================================================
-- PROYECTO: VIVERO Smart
-- Base de datos: vivero_inteligente
-- Motor: MySQL 8.0+
-- =====================================================

CREATE DATABASE IF NOT EXISTS vivero_smart
CHARACTER SET utf8mb4
COLLATE utf8mb4_unicode_ci;

USE vivero_smart;

-- =====================================================
-- 1. TABLA DE USUARIOS Y ROLES
-- =====================================================

CREATE TABLE usuarios (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(120) NOT NULL,
    correo VARCHAR(150) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    rol ENUM('administrador','trabajador','usuario')
        NOT NULL DEFAULT 'usuario',
    telefono VARCHAR(20),
    estado ENUM('activo','inactivo') DEFAULT 'activo',
    fecha_registro TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- =====================================================
-- 2. TABLA DE CONTACTOS
-- CLIENTES Y PROVEEDORES
-- =====================================================

CREATE TABLE contactos (
    id INT AUTO_INCREMENT PRIMARY KEY,
    tipo_contacto ENUM('cliente','proveedor','ambos')
        NOT NULL,
    tipo_persona ENUM('natural','juridica')
        DEFAULT 'natural',
    identificacion VARCHAR(30) UNIQUE,
    nombre VARCHAR(150) NOT NULL,
    persona_contacto VARCHAR(120),
    telefono VARCHAR(20) NOT NULL,
    correo VARCHAR(150),
    departamento VARCHAR(100),
    municipio VARCHAR(100),
    direccion VARCHAR(200),
    estado ENUM('activo','inactivo') DEFAULT 'activo',
    observaciones TEXT,
    fecha_registro TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- =====================================================
-- 3. TABLA DE VIVEROS
-- =====================================================

CREATE TABLE viveros (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(150) NOT NULL,
    nit VARCHAR(30),
    propietario VARCHAR(150) NOT NULL,
    propietario_contacto_id INT NULL,
    departamento VARCHAR(100) DEFAULT 'Boyacá',
    municipio VARCHAR(100) DEFAULT 'Duitama',
    direccion VARCHAR(200),
    telefono VARCHAR(20) NOT NULL,
    correo VARCHAR(150),
    area DECIMAL(12,2),
    capacidad_productiva INT,
    especie_principal VARCHAR(100),
    estado ENUM('activo','inactivo','en desarrollo')
        DEFAULT 'activo',
    fecha_registro TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    creado_por INT NULL,

    FOREIGN KEY (propietario_contacto_id)
        REFERENCES contactos(id)
        ON DELETE SET NULL,

    FOREIGN KEY (creado_por)
        REFERENCES usuarios(id)
        ON DELETE SET NULL
);

-- =====================================================
-- 4. TABLA DE ESPECIES
-- =====================================================

CREATE TABLE especies (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL UNIQUE,
    descripcion TEXT,
    estado ENUM('activo','inactivo') DEFAULT 'activo'
);

INSERT INTO especies (nombre, descripcion) VALUES
('Arándano', 'Cultivo de arándano'),
('Fresa', 'Cultivo de fresa'),
('Mora', 'Cultivo de mora'),
('Frambuesa', 'Cultivo de frambuesa'),
('Manzana', 'Cultivo de manzana'),
('Durazno', 'Cultivo de durazno'),
('Otro', 'Otras especies frutales');

-- =====================================================
-- 5. TABLA DE VARIEDADES
-- =====================================================

CREATE TABLE variedades (
    id INT AUTO_INCREMENT PRIMARY KEY,
    especie_id INT NOT NULL,
    nombre VARCHAR(100) NOT NULL,
    descripcion TEXT,

    FOREIGN KEY (especie_id)
        REFERENCES especies(id)
        ON DELETE RESTRICT,

    UNIQUE (especie_id, nombre)
);

-- =====================================================
-- 6. TABLA DE LOTES
-- =====================================================

CREATE TABLE lotes (
    id INT AUTO_INCREMENT PRIMARY KEY,
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
    estado ENUM(
        'en produccion',
        'en crecimiento',
        'listo para venta',
        'finalizado'
    ) DEFAULT 'en crecimiento',
    descripcion TEXT,
    codigo_qr VARCHAR(255) UNIQUE,
    fecha_registro TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (vivero_id)
        REFERENCES viveros(id)
        ON DELETE RESTRICT,

    FOREIGN KEY (especie_id)
        REFERENCES especies(id)
        ON DELETE RESTRICT,

    FOREIGN KEY (variedad_id)
        REFERENCES variedades(id)
        ON DELETE SET NULL,

    CHECK (cantidad_inicial >= 0),
    CHECK (cantidad_actual >= 0),
    CHECK (cantidad_perdida >= 0),

    INDEX idx_lotes_vivero (vivero_id),
    INDEX idx_lotes_estado (estado)
);

-- =====================================================
-- 7. TABLA DE INSUMOS
-- =====================================================

CREATE TABLE insumos (
    id INT AUTO_INCREMENT PRIMARY KEY,
    codigo VARCHAR(50) NOT NULL UNIQUE,
    nombre VARCHAR(150) NOT NULL,
    categoria ENUM(
        'fertilizantes',
        'abonos',
        'sustratos',
        'herramientas',
        'semillas',
        'bolsas y bandejas',
        'productos fitosanitarios',
        'otros'
    ) NOT NULL,
    unidad VARCHAR(40) NOT NULL,
    descripcion TEXT,
    cantidad DECIMAL(12,2) DEFAULT 0,
    stock_minimo DECIMAL(12,2) DEFAULT 0,
    precio DECIMAL(12,2) DEFAULT 0,
    fecha_ingreso DATE,
    proveedor_id INT NULL,
    ubicacion VARCHAR(150),
    estado ENUM('activo','inactivo') DEFAULT 'activo',
    fecha_registro TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (proveedor_id)
        REFERENCES contactos(id)
        ON DELETE SET NULL,

    CHECK (cantidad >= 0),
    CHECK (stock_minimo >= 0),
    CHECK (precio >= 0),

    INDEX idx_insumos_nombre (nombre)
);

-- =====================================================
-- 8. TABLA DE ACTIVIDADES
-- =====================================================

CREATE TABLE actividades (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nombre_actividad VARCHAR(150) NOT NULL,
    tipo_actividad ENUM(
        'riego',
        'fertilizacion',
        'poda',
        'fumigacion',
        'siembra',
        'trasplante',
        'control de plagas',
        'mantenimiento',
        'otra'
    ) NOT NULL,
    lote_id INT NOT NULL,
    fecha DATE NOT NULL,
    hora TIME,
    responsable VARCHAR(120) NOT NULL,
    usuario_id INT NULL,
    estado ENUM(
        'programada',
        'en ejecucion',
        'finalizada',
        'cancelada'
    ) DEFAULT 'programada',
    duracion DECIMAL(8,2),
    observaciones TEXT,
    fecha_registro TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (lote_id)
        REFERENCES lotes(id)
        ON DELETE RESTRICT,

    FOREIGN KEY (usuario_id)
        REFERENCES usuarios(id)
        ON DELETE SET NULL,

    INDEX idx_actividades_fecha (fecha),
    INDEX idx_actividades_lote (lote_id)
);

-- =====================================================
-- 9. MOVIMIENTOS DE INSUMOS
-- ENTRADAS, SALIDAS Y AJUSTES
-- =====================================================

CREATE TABLE movimientos_insumos (
    id INT AUTO_INCREMENT PRIMARY KEY,
    insumo_id INT NOT NULL,
    actividad_id INT NULL,
    usuario_id INT NULL,
    tipo ENUM('entrada','salida','ajuste') NOT NULL,
    cantidad DECIMAL(12,2) NOT NULL,
    costo_unitario DECIMAL(12,2) DEFAULT 0,
    fecha DATE NOT NULL,
    observaciones TEXT,
    fecha_registro TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (insumo_id)
        REFERENCES insumos(id)
        ON DELETE RESTRICT,

    FOREIGN KEY (actividad_id)
        REFERENCES actividades(id)
        ON DELETE SET NULL,

    FOREIGN KEY (usuario_id)
        REFERENCES usuarios(id)
        ON DELETE SET NULL,

    CHECK (cantidad > 0),
    CHECK (costo_unitario >= 0),

    INDEX idx_movimientos_insumo (insumo_id),
    INDEX idx_movimientos_fecha (fecha)
);

-- =====================================================
-- 10. TABLA DE VENTAS
-- =====================================================

CREATE TABLE ventas (
    id INT AUTO_INCREMENT PRIMARY KEY,
    numero_venta VARCHAR(50) NOT NULL UNIQUE,
    cliente_id INT NOT NULL,
    fecha_venta DATE NOT NULL,
    subtotal DECIMAL(14,2) DEFAULT 0,
    descuento DECIMAL(14,2) DEFAULT 0,
    total DECIMAL(14,2) DEFAULT 0,
    metodo_pago ENUM(
        'efectivo',
        'transferencia bancaria',
        'consignacion',
        'otro'
    ) NOT NULL,
    estado_pago ENUM(
        'pagado',
        'pendiente',
        'abono'
    ) DEFAULT 'pendiente',
    observaciones TEXT,
    registrado_por INT NULL,
    estado ENUM('registrada','anulada')
        DEFAULT 'registrada',
    fecha_registro TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (cliente_id)
        REFERENCES contactos(id)
        ON DELETE RESTRICT,

    FOREIGN KEY (registrado_por)
        REFERENCES usuarios(id)
        ON DELETE SET NULL,

    CHECK (subtotal >= 0),
    CHECK (descuento >= 0),
    CHECK (total >= 0),

    INDEX idx_ventas_fecha (fecha_venta),
    INDEX idx_ventas_cliente (cliente_id)
);

-- =====================================================
-- 11. DETALLES DE VENTAS
-- PERMITE VARIOS LOTES EN UNA MISMA VENTA
-- =====================================================

CREATE TABLE detalle_ventas (
    id INT AUTO_INCREMENT PRIMARY KEY,
    venta_id INT NOT NULL,
    lote_id INT NOT NULL,
    cantidad INT NOT NULL,
    precio_unitario DECIMAL(12,2) NOT NULL,
    subtotal DECIMAL(14,2)
        GENERATED ALWAYS AS (
            cantidad * precio_unitario
        ) STORED,

    FOREIGN KEY (venta_id)
        REFERENCES ventas(id)
        ON DELETE RESTRICT,

    FOREIGN KEY (lote_id)
        REFERENCES lotes(id)
        ON DELETE RESTRICT,

    CHECK (cantidad > 0),
    CHECK (precio_unitario >= 0),

    INDEX idx_detalle_venta (venta_id),
    INDEX idx_detalle_lote (lote_id)
);

-- =====================================================
-- 12. HISTORIAL Y TRAZABILIDAD DE LOTES
-- =====================================================

CREATE TABLE historial_lotes (
    id INT AUTO_INCREMENT PRIMARY KEY,
    lote_id INT NOT NULL,
    usuario_id INT NULL,
    tipo_evento ENUM(
        'registro',
        'actividad',
        'entrada',
        'salida',
        'perdida',
        'venta',
        'actualizacion',
        'otro'
    ) NOT NULL,
    fecha_evento DATETIME DEFAULT CURRENT_TIMESTAMP,
    descripcion TEXT,
    cantidad INT,
    observaciones TEXT,

    FOREIGN KEY (lote_id)
        REFERENCES lotes(id)
        ON DELETE RESTRICT,

    FOREIGN KEY (usuario_id)
        REFERENCES usuarios(id)
        ON DELETE SET NULL,

    INDEX idx_historial_lote (lote_id),
    INDEX idx_historial_fecha (fecha_evento)
);

-- =====================================================
-- 13. TABLA DE ALERTAS INTELIGENTES
-- =====================================================

CREATE TABLE alertas (
    id INT AUTO_INCREMENT PRIMARY KEY,
    tipo ENUM(
        'inventario',
        'produccion',
        'perdidas',
        'ventas',
        'demanda',
        'otro'
    ) NOT NULL,
    titulo VARCHAR(150) NOT NULL,
    mensaje TEXT NOT NULL,
    nivel ENUM('bajo','medio','alto','critico')
        DEFAULT 'medio',
    lote_id INT NULL,
    insumo_id INT NULL,
    estado ENUM('pendiente','atendida','descartada')
        DEFAULT 'pendiente',
    fecha_alerta TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    atendida_por INT NULL,

    FOREIGN KEY (lote_id)
        REFERENCES lotes(id)
        ON DELETE SET NULL,

    FOREIGN KEY (insumo_id)
        REFERENCES insumos(id)
        ON DELETE SET NULL,

    FOREIGN KEY (atendida_por)
        REFERENCES usuarios(id)
        ON DELETE SET NULL,

    INDEX idx_alertas_estado (estado),
    INDEX idx_alertas_nivel (nivel)
);

-- =====================================================
-- 14. TABLA DE PAGOS Y ABONOS
-- =====================================================

CREATE TABLE pagos (
    id INT AUTO_INCREMENT PRIMARY KEY,
    venta_id INT NOT NULL,
    fecha_pago DATE NOT NULL,
    valor DECIMAL(14,2) NOT NULL,
    metodo_pago ENUM(
        'efectivo',
        'transferencia bancaria',
        'consignacion',
        'otro'
    ) NOT NULL,
    referencia VARCHAR(100),
    observaciones TEXT,
    registrado_por INT NULL,

    FOREIGN KEY (venta_id)
        REFERENCES ventas(id)
        ON DELETE RESTRICT,

    FOREIGN KEY (registrado_por)
        REFERENCES usuarios(id)
        ON DELETE SET NULL,

    CHECK (valor > 0)
);

-- =====================================================
-- 15. CONSULTAS PARA VERIFICAR LA BASE DE DATOS
-- =====================================================

SHOW TABLES;

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
