# 🚛 Kenya Freight Backhaul Optimizer
A geospatial SQL engine designed to eliminate 'dead mileage' in Kenyan logistics. Matches empty HGV fleets with high-value backhaul loads using the Haversine formula and PostgreSQL.

## 📌 Project Overview
In Kenya, logistics companies lose millions of shillings daily due to **"Empty Backhaul"**—trucks returning to base (e.g., Nairobi) empty after a delivery. 

This project provides a **PostgreSQL-powered matching engine** that identifies third-party cargo leads within a 50km radius of an offloading truck, turning "dead mileage" into a revenue-generating trip.

## 🛠️ Tech Stack
* **Database:** PostgreSQL 16
* **Logic:** Geospatial querying (Haversine Formula) & Relational Mapping
* **Data:** Synthetic 2026 Kenyan Logistics Dataset (Mombasa-Nairobi-Eldoret Corridor)

## 🚀 Key Features
* **Proximity Search:** Uses coordinate-based math to find loads near the truck's current GPS location.
* **Capacity Validation:** Automatically filters out loads that exceed a truck's weight limit.
* **Revenue Recovery:** Calculates the potential KES gain for every successful match.

## 📊 How It Works
The engine joins two primary datasets:
1. `fleet_status`: Real-time tracking of truck locations and "Empty" status.
2. `backhaul_leads`: A marketplace of cargo needing transport.

### Sample SQL Logic (Radius Matching)
```sql
-- Finds loads within 50km of an empty truck
SELECT truck_id, cargo_type, offered_pay_kes,
       (6371 * acos(...)) AS distance_km
FROM fleet_status
JOIN backhaul_leads ON distance_km <= 50
WHERE status = 'Empty';
