-- ============================================================
-- PHASE 1: DATABASE SCHEMA CREATION
-- ============================================================

-- Create database (run separately if needed)
-- CREATE DATABASE inventory_db;
-- \c inventory_db;

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