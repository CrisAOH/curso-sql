-- Mostrar país con más ciudades
-- Campos: Total de ciudades y nombre del país

SELECT count(*) AS total, b.name AS country
FROM city a
JOIN country b ON a.countrycode = b.code
GROUP BY b.name
ORDER BBY count(*) DESC
LIMIT 1;