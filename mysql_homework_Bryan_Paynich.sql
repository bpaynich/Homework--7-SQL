# University of Arizona Data Science Bootcamp
# Bryan Paynich
# MYSQL HOMEWORK - 2/9/2019

USE sakila;

# 1a. Display the first and last names of all actors from the table actor.
select first_name, last_name from actor;

# 2a. You need to find the ID number, first name, and last name of an actor, 
# of whom you know only the first name, "Joe." What is one query would you 
# use to obtain this information?

SELECT actor_id, first_name, last_name FROM actor WHERE first_name = "Joe";

# 2b. Find all actors whose last name contain the letters GEN:

SELECT actor_id, first_name, last_name FROM actor WHERE last_name LIKE "%GEN%";

# 2c. Find all actors whose last names contain the letters LI. This time, 
# order the rows by last name and first name, in that order:

SELECT actor_id, first_name, last_name FROM actor 
	WHERE last_name LIKE "%LI%" ORDER BY last_name, first_name ASC;
    
# 2d. Using IN, display the country_id and country columns of the following 
# countries: Afghanistan, Bangladesh, and China:
    
select country_id, country FROM country WHERE country = "Afghanistan"
	OR country = "Bangladesh"
    OR country = "China";

# 3a. You want to keep a description of each actor. You don't think you will 
# be performing queries on a description, so create a column in the table actor
# named description and use the data type BLOB (Make sure to research the type 
# BLOB, as the difference between it and VARCHAR are significant).

ALTER TABLE sakila.actor 
ADD COLUMN description BLOB NULL AFTER last_name;

# 3b. Very quickly you realize that entering descriptions for each actor
# is too much effort. Delete the description column.

ALTER TABLE sakila.actor 
DROP COLUMN description;

#4a. List the last names of actors, as well as how many actors have that last name.

SELECT last_name, COUNT(last_name) as Count FROM actor GROUP BY last_name;

#4b. List last names of actors and the number of actors who have that last name, 
# but only for names that are shared by at least two actors

SELECT last_name, COUNT(last_name) AS ACTOR_COUNT FROM actor WHERE COUNT(last_name) > 1;

#4c. The actor HARPO WILLIAMS was accidentally entered in the actor table as GROUCHO WILLIAMS.
# Write a query to fix the record.

UPDATE actor SET first_name = "HARPO" WHERE first_name = "GROUCHO" AND last_name = "WILLIAMS";

# 4d. Perhaps we were too hasty in changing GROUCHO to HARPO. It turns out that GROUCHO was the 
# correct name after all! In a single query, if the first name of the actor is currently HARPO, 
# change it to GROUCHO.

UPDATE actor SET first_name = "GROUCHO" WHERE first_name = "HARPO";

#5a. You cannot locate the schema of the address table. Which query would you use to re-create it?
#Hint: https://dev.mysql.com/doc/refman/5.7/en/show-create-table.html

DESCRIBE address;

# 6a. Use JOIN to display the first and last names, as well as the address, of each staff member. 
# Use the tables staff and address:

SELECT staff.first_name, staff.last_name, address.address FROM staff JOIN address ON staff.address_id = address.address_id;

# 6b. Use JOIN to display the total amount rung up by each staff member in August of 2005.
# Use tables staff and payment.

SELECT staff.first_name, staff.last_name, SUM(amount) as TOTAL_SALES FROM staff JOIN payment ON staff.staff_id = payment.staff_id GROUP BY last_name;

# 6c. List each film and the number of actors who are listed for that film. Use tables film_actor 
# and film. Use inner join.

SELECT film.title, COUNT(actor_id) As ACTOR_COUNT FROM film JOIN film_actor ON film.film_id = film_actor.film_id GROUP BY title;

# 6d. How many copies of the film Hunchback Impossible exist in the inventory system?

SELECT film.title, COUNT(inventory.film_id) FROM film JOIN inventory ON film.film_id = inventory.film_id WHERE film.title = "Hunchback Impossible" ;

# 6e. Using the tables payment and customer and the JOIN command, list the total paid by each 
# customer. List the customers alphabetically by last name:

