\timing on
SELECT MAX(pubid) AS max_pubid FROM publications;

-- ============================================================
-- Q1: 每种文献类型在2016-2025的总数
-- ============================================================

DROP INDEX IF EXISTS idx_pub_year;
DROP INDEX IF EXISTS idx_pub_type;

\echo '=== Q1 FULL NO_INDEX ==='
SELECT pub_type, COUNT(*) AS total_count
FROM publications
WHERE year BETWEEN 2016 AND 2025
GROUP BY pub_type
ORDER BY total_count DESC;

\echo '=== Q1 HALF NO_INDEX ==='
SELECT pub_type, COUNT(*) AS total_count
FROM publications
WHERE year BETWEEN 2016 AND 2025
  AND pubid <= (SELECT MAX(pubid) FROM publications) / 2
GROUP BY pub_type
ORDER BY total_count DESC;

\echo '=== Q1 QUARTER NO_INDEX ==='
SELECT pub_type, COUNT(*) AS total_count
FROM publications
WHERE year BETWEEN 2016 AND 2025
  AND pubid <= (SELECT MAX(pubid) FROM publications) / 4
GROUP BY pub_type
ORDER BY total_count DESC;

-- 创建 Q1 相关索引
CREATE INDEX IF NOT EXISTS idx_pub_year  ON publications(year);
CREATE INDEX IF NOT EXISTS idx_pub_type  ON publications(pub_type);

\echo '=== Q1 FULL WITH_INDEX ==='
SELECT pub_type, COUNT(*) AS total_count
FROM publications
WHERE year BETWEEN 2016 AND 2025
GROUP BY pub_type
ORDER BY total_count DESC;

\echo '=== Q1 HALF WITH_INDEX ==='
SELECT pub_type, COUNT(*) AS total_count
FROM publications
WHERE year BETWEEN 2016 AND 2025
  AND pubid <= (SELECT MAX(pubid) FROM publications) / 2
GROUP BY pub_type
ORDER BY total_count DESC;

\echo '=== Q1 QUARTER WITH_INDEX ==='
SELECT pub_type, COUNT(*) AS total_count
FROM publications
WHERE year BETWEEN 2016 AND 2025
  AND pubid <= (SELECT MAX(pubid) FROM publications) / 4
GROUP BY pub_type
ORDER BY total_count DESC;
