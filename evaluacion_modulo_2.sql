/* BASE DE DATOS SAKILA:

Para este ejercicio utilizaremos la bases de datos Sakila que hemos estado utilizando durante el repaso de SQL. Es una base de datos de 
ejemplo que simula una tienda de alquiler de películas. Contiene tablas como `film` (películas), `actor` (actores), `customer` 
(clientes), `rental` (alquileres), `category` (categorías), entre otras. Estas tablas contienen información sobre películas, actores, 
clientes, alquileres y más, y se utilizan para realizar consultas y análisis de datos en el contexto de una tienda de alquiler de 
películas. */

/* Primer paso para poder hacer uso de la base de datos Sakila*/
USE sakila;
/* Tablas que usaremos a lo largo del ejercicio*/

SELECT * FROM film;
SELECT * FROM actor;
SELECT * FROM customer;
SELECT * FROM rental;
SELECT * FROM category;
SELECT * FROM film_category;
SELECT * FROM film_actor;
SELECT * FROM inventory;

-- COMENZAMOS CON LOS EJERCICIOS PROPUESTOS--

/* 1. Selecciona todos los nombres de las películas sin que aparezcan duplicados.*/
/* Para obtener los títulos de las películas sin duplicados empleamos  SELECT DISTINCT */

 SELECT DISTINCT title FROM film; 

/* 2. Muestra los nombres de todas las películas que tengan una clasificación de "PG-13"*/
/* Establecemos una condición con WHERE*/

SELECT title
FROM film
WHERE rating = 'PG-13';

/* 3. Encuentra el título y la descripción de todas las películas que contengan la cadena 
de caracteres "amazing" en su descripción*/
/* Usamos el filtro LIKE para buscar esa cadena de caracteres 'amazing' en la descripción de las películas*/

SELECT title, description
FROM film
WHERE description LIKE '%amazing%';

/* 4. Encuentra el título de todas las películas que tengan una duración mayor a 120 minutos.*/
/* Establecemos una condición > e incluimos también la columna duración para comprobar el resultado*/

SELECT title, length
FROM film
WHERE length > 120;

/* 5. Recupera los nombres y apellidos de todos los actores.*/

SELECT first_name, last_name
FROM actor;

/* O si usaramos CONCAT: */
SELECT concat(first_name,' ', last_name) AS actor
FROM actor;

/* 6. Encuentra el nombre y apellidos de los actores que tengan "Gibson" en su apellido*/
/* De nuevo, usaremos un filtro para localizar GIBSON en el apellido de los actores*/

SELECT first_name, last_name
FROM actor
WHERE last_name LIKE '%Gibson%';

/* 7.  Encuentra los nombres y apellidos de los actores que tengan un actor_id entre 10 y 20*/
/* Establezcamos una condición con WHERE y rango entre 10 y 20*/

SELECT first_name, last_name
FROM actor
WHERE actor_id BETWEEN 10 AND 20;

/* 8.  Encuentra el título de las películas en la tabla `film` que no sean ni "R" ni "PG-13" en cuanto a 
su clasificación*/
/* Seguimos haciendo uso de filtros; en ese caso  NOT IN pues queremos que la categoría de las películas
buscadas NO se encuentren en R y PG-13*/

SELECT title, rating
FROM film
WHERE rating NOT IN ('R', 'PG-13');

/* 9. Encuentra la cantidad total de películas en cada clasificación de la tabla `film` y muestra 
la clasificación junto con el recuento*/
/* En este punto, necesitamos realizar un cálculo sobre una de las columnas y 
agrupar por otra de ellas*/

SELECT rating, COUNT(film_id) AS total_peliculas
FROM film
GROUP BY rating
ORDER BY total_peliculas DESC;
	
/* 10. Encuentra la cantidad total de películas alquiladas por cada cliente y muestra el ID del cliente,  
su nombre y apellido junto con la cantidad de películas alquiladas*/
/* La información que necesitamos se encuentra en tablas distintas, por lo que deberemos unirlas.
Concretamente las tablas customer y rental*/
/* Usamos un INNER JOIN porque queremos saber clientes que SI han alquilado películas y cuantas*/

SELECT cu.customer_id, CONCAT(cu.first_name,' ', cu.last_name) as cliente, COUNT(*) as alquiladas
FROM customer cu
INNER JOIN rental re ON cu.customer_id = re.customer_id
GROUP BY cu.customer_id
ORDER BY alquiladas DESC;

/* 11. Encuentra la cantidad total de películas alquiladas por categoría y muestra el nombre 
de la categoría junto con el recuento de alquileres*/
/* De nuevo necesitamos unir tablas. En este caso son varias las protagonistas: category, film_category,
film, inventory y rental.*/

