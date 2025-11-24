-- ============================================================
-- PHASE 2: ORDER PLACEMENT AND INVENTORY MANAGEMENT
-- ============================================================

-- Function to process JSON order (main entry point for clients)
CREATE OR REPLACE FUNCTION process_order(order_json JSONB)
RETURNS TEXT AS $$
DECLARE
    new_order_id INT;
    item RECORD;
    total DECIMAL(10,2) := 0;
BEGIN
    -- Validate JSON structure
    IF NOT (order_json ? 'customer_id' AND order_json ? 'items' AND jsonb_array_length(order_json->'items') > 0) THEN
        RAISE EXCEPTION 'Invalid JSON: missing or empty customer_id or items';
    END IF;

    -- Start transaction (implicit in function)
    -- Create order
    INSERT INTO orders (customer_id) VALUES ((order_json->>'customer_id')::INT) RETURNING order_id INTO new_order_id;

    -- Process items
    FOR item IN SELECT * FROM jsonb_array_elements(order_json->'items')
    LOOP
        -- Check stock
        IF (SELECT stock_quantity FROM products WHERE product_id = (item.value->>'product_id')::INT) < (item.value->>'quantity')::INT THEN
            RAISE EXCEPTION 'Insufficient stock for product %', item.value->>'product_id';
        END IF;

        -- Insert order detail (trigger will handle stock deduction)
        INSERT INTO order_details (order_id, product_id, quantity, price)
        VALUES (new_order_id, (item.value->>'product_id')::INT, (item.value->>'quantity')::INT,
                (SELECT price FROM products WHERE product_id = (item.value->>'product_id')::INT));
    END LOOP;

    -- Update total
    UPDATE orders SET total_amount = (SELECT SUM(quantity * price) FROM order_details WHERE order_id = new_order_id) WHERE order_id = new_order_id;

    RETURN 'Order ' || new_order_id || ' processed successfully';
EXCEPTION
    WHEN OTHERS THEN
        -- Rollback handled by PostgreSQL
        RAISE EXCEPTION 'Order processing failed: %', SQLERRM;
END;
$$ LANGUAGE plpgsql;

-- Trigger function for inventory deduction and logging on order detail insert
CREATE OR REPLACE FUNCTION deduct_stock_on_order()
RETURNS TRIGGER AS $$
BEGIN
    -- Deduct stock
    UPDATE products SET stock_quantity = stock_quantity - NEW.quantity WHERE product_id = NEW.product_id;

    -- Log the change
    INSERT INTO inventory_logs (product_id, change_type, quantity_change)
    VALUES (NEW.product_id, 'Order Deduction', -NEW.quantity);

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create the trigger
CREATE TRIGGER trg_deduct_stock
AFTER INSERT ON order_details
FOR EACH ROW
EXECUTE FUNCTION deduct_stock_on_order();