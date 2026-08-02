-- ============================================================================
-- FERRETERIA POS - SCHEMA PRINCIPAL DE BASE DE DATOS
-- Base de Datos: PostgreSQL 16+
-- Descripción: Tablas, tipos ENUM, índices y constraints para el sistema POS
-- ============================================================================

-- Habilitar extensión UUID
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ============================================================================
-- TIPOS ENUM DE DOMINIO
-- ============================================================================

DO $$ BEGIN
  CREATE TYPE user_role AS ENUM ('ADMIN', 'GERENTE', 'VENDEDOR', 'ALMACENERO', 'AUDITOR');
EXCEPTION
  WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
  CREATE TYPE user_status AS ENUM ('ACTIVO', 'INACTIVO', 'SUSPENDIDO');
EXCEPTION
  WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
  CREATE TYPE document_type AS ENUM ('DNI', 'RUC', 'NIT', 'PASAPORTE', 'CI');
EXCEPTION
  WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
  CREATE TYPE product_status AS ENUM ('ACTIVO', 'INACTIVO', 'DESCONTINUADO');
EXCEPTION
  WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
  CREATE TYPE sale_status AS ENUM ('PENDIENTE', 'COMPLETADA', 'CANCELADA', 'DEVUELTA');
EXCEPTION
  WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
  CREATE TYPE payment_method AS ENUM ('EFECTIVO', 'TARJETA_DEBITO', 'TARJETA_CREDITO', 'TRANSFERENCIA', 'CHEQUE', 'QR');
EXCEPTION
  WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
  CREATE TYPE purchase_status AS ENUM ('PENDIENTE', 'RECIBIDA', 'DEVUELTA', 'CANCELADA');
EXCEPTION
  WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
  CREATE TYPE estado_siat AS ENUM ('PENDIENTE', 'EMITIDA', 'ANULADA', 'RECHAZADA', 'OBSERVADA');
EXCEPTION
  WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
  CREATE TYPE canal_envio AS ENUM ('WHATSAPP', 'EMAIL', 'NINGUNO');
EXCEPTION
  WHEN duplicate_object THEN null;
END $$;

-- ============================================================================
-- TABLA: usuarios
-- ============================================================================
CREATE TABLE IF NOT EXISTS usuarios (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  email VARCHAR(255) NOT NULL UNIQUE,
  nombre VARCHAR(255) NOT NULL,
  apellido VARCHAR(255) NOT NULL,
  tipo_documento document_type NOT NULL DEFAULT 'CI',
  numero_documento VARCHAR(20) NOT NULL UNIQUE,
  telefono VARCHAR(20),
  direccion TEXT,
  rol user_role NOT NULL DEFAULT 'VENDEDOR',
  estado user_status NOT NULL DEFAULT 'ACTIVO',
  contrasena_hash VARCHAR(255) NOT NULL,
  fecha_creacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  fecha_actualizacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  fecha_ultimo_acceso TIMESTAMP,
  creado_por UUID,
  activo BOOLEAN NOT NULL DEFAULT true,
  FOREIGN KEY (creado_por) REFERENCES usuarios(id) ON DELETE SET NULL
);

-- ============================================================================
-- TABLA: categorias
-- ============================================================================
CREATE TABLE IF NOT EXISTS categorias (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  nombre VARCHAR(255) NOT NULL UNIQUE,
  descripcion TEXT,
  slug VARCHAR(255) NOT NULL UNIQUE,
  imagen_url VARCHAR(500),
  estado product_status NOT NULL DEFAULT 'ACTIVO',
  orden_visualizacion INT DEFAULT 0,
  fecha_creacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  fecha_actualizacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  creado_por UUID NOT NULL,
  FOREIGN KEY (creado_por) REFERENCES usuarios(id) ON DELETE RESTRICT
);

