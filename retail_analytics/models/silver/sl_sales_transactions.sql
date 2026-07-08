select
    order_line_id,
    order_id,
    order_date,
    customer_id,
    store_id,
    product_id,
    quantity,
    unit_price,
    discount_amount,
    net_sales_amount,
    cost_amount,
    channel,
    payment_method,
    order_status,

    case
        when order_status = 'Returned' then true
        else false
    end as is_returned,

    cast(net_sales_amount - cost_amount as decimal(18,2)) as gross_profit_amount,

    case
        when net_sales_amount = 0 then cast(0 as decimal(18,4))
        else cast(
            round(
                (net_sales_amount - cost_amount) / net_sales_amount,
                4
            ) as decimal(18,4)
        )
    end as gross_margin_pct,

    bronze_loaded_at
from {{ ref('br_sales_transaction') }}
where order_line_id is not null
  and order_id is not null
  and order_date is not null
  and quantity > 0
  and order_status <> 'Cancelled'