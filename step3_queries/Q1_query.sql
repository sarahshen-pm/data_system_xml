-- Q1: For each type of publication, count the total number of publications of 
-- that type between 2016- 2025. Your query should return a set of (publication-type, count) pairs. 
-- For example, (article, 20000), (inproceedings, 30000), ...

-- === Q1 FULL ===
SELECT pub_type, COUNT(*) AS total_count
FROM publications
WHERE year BETWEEN 2016 AND 2025
GROUP BY pub_type
ORDER BY total_count DESC;

-- === Q1 HALF ===
SELECT pub_type, COUNT(*) AS total_count
FROM publications
WHERE year BETWEEN 2016 AND 2025
  AND pubid <= (SELECT MAX(pubid) FROM publications) / 2
GROUP BY pub_type
ORDER BY total_count DESC;

-- === Q1 QUARTER ===
SELECT pub_type, COUNT(*) AS total_count
FROM publications
WHERE year BETWEEN 2016 AND 2025
  AND pubid <= (SELECT MAX(pubid) FROM publications) / 4
GROUP BY pub_type
ORDER BY total_count DESC;

