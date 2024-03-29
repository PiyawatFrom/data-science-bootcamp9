-- make 3 Tables --------------------------

-- customer table 
CREATE TABLE customers (
    id INTEGER PRIMARY KEY,
    name TEXT,
    gender TEXT, -- male , female
    cus_type TEXT -- norm , vip
);

-- Insert 20 random values
INSERT INTO customers (name, gender, cus_type) VALUES
  ('John Doe', 'male', 'norm'),
  ('Jane Smith', 'female', 'vip'),
  ('Bob Johnson', 'male', 'norm'),
  ('Alice Williams', 'female', 'vip'),
  ('Charlie Brown', 'male', 'norm'),
  ('Emma Davis', 'female', 'norm'),
  ('Frank Miller', 'male', 'vip'),
  ('Grace Taylor', 'female', 'norm'),
  ('Henry Clark', 'male', 'vip'),
  ('Ivy White', 'female', 'norm'),
  ('Jack Robinson', 'male', 'vip'),
  ('Karen Lee', 'female', 'norm'),
  ('Leo Garcia', 'male', 'norm'),
  ('Mia Adams', 'female', 'vip'),
  ('Nathan Hall', 'male', 'norm'),
  ('Olivia Moore', 'female', 'vip'),
  ('Paula Brown', 'male', 'norm'),
  ('Quincy Turner', 'female', 'vip'),
  ('Ryan Mitchell', 'male', 'norm'),
  ('Samantha Davis', 'female', 'vip');

-- menus table
CREATE TABLE menus (
    id INTEGER PRIMARY KEY,
    name TEXT, -- pizza
    price REAL -- Thai Baht
);

-- Insert 10 pizza menu items
INSERT INTO menus (name, price) VALUES
  ('Margherita Pizza', 199.99),
  ('Pepperoni Pizza', 229.99),
  ('Vegetarian Pizza', 219.99),
  ('Hawaiian Pizza', 249.99),
  ('BBQ Chicken Pizza', 269.99),
  ('Supreme Pizza', 289.99),
  ('Mushroom and Olive Pizza', 239.99),
  ('Buffalo Chicken Pizza', 259.99),
  ('Four Cheese Pizza', 279.99),
  ('Spinach and Feta Pizza', 249.99);

-- orders table
CREATE TABLE orders (
    id INTEGER PRIMARY KEY ,
    cus_id INTEGER , -- FK : 1-20
    food_id INTEGER , -- FK : 1-10
    portion INTEGER -- 1-4
);

INSERT INTO orders (cus_id, food_id, portion) VALUES
    (3, 8, 2),
    (8, 6, 3),
    (9, 2, 4),
    (13, 9, 2),
    (12, 7, 1),
    (17, 2, 1),
    (10, 5, 2),
    (6, 3, 3),
    (18, 1, 1),
    (5, 8, 4),
    (7, 7, 2),
    (4, 6, 2),
    (19, 10, 3),
    (16, 9, 1),
    (11, 4, 4),
    (2, 2, 3),
    (15, 5, 3),
    (1, 9, 1),
    (8, 1, 4),
    (3, 3, 1),
    (4, 8, 3),
    (12, 3, 4),
    (9, 4, 3),
    (14, 6, 2),
    (5, 10, 2),
    (20, 8, 4),
    (10, 7, 1),
    (6, 5, 1),
    (1, 1, 2),
    (7, 2, 1),
    (13, 1, 3),
    (2, 6, 3),
    (9, 9, 4),
    (4, 4, 2),
    (15, 8, 1),
    (11, 3, 3),
    (1, 7, 4),
    (7, 1, 2),
    (3, 2, 4),
    (14, 5, 3),
    (10, 10, 1),
    (5, 4, 1),
    (16, 7, 2),
    (2, 1, 4),
    (8, 8, 3),
    (4, 3, 1),
    (10, 6, 4),
    (6, 1, 2),
    (2, 5, 2),
    (8, 9, 1);

-- 3 queries for homework --------------------------

SELECT "Table 1 : Top 5 most spend money";
SELECT "Table 2 : Top 5 Popular foods";
SELECT "Table 3 : Popular foods of each gender";
.mode box
-- spend top 5 customers
WITH full_orders AS (
SELECT
    od.id ,
    cus.name ,
    cus.gender ,
    cus.cus_type ,
    mu.name food_name ,
    od.portion,
    mu.price food_price
FROM orders od
JOIN customers cus ON od.cus_id = cus.id
JOIN menus mu ON mu.id = od.food_id
)

SELECT
    name,
    gender,
    cus_type,
    ROUND(SUM(portion*food_price),2) spend_total
FROM full_orders
GROUP BY 1 
ORDER BY 4 DESC
LIMIT 5;


-- Top 5 favorite dishs
WITH full_orders AS (
SELECT
    od.id ,
    cus.name ,
    cus.gender ,
    cus.cus_type ,
    mu.name food_name ,
    od.portion,
    mu.price food_price
FROM orders od
JOIN customers cus ON od.cus_id = cus.id
JOIN menus mu ON mu.id = od.food_id
)

SELECT
    food_name ,
    SUM(portion) frequency
FROM full_orders
GROUP BY 1 
ORDER BY 2 DESC
LIMIT 5;

-- Top favorite dish
-- Male
WITH male_orders AS (
    SELECT
        cus.gender,
        mu.name AS top_food,
        SUM(od.portion) AS frequency
    FROM orders od
    JOIN customers cus ON od.cus_id = cus.id
    JOIN menus mu ON mu.id = od.food_id
    WHERE cus.gender = 'male'
    GROUP BY cus.gender, mu.name
    ORDER BY frequency DESC
    LIMIT 1
),
-- Female
female_orders AS (
    SELECT
        cus.gender,
        mu.name AS top_food,
        SUM(od.portion) AS frequency
    FROM orders od
    JOIN customers cus ON od.cus_id = cus.id
    JOIN menus mu ON mu.id = od.food_id
    WHERE cus.gender = 'female'
    GROUP BY cus.gender, mu.name
    ORDER BY frequency DESC
    LIMIT 1
)

-- Combine results for both genders
SELECT * FROM male_orders
UNION
SELECT * FROM female_orders;
