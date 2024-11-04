-- Retrieve the total number of orders placed.

SELECT COUNT(order_id) AS total_orders FROM orders;

-- Calculate the total revenue generated from pizza sales

SELECT round(SUM(order_details.quantity * pizzas.price), 2)
 FROM order_details
 JOIN pizzas ON pizzas.pizza_id = order_details.pizza_id;
 
 -- 3. Identify the highest price of pizza
 SELECT pizza_types.name, pizzas.price FROM pizza_types
 JOIN pizzas ON pizza_types.pizza_type_id=pizzas.pizza_type_id
 ORDER BY pizzas.price DESC
 LIMIT 1;
 
 -- 4. Identify the most common pizzas size ordered
SELECT COUNT(order_details.order_details_id), pizzas.size  FROM  order_details
JOIN pizzas ON pizzas.pizza_id = order_details.pizza_id
GROUP BY 2
ORDER BY 1 DESC;

-- 5. List the top 5 most ordered pizza types along with their quantities.
SELECT pizza_types.name, SUM(order_details.quantity) AS total_quantity, COUNT(order_details.order_details_id) AS Order_count FROM order_details
JOIN pizzas ON pizzas.pizza_id = order_details.pizza_id
JOIN pizza_types ON pizza_types.pizza_type_id=pizzas.pizza_type_id
GROUP BY 1
ORDER BY 3 DESC
LIMIT 5 ;
SELECT * FROM pizzas;

-- 6. Join the necessary  tables to find the total quantity of each pizza category ordered.
SELECT pizza_types.category, SUM(order_details.quantity) FROM pizza_types
JOIN pizzas ON pizzas.pizza_type_id = pizza_types.pizza_type_id
JOIN order_details ON order_details.pizza_id = pizzas.pizza_id
GROUP BY 1
ORDER BY 2 DESC;

-- 7. Determine the distribution of orders by hour of the day
SELECT hour(orders.time), COUNT(order_id) FROM orders
GROUP BY 1
ORDER BY 2 DESC;

-- 8. Join relevant tables to find the category-wise distribution of pizzas.
SELECT pizza_types.category, COUNT(name) FROM pizza_types
GROUP BY 1;

-- 9. Group the orders by date and calculate the average number of pizzas ordered per day
SELECT ROUND(AVG(quantity)) AS average_num_of_pizzas_perday 
FROM
(SELECT orders.date, SUM(order_details.quantity) AS quantity FROM orders
JOIN order_details ON order_details.order_id = orders.order_id
GROUP BY 1) AS order_quantity;

-- 10. TOP  3 most ordered pizza types based on revenue
SELECT SUM(order_details.quantity * pizzas.price), pizza_types.name FROM pizza_types
JOIN pizzas ON pizzas.pizza_type_id = pizza_types.pizza_type_id
JOIN order_details ON order_details.pizza_id = pizzas.pizza_id
GROUP BY 2
ORDER BY 1 DESC
LIMIT 3;

-- 11. Calculate the percentage contribution of each pizza type to total revenue
SELECT pizza_types.category, (SUM(order_details.quantity * pizzas.price)) / (SELECT SUM(order_details.quantity * pizzas.price)
FROM order_details 
JOIN pizzas ON pizzas.pizza_id = order_details.pizza_id) * 100
   FROM pizza_types
JOIN pizzas ON pizzas.pizza_type_id = pizza_types.pizza_type_id
JOIN order_details ON order_details.pizza_id = pizzas.pizza_id
GROUP BY 1
ORDER BY 2 DESC;

-- 12. Analyze the cumulative revenue generated over time

SELECT order_date, SUM(revenue) OVER(ORDER BY order_date) as cum_revenue 
FROM
(SELECT orders.date AS order_date, sum(order_details.quantity * pizzas.price) AS revenue FROM order_details
JOIN pizzas ON pizzas.pizza_id = order_details.pizza_id
JOIN orders ON orders.order_id = order_details.order_id
GROUP BY 1) AS sales;

-- 13.Determine the top 3 most ordered pizza types based on revenue for each pizza category.
SELECT b.category, b.name, revenue, rn
FROM
(SELECT a.category, a.name, revenue , RANK() OVER(partition by category ORDER BY revenue DESC) AS rn
FROM
(SELECT pizza_types.category,pizza_types.name, SUM(order_details.quantity * pizzas.price) AS revenue FROM order_details
JOIN pizzas ON pizzas.pizza_id = order_details.pizza_id
JOIN pizza_types ON pizza_types.pizza_type_id = pizzas.pizza_type_id
GROUP BY 1,2 ) AS a) AS b
WHERE rn <= 3   -- We cannot use rank directly in where so we make sub query
 ;