-- ============================================================================
-- FERRETERIA POS - DATOS DE PRUEBA Y SEMILLAS INICIALES (SEEDS)
-- Base de Datos: PostgreSQL 16+
-- Descripción: Datos iniciales automatizados para arranque inmediato del sistema
-- ============================================================================

-- ============================================================================
-- 1. USUARIOS DEL SISTEMA
-- Contraseña simple para pruebas: 123
-- Hash bcrypt: $2b$10$zfbtxCRBKTzqHFVahszZ6.eTBgql.h46hoopvUbgQrsV.qieee1Em
-- ============================================================================

INSERT INTO usuarios (
  id, email, nombre, apellido, tipo_documento, numero_documento, 
  telefono, rol, estado, contrasena_hash
) VALUES 
(
  'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11',
  'admin@ferreteria.com',
  'Gerardo (Admin)',
  'Ferretero',
  'CI',
  '12345678',
  '71234567',
  'ADMIN',
  'ACTIVO',
  '$2b$10$zfbtxCRBKTzqHFVahszZ6.eTBgql.h46hoopvUbgQrsV.qieee1Em'
),
(
  'b0eebc99-9c0b-4ef8-bb6d-6bb9bd380a22',
  'gerente@ferreteria.com',
  'Carlos (Gerente)',
  'Mendoza',
  'CI',
  '87654321',
  '72345678',
  'GERENTE',
  'ACTIVO',
  '$2b$10$zfbtxCRBKTzqHFVahszZ6.eTBgql.h46hoopvUbgQrsV.qieee1Em'
),
(
  'c0eebc99-9c0b-4ef8-bb6d-6bb9bd380a33',
  'vendedor@ferreteria.com',
  'Juan (Vendedor)',
  'Pérez',
  'CI',
  '11111111',
  '73456789',
  'VENDEDOR',
  'ACTIVO',
  '$2b$10$zfbtxCRBKTzqHFVahszZ6.eTBgql.h46hoopvUbgQrsV.qieee1Em'
),
(
  'd0eebc99-9c0b-4ef8-bb6d-6bb9bd380a44',
  'almacen@ferreteria.com',
  'Miguel (Almacén)',
  'Rodríguez',
  'CI',
  '22222222',
  '74567890',
  'ALMACENERO',
  'ACTIVO',
  '$2b$10$zfbtxCRBKTzqHFVahszZ6.eTBgql.h46hoopvUbgQrsV.qieee1Em'
)
ON CONFLICT (email) DO UPDATE SET 
  contrasena_hash = EXCLUDED.contrasena_hash,
  estado = 'ACTIVO',
  activo = true;

-- ============================================================================
-- 2. CATEGORÍAS DE FERRETERÍA
-- ============================================================================

INSERT INTO categorias (id, nombre, descripcion, slug, orden_visualizacion, creado_por) VALUES
(
  'c1111111-1111-1111-1111-111111111111',
  'Herramientas Manuales',
  'Martillos, desarmadores, alicates, llaves y herramientas de mano',
  'herramientas-manuales',
  1,
  'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11'
),
(
  'c2222222-2222-2222-2222-222222222222',
  'Herramientas Eléctricas',
  'Taladros, amoladoras, sierras eléctricas y accesorios',
  'herramientas-electricas',
  2,
  'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11'
),
(
  'c3333333-3333-3333-3333-333333333333',
  'Materiales de Construcción',
  'Cemento, ladrillos, arena, estuco y fierros',
  'materiales-construccion',
  3,
  'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11'
),
(
  'c4444444-4444-4444-4444-444444444444',
  'Pinturas y Acabados',
  'Pinturas látex, al aceite, barnices, brochas y rodillos Monopol',
  'pinturas-acabados',
  4,
  'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11'
),
(
  'c5555555-5555-5555-5555-555555555555',
  'Tuberías y Plomería',
  'Tubos PVC Plasmar, accesorios, grifería y pegamentos',
  'tuberias-plomeria',
  5,
  'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11'
),
(
  'c6666666-6666-6666-6666-666666666666',
  'Electricidad y Cableado',
  'Cables de cobre, tomas, interruptores, focos LED y breakers',
  'electricidad-cableado',
  6,
  'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11'
),
(
  'c7777777-7777-7777-7777-777777777777',
  'Ferretería General',
  'Clavos, tornillos, pernos, arandelas, remaches y abrazaderas',
  'ferreteria-general',
  7,
  'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11'
)
ON CONFLICT (slug) DO NOTHING;

