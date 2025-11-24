-- ============================================================
-- PHASE 5: ADVANCED QUERIES AND OPTIMIZATION
-- ============================================================

-- View: Order Summary (enhanced)
CREATE OR REPLACE VIEW order_summary_view AS
SELECT
    c.name AS customer_name,
    o.order_id,
    o.order_date,
    o.total_amount,
    COUNT(od.product_id) AS item_count
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
JOIN order_details od ON o.order_id = od.order_id
GROUP BY c.name, o.order_id, o.order_date, o.total_amount;

-- View: Low Stock Status (with status indicator)
CREATE OR REPLACE VIEW low_stock_status_view AS
SELECT
    product_id,
    name,
    stock_quantity,
    reorder_level,
    CASE
        WHEN stock_quantity < reorder_level THEN 'LOW'
        ELSE 'OK'
    END AS stock_status
FROM products;

-- Indexes for performance
CREATE INDEX IF NOT EXISTS idx_orders_customer_id ON orders(customer_id);
CREATE INDEX IF NOT EXISTS idx_order_details_product_id ON order_details(product_id);
CREATE INDEX IF NOT EXISTS idx_inventory_logs_product_id ON inventory_logs(product_id);
CREATE INDEX IF NOT EXISTS idx_orders_date ON orders(order_date);

-- Procedure: Get Period-Based Order Analytics
CREATE OR REPLACE FUNCTION get_period_orders(p_start_date DATE, p_end_date DATE)
RETURNS TABLE(
    total_orders BIGINT,
    total_revenue DECIMAL(10,2),
    total_items BIGINT
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        COUNT(DISTINCT o.order_id),
        COALESCE(SUM(o.total_amount), 0),
        COALESCE(SUM(od.quantity), 0)
    FROM orders o
    LEFT JOIN order_details od ON o.order_id = od.order_id
    WHERE o.order_date::DATE BETWEEN p_start_date AND p_end_date;
END;
$$ LANGUAGE plpgsql;