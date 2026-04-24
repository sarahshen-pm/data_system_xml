-- 7. (a) Find authors who have published at least 1 paper every year 
-- in the last 30 years (1996 - 2025), and whose family name start with ‘H’. 

-- === Q7a FULL ===
SELECT au.name, COUNT(DISTINCT pub.year) AS active_years
FROM authors au
JOIN authored aed     ON au.author_id = aed.author_id
JOIN publications pub ON aed.pubid = pub.pubid
WHERE pub.year BETWEEN 1996 AND 2025 AND au.name ILIKE 'H%'
GROUP BY au.author_id, au.name
HAVING COUNT(DISTINCT pub.year) = 30
ORDER BY au.name;

-- === Q7a HALF ===
SELECT au.name, COUNT(DISTINCT pub.year) AS active_years
FROM authors au
JOIN authored aed     ON au.author_id = aed.author_id
JOIN publications pub ON aed.pubid = pub.pubid
WHERE pub.year BETWEEN 1996 AND 2025 AND au.name ILIKE 'H%'
  AND pub.pubid <= (SELECT MAX(pubid) FROM publications) / 2
GROUP BY au.author_id, au.name
HAVING COUNT(DISTINCT pub.year) = 30
ORDER BY au.name;

-- === Q7a QUARTER  ===
SELECT au.name, COUNT(DISTINCT pub.year) AS active_years
FROM authors au
JOIN authored aed     ON au.author_id = aed.author_id
JOIN publications pub ON aed.pubid = pub.pubid
WHERE pub.year BETWEEN 1996 AND 2025 AND au.name ILIKE 'H%'
  AND pub.pubid <= (SELECT MAX(pubid) FROM publications) / 4
GROUP BY au.author_id, au.name
HAVING COUNT(DISTINCT pub.year) = 30
ORDER BY au.name;


-- (b) Find the names and number of publications for authors who have 
-- the earliest publication record in DBLP.

-- === Q7b FULL ===
WITH earliest_year AS (
    SELECT MIN(year) AS min_year FROM publications WHERE year IS NOT NULL
)
SELECT au.name, COUNT(aed.pubid) AS total_pubs,
       (SELECT min_year FROM earliest_year) AS earliest_year
FROM authors au
JOIN authored aed     ON au.author_id = aed.author_id
JOIN publications pub ON aed.pubid = pub.pubid
WHERE pub.year = (SELECT min_year FROM earliest_year)
GROUP BY au.author_id, au.name
ORDER BY total_pubs DESC;

-- === Q7b HALF ===
WITH earliest_year AS (
    SELECT MIN(year) AS min_year FROM publications
    WHERE year IS NOT NULL
      AND pubid <= (SELECT MAX(pubid) FROM publications) / 2
)
SELECT au.name, COUNT(aed.pubid) AS total_pubs,
       (SELECT min_year FROM earliest_year) AS earliest_year
FROM authors au
JOIN authored aed     ON au.author_id = aed.author_id
JOIN publications pub ON aed.pubid = pub.pubid
WHERE pub.year = (SELECT min_year FROM earliest_year)
  AND pub.pubid <= (SELECT MAX(pubid) FROM publications) / 2
GROUP BY au.author_id, au.name
ORDER BY total_pubs DESC;

-- === Q7b QUARTER ===
WITH earliest_year AS (
    SELECT MIN(year) AS min_year FROM publications
    WHERE year IS NOT NULL
      AND pubid <= (SELECT MAX(pubid) FROM publications) / 4
)
SELECT au.name, COUNT(aed.pubid) AS total_pubs,
       (SELECT min_year FROM earliest_year) AS earliest_year
FROM authors au
JOIN authored aed     ON au.author_id = aed.author_id
JOIN publications pub ON aed.pubid = pub.pubid
WHERE pub.year = (SELECT min_year FROM earliest_year)
  AND pub.pubid <= (SELECT MAX(pubid) FROM publications) / 4
GROUP BY au.author_id, au.name
ORDER BY total_pubs DESC;

