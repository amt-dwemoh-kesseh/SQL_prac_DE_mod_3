-- ============================================================
-- PHASE 3: MONITORING AND REPORTING
-- ============================================================

-- View: Customer Orders Summary
CREATE OR REPLACE VIEW customer_orders_view AS
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

-- View: Low Stock Products
CREATE OR REPLACE VIEW low_stock_view AS
SELECT
    product_id,
    name,
    stock_quantity,
    reorder_level
FROM products
WHERE stock_quantity <= reorder_level;

-- View: Customer Spending Categories
CREATE OR REPLACE VIEW customer_spending_view AS
SELECT
    c.customer_id,
    c.name,
    COALESCE(SUM(o.total_amount), 0) AS total_spent,
    CASE
        WHEN COALESCE(SUM(o.total_amount), 0) < 500 THEN 'Bronze'
        WHEN COALESCE(SUM(o.total_amount), 0) BETWEEN 500 AND 1000 THEN 'Silver'
        ELSE 'Gold'
    END AS category
FROM customers c
LEFT JOIN orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.name;

-- Procedure: Get Order Summary (for specific customer or all)
CREATE OR REPLACE FUNCTION get_order_summary(p_customer_id INT DEFAULT NULL)
RETURNS TABLE(
    customer_name VARCHAR(100),
    order_id INT,
    order_date TIMESTAMP,
    total_amount DECIMAL(10,2),
    item_count BIGINT
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        c.name,
        o.order_id,
        o.order_date,
        o.total_amount,
        COUNT(od.product_id)
    FROM customers c
    JOIN orders o ON c.customer_id = o.customer_id
    JOIN order_details od ON o.order_id = od.order_id
    WHERE (p_customer_id IS NULL OR c.customer_id = p_customer_id)
    GROUP BY c.name, o.order_id, o.order_date, o.total_amount
    ORDER BY o.order_date DESC;
END;
$$ LANGUAGE plpgsql;