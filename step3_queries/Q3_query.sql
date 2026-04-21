\timing on
SELECT MAX(pubid) AS max_pubid FROM publications;

-- ============================================================
-- Q3: 每10年区间会议论文总数（1976起）
-- ============================================================

DROP INDEX IF EXISTS idx_pub_year;
DROP INDEX IF EXISTS idx_pub_type;

\echo '=== Q3 FULL NO_INDEX ==='
WITH decade AS (
    SELECT CASE
        WHEN year BETWEEN 1976 AND 1985 THEN '[1976, 1985]'
        WHEN year BETWEEN 1986 AND 1995 THEN '[1986, 1995]'
        WHEN year BETWEEN 1996 AND 2005 THEN '[1996, 2005]'
        WHEN year BETWEEN 2006 AND 2015 THEN '[2006, 2015]'
        WHEN year BETWEEN 2016 AND 2025 THEN '[2016, 2025]'
    END AS decade_range
    FROM publications
    WHERE pub_type = 'inproceedings' AND year BETWEEN 1976 AND 2025
)
SELECT decade_range, COUNT(*) AS total
FROM decade WHERE decade_range IS NOT NULL
GROUP BY decade_range ORDER BY decade_range;

\echo '=== Q3 HALF NO_INDEX ==='
WITH decade AS (
    SELECT CASE
        WHEN year BETWEEN 1976 AND 1985 THEN '[1976, 1985]'
        WHEN year BETWEEN 1986 AND 1995 THEN '[1986, 1995]'
        WHEN year BETWEEN 1996 AND 2005 THEN '[1996, 2005]'
        WHEN year BETWEEN 2006 AND 2015 THEN '[2006, 2015]'
        WHEN year BETWEEN 2016 AND 2025 THEN '[2016, 2025]'
    END AS decade_range
    FROM publications
    WHERE pub_type = 'inproceedings'
      AND year BETWEEN 1976 AND 2025
      AND pubid <= (SELECT MAX(pubid) FROM publications) / 2
)
SELECT decade_range, COUNT(*) AS total
FROM decade WHERE decade_range IS NOT NULL
GROUP BY decade_range ORDER BY decade_range;

\echo '=== Q3 QUARTER NO_INDEX ==='
WITH decade AS (
    SELECT CASE
        WHEN year BETWEEN 1976 AND 1985 THEN '[1976, 1985]'
        WHEN year BETWEEN 1986 AND 1995 THEN '[1986, 1995]'
        WHEN year BETWEEN 1996 AND 2005 THEN '[1996, 2005]'
        WHEN year BETWEEN 2006 AND 2015 THEN '[2006, 2015]'
        WHEN year BETWEEN 2016 AND 2025 THEN '[2016, 2025]'
    END AS decade_range
    FROM publications
    WHERE pub_type = 'inproceedings'
      AND year BETWEEN 1976 AND 2025
      AND pubid <= (SELECT MAX(pubid) FROM publications) / 4
)
SELECT decade_range, COUNT(*) AS total
FROM decade WHERE decade_range IS NOT NULL
GROUP BY decade_range ORDER BY decade_range;

CREATE INDEX IF NOT EXISTS idx_pub_year ON publications(year);
CREATE INDEX IF NOT EXISTS idx_pub_type ON publications(pub_type);

\echo '=== Q3 FULL WITH_INDEX ==='
WITH decade AS (
    SELECT CASE
        WHEN year BETWEEN 1976 AND 1985 THEN '[1976, 1985]'
        WHEN year BETWEEN 1986 AND 1995 THEN '[1986, 1995]'
        WHEN year BETWEEN 1996 AND 2005 THEN '[1996, 2005]'
        WHEN year BETWEEN 2006 AND 2015 THEN '[2006, 2015]'
        WHEN year BETWEEN 2016 AND 2025 THEN '[2016, 2025]'
    END AS decade_range
    FROM publications
    WHERE pub_type = 'inproceedings' AND year BETWEEN 1976 AND 2025
)
SELECT decade_range, COUNT(*) AS total
FROM decade WHERE decade_range IS NOT NULL
GROUP BY decade_range ORDER BY decade_range;

\echo '=== Q3 HALF WITH_INDEX ==='
WITH decade AS (
    SELECT CASE
        WHEN year BETWEEN 1976 AND 1985 THEN '[1976, 1985]'
        WHEN year BETWEEN 1986 AND 1995 THEN '[1986, 1995]'
        WHEN year BETWEEN 1996 AND 2005 THEN '[1996, 2005]'
        WHEN year BETWEEN 2006 AND 2015 THEN '[2006, 2015]'
        WHEN year BETWEEN 2016 AND 2025 THEN '[2016, 2025]'
    END AS decade_range
    FROM publications
    WHERE pub_type = 'inproceedings'
      AND year BETWEEN 1976 AND 2025
      AND pubid <= (SELECT MAX(pubid) FROM publications) / 2
)
SELECT decade_range, COUNT(*) AS total
FROM decade WHERE decade_range IS NOT NULL
GROUP BY decade_range ORDER BY decade_range;

\echo '=== Q3 QUARTER WITH_INDEX ==='
WITH decade AS (
    SELECT CASE
        WHEN year BETWEEN 1976 AND 1985 THEN '[1976, 1985]'
        WHEN year BETWEEN 1986 AND 1995 THEN '[1986, 1995]'
        WHEN year BETWEEN 1996 AND 2005 THEN '[1996, 2005]'
        WHEN year BETWEEN 2006 AND 2015 THEN '[2006, 2015]'
        WHEN year BETWEEN 2016 AND 2025 THEN '[2016, 2025]'
    END AS decade_range
    FROM publications
    WHERE pub_type = 'inproceedings'
      AND year BETWEEN 1976 AND 2025
      AND pubid <= (SELECT MAX(pubid) FROM publications) / 4
)
SELECT decade_range, COUNT(*) AS total
FROM decade WHERE decade_range IS NOT NULL
GROUP BY decade_range ORDER BY decade_range;
