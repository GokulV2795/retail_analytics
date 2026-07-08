select
snapshot_date,
store_id,
product_id,
on_hand_qty,
reorder_point,
case
when on_hand_qty <= 0 then 'Out of Stock'
when on_hand_qty <= reorder_point then 'Low Stock'
else 'In Stock'
end as stock_status,
bronze_loaded_at
from {{ ref('br_inventory_snapshots') }}
where snapshot_date is not null
and store_id is not null
and product_id is not null