SELECT ca.name as categoria, COUNT(re.rental_id) as peliculas_alquiladas
FROM category ca
INNER JOIN film_category fc ON ca.category_id = fc.category_id
INNER JOIN film f ON fc.film_id = f.film_id
INNER JOIN  inventory i ON f.film_id = i.film_id
INNER JOIN rental re ON i.inventory_id = re.inventory_id
GROUP BY ca.name
ORDER BY peliculas_alquiladas DESC;

/* 12. Encuentra el promedio de duración de las películas para cada clasificación de la tabla `film` y 
muestra la clasificación junto con el promedio de duración*/
/* En este caso, los datos que precisamos están en la misma tabla. Por lo que vamos a calcular y agrupar*/

SELECT rating, ROUND(AVG(length)) AS duracion_media
FROM film
GROUP BY rating
ORDER BY duracion_media DESC;
/* Redondeamos la duración media sin decimales para que se asemeje al formato de la columna duración*/

/* 13. Encuentra el nombre y apellido de los actores que aparecen en la película con title "Indian Love"*/
/* Realicemos una subconsulta. En la tabla FILM puedo filtrar por título de película, pero después
necesitaría unir las tablas FILM_ACTOR y ACTOR para conocer su nombre y apellidos*/

SELECT CONCAT(a.first_name, ' ',  a.last_name) AS actor
FROM actor a
INNER JOIN film_actor fa ON a.actor_id = fa.actor_id
WHERE fa.film_id = (SELECT film_id
					FROM film
					WHERE title = 'Indian Love');

/* 14. Muestra el título de todas las películas que contengan la cadena de caracteres "dog" o "cat" 
en su descripción*/
/* Para esta consulta, los datos que necesitamos se encuentran en la misma tabla*/

SELECT title
FROM film
WHERE description LIKE '%dog%' OR  description LIKE '%cat%';
/* Usamos el  filtro LIKE porque se nos pide buscar la cadena de caracteres 'dog' o 'cat', no 
 esas palabras concretas. De pedirnos eso podríamos utilizar REGEXP*/

/* 15. Hay algún actor o actriz que no aparezca en ninguna película en la tabla `film_actor`*/
/* Vamos a probar con un LEFT JOIN entre las tablas ACTOR y FILM_ACTOR. Esta unión nos conservaría 
todos los actores, aunque no tuvieran coincidencias; estos aparecerían como NULL y de ahí la condición
WHERE...IS NULL*/

SELECT CONCAT(a.first_name, ' ', a.last_name) AS actor_no_presente
FROM actor a
LEFT JOIN film_actor fa ON a.actor_id = fa.actor_id
WHERE fa.actor_id  IS NULL;

/* Nos devuelve una tabla sin valores, por lo que todos los actores aparecieron al menos en una película*/

/* Vamos a resolverlo también con una CONSULTA CORRELACIONADA*/ 
SELECT CONCAT(a.first_name, ' ', a.last_name) AS actor_no_presente
FROM actor a
WHERE NOT EXISTS (SELECT * FROM film_actor fa
					WHERE fa.actor_id = a.actor_id);
                    
/* 16. Encuentra el título de todas las películas que fueron lanzadas entre el año 2005 y 2010*/
/* Los datos de interés se encuentran en la misma tabla FILM. Vamos a utilizar la condición WHERE 
con BETWEEN para incluir todas las películas entre esos años (incluidos)*/

SELECT title 
FROM film
WHERE release_year BETWEEN 2005 AND 2010;

/* 17. Encuentra el título de todas las películas que son de la misma categoría que "Family"*/
/* Unamos la tabla principal de la consulta FILM con FILM_CATEGORY y CATEGORY*/

SELECT f.title
FROM film f
INNER JOIN film_category fc ON f.film_id = fc.film_id
INNER JOIN category ca ON ca.category_id = fc.category_id
WHERE ca.name = 'Family';

/* 18. Muestra el nombre y apellido de los actores que aparecen en más de 10 películas*/
/* Para la resolución de este enunciado, necesitamos la unión de diferentes tablas, agrupar y
establecer la condición de más de 10 películas con HAVING*/

SELECT CONCAT(a.first_name, ' ', a.last_name) AS actor , COUNT(f.film_id) AS num_peliculas
FROM actor a
INNER JOIN film_actor fa ON fa.actor_id = a.actor_id
INNER JOIN film f ON f.film_id = fa.film_id
GROUP BY a.actor_id, a.first_name, a.last_name
HAVING num_peliculas > 10
ORDER BY num_peliculas DESC;

