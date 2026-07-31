import random
from pathlib import Path
from datetime import date, timedelta

import pandas as pd

random.seed(42)

# Crear carpeta de salida
output_dir = Path("datasets/oltp")
output_dir.mkdir(parents=True, exist_ok=True)

# -------------------------
# customers.csv
# -------------------------
customers = pd.DataFrame({
    "customer_id": range(1, 21),
    "customer_name": [
        "Ana Pérez", "Luis García", "María López", "Carlos Torres",
        "Sofía Ramírez", "Diego Flores", "Valeria Sánchez", "Jorge Díaz",
        "Camila Rojas", "Andrés Cruz", "Lucía Herrera", "Pedro Vargas",
        "Daniela Castro", "Miguel Reyes", "Paola Mendoza", "Juan Silva",
        "Elena Morales", "Ricardo Navarro", "Claudia Vega", "Fernando León"
    ],
    "city": [
        "Lima", "Arequipa", "Trujillo", "Cusco", "Piura",
        "Lima", "Arequipa", "Trujillo", "Cusco", "Piura",
        "Lima", "Arequipa", "Trujillo", "Cusco", "Piura",
        "Lima", "Arequipa", "Trujillo", "Cusco", "Piura"
    ]
})

# -------------------------
# orders.csv
# -------------------------
orders = []

for order_id in range(1, 101):
    order_date = date(2026, 7, 28) + timedelta(
        days=random.randint(0, 28)
    )

    orders.append({
        "order_id": order_id,
        "customer_id": random.randint(1, 20),
        "order_date": order_date.isoformat(),
        "order_status": "COMPLETED"
    })

orders = pd.DataFrame(orders)

# -------------------------
# order_items.csv
# -------------------------
order_items = []
order_item_id = 1

for order_id in orders["order_id"]:
    for _ in range(random.randint(1, 3)):
        order_items.append({
            "order_item_id": order_item_id,
            "order_id": order_id,
            "product_id": random.randint(1, 20),
            "quantity": random.randint(1, 3)
        })

        order_item_id += 1

order_items = pd.DataFrame(order_items)

# -------------------------
# Guardar CSV
# -------------------------
customers.to_csv(
    output_dir / "customers.csv",
    index=False
)

orders.to_csv(
    output_dir / "orders.csv",
    index=False
)

order_items.to_csv(
    output_dir / "order_items.csv",
    index=False
)

print("Archivos creados correctamente:")
print(f"Clientes: {len(customers)}")
print(f"Pedidos: {len(orders)}")
print(f"Ítems de pedido: {len(order_items)}")