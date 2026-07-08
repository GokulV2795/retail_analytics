select
i.snapshot_date,
i.store_id,
i.product_id,
i.on_hand_qty,
i.reorder_point,
i.stock_status,
p.product_name,
p.category,
st.store_name,
st.city as store_city,
st.region as store_region
from {{ ref('sl_inventory_snapshots') }} i
left join {{ ref('sl_products') }} p
on i.product_id = p.product_id
left join {{ ref('sl_stores') }} st
on i.store_id = st.store_id