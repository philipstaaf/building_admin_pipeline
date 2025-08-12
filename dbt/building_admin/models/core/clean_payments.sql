{{ config(materialized="table") }}

select
  (payload->>'payment_id')::bigint  as payment_id,
  (payload->>'invoice_id')::bigint  as invoice_id,
  (payload->>'tenant_id')::bigint   as tenant_id,
  (payload->>'building_id')::text   as building_id,
  to_date(payload->>'paid_date','DD/MM/YYYY')         as paid_date,
  replace(payload->>'amount',',','.')::numeric(12,2)  as amount,
  lower(payload->>'payment_method')                    as method_raw
from {{ source('raw','raw_payments') }}
