select
cast(customer_id as string) as customer_id,
cast(customer_name as string) as customer_name,
cast(email as string) as email,
cast(gender as string) as gender,
cast(age_band as string) as age_band,
cast(home_store_id as string) as home_store_id,
current_timestamp() as bronze_loaded_at
from {{ ref('raw_customers') }}