/* 19. Encuentra el título de todas las películas que son "R" y tienen una duración mayor a 
2 horas en la tabla 'film'*/
/* Tenemos que definir dos condiciones: la categoría  'R' y la duración mayor a 120 minutos, sobre
datos en la misma tabla*/

SELECT title
FROM film
WHERE rating = 'R' AND length > (120); 

/* 20. Encuentra las categorías de películas que tienen un promedio de duración superior a 120 minutos y 
muestra el nombre de la categoría junto con el promedio de duración*/
/*Necesitamos unir varias tablas, realizar una función agregada sobre la columna de una de ellas para
después establecer la condición de que su duración media sea superior a 120 minutos*/

SELECT c.name AS categoria, ROUND(AVG(f.length)) AS duracion_media
FROM category c
INNER JOIN film_category fc ON fc.category_id = c.category_id
INNER JOIN film f ON f.film_id = fc.film_id
GROUP BY c.name, c.category_id
HAVING duracion_media > 120
ORDER BY duracion_media DESC;

/* 21. Encuentra los actores que han actuado en al menos 5 películas y muestra el 
nombre del actor junto con la cantidad de películas en las que han actuado*/
/* En este caso, necesitamos las tablas ACTOR y FILM_ACTOR. Sobre esta segunda tabla, contamos los film_id
para cada actor*/

SELECT CONCAT(a.first_name, ' ', a.last_name) AS nombre, COUNT(fa.film_id) AS peliculas
FROM actor a
INNER JOIN film_actor fa ON fa.actor_id = a.actor_id
GROUP BY a.first_name, a.last_name, a.actor_id
HAVING COUNT(fa.film_id) >= 5
ORDER BY peliculas DESC;

/* 22. Encuentra el título de todas las películas que fueron alquiladas por más de 5 días. 
Utiliza una subconsulta para encontrar los rental_ids con una duración superior a 5 días y luego 
selecciona las películas correspondientes*/

SELECT DISTINCT f.title
FROM film f
INNER JOIN  inventory i ON i.film_id = f.film_id
INNER JOIN  rental re ON re.inventory_id = i.inventory_id
WHERE re.rental_id  IN (SELECT rental_id
	   FROM rental 
       WHERE return_date IS NOT NULL
       AND DATEDIFF(return_date, rental_date) > 5);
/* En la subconsulta establecemos dos condiciones, que los días que se haya alquilado la película sean
más de 5 y también que hayan sido devueltas (return_date IS NOT NULL). Después se hace una selección
de títulos distintos, pues cabe suponer que la misma película se alquilaría en repetidas ocasiones*/

/* 23. Encuentra el nombre y apellido de los actores que no han actuado en ninguna película de la 
categoría "Horror". Utiliza una subconsulta para encontrar los actores que han actuado en películas 
de la categoría "Horror" y luego exclúyelos de la lista de actores*/

SELECT CONCAT(a.first_name, ' ', a.last_name) AS actor_no_horror
FROM actor a
WHERE a.actor_id NOT IN (
SELECT DISTINCT fa.actor_id
FROM film_actor fa
INNER JOIN film_category fc ON fc.film_id = fa.film_id
INNER JOIN category c ON c.category_id = fc.category_id
WHERE c.name = 'Horror');

/* Vayamos por partes ;). En la consulta principal estamos tomando la tabla ACTOR de la cual queremos 
nombre y apellidos y donde su actor_id NO ESTÉ en la subconsulta -->¿Qué dice la subconsulta?---> De la 
tabla FILM_ACTOR estamos llegando hasta CATEGORY y seleccionando aquellos ACTOR_ID distintos que coinciden con 
Horror. Estos son los que serán excluidos en la consulta principal*/

/* 24. Encuentra el título de las películas que son comedias y tienen una duración mayor a 
180 minutos en la tabla `film`*/
/* Unimos las tablas precisas para llegar de FILM a CATEGORY*/

SELECT f.title
FROM film f
INNER JOIN film_category fc ON fc.film_id = f.film_id
INNER JOIN  category c ON c.category_id = fc.category_id
WHERE c.name = 'Comedy' AND f.length > 180;

/* Probemos a hacerlo con una subconsulta en la que obtengamos el category_id 'Comedy'*/

SELECT f.title
FROM film f
INNER JOIN film_category fc ON fc.film_id = f.film_id
WHERE f.length > 180 AND fc.category_id = (SELECT category_id
										FROM category
                                        WHERE name = 'Comedy');
