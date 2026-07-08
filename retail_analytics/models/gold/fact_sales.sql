{{ 
    config(
        materialized='incremental',
        incremental_strategy='merge',
        unique_key='source_order_line_id',
        on_schema_change='sync_all_columns'
    ) 
}}

with sales_enriched as (

    select
        s.order_line_id as source_order_line_id,
        s.order_id,
        s.order_date,
        s.customer_id,
        s.store_id,
        s.product_id,
        s.quantity,
        s.unit_price,
        s.discount_amount,
        s.net_sales_amount,
        s.cost_amount,
        s.gross_profit_amount,
        s.gross_margin_pct,
        s.channel,
        s.payment_method,
        s.order_status,
        s.is_returned,
        p.product_name,
        p.category,
        st.store_name,
        st.city as store_city,
        st.region as store_region
    from {{ ref('sl_sales_transactions') }} s
    left join {{ ref('sl_products') }} p
        on s.product_id = p.product_id
    left join {{ ref('sl_stores') }} st
        on s.store_id = st.store_id
    where s.order_date is not null

    {% if is_incremental() %}
        and s.order_date >= (
            select coalesce(max(order_date), cast('1900-01-01' as date))
            from {{ this }}
        )
    {% endif %}

),

final as (

    select
        concat(
            'OL',
            lpad(
                cast(
                    row_number() over (
                        order by
                            order_date asc,
                            order_id asc,
                            source_order_line_id asc
                    ) as string
                ),
                7,
                '0'
            )
        ) as order_line_id,

        source_order_line_id,
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
        gross_profit_amount,
        gross_margin_pct,
        channel,
        payment_method,
        order_status,
        is_returned,
        product_name,
        category,
        store_name,
        store_city,
        store_region
    from sales_enriched

)

select * from final