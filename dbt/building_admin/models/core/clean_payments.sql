{{ config(materialized="table") }}

with src as (
  select *
  from {{ source('raw','raw_payments') }}
),
typed as (
  select
    (payload->>'payment_id')::bigint  as payment_id,
    (payload->>'invoice_id')::bigint  as invoice_id,
    (payload->>'tenant_id')::bigint   as tenant_id,
    (payload->>'building_id')::text   as building_id,
    to_date(payload->>'paid_date','DD/MM/YYYY')         as paid_date,
    -- optional: safer numeric cast if blanks occur
    nullif(replace(payload->>'amount',',','.'), '')::numeric(12,2) as amount,
    lower(payload->>'payment_method')                    as method_raw,
    coalesce((payload->>'updated_at')::timestamp, now()) as _updated_at
  from src
),
dedup as (
  select *
  from (
    select
      *,
      row_number() over (
        partition by payment_id
        order by _updated_at desc, paid_date desc, amount desc
      ) as rn
    from typed
  ) t
  where rn = 1
)
select
  payment_id, invoice_id, tenant_id, building_id, paid_date, amount, method_raw
from dedup
