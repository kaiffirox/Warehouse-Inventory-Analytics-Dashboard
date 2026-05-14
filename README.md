# 🏭 Warehouse & Inventory Analytics Dashboard

**Tools:** SQL (MySQL) · Power BI · Python (Pandas, Matplotlib) · Excel  
**Domain:** Supply Chain · Warehouse Management · Inventory Analytics · Logistics  
**Dataset:** [Supply Chain Dataset — Kaggle](https://www.kaggle.com/datasets/amirmotefaker/supply-chain-dataset)

---

## 📌 Business Problem

A mid-size product company dealing in **skincare, haircare, and cosmetics** was facing operational challenges:

- No visibility into which products were at **stockout risk**
- Unable to identify **underperforming suppliers** causing quality failures
- Logistics costs were rising with no clear view of **carrier efficiency**
- Management lacked a single dashboard to monitor **supply chain KPIs**

As a Business Analyst, I was tasked with building an end-to-end analytics solution to address these gaps and support data-driven operational decisions.

---

## 🎯 Project Objective

> To design and deliver a **Warehouse & Inventory Analytics Dashboard** that gives operations and supply chain teams real-time visibility into stock health, supplier performance, logistics efficiency, and revenue contribution — enabling faster, smarter business decisions.

---

## 💼 Business Impact

| Finding | Business Action |
|--------|----------------|
| 8 SKUs at critical stock level (< 15 units) | Trigger immediate reorder process |
| SKU68 has 0 stock but active revenue | Investigate demand-supply gap urgently |
| Supplier 5 has highest defect rate (2.81%) | Review supplier contract & quality SLA |
| Skincare contributes 41.8% of total revenue | Prioritize stock replenishment for skincare |
| Air transport has highest logistics cost | Shift low-urgency orders to Road/Rail |

---

## 🗂️ Project Structure

```
warehouse-inventory-analytics/
│
├── data/
│   └── supply_chain_data.csv          # Raw dataset (Kaggle)
│
├── sql/
│   └── supply_chain_analysis.sql      # All 10 KPI queries
│
├── python/
│   └── eda_cleaning.ipynb             # Data cleaning & EDA notebook
│
├── powerbi/
│   └── supply_chain_dashboard.pbix    # Power BI dashboard file
│
├── assets/
│   └── dashboard_preview.png          # Dashboard screenshot
│
└── README.md
```

---

## 🔄 Project Workflow

```
Raw CSV Data
    ↓
Python — Data Cleaning & EDA (Pandas, Matplotlib)
    ↓
MySQL — KPI Queries & Business Analysis (10 SQL queries)
    ↓
Power BI — Interactive Dashboard (DAX, Power Query)
    ↓
Business Insights & Recommendations
```

---

## 📊 Dataset Overview

| Column | Description |
|--------|-------------|
| `SKU` | Unique product identifier |
| `Product type` | Category: skincare / haircare / cosmetics |
| `Stock levels` | Current warehouse stock quantity |
| `Lead times` | Days from order to delivery |
| `Supplier name` | Supplier 1–5 |
| `Defect rates` | % of defective units per SKU |
| `Revenue generated` | Total revenue per product |
| `Shipping carrier` | Carrier A / B / C |
| `Transportation mode` | Road / Air / Rail / Sea |
| `Location` | Warehouse city (Mumbai, Delhi, Kolkata, Chennai, Bangalore) |

**Size:** 100 rows × 24 columns

---

## 🔍 SQL KPI Analysis

### KPI 1 — Revenue by Product Type
```sql
SELECT 
    product_type,
    COUNT(sku) AS total_skus,
    SUM(revenue_generated) AS total_revenue,
    ROUND(SUM(revenue_generated) * 100.0 / 
        (SELECT SUM(revenue_generated) FROM supply_chain), 2) AS revenue_share_pct
FROM supply_chain
GROUP BY product_type
ORDER BY total_revenue DESC;
```
**Finding:** Skincare leads with ₹2,41,628 (41.8% revenue share)

---

### KPI 2 — Inventory Turnover Ratio
```sql
SELECT 
    product_type,
    ROUND(SUM(products_sold) / NULLIF(AVG(stock_levels), 0), 2) AS inventory_turnover_ratio
FROM supply_chain
GROUP BY product_type
ORDER BY inventory_turnover_ratio DESC;
```
**Finding:** Higher turnover = product moving fast relative to stock held

---

### KPI 3 — Supplier Performance
```sql
SELECT 
    supplier_name,
    ROUND(AVG(defect_rates) * 100, 2) AS avg_defect_rate_pct,
    ROUND(AVG(lead_time), 1) AS avg_lead_time_days,
    ROUND(SUM(CASE WHEN inspection_results = 'Pass' THEN 1 ELSE 0 END) 
        * 100.0 / COUNT(sku), 2) AS pass_rate_pct
FROM supply_chain
GROUP BY supplier_name
ORDER BY avg_defect_rate_pct ASC;
```
**Finding:** Supplier 1 is best performer; Supplier 5 has highest defect risk at 2.81%

---

### KPI 4 — Stock Risk Classification
```sql
SELECT sku, product_type, stock_levels,
    CASE 
        WHEN stock_levels < 10 THEN 'CRITICAL - Reorder Now'
        WHEN stock_levels BETWEEN 10 AND 30 THEN 'LOW - Monitor Closely'
        WHEN stock_levels BETWEEN 31 AND 60 THEN 'MODERATE'
        ELSE 'HEALTHY'
    END AS stock_status
FROM supply_chain
ORDER BY stock_levels ASC;
```
**Finding:** 8 SKUs in critical zone; SKU68 has 0 stock (stockout)

---

### KPI 5 — Fast vs Slow Moving Products
```sql
SELECT sku, product_type, products_sold,
    CASE 
        WHEN products_sold >= 700 THEN 'Fast Mover'
        WHEN products_sold BETWEEN 300 AND 699 THEN 'Moderate Mover'
        ELSE 'Slow Mover'
    END AS movement_category
FROM supply_chain
ORDER BY products_sold DESC;
```

> 📁 See `sql/supply_chain_analysis.sql` for all 10 KPI queries including shipping analysis, location performance, route efficiency, and order fulfillment.

---

## 📈 Power BI Dashboard

### Pages Designed

**Page 1 — Executive Summary**
- Total Revenue KPI card
- Revenue by Product Type (Bar chart)
- Stock Status Distribution (Donut chart)
- City-wise Revenue (Map visual)

**Page 2 — Inventory & Stock Management**
- Stock Level by SKU (sorted bar — low to high)
- Stock Status Classification (Conditional formatting table)
- Fast vs Slow Movers (Horizontal bar)
- Reorder Alert Panel

**Page 3 — Supplier & Quality Analysis**
- Defect Rate by Supplier (Bar chart)
- Inspection Pass/Fail Rate (Clustered bar)
- Avg Lead Time by Supplier (Line chart)
- Manufacturing Cost comparison

**Page 4 — Logistics & Shipping**
- Shipping Cost by Carrier (Bar chart)
- Transportation Mode vs Defect Rate (Scatter)
- Route Cost Efficiency (Table)
- Avg Shipping Days by Carrier

### DAX Measures Used
```
Total Revenue = SUM(supply_chain[revenue_generated])
Avg Defect Rate = AVERAGE(supply_chain[defect_rates]) * 100
Inventory Turnover = DIVIDE(SUM([products_sold]), AVERAGE([stock_levels]))
Critical SKU Count = COUNTROWS(FILTER(supply_chain, supply_chain[stock_levels] < 10))
Pass Rate % = DIVIDE(COUNTROWS(FILTER(supply_chain, [inspection_results]="Pass")), COUNTROWS(supply_chain)) * 100
```

### Slicers Applied
- Product Type (skincare / haircare / cosmetics)
- Supplier Name
- Location (City)
- Transportation Mode
- Inspection Result (Pass / Fail / Pending)

---

## 🐍 Python EDA Highlights

```python
import pandas as pd
import matplotlib.pyplot as plt

df = pd.read_csv('supply_chain_data.csv')

# Shape & nulls
print(df.shape)           # (100, 24)
print(df.isnull().sum())  # No missing values

# Revenue distribution
df.groupby('Product type')['Revenue generated'].sum().plot(kind='bar')

# Stock risk
df['Stock Status'] = df['Stock levels'].apply(
    lambda x: 'Critical' if x < 10 else ('Low' if x < 30 else 'Healthy')
)

# Defect rate by supplier
df.groupby('Supplier name')['Defect rates'].mean().sort_values().plot(kind='barh')
```

---

## 💡 Key Business Insights

1. **Skincare is the revenue engine** — 41.8% of total revenue from 40 SKUs. Stock replenishment priority must be skincare-first.

2. **8 SKUs face stockout risk** — Immediate procurement action needed. SKU68 has zero stock with active sales — revenue leakage occurring.

3. **Supplier 5 is highest quality risk** — 2.81% defect rate vs Supplier 1's 2.39%. Quality SLA review recommended.

4. **Air transport drives cost up** — Avg logistics cost via Air is highest. Road and Rail offer better cost-efficiency for non-urgent orders.

5. **Mumbai & Kolkata are top revenue cities** — Warehouse allocation and supplier contracts should be optimized around these hubs.

---

## 📝 Resume Project Points

- Built end-to-end supply chain analytics project using SQL, Power BI, and Python on 100-SKU inventory dataset covering 5 suppliers, 5 cities, and 3 product categories
- Designed 10 SQL KPI queries in MySQL covering inventory turnover, supplier defect analysis, stock risk classification, and logistics cost efficiency
- Identified 8 critical stockout SKUs and flagged Supplier 5 as highest defect risk (2.81%), enabling targeted procurement action
- Delivered 4-page interactive Power BI dashboard with DAX measures, conditional formatting, and slicers for product, supplier, and location-level drill-down

---

## 🔗 Connect

**Kaif Firoz** — Data Analyst | BBA Graduate  
📧 kaifsidd2003@gmail.com  
🔗 [LinkedIn](https://linkedin.com/in/kaiffiroz)  
💻 [GitHub](https://github.com)

---

*This project was built as part of my data analytics portfolio to demonstrate domain expertise in warehouse management, inventory analytics, and supply chain operations.*