-- ============================================================================
-- 3. PROVEEDORES
-- ============================================================================

INSERT INTO proveedores (
  id, nombre, tipo_documento, numero_documento, contacto_nombre, contacto_email,
  direccion, ciudad, departamento, pais, telefono, email, dias_entrega, creado_por
) VALUES 
(
  '11111111-1111-1111-1111-111111111111',
  'Distribuidora Tramontina Bolivia S.R.L.',
  'NIT',
  '1020304050',
  'Roberto Flores',
  'ventas@tramontina.com.bo',
  'Av. Blanco Galindo Km 4',
  'Cochabamba',
  'Cochabamba',
  'Bolivia',
  '4-4455667',
  'contacto@tramontina.com.bo',
  2,
  'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11'
),
(
  '22222222-2222-2222-2222-222222222222',
  'Fabrica de Cemento Coboce R.L.',
  'NIT',
  '2030405060',
  'Patricia González',
  'ventas@coboce.com',
  'Av. Villazón Km 3',
  'Cochabamba',
  'Cochabamba',
  'Bolivia',
  '4-4233445',
  'info@coboce.com',
  1,
  'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11'
),
(
  '33333333-3333-3333-3333-333333333333',
  'Pinturas Monopol S.A.',
  'NIT',
  '3040506070',
  'Alexander Méndez',
  'ventas@monopol.com.bo',
  'Av. Petrolera Km 2',
  'Cochabamba',
  'Cochabamba',
  'Bolivia',
  '4-4567890',
  'contacto@monopol.com.bo',
  2,
  'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11'
),
(
  '44444444-4444-4444-4444-444444444444',
  'Plasmar Tuberías PVC S.A.',
  'NIT',
  '4050607080',
  'Gonzalo Vargas',
  'pedidos@plasmar.com.bo',
  'Zona Industrial Maica',
  'Cochabamba',
  'Cochabamba',
  'Bolivia',
  '4-4112233',
  'ventas@plasmar.com.bo',
  2,
  'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11'
)
ON CONFLICT (numero_documento) DO NOTHING;

-- ============================================================================
-- 4. PRODUCTOS DE FERRETERÍA
-- ============================================================================

INSERT INTO productos (
  codigo_producto, nombre, descripcion, categoria_id,
  precio_costo, precio_venta, margen_ganancia, unidad_medida,
  stock_actual, stock_minimo, stock_maximo, codigo_barras, creado_por
) VALUES
-- Herramientas Manuales
(
  'MART-001',
  'Martillo de Garra 500g Tramontina',
  'Martillo con mango de madera forjado de alto impacto',
  'c1111111-1111-1111-1111-111111111111',
  28.00, 45.00, 60.71, 'UNIDAD',
  45, 10, 200, '7891117001001',
  'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11'
),
(
  'DESAR-001',
  'Juego de Desarmadores 6 piezas',
  'Punta plana y phillips magnéticas aisladas 1000V',
  'c1111111-1111-1111-1111-111111111111',
  35.00, 60.00, 71.43, 'JUEGO',
  30, 8, 100, '7891117002002',
  'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11'
),
(
  'ALIC-001',
  'Alicante Universal 8" Profesional',
  'Alicante de fuerza en acero cromo vanadio',
  'c1111111-1111-1111-1111-111111111111',
  22.00, 38.00, 72.73, 'UNIDAD',
  50, 10, 150, '7891117003003',
  'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11'
),

