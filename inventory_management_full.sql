
-- ============================================================
-- INVENTORY AND ORDER MANAGEMENT SYSTEM (PostgreSQL Project)
-- Description: Complete SQL Script (Phases 1 - 5)
-- ============================================================

-- ============================================================
-- PHASE 1: DATABASE CREATION AND SCHEMA DESIGN
-- ============================================================

-- 1️⃣ Create database
CREATE DATABASE inventory_db;

-- Connect to the new database
\c inventory_db;

-- Drop existing tables if rerunning
DROP TABLE IF EXISTS inventory_logs, order_details, orders, products, customers CASCADE;

-- PRODUCTS TABLE
CREATE TABLE products (
  product_id SERIAL PRIMARY KEY,
  name VARCHAR(100) NOT NULL,
  category VARCHAR(50),
  price DECIMAL(10,2) NOT NULL,
  stock_quantity INT NOT NULL CHECK (stock_quantity >= 0),
  reorder_level INT NOT NULL DEFAULT 10
);

-- CUSTOMERS TABLE
CREATE TABLE customers (
  customer_id SERIAL PRIMARY KEY,
  name VARCHAR(100) NOT NULL,
  email VARCHAR(100) UNIQUE NOT NULL,
  phone VARCHAR(20)
);

-- ORDERS TABLE
CREATE TABLE orders (
  order_id SERIAL PRIMARY KEY,
  customer_id INT NOT NULL REFERENCES customers(customer_id) ON DELETE CASCADE,
  order_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  total_amount DECIMAL(10,2) DEFAULT 0
);

-- ORDER DETAILS TABLE
CREATE TABLE order_details (
  order_id INT REFERENCES orders(order_id) ON DELETE CASCADE,
  product_id INT REFERENCES products(product_id),
  quantity INT NOT NULL CHECK (quantity > 0),
  price DECIMAL(10,2) NOT NULL,
  PRIMARY KEY (order_id, product_id)
);

-- INVENTORY LOGS TABLE
CREATE TABLE inventory_logs (
  log_id SERIAL PRIMARY KEY,
  product_id INT REFERENCES products(product_id),
  change_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  change_type VARCHAR(50),
  quantity_change INT
);

-- SAMPLE DATA
INSERT INTO products (name, category, price, stock_quantity, reorder_level) VALUES
('Laptop', 'Electronics', 1200.00, 20, 5),
('Headphones', 'Accessories', 150.00, 50, 10),
('Office Chair', 'Furniture', 300.00, 15, 3);

INSERT INTO customers (name, email, phone) VALUES
('Alice Johnson', 'alice@example.com', '123456789'),
('Bob Smith', 'bob@example.com', '987654321');

-- ============================================================
-- PHASE 2: ORDER PLACEMENT & INVENTORY MANAGEMENT
-- ============================================================

-- Example Order Placement Process
INSERT INTO orders (customer_id) VALUES (1) RETURNING order_id;

-- Assume order_id = 1
INSERT INTO order_details (order_id, product_id, quantity, price)
VALUES
(1, 1, 1, 1200.00),
(1, 2, 2, 150.00);

-- Deduct stock
UPDATE products SET stock_quantity = stock_quantity - 1 WHERE product_id = 1;
UPDATE products SET stock_quantity = stock_quantity - 2 WHERE product_id = 2;

-- Update total
UPDATE orders
SET total_amount = (SELECT SUM(quantity * price) FROM order_details WHERE order_id = 1)
WHERE order_id = 1;

-- Log changes
INSERT INTO inventory_logs (product_id, change_type, quantity_change) VALUES
(1, 'Order Placed', -1),
(2, 'Order Placed', -2);

-- ============================================================
-- PHASE 3: MONITORING & REPORTING
-- ============================================================

-- Orders by Customer
CREATE OR REPLACE VIEW customer_orders_view AS
SELECT c.name AS customer_name, o.order_id, o.order_date, o.total_amount, COUNT(od.product_id) AS item_count
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
JOIN order_details od ON o.order_id = od.order_id
GROUP BY c.name, o.order_id, o.order_date, o.total_amount;

-- Low Stock Products
CREATE OR REPLACE VIEW low_stock_view AS
SELECT product_id, name, stock_quantity, reorder_level
FROM products
WHERE stock_quantity < reorder_level;

-- Customer Spending Category
CREATE OR REPLACE VIEW customer_spending_view AS
SELECT 
  c.customer_id,
  c.name,
  SUM(o.total_amount) AS total_spent,
  CASE
    WHEN SUM(o.total_amount) < 500 THEN 'Bronze'
    WHEN SUM(o.total_amount) BETWEEN 500 AND 1000 THEN 'Silver'
    ELSE 'Gold'
  END AS category
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.name;

-- ============================================================
-- PHASE 4: STOCK REPLENISHMENT & AUTOMATION
-- ============================================================

-- Replenish low-stock items
UPDATE products SET stock_quantity = stock_quantity + 100 WHERE stock_quantity < reorder_level;

-- Log replenishment
INSERT INTO inventory_logs (product_id, change_type, quantity_change)
SELECT product_id, 'Replenishment', 100 FROM products WHERE stock_quantity >= reorder_level;

-- Trigger: Auto-update inventory when new order detail inserted
CREATE OR REPLACE FUNCTION update_inventory_on_order()
RETURNS TRIGGER AS $$
BEGIN
  UPDATE products
  SET stock_quantity = stock_quantity - NEW.quantity
  WHERE product_id = NEW.product_id;

  INSERT INTO inventory_logs (product_id, change_type, quantity_change)
  VALUES (NEW.product_id, 'Auto Deduction', -NEW.quantity);
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_update_inventory
AFTER INSERT ON order_details
FOR EACH ROW
EXECUTE FUNCTION update_inventory_on_order();

-- ============================================================
-- PHASE 5: ADVANCED QUERIES & OPTIMIZATION
-- ============================================================

-- Order Summary View
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

-- Low Stock Summary View (enhanced)
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

-- Optimization Suggestions
CREATE INDEX idx_orders_customer_id ON orders(customer_id);
CREATE INDEX idx_order_details_product_id ON order_details(product_id);
