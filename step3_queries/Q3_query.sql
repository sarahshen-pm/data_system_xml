-- 3. For each 10 consecutive years starting from 1976, i.e., [1976, 1985], 
-- [1986, 1995],…, [2016, 2025], compute the total number of conference 
-- publications in DBLP in that 10 years. Hint: for this query you may want 
-- to compute a temporary table with all distinct years.

-- === Q3 FULL ===
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

-- === Q3 HALF ===
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

-- === Q3 QUARTER ===
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