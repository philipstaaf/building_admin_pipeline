import os, json
from datetime import datetime
from dotenv import load_dotenv
import psycopg2
from psycopg2.extras import Json

load_dotenv()  # loads from .env if present

PGHOST = os.getenv("PGHOST", "localhost")
PGPORT = int(os.getenv("PGPORT", "5432"))
PGDATABASE = os.getenv("PGDATABASE", "mcd")
PGUSER = os.getenv("PGUSER", "mcd_loader")  # use loader user
PGPASSWORD = os.getenv("PGPASSWORD")
if not PGPASSWORD:
    raise RuntimeError("Set PGPASSWORD for the loader user (mcd_loader)")

conn = psycopg2.connect(host=PGHOST, port=PGPORT, dbname=PGDATABASE, user=PGUSER, password=PGPASSWORD)
cur = conn.cursor()

cur.execute("""
CREATE TABLE IF NOT EXISTS raw.raw_payments(
  payload jsonb,
  batch_id text,
  ingested_at timestamptz default now()
)""")

payload = {
  "payment_id": 2,
  "invoice_id": 202,
  "tenant_id": 777,
  "building_id": "B002",
  "paid_date": datetime.now().strftime("%d/%m/%Y"),
  "amount": "250.00",
  "payment_method": "transfer"
}
cur.execute("INSERT INTO raw.raw_payments(payload, batch_id) VALUES (%s, %s)", (Json(payload), "manual_test"))
conn.commit()
cur.close(); conn.close()
print("Inserted 1 row into raw.raw_payments")