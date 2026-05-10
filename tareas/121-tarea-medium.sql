-- 1. Cuantos Post hay - 1050
SELECT COUNT(*) AS total_posts
FROM posts;

-- 2. Cuantos Post publicados hay - 543
SELECT COUNT(*) AS published_posts
FROM posts
WHERE published = TRUE;

-- 3. Cual es el Post mas reciente
-- 544 - nisi commodo officia...2024-05-30 00:29:21.277
SELECT *
FROM posts
ORDER BY created_at DESC
LIMIT 1;

-- 4. Quiero los 10 usuarios con más post, cantidad de posts, id y nombre
/*
4	1553	Jessie Sexton
3	1400	Prince Fuentes
3	1830	Hull George
3	470	Traci Wood
3	441	Livingston Davis
3	1942	Inez Dennis
3	1665	Maggie Davidson
3	524	Lidia Sparks
3	436	Mccoy Boone
3	2034	Bonita Rowe
*/
SELECT COUNT(p.post_id) AS total_posts, u.user_id, u.name
FROM posts p
         JOIN users u ON p.created_by = u.user_id
GROUP BY u.user_id, u.name
ORDER BY total_posts DESC
LIMIT 10;

-- 5. Quiero los 5 post con más "Claps" sumando la columna "counter"
/*
692	sit excepteur ex ipsum magna fugiat laborum exercitation fugiat
646	do deserunt ea
542	do
504	ea est sunt magna consectetur tempor cupidatat
502	amet exercitation tempor laborum fugiat aliquip dolore
*/
SELECT SUM(c.counter) AS total_claps, p.title
FROM posts p
         JOIN claps c ON p.post_id = c.post_id
GROUP BY p.title
ORDER BY total_claps DESC
LIMIT 5;

-- 6. Top 5 de personas que han dado más claps (voto único no acumulado ) *count
/*
7	Lillian Hodge
6	Dominguez Carson
6	Marva Joyner
6	Lela Cardenas
6	Rose Owen
*/
SELECT COUNT(clap_id) AS total_claps, u.name
FROM claps c
    JOIN users u ON c.user_id = u.user_id
GROUP BY u.name
ORDER BY total_claps DESC
LIMIT 5;

-- 7. Top 5 personas con votos acumulados (sumar counter)
/*
437	Rose Owen
394	Marva Joyner
386	Marquez Kennedy
379	Jenna Roth
364	Lillian Hodge
*/
SELECT SUM(c.counter) AS total_claps, u.name
FROM claps c
    JOIN users u ON c.user_id = u.user_id
GROUP BY u.name
ORDER BY total_claps DESC
LIMIT 5;

-- 8. Cuantos usuarios NO tienen listas de favoritos creada
-- 329
SELECT COUNT(*)
FROM user_lists ul
RIGHT JOIN users u on u.user_id = ul.user_id
WHERE ul.user_id IS NULL;

-- 9. Quiero el comentario con id #1
-- Y en el mismo resultado, quiero sus respuestas (visibles e invisibles)
-- Tip: union
/*
1	    648	1905	elit id...
3058	583	1797	tempor mollit...
4649	51	1842	laborum mollit...
4768	835	1447	nostrud nulla...
*/
SELECT c.comment_id, c.post_id, c.user_id, c.content
FROM comments c
WHERE c.comment_id = 1
UNION
SELECT c2.comment_id, c2.post_id, c2.user_id, c2.content
FROM comments c2
WHERE c2.comment_parent_id = 1;

-- ** 10. Avanzado
-- Investigar sobre el json_agg y json_build_object
-- Crear una única linea de respuesta, con las respuestas
-- del comentario con id 1 (comment_parent_id = 1)
-- Mostrar el user_id y el contenido del comentario

-- Salida esperada:
/*
"[{""user"" : 1797, ""comment"" : ""tempor mollit aliqua dolore cupidatat dolor tempor""}, {""user"" : 1842, ""comment"" : ""laborum mollit amet aliqua enim eiusmod ut""}, {""user"" : 1447, ""comment"" : ""nostrud nulla duis enim duis reprehenderit laboris voluptate cupidatat""}]"
*/
SELECT json_agg(
               json_build_object(
                       'user', c2.user_id,
                       'comment', c2.content
               )
       )
FROM comments c2
WHERE c2.comment_parent_id = 1;

-- ** 11. Avanzado
-- Listar todos los comentarios principales (no respuestas) 
-- Y crear una columna adicional "replies" con las respuestas en formato JSON
SELECT c.comment_id,
       c.post_id,
       c.user_id,
       c.content,
       (SELECT json_agg(
                       json_build_object(
                               'user', c2.user_id,
                               'comment', c2.content
                       )
               )
        FROM comments c2
        WHERE c2.comment_parent_id = c.comment_id) AS replies
FROM comments c
WHERE c.comment_parent_id IS NULL;

-- CON FUNCIONES DE SQL
CREATE OR REPLACE FUNCTION comment_replies(id INTEGER)
    RETURNS JSON
AS
$$
DECLARE result JSON;
BEGIN
    SELECT json_agg(
                   json_build_object(
                           'user', c2.user_id,
                           'comment', c2.content
                   )
           ) INTO result
    FROM comments c2
    WHERE c2.comment_parent_id = id;

    RETURN result;
END
$$
    LANGUAGE plpgsql;



