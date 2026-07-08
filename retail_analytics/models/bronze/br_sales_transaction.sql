select
cast(order_line_id as string) as order_line_id,
cast(order_id as string) as order_id,
to_date(order_date, 'dd-MM-yyyy') as order_date,
cast(customer_id as string) as customer_id,
cast(store_id as string) as store_id,
cast(product_id as string) as product_id,
cast(quantity as integer) as quantity,
cast(unit_price as decimal(18,2)) as unit_price,
cast(discount_amount as decimal(18,2)) as discount_amount,
cast(net_sales_amount as decimal(18,2)) as net_sales_amount,
cast(cost_amount as decimal(18,2)) as cost_amount,
cast(channel as string) as channel,
cast(payment_method as string) as payment_method,
cast(order_status as string) as order_status,
current_timestamp() as bronze_loaded_at
from {{ ref('raw_sales_transactions') }}