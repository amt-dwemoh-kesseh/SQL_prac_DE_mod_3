# Inventory and Order Management System

This project demonstrates a PostgreSQL-based inventory and order management system. It includes a complete SQL script (`inventory_management_full.sql`) for database schema creation, sample data insertion, and business logic implementation.

## Overview

The system manages products, customers, orders, and inventory through automated triggers and views. It covers phases from schema design to optimization, including order placement, reporting, and stock replenishment.

## Prerequisites

- **PostgreSQL**: Installed and running locally (default port 5432, or as configured).
- Access to PostgreSQL shell (`psql`) or a GUI tool like pgAdmin.

## Setup and Execution

### 1. Create the Database
Open PostgreSQL shell or your preferred GUI tool and create the database:
```sql
CREATE DATABASE inventory_db;
```

### 2. Connect to the Database
Connect to the newly created database:
```sql
\c inventory_db;
```

### 3. Execute the SQL Script
Run the entire `inventory_management_full.sql` script. You can do this in several ways:

#### Option A: Using psql Command Line
```bash
psql -U your_username -d inventory_db -f inventory_management_full.sql
```

#### Option B: Using pgAdmin or Similar GUI
- Open the SQL script in pgAdmin.
- Execute the entire script.

#### Option C: Copy-Paste in psql
- Open psql and connect to `inventory_db`.
- Copy and paste the contents of `inventory_management_full.sql` and execute.

### 4. Verify Setup
After execution, verify the setup by running some queries:
```sql
-- Check tables
\dt

-- Check views
\dv

-- Sample data check
SELECT * FROM products;
SELECT * FROM customers;
SELECT * FROM orders;
```

## Phases Demonstrated

The SQL script is organized into phases:

- **Phase 1: Database Creation and Schema Design**
  - Creates tables: `products`, `customers`, `orders`, `order_details`, `inventory_logs`
  - Defines relationships and constraints

- **Phase 2: Order Placement & Inventory Management**
  - Inserts sample data
  - Demonstrates order placement process
  - Shows inventory deduction

- **Phase 3: Monitoring & Reporting**
  - Creates views for customer orders, low stock, and spending categories

- **Phase 4: Stock Replenishment & Automation**
  - Implements triggers for automatic inventory updates
  - Shows replenishment process

- **Phase 5: Advanced Queries & Optimization**
  - Creates additional views and indexes for performance

## Key Features

- **Automated Inventory Management**: Triggers automatically update stock levels when orders are placed.
- **Reporting Views**: Pre-built views for common reports like customer spending and low stock alerts.
- **Data Integrity**: Foreign key constraints and check constraints ensure data consistency.
- **Performance Optimization**: Indexes on frequently queried columns.

## Testing the System

After setup, you can test the system by:

1. **Placing a new order**:
   ```sql
   INSERT INTO orders (customer_id) VALUES (1) RETURNING order_id;
   -- Note the order_id, then:
   INSERT INTO order_details (order_id, product_id, quantity, price) VALUES (1, 1, 1, 1200.00);
   ```

2. **Checking inventory changes**:
   ```sql
   SELECT * FROM products WHERE product_id = 1;
   SELECT * FROM inventory_logs ORDER BY log_id DESC LIMIT 5;
   ```

3. **Viewing reports**:
   ```sql
   SELECT * FROM customer_orders_view;
   SELECT * FROM low_stock_view;
   SELECT * FROM customer_spending_view;
   ```

## Files

- `inventory_management_full.sql`: Complete SQL script for the entire system.
- `README.md`: This setup and usage guide.

## Notes

- The script assumes PostgreSQL is running and you have appropriate permissions.
- All phases are executed in sequence within the single script.
- Triggers ensure real-time inventory updates.
- Views provide efficient access to complex queries.

For any issues, ensure PostgreSQL is running and you have the necessary permissions to create databases and execute DDL statements.