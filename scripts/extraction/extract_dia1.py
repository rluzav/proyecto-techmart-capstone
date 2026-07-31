# scripts/extraction/extract_dia1.py
import requests, json
from datetime import date
import pandas as pd
resp = requests.get("https://fakestoreapi.com/products")
resp.raise_for_status()
products = resp.json()

fecha = str(date.today())
for p in products:
    p["extraction_date"] = fecha
with open(f"datasets/api_snapshots/products_{fecha}.json", "w") as f:
    json.dump(products, f, indent=2)
print(f"{len(products)} productos guardados para {fecha}")
prueba = pd.json_normalize(products)
pd.set_option('display.max_columns', None)
print(prueba.head())