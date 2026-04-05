CREATE TABLE fleet_status (
    truck_id VARCHAR(15),
    current_city VARCHAR(50),
    destination_city VARCHAR(50),
    capacity_tonnes INT,
    status VARCHAR(20),
    current_latitude FLOAT,
    current_longitude FLOAT
);

CREATE TABLE backhaul_leads (
    lead_id INT,
    cargo_type VARCHAR(50),
    pickup_city VARCHAR(50),
    dropoff_city VARCHAR(50),
    weight_tonnes INT,
    offered_pay_kes INT
);

---The Backhaul Matching Engine
-- Query to find "Golden Matches" (Direct Profit Opportunities)
SELECT 
    f.truck_id AS "Empty_Truck",
    f.current_city AS "Location",
    l.cargo_type AS "Available_Cargo",
    l.weight_tonnes AS "Load_Weight",
    f.capacity_tonnes AS "Truck_Capacity",
    l.offered_pay_kes AS "Revenue_Gain"
FROM fleet_status f
INNER JOIN backhaul_leads l 
    ON f.current_city = l.pickup_city 
    AND f.destination_city = l.dropoff_city
WHERE f.status = 'Empty' 
AND f.capacity_tonnes >= l.weight_tonnes 
ORDER BY l.offered_pay_kes DESC;

----Guidelines 
f.current_city = l.pickup_city -- Truck and Load are in the same place
f.destination_city = l.dropoff_city -- Load is going where the truck needs to go
f.status = 'Empty' -- Only target trucks wasting fuel
f.capacity_tonnes >= l.weight_tonnes -- Ensure the load fits in the truck

----The Revenue Recovery Report
--calculation of the total potential revenue currently sitting idle before the backhaul Machine took effect.
SELECT 
    COUNT(f.truck_id) AS "Total_Empty_Trucks",
    SUM(l.offered_pay_kes) AS "Total_Recoverable_Revenue_KES",
    ROUND(AVG(l.offered_pay_kes), 0) AS "Avg_Gain_Per_Trip"
FROM fleet_status f
JOIN backhaul_leads l 
    ON f.current_city = l.pickup_city
WHERE f.status = 'Empty' 
AND f.capacity_tonnes >= l.weight_tonnes;


----The Search Radius
--Allows one to find loads within 50 km of the truck
-- Create a lookup table for Kenyan City Coordinates
CREATE TABLE city_locations (
    city_name VARCHAR(50) PRIMARY KEY,
    latitude FLOAT,
    longitude FLOAT
);

INSERT INTO city_locations (city_name, latitude, longitude) VALUES
('Nairobi', -1.286389, 36.817223),
('Mombasa', -4.043477, 39.668206),
('Eldoret', 0.514277, 35.269780),
('Nakuru', -0.303099, 36.080025),
('Kisumu', -0.091702, 34.767956),
('Thika', -1.039613, 37.090008);

---The Advanced Search Radius Script
--Calculates the distance between the empty truck and the load having filtered it to a search radius of 50km
SELECT 
    f.truck_id,
    f.current_city AS truck_location,
    l.pickup_city AS load_location,
    l.cargo_type,
    l.offered_pay_kes,
    -- Haversine Formula to calculate distance in Kilometers
    ROUND((6371 * acos(
        cos(radians(f.current_latitude)) * cos(radians(loc.latitude)) * cos(radians(loc.longitude) - radians(f.current_longitude)) + 
        sin(radians(f.current_latitude)) * sin(radians(loc.latitude))
    ))::numeric, 2) AS distance_km
FROM fleet_status f
CROSS JOIN backhaul_leads l
JOIN city_locations loc ON l.pickup_city = loc.city_name
WHERE f.status = 'Empty'
AND f.capacity_tonnes >= l.weight_tonnes
-- Logic: Find loads within 50km of the truck
AND (6371 * acos(
        cos(radians(f.current_latitude)) * cos(radians(loc.latitude)) * cos(radians(loc.longitude) - radians(f.current_longitude)) + 
        sin(radians(f.current_latitude)) * sin(radians(loc.latitude))
    )) <= 50
ORDER BY distance_km ASC;