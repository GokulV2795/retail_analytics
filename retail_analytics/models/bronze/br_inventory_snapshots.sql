select
to_date(snapshot_date, 'yyyy-MM-dd') as snapshot_date,
cast(store_id as string) as store_id,
cast(product_id as string) as product_id,
cast(on_hand_qty as integer) as on_hand_qty,
cast(reorder_point as integer) as reorder_point,
current_timestamp() as bronze_loaded_at
from {{ ref('raw_inventory_snapshots') }}
