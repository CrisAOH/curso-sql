-- Count Union - Tarea
-- Total |  Continent
-- 5	  | Antarctica
-- 28	  | Oceania
-- 46	  | Europe
-- 51	  | America
-- 51	  | Asia
-- 58	  | Africa

SELECT count(*) AS Total, ctnt.name AS Continent
FROM country ctry
JOIN continent ctnt ON ctry.continent = ctnt.code
WHERE ctnt.name NOT LIKE '%America'
GROUP BY ctnt.name
UNION
SELECT count(*) AS Total, 'America' AS Continent
FROM country ctry
JOIN continent ctnt ON ctry.continent = ctnt.code
WHERE ctnt.name LIKE '%America'
ORDER BY Total;