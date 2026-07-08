select
customer_id,
customer_name,
email,
gender,
age_band,
home_store_id
from {{ ref('sl_customers') }}