-- Jacob Ardoin
-- Student ID: 012456585 
-- Advanced Data Management - D326
-- Rental Revenue By Film Category

-- B - User Defined Function From A4
CREATE OR REPLACE FUNCTION calculate_rental_revenue(rental_count BIGINT, rental_rate NUMERIC) 
RETURNS NUMERIC AS $$
BEGIN
    RETURN rental_count * rental_rate;
END;
$$ LANGUAGE plpgsql;


-- C - Create Detailed Table
CREATE TABLE detailed_category_revenue AS
SELECT 
    c.name AS category_name, 
    f.film_id, 
    f.title, 
    calculate_rental_revenue(COUNT(r.rental_id), f.rental_rate) AS rental_revenue
FROM rental r
JOIN inventory i ON r.inventory_id = i.inventory_id
JOIN film f ON i.film_id = f.film_id
JOIN film_category fc ON f.film_id = fc.film_id
JOIN category c ON fc.category_id = c.category_id
GROUP BY c.name, f.film_id, f.title, f.rental_rate
ORDER BY rental_revenue DESC;


-- C - Confirm Detailed Data
SELECT * FROM detailed_category_revenue 


-- C - Create Summary Table
CREATE TABLE summary_category_revenue AS
SELECT 
    category_name, 
    SUM(rental_revenue) AS total_revenue,
    RANK() OVER (ORDER BY SUM(rental_revenue) DESC) AS rank
FROM detailed_category_revenue
GROUP BY category_name
ORDER BY total_revenue DESC;


-- C - Confirm Summary Data
SELECT * FROM summary_category_revenue


-- D - Raw Data Extraction
SELECT 
    c.name AS category_name, 
    f.film_id, 
    f.title, 
    r.rental_id, 
    f.rental_rate
FROM rental r
JOIN inventory i ON r.inventory_id = i.inventory_id
JOIN film f ON i.film_id = f.film_id
JOIN film_category fc ON f.film_id = fc.film_id
JOIN category c ON fc.category_id = c.category_id
ORDER BY c.name, f.film_id;


-- E - Create Summary Update Funtion
CREATE OR REPLACE FUNCTION update_summary_table()
RETURNS TRIGGER AS $$
BEGIN
    DELETE FROM summary_category_revenue;

    INSERT INTO summary_category_revenue (category_name, total_revenue, rank)
    SELECT 
        category_name, 
        SUM(rental_revenue) AS total_revenue,
        RANK() OVER (ORDER BY SUM(rental_revenue) DESC) AS rank
    FROM detailed_category_revenue
    GROUP BY category_name;

	RETURN NULL;
END;
$$ LANGUAGE plpgsql;


-- E - Create Trigger for Summary Update
CREATE TRIGGER trigger_update_summary
AFTER INSERT OR UPDATE OR DELETE ON detailed_category_revenue
FOR EACH STATEMENT
EXECUTE FUNCTION update_summary_table();


-- E - Trigger Test
INSERT INTO detailed_category_revenue (category_name, film_id, title, rental_revenue)
VALUES ('Action', 5648, 'Movie by Jake', 1000000000.00);


-- F - Create Procedure
CREATE OR REPLACE PROCEDURE refresh_report_data() --pgAgent CALL
LANGUAGE plpgsql
AS $$
BEGIN
    TRUNCATE detailed_category_revenue;

    INSERT INTO detailed_category_revenue
    SELECT 
        c.name AS category_name, 
        f.film_id, 
        f.title, 
        calculate_rental_revenue(COUNT(r.rental_id), f.rental_rate) AS rental_revenue
    FROM rental r
    JOIN inventory i ON r.inventory_id = i.inventory_id
    JOIN film f ON i.film_id = f.film_id
    JOIN film_category fc ON f.film_id = fc.film_id
    JOIN category c ON fc.category_id = c.category_id
    GROUP BY c.name, f.film_id, f.title, f.rental_rate;

    TRUNCATE summary_category_revenue;

    INSERT INTO summary_category_revenue
    SELECT 
        category_name, 
        SUM(rental_revenue) AS total_revenue,
        RANK() OVER (ORDER BY SUM(rental_revenue) DESC) AS rank
    FROM detailed_category_revenue
    GROUP BY category_name;
END;
$$;
