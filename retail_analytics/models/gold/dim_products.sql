select
product_id,
product_name,
category,
standard_cost,
list_price
from {{ ref('sl_products') }}