select
cast(store_id as string) as store_id,
cast(store_name as string) as store_name,
cast(city as string) as city,
cast(state as string) as state,
cast(region as string) as region,
current_timestamp() as bronze_loaded_at
from {{ ref('raw_stores') }}