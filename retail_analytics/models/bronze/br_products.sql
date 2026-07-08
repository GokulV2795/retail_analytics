select
cast(product_id as string) as product_id,
cast(product_name as string) as product_name,
cast(category as string) as category,
cast(standard_cost as decimal(18,2)) as standard_cost,
cast(list_price as decimal(18,2)) as list_price,
current_timestamp() as bronze_loaded_at
from {{ ref('raw_products') }}