-- ============================================================================
-- TABLA: productos
-- ============================================================================
CREATE TABLE IF NOT EXISTS productos (
  id SERIAL PRIMARY KEY,
  codigo_producto VARCHAR(50) NOT NULL UNIQUE,
  nombre VARCHAR(255) NOT NULL,
  descripcion TEXT,
  categoria_id UUID NOT NULL,
  precio_costo DECIMAL(12, 2) NOT NULL,
  precio_venta DECIMAL(12, 2) NOT NULL,
  margen_ganancia DECIMAL(10, 2),
  unidad_medida VARCHAR(20) NOT NULL DEFAULT 'UNIDAD',
  stock_actual INT NOT NULL DEFAULT 0,
  stock_minimo INT NOT NULL DEFAULT 10,
  stock_maximo INT NOT NULL DEFAULT 1000,
  sku VARCHAR(100) UNIQUE,
  codigo_barras VARCHAR(100) UNIQUE,
  imagen_url VARCHAR(500),
  estado product_status NOT NULL DEFAULT 'ACTIVO',
  es_compuesto BOOLEAN NOT NULL DEFAULT false,
  requiere_seguimiento_lote BOOLEAN NOT NULL DEFAULT false,
  fecha_creacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  fecha_actualizacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  fecha_ultimo_movimiento TIMESTAMP,
  creado_por UUID NOT NULL,
  FOREIGN KEY (categoria_id) REFERENCES categorias(id) ON DELETE RESTRICT,
  FOREIGN KEY (creado_por) REFERENCES usuarios(id) ON DELETE RESTRICT
);

-- ============================================================================
-- TABLA: proveedores
-- ============================================================================
CREATE TABLE IF NOT EXISTS proveedores (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  nombre VARCHAR(255) NOT NULL,
  tipo_documento document_type NOT NULL DEFAULT 'NIT',
  numero_documento VARCHAR(20) NOT NULL UNIQUE,
  contacto_nombre VARCHAR(255),
  contacto_telefono VARCHAR(20),
  contacto_email VARCHAR(255),
  direccion TEXT NOT NULL,
  ciudad VARCHAR(100),
  departamento VARCHAR(100),
  pais VARCHAR(100) DEFAULT 'Bolivia',
  telefono VARCHAR(20),
  email VARCHAR(255),
  sitio_web VARCHAR(255),
  condiciones_pago VARCHAR(255),
  dias_entrega INT,
  cuenta_bancaria VARCHAR(50),
  estado user_status NOT NULL DEFAULT 'ACTIVO',
  es_acreedor BOOLEAN NOT NULL DEFAULT false,
  saldo_pendiente DECIMAL(12, 2) DEFAULT 0,
  limite_credito DECIMAL(12, 2),
  fecha_creacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  fecha_actualizacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  creado_por UUID NOT NULL,
  FOREIGN KEY (creado_por) REFERENCES usuarios(id) ON DELETE RESTRICT
);

-- ============================================================================
-- TABLA: compras
-- ============================================================================
CREATE TABLE IF NOT EXISTS compras (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  numero_compra VARCHAR(20) NOT NULL UNIQUE,
  proveedor_id UUID NOT NULL,
  fecha_compra TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  fecha_entrega_esperada TIMESTAMP,
  fecha_entrega_real TIMESTAMP,
  numero_orden_compra VARCHAR(50),
  numero_factura VARCHAR(50),
  subtotal DECIMAL(12, 2) NOT NULL,
  igv DECIMAL(12, 2) NOT NULL DEFAULT 0,
  total DECIMAL(12, 2) NOT NULL,
  descuento DECIMAL(12, 2) DEFAULT 0,
  estado purchase_status NOT NULL DEFAULT 'PENDIENTE',
  observaciones TEXT,
  creado_por UUID NOT NULL,
  fecha_creacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  fecha_actualizacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (proveedor_id) REFERENCES proveedores(id) ON DELETE RESTRICT,
  FOREIGN KEY (creado_por) REFERENCES usuarios(id) ON DELETE RESTRICT
);

-- ============================================================================
-- TABLA: detalle_compras
-- ============================================================================
CREATE TABLE IF NOT EXISTS detalle_compras (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  compra_id UUID NOT NULL,
  producto_id INT NOT NULL,
  cantidad INT NOT NULL,
  precio_unitario DECIMAL(12, 2) NOT NULL,
  subtotal DECIMAL(12, 2) NOT NULL,
  lote_id VARCHAR(100),
  fecha_vencimiento DATE,
  fecha_creacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (compra_id) REFERENCES compras(id) ON DELETE CASCADE,
  FOREIGN KEY (producto_id) REFERENCES productos(id) ON DELETE RESTRICT
);

