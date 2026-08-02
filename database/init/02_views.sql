-- ============================================================================
-- FERRETERIA POS - VISTAS ANALÍTICAS Y REPORTES
-- Base de Datos: PostgreSQL 16+
-- ============================================================================

-- VISTA: Inventario Actual
CREATE OR REPLACE VIEW vw_inventario_actual AS
SELECT
  p.id,
  p.codigo_producto,
  p.nombre AS producto,
  c.nombre AS categoria,
  p.stock_actual,
  p.stock_minimo,
  p.stock_maximo,
  CASE
    WHEN p.stock_actual <= p.stock_minimo THEN 'CRÍTICO'
    WHEN p.stock_actual <= (p.stock_minimo * 1.5) THEN 'BAJO'
    ELSE 'NORMAL'
  END AS estado_stock,
  p.precio_costo,
  p.precio_venta,
  p.margen_ganancia,
  (p.stock_actual * p.precio_costo) AS valor_inventario_costo,
  (p.stock_actual * p.precio_venta) AS valor_inventario_venta,
  p.fecha_ultimo_movimiento,
  p.estado
FROM productos p
LEFT JOIN categorias c ON p.categoria_id = c.id
WHERE p.estado = 'ACTIVO'
ORDER BY p.codigo_producto;

-- VISTA: Resumen de Ventas Diarias
CREATE OR REPLACE VIEW vw_resumen_ventas_diarias AS
SELECT
  DATE(v.fecha_venta) AS fecha,
  u.nombre || ' ' || u.apellido AS vendedor,
  COUNT(DISTINCT v.id) AS cantidad_transacciones,
  SUM(v.subtotal) AS subtotal,
  SUM(v.igv) AS igv_total,
  SUM(v.descuento_total) AS descuentos,
  SUM(v.total) AS total_ventas,
  AVG(v.total) AS ticket_promedio,
  COUNT(DISTINCT v.metodo_pago) AS formas_pago
FROM ventas v
LEFT JOIN usuarios u ON v.vendedor_id = u.id
WHERE v.estado = 'COMPLETADA'
GROUP BY DATE(v.fecha_venta), u.id, u.nombre, u.apellido
ORDER BY fecha DESC;

-- VISTA: Productos Más Vendidos
CREATE OR REPLACE VIEW vw_productos_mas_vendidos AS
SELECT
  p.codigo_producto,
  p.nombre AS producto,
  c.nombre AS categoria,
  SUM(dv.cantidad) AS cantidad_vendida,
  COUNT(DISTINCT dv.venta_id) AS transacciones,
  SUM(dv.subtotal) AS monto_total,
  AVG(dv.precio_unitario) AS precio_promedio_venta,
  ROW_NUMBER() OVER (ORDER BY COALESCE(SUM(dv.cantidad), 0) DESC) AS ranking
FROM productos p
LEFT JOIN detalle_ventas dv ON dv.producto_id = p.id
LEFT JOIN categorias c ON p.categoria_id = c.id
LEFT JOIN ventas v ON dv.venta_id = v.id AND v.estado = 'COMPLETADA'
GROUP BY p.id, p.codigo_producto, p.nombre, c.id, c.nombre
ORDER BY cantidad_vendida DESC NULLS LAST;

-- VISTA: Alertas de Stock Bajo
CREATE OR REPLACE VIEW vw_alertas_stock_bajo AS
SELECT
  p.id,
  p.codigo_producto,
  p.nombre AS producto,
  c.nombre AS categoria,
  p.stock_actual,
  p.stock_minimo,
  (p.stock_minimo - p.stock_actual) AS unidades_faltantes,
  p.precio_costo,
  ((p.stock_minimo - p.stock_actual) * p.precio_costo) AS valor_reorden,
  a.id AS alerta_id,
  COALESCE(a.leida, false) AS leida
FROM productos p
LEFT JOIN categorias c ON p.categoria_id = c.id
LEFT JOIN alertas_inventario a ON p.id = a.producto_id AND a.leida = false
WHERE p.stock_actual <= p.stock_minimo
  AND p.estado = 'ACTIVO'
ORDER BY (p.stock_minimo - p.stock_actual) DESC;

-- VISTA: Caja Diaria
CREATE OR REPLACE VIEW vw_caja_diaria AS
SELECT
  ca.id,
  ca.numero_caja,
  u1.nombre || ' ' || u1.apellido AS usuario_apertura,
  ca.fecha_apertura,
  ca.saldo_inicial,
  SUM(CASE WHEN mc.tipo_movimiento = 'INGRESO' THEN mc.monto ELSE 0 END) AS total_ingresos,
  SUM(CASE WHEN mc.tipo_movimiento = 'EGRESO' THEN mc.monto ELSE 0 END) AS total_egresos,
  ca.saldo_inicial +
    SUM(CASE WHEN mc.tipo_movimiento = 'INGRESO' THEN mc.monto ELSE 0 END) -
    SUM(CASE WHEN mc.tipo_movimiento = 'EGRESO' THEN mc.monto ELSE 0 END) AS saldo_esperado,
  ca.saldo_real,
  ca.estado
FROM caja ca
LEFT JOIN usuarios u1 ON ca.usuario_apertura = u1.id
LEFT JOIN movimientos_caja mc ON ca.id = mc.caja_id
WHERE DATE(ca.fecha_apertura) = CURRENT_DATE
GROUP BY ca.id, ca.numero_caja, u1.id, u1.nombre, u1.apellido,
         ca.fecha_apertura, ca.saldo_inicial, ca.saldo_real, ca.estado;
