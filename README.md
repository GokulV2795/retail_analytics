# Retail Analytics — dbt on Databricks Medallion Pipeline

A synthetic, two-year omnichannel retail dataset transformed through a **Bronze → Silver → Gold** medallion architecture using [dbt](https://www.getdbt.com/) on **Databricks**. The project models sales, customers, products, stores, and inventory into an analytics-ready star schema, with each layer mapped to its own Unity Catalog schema.

## Overview

This repo simulates an end-to-end retail data platform: raw CSV extracts land as dbt seeds, get standardized in Bronze, cleaned and enriched in Silver, and shaped into dimensional facts/dimensions in Gold for BI and reporting.

| Layer | Materialization | Purpose |
|---|---|---|
| **Bronze** | View | Type casting and light standardization straight from raw seeds |
| **Silver** | Table | Business rules, filtering, derived fields (margins, stock status, return flags) |
| **Gold** | Table | Star-schema facts and dimensions joined and ready for consumption |

## Data Model

**Dimensions**
- `dim_customers` — customer profile (name, email, gender, age band, home store)
- `dim_products` — product catalog (category, standard cost, list price)
- `dim_stores` — store master (name, city, state, region)

**Facts**
- `fact_sales` — order-line grain sales with quantity, pricing, discounts, cost, gross profit, gross margin %, channel, payment method, order status, and return flag. A surrogate `order_line_id` (`OL0000001`, …) is generated via `row_number()` ordered by date/order.
- `fact_inventory_snapshot` — monthly on-hand inventory by store/product, enriched with a derived `stock_status` (`Out of Stock` / `Low Stock` / `In Stock` based on `reorder_point`).

## Source Data (Seeds)

| Seed | Rows | Grain |
|---|---|---|
| `raw_customers` | ~3,000 | one row per customer |
| `raw_products` | ~100 | one row per product |
| `raw_stores` | 8 | one row per store (Bengaluru-area retail outlets) |
| `raw_sales_transactions` | ~60,000 | one row per order line |
| `raw_inventory_snapshots` | ~19,200 | one row per store/product/month |

## Project Structure

```
retail_analytics/
├── retail_analytics/            # dbt project
│   ├── dbt_project.yml
│   ├── seeds/                   # raw CSV source data
│   ├── models/
│   │   ├── bronze/               # standardized views over seeds
│   │   ├── silver/                # cleaned, business-rule tables
│   │   ├── gold/                # star-schema facts & dimensions
│   │   └── schema/schema.yml     # seed-level tests & descriptions
│   ├── snapshots/                 # (reserved for SCD2 snapshots)
│   ├── macros/                   # (reserved for custom macros)
│   ├── tests/                    # (reserved for custom/singular tests)
│   └── analyses/
└── logs/                          # dbt run logs (gitignored on future commits)
```

## Prerequisites

- Python 3.9+
- [dbt-core](https://docs.getdbt.com/docs/core/installation-overview) `1.11.x` with the [`dbt-databricks`](https://docs.getdbt.com/reference/warehouse-setups/databricks-setup) adapter
- A Databricks workspace with a SQL Warehouse (or all-purpose cluster) and Unity Catalog enabled
- A personal access token (or OAuth) for authenticating dbt to Databricks
- A configured `profiles.yml` with a profile named `retail_analytics`

## Setup

```bash
# 1. Install dbt and the Databricks adapter
pip install dbt-core dbt-databricks

# 2. Clone and move into the dbt project
git clone https://github.com/GokulV2795/retail_analytics.git
cd retail_analytics/retail_analytics
```

Configure `~/.dbt/profiles.yml`:

```yaml
retail_analytics:
  target: dev
  outputs:
    dev:
      type: databricks
      catalog: retail_analytics          # Unity Catalog catalog
      schema: dev_bronze                 # default/base schema (bronze/silver/gold override per model config)
      host: <your-workspace-host>.cloud.databricks.com
      http_path: /sql/1.0/warehouses/<warehouse-id>
      token: "{{ env_var('DBT_DATABRICKS_TOKEN') }}"
      threads: 4
```

```bash
# 3. Verify the connection
dbt debug

# 4. Load raw seed data
dbt seed

# 5. Build Bronze → Silver → Gold
dbt run

# 6. Run data quality tests
dbt test
```

Useful selectors:

```bash
dbt run --select bronze      # bronze layer only
dbt run --select silver+     # silver and everything downstream
dbt run --select gold        # gold facts & dimensions
dbt test --select tag:bi     # tests tagged for BI-facing models
```

## Data Quality

`not_null` and `unique` tests are enforced on primary keys at the seed level (`store_id`, `product_id`, `customer_id`, `order_line_id`, `snapshot_date`). Silver models additionally filter out cancelled orders and null/zero-quantity rows before they reach Gold.

## Roadmap

- [ ] Convert `fact_sales` to an **incremental** model (Delta `merge` strategy, keyed on `order_line_id`)
- [ ] Add a **snapshot** for `dim_customers` to track SCD Type 2 history on `home_store_id`
- [ ] Expand `schema.yml` coverage to Silver/Gold models
- [ ] Add singular tests for referential integrity between facts and dimensions
- [ ] Evaluate Delta Live Tables / Databricks Workflows for orchestrating scheduled runs

## Tech Stack

dbt-core 1.11 · dbt-databricks · Databricks SQL Warehouse · Unity Catalog · Delta Lake · SQL · CSV seeds · Medallion (Bronze/Silver/Gold) architecture

## Author

[Gokul Vijayan](https://github.com/GokulV2795)
