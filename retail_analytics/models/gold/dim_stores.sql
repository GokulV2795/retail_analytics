select
store_id,
store_name,
city,
state,
region
from {{ ref('sl_stores') }}