SELECT customer.first_name, customer.last_name, SUM(payment.amount) AS TOTAL_PAID FROM payment JOIN customer ON customer.customer_id = payment.customer_id GROUP BY last_name, first_name ASC;

# 7a. The music of Queen and Kris Kristofferson have seen an unlikely resurgence. As an unintended consequence, films starting with the letters
# K and Q have also soared in popularity. Use subqueries to display the titles of movies starting with the letters K and Q whose language is English.

SELECT title FROM film WHERE title like "Q%" OR title like "K%" AND language_id = 1;

# 7b. Use subqueries to display all actors who appear in the film Alone Trip.

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
  WHERE title = "Alone Trip"
  )
 );
 
# 7c. You want to run an email marketing campaign in Canada, for which you will need the names and email addresses of 
# all Canadian customers. Use joins to retrieve this information.

SELECT customer.first_name, customer.last_name, customer.email, address.address, city.city, country.country FROM customer 
	JOIN address ON customer.address_id = address.address_id
    JOIN city ON address.city_id = city.city_id
    JOIN country ON city.country_id = country.country_id WHERE country = "Canada";

# 7d. Sales have been lagging among young families, and you wish to target all family movies for a promotion. 
# Identify all movies categorized as family films.

# ====== I DONT THINK THE FILMS HAVE THE RIGHT CATEGORIES,  NC-17 shouldn't be FAMILY =====

SELECT film.title, film.rating, category.name FROM film
	JOIN film_category ON film.film_id = film_category.film_id
    JOIN category ON film_category.category_id = category.category_id WHERE category.name = "Family" ORDER BY rating ASC;

# 7e. Display the most frequently rented movies in descending order.

SELECT film.title, COUNT(inventory.inventory_id) AS RENTAL_COUNT FROM film
	JOIN inventory ON film.film_id = inventory.film_id
    JOIN rental ON inventory.inventory_id = rental.inventory_id GROUP BY film.title ORDER BY COUNT(inventory.inventory_id) DESC;

# 7f. Write a query to display how much business, in dollars, each store brought in.

SELECT payment.staff_id AS STORE, SUM(payment.amount) AS TOTAL FROM payment            
	JOIN staff ON payment.staff_id = staff.staff_id GROUP BY staff.store_id ASC;
    
# 7g. Write a query to display for each store its store ID, city, and country.

SELECT store.store_id, city.city, country.country FROM store
	JOIN address ON store.address_id = address.address_id
	JOIN city ON city.city_id = address.city_id
    JOIN country ON city.country_id = country.country_id;

# 7h. List the top five genres in gross revenue in descending order. (Hint: you may need to use the following 
# tables: category, film_category, inventory, payment, and rental.)

SELECT category.name AS GENRE, SUM(payment.amount) AS GROSS_REV FROM payment
	JOIN rental ON payment.rental_id = rental.rental_id
    JOIN inventory ON rental.inventory_id = inventory.inventory_id
    JOIN film_category ON inventory.film_id = film_category.film_id
    JOIN category ON category.category_id = film_category.category_id GROUP BY category.name;
    
# 8a. In your new role as an executive, you would like to have an easy way of viewing the Top five genres by gross revenue.
# Use the solution from the problem above to create a view. If you haven't solved 7h, you can substitute another query to create a view.

CREATE VIEW GENRE_VS_GROSS_REV AS SELECT category.name AS GENRE, SUM(payment.amount) AS GROSS_REV FROM payment
	JOIN rental ON payment.rental_id = rental.rental_id
    JOIN inventory ON rental.inventory_id = inventory.inventory_id
    JOIN film_category ON inventory.film_id = film_category.film_id
    JOIN category ON category.category_id = film_category.category_id GROUP BY category.name;

# 8b. How would you display the view that you created in 8a?

SHOW VIEW GENRE_VS_GROSS_REV;

# 8c. You find that you no longer need the view top_five_genres. Write a query to delete it.

DROP VIEW GENRE_VS_GROSS_REV;