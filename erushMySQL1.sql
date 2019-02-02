use sakila;
-- 1a. Return first and last names
SELECT first_name, last_name FROM actor;
-- 1b. Combine first and last names
SELECT CONCAT_WS(" ", first_name, last_name) AS "Actor Name" FROM actor;
-- 2a. Return actor id of all Joes
SELECT actor_id, first_name, last_name FROM actor WHERE first_name = "Joe";
-- 2b. Actors with last names including "gen"
SELECT first_name, last_name FROM actor WHERE last_name LIKE "%gen%";
-- 2c. Actors who have the last name including "li", ordered by last then first
SELECT first_name, last_name FROM actor WHERE last_name LIKE "%li%" ORDER BY last_name, first_name;
-- 2d. Display country_id and country of 3 countries
SELECT country_id, country FROM country WHERE country = "Afghanistan" OR country = "Bangladesh" OR country = "China";
-- 3a. Add column in Actor named Description
ALTER TABLE actor 
ADD COLUMN description BLOB;
-- 3b Delete description column
ALTER TABLE actor
DROP COLUMN description;
-- 4a. Last names of actors with count
SELECT last_name, COUNT(last_name) FROM actor GROUP BY last_name; 
-- 4b. Last names with a count of more than two
SELECT last_name, COUNT(last_name) FROM actor GROUP BY last_name HAVING COUNT(last_name) > 1;
-- 4c. Change Harpo Williams to Groucho Williams
UPDATE actor SET first_name = "GROUCHO" WHERE first_name = "HARPO" AND last_name = "WILLIAMS" ; 
-- 4d. J/k. 
UPDATE actor SET first_name = "HARPO" WHERE first_name = "GROUCHO" AND last_name = "WILLIAMS";  
-- 5a. Query to re-create the 'address' table schema
SHOW CREATE TABLE address;
-- 6a. Use `JOIN` to display the first and last names, as well as the address, of each staff member.
SELECT staff.first_name, staff.last_name, address.address FROM staff INNER JOIN address ON staff.address_id=address.address_id;
-- 6b. Use `JOIN` to display the total amount rung up by each staff member in August of 2005. Use tables `staff` and `payment`.
SELECT staff.first_name, staff.last_name, SUM(payment.amount) FROM payment INNER JOIN staff ON staff.staff_id=payment.staff_id WHERE payment.payment_date LIKE '%2005-08%' ; 
-- 6c. List each film and the number of actors who are listed for that film. Use tables `film_actor` and `film`.
SELECT film.title, COUNT(film_actor.film_id) AS num_actors FROM film INNER JOIN film_actor ON film.film_id=film_actor.film_id GROUP BY film.title;
-- 6d. How many copies of the film `Hunchback Impossible` exist in the inventory system?
SELECT film.title, COUNT(inventory.film_id) AS inventory_qty FROM inventory JOIN film ON film.film_id=inventory.film_id WHERE film.title = "Hunchback Impossible";
-- 6e. Using the tables `payment` and `customer` and the `JOIN` command, list the total paid by each customer. List the customers alphabetically by last name:
SELECT customer.first_name, customer.last_name, SUM(payment.amount) AS total_spent FROM customer JOIN payment ON customer.customer_id=payment.customer_id GROUP BY customer.customer_id ORDER BY customer.last_name;
-- 7a. Use subqueries to display the titles of movies starting with the letters `K` and `Q` whose language is English.
SELECT title FROM film WHERE language_id IN
(
	SELECT language_id FROM language WHERE name = "English"
) AND title LIKE "Q%" or title LIKE "K%";
-- 7b. Use subqueries to display all actors who appear in the film `Alone Trip`.
SELECT first_name, last_name
FROM actor
WHERE actor_id IN
(
  SELECT actor_id
  FROM film_actor
  WHERE film_id IN
  (
   SELECT film_id
   FROM film
   WHERE title = 'ALONE TRIP'
  )
);
-- 7c.  You want to run an email marketing campaign in Canada, for which you will need the names and email addresses of all Canadian customers.
SELECT first_name, last_name, email
FROM customer
WHERE address_id 
IN (
	SELECT address_id
		FROM address
		WHERE city_id
		IN (
			SELECT city_id
				FROM city
				WHERE country_id
				IN (
					SELECT country_id FROM country
                    WHERE country = "Canada"
))); 
-- 7d. Identify all movies categorized as _family_ films.
SELECT title 
FROM film 
WHERE film_id IN (
	SELECT film_id 
    FROM film_category
	WHERE category_id IN (
		SELECT category_id 
			FROM category 
				WHERE name = "Family")); 
-- 7e. Display the most frequently rented movies in descending order.
SELECT film.title, COUNT(rental.rental_date) AS total_rental
FROM film
	JOIN inventory ON film.film_id=inventory.film_id
		JOIN rental ON inventory.inventory_id=rental.inventory_id 
			GROUP BY film.title
			ORDER BY total_rental DESC;
-- 7f. Write a query to display how much business, in dollars, each store brought in.
SELECT store.store_id, SUM(payment.amount) 
FROM store 
	JOIN staff ON store.store_id=staff.store_id 
		JOIN payment ON staff.staff_id=payment.staff_id
        GROUP BY store.store_id;
-- 7g. Write a query to display for each store its store ID, city, and country.
SELECT store.store_id, city.city, country.country
FROM store
	JOIN address ON store.address_id=address.address_id 
    JOIN city ON address.city_id=city.city_id
    JOIN country ON city.country_id=country.country_id;
-- 7h. List the top five genres in gross revenue in descending order. 
SELECT category.name, SUM(payment.amount) AS gross_revenue
FROM category
	JOIN film_category ON category.category_id=film_category.category_id
    JOIN inventory ON film_category.film_id=inventory.film_id
    JOIN rental ON inventory.inventory_id=rental.inventory_id
    JOIN payment ON rental.rental_id=payment.rental_id
		GROUP BY category.name
        ORDER BY gross_revenue DESC
		LIMIT 5;
-- 8a. Use the solution from the problem above to create a view.
CREATE VIEW top_five_genres AS
	SELECT category.name, SUM(payment.amount) AS gross_revenue
	FROM category
		JOIN film_category ON category.category_id=film_category.category_id
		JOIN inventory ON film_category.film_id=inventory.film_id
		JOIN rental ON inventory.inventory_id=rental.inventory_id
		JOIN payment ON rental.rental_id=payment.rental_id
			GROUP BY category.name
			ORDER BY gross_revenue DESC
			LIMIT 5;
-- 8B. How would you display the view that you created in 8a?
SELECT * FROM top_five_genres;
-- 8c. You find that you no longer need the view `top_five_genres`. Write a query to delete it.
DROP VIEW top_five_genres;