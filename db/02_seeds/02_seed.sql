INSERT INTO hotel_bookings (id, org_id, hotel_id, city, checkin_date, checkout_date, amount, status, created_at)
SELECT 
    gen_random_uuid(),
    gen_random_uuid(),
    'HOTEL-' || i,
    CASE WHEN i % 3 = 0 THEN 'delhi' WHEN i % 3 = 1 THEN 'mumbai' ELSE 'bangalore' END,
    CURRENT_DATE + (i % 5),
    CURRENT_DATE + (i % 5) + 3,
    (1000 + (i * 15))::NUMERIC(12,2),
    CASE WHEN i % 4 = 0 THEN 'CONFIRMED' WHEN i % 4 = 1 THEN 'PENDING' ELSE 'CANCELLED' END,
    NOW() - (i % 45 || ' days')::INTERVAL
FROM generate_series(1, 120) AS i;