-- Herramientas Eléctricas
(
  'TAL-001',
  'Taladro percutor Bosch 650W',
  'Taladro profesional de velocidad variable 1/2"',
  'c2222222-2222-2222-2222-222222222222',
  320.00, 480.00, 50.00, 'UNIDAD',
  12, 3, 30, '7892227001001',
  'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11'
),
(
  'AMOL-001',
  'Amoladora Angular 4 1/2" DeWalt 800W',
  'Amoladora para corte y desbaste en metal y concreto',
  'c2222222-2222-2222-2222-222222222222',
  280.00, 420.00, 50.00, 'UNIDAD',
  15, 4, 40, '7892227002002',
  'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11'
),

-- Materiales de Construcción
(
  'CEM-001',
  'Cemento Coboce IP-40 Bolsa 50kg',
  'Cemento de alta resistencia para estructuras y losas',
  'c3333333-3333-3333-3333-333333333333',
  46.00, 54.00, 17.39, 'BOLSA',
  350, 50, 1000, '7893337001001',
  'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11'
),
(
  'LAD-001',
  'Ladrillo 6 Huecos de Arcilla 18x12x24',
  'Ladrillo cerámico para tabiquería de primera calidad',
  'c3333333-3333-3333-3333-333333333333',
  1.10, 1.60, 45.45, 'UNIDAD',
  2500, 500, 10000, '7893337002002',
  'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11'
),
(
  'EST-001',
  'Estuco en Bolsa 40kg',
  'Estuco fino para revoque interior',
  'c3333333-3333-3333-3333-333333333333',
  18.00, 26.00, 44.44, 'BOLSA',
  120, 30, 500, '7893337003003',
  'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11'
),

-- Pinturas y Acabados
(
  'PINT-001',
  'Pintura Látex Lavable Blanco 1 Galón Monopol',
  'Pintura de alto cubrimiento interior y exterior',
  'c4444444-4444-4444-4444-444444444444',
  65.00, 98.00, 50.77, 'GALON',
  40, 10, 150, '7894447001001',
  'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11'
),
(
  'BROC-001',
  'Brocha 3" Cerda Natural Monopol',
  'Brocha profesional para látex y esmaltes',
  'c4444444-4444-4444-4444-444444444444',
  8.50, 15.00, 76.47, 'UNIDAD',
  80, 20, 300, '7894447002002',
  'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11'
),

-- Tuberías y Plomería
(
  'TUB-001',
  'Tubo PVC 1/2" Desagüe 4 metros Plasmar',
  'Tubo estándar para desagüe y alcantarillado',
  'c5555555-5555-5555-5555-555555555555',
  14.00, 22.00, 57.14, 'METRO',
  150, 40, 600, '7895557001001',
  'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11'
),
(
  'PEG-001',
  'Pegamento PVC Plasmar 250ml',
  'Pegamento de soldadura fría para tubos rígidos de PVC',
  'c5555555-5555-5555-5555-555555555555',
  12.00, 20.00, 66.67, 'UNIDAD',
  60, 15, 200, '7895557002002',
  'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11'
),

-- Ferretería General
(
  'CLAV-001',
  'Clavos de 2 1/2" con Cabeza (Kilo)',
  'Clavos de acero galvanizado para madera',
  'c7777777-7777-7777-7777-777777777777',
  8.00, 13.00, 62.50, 'KG',
  200, 50, 800, '7897777001001',
  'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11'
),
(
  'TORN-001',
  'Tornillos Ensamble Madera 1 1/2" Caja 100u',
  'Tornillos fosfatados rosca gruesa phillips',
  'c7777777-7777-7777-7777-777777777777',
  12.00, 22.00, 83.33, 'CAJA',
  90, 20, 300, '7897777002002',
  'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11'
)
ON CONFLICT (codigo_producto) DO NOTHING;

-- ============================================================================
-- 5. CAJA DE PRUEBA ABIERTA
-- ============================================================================

INSERT INTO caja (
  id, numero_caja, usuario_apertura, saldo_inicial, estado
) VALUES (
  'e0eebc99-9c0b-4ef8-bb6d-6bb9bd380a55',
  'CAJA-001',
  'c0eebc99-9c0b-4ef8-bb6d-6bb9bd380a33',
  300.00,
  'ABIERTA'
)
ON CONFLICT (numero_caja) DO NOTHING;

-- ============================================================================
-- FIN DE SEMILLAS
-- ============================================================================
