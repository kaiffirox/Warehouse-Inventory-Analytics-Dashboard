-- ============================================================
-- SUPPLY CHAIN & INVENTORY ANALYTICS PROJECT
-- Analyst: Kaif Firoz | Dataset: Supply Chain Dataset (Kaggle)
-- Tools: MySQL | Power BI | Python
-- ============================================================

-- TABLE CREATION
CREATE TABLE supply_chain (
    product_type VARCHAR(50),
    sku VARCHAR(20) PRIMARY KEY,
    price DECIMAL(10,2),
    availability INT,
    products_sold INT,
    revenue_generated DECIMAL(10,2),
    customer_demographics VARCHAR(50),
    stock_levels INT,
    lead_times INT,
    order_quantities INT,
    shipping_times INT,
    shipping_carrier VARCHAR(50),
    shipping_costs DECIMAL(10,2),
    supplier_name VARCHAR(50),
    location VARCHAR(50),
    lead_time INT,
    production_volumes INT,
    manufacturing_lead_time INT,
    manufacturing_costs DECIMAL(10,2),
    inspection_results VARCHAR(20),
    defect_rates DECIMAL(5,4),
    transportation_mode VARCHAR(20),
    routes VARCHAR(20),
    costs DECIMAL(10,2)
);

-- ============================================================
-- KPI 1: TOTAL REVENUE BY PRODUCT TYPE
-- Business Question: Which product category drives the most revenue?
-- ============================================================
SELECT 
    product_type,
    COUNT(sku) AS total_skus,
    SUM(revenue_generated) AS total_revenue,
    ROUND(AVG(revenue_generated), 2) AS avg_revenue_per_sku,
    ROUND(SUM(revenue_generated) * 100.0 / (SELECT SUM(revenue_generated) FROM supply_chain), 2) AS revenue_share_pct
FROM supply_chain
GROUP BY product_type
ORDER BY total_revenue DESC;

-- ============================================================
-- KPI 2: INVENTORY TURNOVER RATIO
-- Business Question: How efficiently is inventory being used?
-- Formula: Products Sold / Average Stock Level
-- ============================================================
SELECT 
    product_type,
    SUM(products_sold) AS total_sold,
    ROUND(AVG(stock_levels), 2) AS avg_stock,
    ROUND(SUM(products_sold) / NULLIF(AVG(stock_levels), 0), 2) AS inventory_turnover_ratio
FROM supply_chain
GROUP BY product_type
ORDER BY inventory_turnover_ratio DESC;

-- ============================================================
-- KPI 3: SUPPLIER PERFORMANCE ANALYSIS
-- Business Question: Which supplier has the best defect rate and lead time?
-- ============================================================
SELECT 
    supplier_name,
    COUNT(sku) AS total_products,
    ROUND(AVG(defect_rates) * 100, 2) AS avg_defect_rate_pct,
    ROUND(AVG(lead_time), 1) AS avg_lead_time_days,
    ROUND(AVG(manufacturing_costs), 2) AS avg_manufacturing_cost,
    SUM(CASE WHEN inspection_results = 'Pass' THEN 1 ELSE 0 END) AS passed_inspections,
    SUM(CASE WHEN inspection_results = 'Fail' THEN 1 ELSE 0 END) AS failed_inspections,
    ROUND(SUM(CASE WHEN inspection_results = 'Pass' THEN 1 ELSE 0 END) * 100.0 / COUNT(sku), 2) AS pass_rate_pct
FROM supply_chain
GROUP BY supplier_name
ORDER BY avg_defect_rate_pct ASC;

-- ============================================================
-- KPI 4: SHIPPING PERFORMANCE BY CARRIER
-- Business Question: Which shipping carrier is most cost-efficient?
-- ============================================================
SELECT 
    shipping_carrier,
    COUNT(sku) AS shipments,
    ROUND(AVG(shipping_times), 1) AS avg_shipping_days,
    ROUND(AVG(shipping_costs), 2) AS avg_shipping_cost,
    ROUND(AVG(costs), 2) AS avg_total_logistics_cost,
    transportation_mode
