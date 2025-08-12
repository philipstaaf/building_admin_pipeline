{{ config(materialized="view") }}

select
  paid_date as date,
  building_id,
  sum(amount) as collected_amount
from {{ ref("clean_payments") }}
group by 1,2
