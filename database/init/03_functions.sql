-- ============================================================================
-- FERRETERIA POS - FUNCIONES Y PROCEDIMIENTOS ALMACENADOS
-- Base de Datos: PostgreSQL 16+
-- ============================================================================

-- Function: Crear alerta de inventario
CREATE OR REPLACE FUNCTION crear_alerta_inventario(
  p_producto_id INT
) RETURNS BOOLEAN AS $$
DECLARE
  v_stock_actual INT;
  v_stock_minimo INT;
  v_tipo_alerta VARCHAR;
  v_mensaje TEXT;
BEGIN
  SELECT p.stock_actual, p.stock_minimo
  INTO v_stock_actual, v_stock_minimo
  FROM productos p
  WHERE p.id = p_producto_id;

  IF v_stock_actual <= 0 THEN
    v_tipo_alerta := 'SIN_STOCK';
    v_mensaje := 'Producto agotado - Reorden urgente';
  ELSIF v_stock_actual <= v_stock_minimo THEN
    v_tipo_alerta := 'STOCK_BAJO';
    v_mensaje := 'Stock bajo - Considerar reorden';
  ELSE
    RETURN TRUE;
  END IF;

  INSERT INTO alertas_inventario (
    producto_id, tipo_alerta, stock_actual,
    stock_minimo, mensaje, leida
  )
  SELECT
    p_producto_id, v_tipo_alerta, v_stock_actual,
    v_stock_minimo, v_mensaje, false
  WHERE NOT EXISTS (
    SELECT 1 FROM alertas_inventario
    WHERE producto_id = p_producto_id AND leida = false
  );

  RETURN TRUE;
END;
$$ LANGUAGE plpgsql;

-- Function: Actualizar stock por venta
CREATE OR REPLACE FUNCTION actualizar_stock_venta(
  p_detalle_venta_id UUID
) RETURNS BOOLEAN AS $$
DECLARE
  v_producto_id INT;
  v_cantidad INT;
  v_stock_actual INT;
BEGIN
  SELECT dv.producto_id, dv.cantidad
  INTO v_producto_id, v_cantidad
  FROM detalle_ventas dv
  WHERE dv.id = p_detalle_venta_id;

  SELECT p.stock_actual
  INTO v_stock_actual
  FROM productos p
  WHERE p.id = v_producto_id;

  IF v_stock_actual < v_cantidad THEN
    RAISE EXCEPTION 'Stock insuficiente para el producto %', v_producto_id;
  END IF;

  UPDATE productos
  SET
    stock_actual = stock_actual - v_cantidad,
    fecha_ultimo_movimiento = CURRENT_TIMESTAMP
  WHERE id = v_producto_id;

  PERFORM crear_alerta_inventario(v_producto_id);

  RETURN TRUE;
END;
$$ LANGUAGE plpgsql;

-- Function: Generar número secuencial de venta
CREATE OR REPLACE FUNCTION generar_numero_venta(
  p_prefijo VARCHAR DEFAULT 'VENTA'
) RETURNS VARCHAR AS $$
DECLARE
  v_numero VARCHAR;
  v_contador INT;
BEGIN
  SELECT COUNT(*) + 1
  INTO v_contador
  FROM ventas
  WHERE DATE(fecha_venta) = CURRENT_DATE;

  v_numero := p_prefijo || '-' || TO_CHAR(CURRENT_DATE, 'YYYYMMDD') || '-' ||
              LPAD(v_contador::TEXT, 6, '0');

  RETURN v_numero;
END;
$$ LANGUAGE plpgsql;