-- ============================================================================
-- TABLA: lotes
-- ============================================================================
CREATE TABLE IF NOT EXISTS lotes (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  numero_lote VARCHAR(100) NOT NULL UNIQUE,
  producto_id INT NOT NULL,
  cantidad_inicial INT NOT NULL,
  cantidad_disponible INT NOT NULL,
  fecha_fabricacion DATE,
  fecha_vencimiento DATE NOT NULL,
  proveedor_id UUID,
  compra_id UUID,
  fecha_creacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (producto_id) REFERENCES productos(id) ON DELETE RESTRICT,
  FOREIGN KEY (proveedor_id) REFERENCES proveedores(id) ON DELETE SET NULL,
  FOREIGN KEY (compra_id) REFERENCES compras(id) ON DELETE SET NULL
);

-- ============================================================================
-- TABLA: ventas
-- ============================================================================
CREATE TABLE IF NOT EXISTS ventas (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  numero_venta VARCHAR(20) NOT NULL UNIQUE,
  numero_comprobante VARCHAR(50),
  tipo_comprobante VARCHAR(20) DEFAULT 'FACTURA',
  cliente_nombre VARCHAR(255),
  cliente_documento VARCHAR(20),
  cliente_telefono VARCHAR(20),
  fecha_venta TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  vendedor_id UUID NOT NULL,
  subtotal DECIMAL(12, 2) NOT NULL,
  igv DECIMAL(12, 2) NOT NULL DEFAULT 0,
  descuento_total DECIMAL(12, 2) DEFAULT 0,
  total DECIMAL(12, 2) NOT NULL,
  monto_pagado DECIMAL(12, 2) NOT NULL,
  vuelto DECIMAL(12, 2) DEFAULT 0,
  metodo_pago payment_method NOT NULL DEFAULT 'EFECTIVO',
  estado sale_status NOT NULL DEFAULT 'COMPLETADA',
  numero_referencia VARCHAR(100),
  observaciones TEXT,
  es_devolucion BOOLEAN NOT NULL DEFAULT false,
  venta_originalid UUID,
  fecha_cierre_caja TIMESTAMP,
  creado_por UUID,
  fecha_creacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  fecha_actualizacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (vendedor_id) REFERENCES usuarios(id) ON DELETE RESTRICT,
  FOREIGN KEY (creado_por) REFERENCES usuarios(id) ON DELETE SET NULL,
  FOREIGN KEY (venta_originalid) REFERENCES ventas(id) ON DELETE SET NULL
);

-- ============================================================================
-- TABLA: detalle_ventas
-- ============================================================================
CREATE TABLE IF NOT EXISTS detalle_ventas (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  venta_id UUID NOT NULL,
  producto_id INT NOT NULL,
  cantidad INT NOT NULL,
  precio_unitario DECIMAL(12, 2) NOT NULL,
  descuento_item DECIMAL(12, 2) DEFAULT 0,
  subtotal DECIMAL(12, 2) NOT NULL,
  lote_id UUID,
  fecha_creacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (venta_id) REFERENCES ventas(id) ON DELETE CASCADE,
  FOREIGN KEY (producto_id) REFERENCES productos(id) ON DELETE RESTRICT,
  FOREIGN KEY (lote_id) REFERENCES lotes(id) ON DELETE SET NULL
);

-- ============================================================================
-- TABLA: caja
-- ============================================================================
CREATE TABLE IF NOT EXISTS caja (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  numero_caja VARCHAR(20) NOT NULL UNIQUE,
  usuario_apertura UUID NOT NULL,
  fecha_apertura TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  saldo_inicial DECIMAL(12, 2) NOT NULL,
  saldo_esperado DECIMAL(12, 2) DEFAULT 0,
  saldo_real DECIMAL(12, 2) DEFAULT 0,
  diferencia DECIMAL(12, 2) DEFAULT 0,
  usuario_cierre UUID,
  fecha_cierre TIMESTAMP,
  observaciones TEXT,
  estado VARCHAR(20) NOT NULL DEFAULT 'ABIERTA',
  fecha_creacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  fecha_actualizacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (usuario_apertura) REFERENCES usuarios(id) ON DELETE RESTRICT,
  FOREIGN KEY (usuario_cierre) REFERENCES usuarios(id) ON DELETE SET NULL
);

