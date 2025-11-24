# Inventory and Order Management System

This project demonstrates a modular PostgreSQL-based inventory and order management system. It uses separate SQL files for each phase, with stored procedures and triggers for automated order processing from JSON inputs, ensuring ACID compliance and database integrity.

## Overview

The system manages products, customers, orders, and inventory through automated triggers, procedures, and views. Clients can submit orders via JSON, triggering full pipelines for validation, stock updates, and logging. It covers phases from schema design to optimization, including order placement, reporting, and stock replenishment.

## Prerequisites

- **PostgreSQL 12+**: Installed and running locally (default port 5432, or as configured) for JSON support.
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

### 3. Execute the SQL Files in Order
Run the modular SQL files sequentially. Use psql or a GUI tool:

#### Option A: Using psql Command Line
### check your port number and apply, mine is 5433 as default. 
```bash
psql -U postgres -d inventory_db -p 5433 -f 01_schema.sql
psql -U postgres -d inventory_db -p 5433 -f 02_order_inventory.sql
psql -U postgres -d inventory_db -p 5433 -f 03_monitoring_reporting.sql
psql -U postgres -d inventory_db -p 5433 -f 04_stock_replenishment.sql
psql -U postgres -d inventory_db -p 5433 -f 05_advanced_queries.sql
```

#### Option B: Using pgAdmin or Similar GUI
- Open each file in order and execute.

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

The system is organized into modular phases:

- **Phase 1: Database Creation and Schema Design** (`01_schema.sql`)
  - Creates tables: `products`, `customers`, `orders`, `order_details`, `inventory_logs`
  - Defines relationships, constraints, and inserts sample data

- **Phase 2: Order Placement & Inventory Management** (`02_order_inventory.sql`)
  - `process_order` function for JSON-based order submission
  - Triggers for automatic stock deduction and logging

- **Phase 3: Monitoring & Reporting** (`03_monitoring_reporting.sql`)
  - Views for customer orders, low stock, and spending categories
  - `get_order_summary` procedure for detailed reports

- **Phase 4: Stock Replenishment & Automation** (`04_stock_replenishment.sql`)
  - `replenish_stock` procedure for manual replenishment
  - Triggers for auto-replenishment on low stock

- **Phase 5: Advanced Queries & Optimization** (`05_advanced_queries.sql`)
  - Additional views, indexes, and `get_period_orders` for analytics

## Key Features

- **JSON Order Processing**: `process_order` function accepts JSON inputs for seamless client integration.
- **Automated Inventory Management**: Triggers ensure real-time stock updates and ACID compliance.
- **Reporting and Analytics**: Views and procedures for customer insights, low stock alerts, and period-based reports.
- **Auto-Replenishment**: Triggers detect low stock and replenish automatically.
- **Data Integrity**: Foreign keys, checks, and transactions prevent inconsistencies.
- **Performance Optimization**: Indexes on key columns for efficient queries.

## Testing the System

After setup, you can test the system by:

1. **Placing a new order via JSON**:
   ```sql
   SELECT process_order('{"customer_id":3,"items":[{"product_id":1,"quantity":2}]}'::jsonb);
   -- Returns success message or error.
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
   SELECT * FROM get_order_summary(1);  -- For customer 1
   SELECT * FROM get_period_orders('2025-01-01', '2025-12-31');
   ```

## Files

- `01_schema.sql`: Database schema and sample data.
- `02_order_inventory.sql`: Order processing procedures and triggers.
- `03_monitoring_reporting.sql`: Views and reporting functions.
- `04_stock_replenishment.sql`: Replenishment procedures and automation triggers.
- `05_advanced_queries.sql`: Additional views, indexes, and analytics functions.
- `inventory_management_full.sql`: Original monolithic script (for reference).
- `README.md`: This setup and usage guide.

## Notes

- The modular files assume PostgreSQL 12+ is running and you have appropriate permissions.
- Execute files in numerical order (01 to 05) to build the system incrementally.
- The `process_order` function handles JSON inputs for orders, with ACID transactions ensuring integrity.
- Triggers automate inventory updates and replenishment.
- Views and procedures provide efficient reporting and analytics.

For any issues, ensure PostgreSQL is running, JSON support is enabled, and you have permissions for DDL/DML operations.