FROM supply_chain
GROUP BY shipping_carrier, transportation_mode
ORDER BY avg_shipping_cost ASC;

-- ============================================================
-- KPI 5: STOCK RISK ANALYSIS (Low Stock Alert)
-- Business Question: Which SKUs are at risk of stockout?
-- ============================================================
SELECT 
    sku,
    product_type,
    stock_levels,
    order_quantities,
    lead_time,
    CASE 
        WHEN stock_levels < 10 THEN 'CRITICAL - Reorder Now'
        WHEN stock_levels BETWEEN 10 AND 30 THEN 'LOW - Monitor Closely'
        WHEN stock_levels BETWEEN 31 AND 60 THEN 'MODERATE - On Watch'
        ELSE 'HEALTHY'
    END AS stock_status
FROM supply_chain
ORDER BY stock_levels ASC;

-- ============================================================
-- KPI 6: DEFECT RATE BY TRANSPORTATION MODE
-- Business Question: Does transportation mode affect product quality?
-- ============================================================
SELECT 
    transportation_mode,
    COUNT(sku) AS total_shipments,
    ROUND(AVG(defect_rates) * 100, 2) AS avg_defect_rate_pct,
    ROUND(AVG(costs), 2) AS avg_cost,
    SUM(CASE WHEN inspection_results = 'Fail' THEN 1 ELSE 0 END) AS quality_failures
FROM supply_chain
GROUP BY transportation_mode
ORDER BY avg_defect_rate_pct ASC;

-- ============================================================
-- KPI 7: LOCATION-WISE REVENUE & OPERATIONS
-- Business Question: Which city warehouse performs best?
-- ============================================================
SELECT 
    location,
    COUNT(sku) AS total_products,
    ROUND(SUM(revenue_generated), 2) AS total_revenue,
    ROUND(AVG(manufacturing_costs), 2) AS avg_mfg_cost,
    ROUND(AVG(defect_rates) * 100, 2) AS avg_defect_rate_pct,
    ROUND(AVG(lead_time), 1) AS avg_lead_days
FROM supply_chain
GROUP BY location
ORDER BY total_revenue DESC;

-- ============================================================
-- KPI 8: FAST vs SLOW MOVING PRODUCTS
-- Business Question: Which SKUs are fast movers vs slow movers?
-- ============================================================
SELECT 
    sku,
    product_type,
    products_sold,
    revenue_generated,
    stock_levels,
    CASE 
        WHEN products_sold >= 700 THEN 'Fast Mover'
        WHEN products_sold BETWEEN 300 AND 699 THEN 'Moderate Mover'
        ELSE 'Slow Mover'
    END AS movement_category
FROM supply_chain
ORDER BY products_sold DESC;

-- ============================================================
-- KPI 9: ORDER FULFILLMENT EFFICIENCY
-- Business Question: Are order quantities aligned with production volumes?
-- ============================================================
SELECT 
    product_type,
    ROUND(AVG(order_quantities), 1) AS avg_order_qty,
    ROUND(AVG(production_volumes), 1) AS avg_production_vol,
    ROUND(AVG(production_volumes) - AVG(order_quantities), 1) AS production_surplus,
    ROUND(AVG(manufacturing_lead_time), 1) AS avg_mfg_lead_days
FROM supply_chain
GROUP BY product_type;

-- ============================================================
-- KPI 10: ROUTE COST EFFICIENCY
-- Business Question: Which route is most cost-effective?
-- ============================================================
SELECT 
    routes,
    transportation_mode,
    COUNT(sku) AS shipments,
    ROUND(AVG(costs), 2) AS avg_logistics_cost,
    ROUND(AVG(shipping_times), 1) AS avg_days,
    ROUND(AVG(defect_rates)*100, 2) AS avg_defect_pct
FROM supply_chain
GROUP BY routes, transportation_mode
ORDER BY avg_logistics_cost ASC;
