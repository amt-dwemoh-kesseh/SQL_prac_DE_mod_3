-- ============================================================
-- PHASE 4: STOCK REPLENISHMENT AND AUTOMATION
-- ============================================================

-- Procedure: Replenish stock for a product
CREATE OR REPLACE FUNCTION replenish_stock(p_product_id INT, p_amount INT DEFAULT 100)
RETURNS VOID AS $$
BEGIN
    -- Update stock
    UPDATE products SET stock_quantity = stock_quantity + p_amount WHERE product_id = p_product_id;

    -- Log the replenishment
    INSERT INTO inventory_logs (product_id, change_type, quantity_change)
    VALUES (p_product_id, 'Replenishment', p_amount);
END;
$$ LANGUAGE plpgsql;

-- Trigger function: Auto-replenish when stock drops below reorder level
CREATE OR REPLACE FUNCTION auto_replenish_on_low_stock()
RETURNS TRIGGER AS $$
BEGIN
    -- Check if stock is now below reorder level
    IF NEW.stock_quantity < NEW.reorder_level THEN
        -- Auto-replenish
        PERFORM replenish_stock(NEW.product_id, 100);
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create the trigger on products update
CREATE TRIGGER trg_auto_replenish
AFTER UPDATE ON products
FOR EACH ROW
EXECUTE FUNCTION auto_replenish_on_low_stock();