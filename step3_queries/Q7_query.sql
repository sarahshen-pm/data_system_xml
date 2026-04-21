\timing on
SELECT MAX(pubid) AS max_pubid FROM publications;

-- ============================================================
-- Q7a: 1996-2025每年都发表且姓H的作者
-- ============================================================

DROP INDEX IF EXISTS idx_pub_year;
DROP INDEX IF EXISTS idx_authored_pubid;
DROP INDEX IF EXISTS idx_authored_aid;
DROP INDEX IF EXISTS idx_authors_name;

\echo '=== Q7a FULL NO_INDEX ==='
SELECT au.name, COUNT(DISTINCT pub.year) AS active_years
FROM authors au
JOIN authored aed     ON au.author_id = aed.author_id
JOIN publications pub ON aed.pubid = pub.pubid
WHERE pub.year BETWEEN 1996 AND 2025 AND au.name ILIKE 'H%'
GROUP BY au.author_id, au.name
HAVING COUNT(DISTINCT pub.year) = 30
ORDER BY au.name;

\echo '=== Q7a HALF NO_INDEX ==='
SELECT au.name, COUNT(DISTINCT pub.year) AS active_years
FROM authors au
JOIN authored aed     ON au.author_id = aed.author_id
JOIN publications pub ON aed.pubid = pub.pubid
WHERE pub.year BETWEEN 1996 AND 2025 AND au.name ILIKE 'H%'
  AND pub.pubid <= (SELECT MAX(pubid) FROM publications) / 2
GROUP BY au.author_id, au.name
HAVING COUNT(DISTINCT pub.year) = 30
ORDER BY au.name;

\echo '=== Q7a QUARTER NO_INDEX ==='
SELECT au.name, COUNT(DISTINCT pub.year) AS active_years
FROM authors au
JOIN authored aed     ON au.author_id = aed.author_id
JOIN publications pub ON aed.pubid = pub.pubid
WHERE pub.year BETWEEN 1996 AND 2025 AND au.name ILIKE 'H%'
  AND pub.pubid <= (SELECT MAX(pubid) FROM publications) / 4
GROUP BY au.author_id, au.name
HAVING COUNT(DISTINCT pub.year) = 30
ORDER BY au.name;

CREATE INDEX IF NOT EXISTS idx_pub_year      ON publications(year);
CREATE INDEX IF NOT EXISTS idx_authored_pubid ON authored(pubid);
CREATE INDEX IF NOT EXISTS idx_authored_aid   ON authored(author_id);
CREATE INDEX IF NOT EXISTS idx_authors_name   ON authors(name);

\echo '=== Q7a FULL WITH_INDEX ==='
SELECT au.name, COUNT(DISTINCT pub.year) AS active_years
FROM authors au
JOIN authored aed     ON au.author_id = aed.author_id
JOIN publications pub ON aed.pubid = pub.pubid
WHERE pub.year BETWEEN 1996 AND 2025 AND au.name ILIKE 'H%'
GROUP BY au.author_id, au.name
HAVING COUNT(DISTINCT pub.year) = 30
ORDER BY au.name;

\echo '=== Q7a HALF WITH_INDEX ==='
SELECT au.name, COUNT(DISTINCT pub.year) AS active_years
FROM authors au
JOIN authored aed     ON au.author_id = aed.author_id
JOIN publications pub ON aed.pubid = pub.pubid
WHERE pub.year BETWEEN 1996 AND 2025 AND au.name ILIKE 'H%'
  AND pub.pubid <= (SELECT MAX(pubid) FROM publications) / 2
GROUP BY au.author_id, au.name
HAVING COUNT(DISTINCT pub.year) = 30
ORDER BY au.name;

\echo '=== Q7a QUARTER WITH_INDEX ==='
SELECT au.name, COUNT(DISTINCT pub.year) AS active_years
FROM authors au
JOIN authored aed     ON au.author_id = aed.author_id
JOIN publications pub ON aed.pubid = pub.pubid
WHERE pub.year BETWEEN 1996 AND 2025 AND au.name ILIKE 'H%'
  AND pub.pubid <= (SELECT MAX(pubid) FROM publications) / 4
GROUP BY au.author_id, au.name
HAVING COUNT(DISTINCT pub.year) = 30
ORDER BY au.name;


-- ============================================================
-- Q7b: 最早发表记录的作者及论文数
-- ============================================================

DROP INDEX IF EXISTS idx_pub_year;
DROP INDEX IF EXISTS idx_authored_pubid;
DROP INDEX IF EXISTS idx_authored_aid;

\echo '=== Q7b FULL NO_INDEX ==='
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

\echo '=== Q7b HALF NO_INDEX ==='
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

\echo '=== Q7b QUARTER NO_INDEX ==='
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

CREATE INDEX IF NOT EXISTS idx_pub_year       ON publications(year);
CREATE INDEX IF NOT EXISTS idx_authored_pubid  ON authored(pubid);
CREATE INDEX IF NOT EXISTS idx_authored_aid    ON authored(author_id);

\echo '=== Q7b FULL WITH_INDEX ==='
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

\echo '=== Q7b HALF WITH_INDEX ==='
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

\echo '=== Q7b QUARTER WITH_INDEX ==='
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
