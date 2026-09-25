import duckdb

conn = duckdb.connect("dev.db")
with open("transform.sql", encoding="utf-8") as f:
    conn.execute(f.read())
conn.close()
print("Created dev.db from transform.sql")