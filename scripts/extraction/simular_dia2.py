# Script para simulación - Día 2
# Proyecto: TechMart Capstone
# scripts/extraction/simular_dia2.py
import json, random, glob
from datetime import date, timedelta

archivo_dia1 = sorted(glob.glob("datasets/api_snapshots/products_*.json"))[0]
with open(archivo_dia1 , encoding="utf-8") as f:
    products = json.load(f)
fecha_simulada = str(date.today() + timedelta(days=7))
for p in products:
    if random.random() < 0.3: # ~30% de los productos cambia de precio
        p["price"] = round(p["price"] * random.uniform(0.85, 1.15), 2)
    p["extraction_date"] = fecha_simulada

with open(f"datasets/api_snapshots/products_{fecha_simulada}.json", "w") as f:
    json.dump(products, f, indent=2)

print(f"Snapshot simulado para {fecha_simulada}")