-- ============================================================================
-- TABLA: movimientos_caja
-- ============================================================================
CREATE TABLE IF NOT EXISTS movimientos_caja (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  caja_id UUID NOT NULL,
  tipo_movimiento VARCHAR(50) NOT NULL,
  descripcion TEXT NOT NULL,
  monto DECIMAL(12, 2) NOT NULL,
  venta_id UUID,
  referencia VARCHAR(100),
  usuario_id UUID NOT NULL,
  fecha_creacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (caja_id) REFERENCES caja(id) ON DELETE RESTRICT,
  FOREIGN KEY (venta_id) REFERENCES ventas(id) ON DELETE SET NULL,
  FOREIGN KEY (usuario_id) REFERENCES usuarios(id) ON DELETE RESTRICT
);

-- ============================================================================
-- TABLA: alertas_inventario
-- ============================================================================
CREATE TABLE IF NOT EXISTS alertas_inventario (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  producto_id INT NOT NULL,
  tipo_alerta VARCHAR(50) NOT NULL,
  stock_actual INT NOT NULL,
  stock_minimo INT NOT NULL,
  mensaje TEXT NOT NULL,
  leida BOOLEAN NOT NULL DEFAULT false,
  fecha_creacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  fecha_actualizacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (producto_id) REFERENCES productos(id) ON DELETE CASCADE
);

-- ============================================================================
-- TABLA: auditoria
-- ============================================================================
CREATE TABLE IF NOT EXISTS auditoria (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  usuario_id UUID NOT NULL,
  entidad VARCHAR(255) NOT NULL,
  id_entidad UUID NOT NULL,
  accion VARCHAR(50) NOT NULL,
  datos_anterior JSONB,
  datos_nuevo JSONB,
  ip_address VARCHAR(45),
  user_agent TEXT,
  fecha_creacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (usuario_id) REFERENCES usuarios(id) ON DELETE SET NULL
);

-- ============================================================================
-- TABLA: facturas (SIAT Bolivia)
-- ============================================================================
CREATE TABLE IF NOT EXISTS facturas (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  venta_id UUID NOT NULL UNIQUE,
  cuf VARCHAR(150),
  cufd VARCHAR(150),
  numero_factura BIGINT NOT NULL,
  fecha_emision TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  codigo_control VARCHAR(50),
  numero_autorizacion VARCHAR(100),
  leyenda_siat TEXT,
  estado_siat estado_siat NOT NULL DEFAULT 'PENDIENTE',
  motivo_anulacion TEXT,
  fecha_anulacion TIMESTAMPTZ,
  actividad_economica VARCHAR(20) NOT NULL DEFAULT '477310',
  punto_venta INT NOT NULL DEFAULT 0,
  sucursal INT NOT NULL DEFAULT 0,
  xml_content TEXT,
  pdf_url VARCHAR(500),
  enviada_cliente BOOLEAN NOT NULL DEFAULT false,
  canal_envio canal_envio NOT NULL DEFAULT 'NINGUNO',
  fecha_envio TIMESTAMPTZ,
  destino_envio VARCHAR(255),
  creado_por UUID,
  fecha_creacion TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  fecha_actualizacion TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (venta_id) REFERENCES ventas(id) ON DELETE RESTRICT,
  FOREIGN KEY (creado_por) REFERENCES usuarios(id) ON DELETE SET NULL
);

-- ============================================================================
-- ÍNDICES DE RENDIMIENTO
-- ============================================================================
CREATE INDEX IF NOT EXISTS idx_usuarios_email ON usuarios(email);
CREATE INDEX IF NOT EXISTS idx_usuarios_numero_documento ON usuarios(numero_documento);
CREATE INDEX IF NOT EXISTS idx_usuarios_rol ON usuarios(rol);

CREATE INDEX IF NOT EXISTS idx_categorias_slug ON categorias(slug);

CREATE INDEX IF NOT EXISTS idx_productos_codigo ON productos(codigo_producto);
CREATE INDEX IF NOT EXISTS idx_productos_categoria ON productos(categoria_id);
CREATE INDEX IF NOT EXISTS idx_productos_stock ON productos(stock_actual, stock_minimo);

CREATE INDEX IF NOT EXISTS idx_ventas_fecha ON ventas(fecha_venta);
CREATE INDEX IF NOT EXISTS idx_ventas_numero ON ventas(numero_venta);
CREATE INDEX IF NOT EXISTS idx_ventas_vendedor ON ventas(vendedor_id);

CREATE INDEX IF NOT EXISTS idx_facturas_venta ON facturas(venta_id);
CREATE INDEX IF NOT EXISTS idx_facturas_cuf ON facturas(cuf);
