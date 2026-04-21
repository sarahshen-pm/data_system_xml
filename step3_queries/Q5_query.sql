\timing on
SELECT MAX(pubid) AS max_pubid FROM publications;

-- ============================================================
-- Q5: 2021-2025在含"Data"的venue发表最多Top10作者
-- ============================================================

DROP INDEX IF EXISTS idx_inproc_booktitle;
DROP INDEX IF EXISTS idx_articles_journal;
DROP INDEX IF EXISTS idx_pub_year;
DROP INDEX IF EXISTS idx_authored_pubid;
DROP INDEX IF EXISTS idx_authored_aid;

\echo '=== Q5 FULL NO_INDEX ==='
WITH data_pubs AS (
    SELECT ip.pubid FROM inproceedings ip
    JOIN publications pub ON ip.pubid = pub.pubid
    WHERE ip.booktitle ILIKE '%data%' AND pub.year BETWEEN 2021 AND 2025
    UNION
    SELECT a.pubid FROM articles a
    JOIN publications pub ON a.pubid = pub.pubid
    WHERE a.journal ILIKE '%data%' AND pub.year BETWEEN 2021 AND 2025
)
SELECT au.name, COUNT(*) AS pub_count
FROM authored aed JOIN authors au ON aed.author_id = au.author_id
WHERE aed.pubid IN (SELECT pubid FROM data_pubs)
GROUP BY au.name ORDER BY pub_count DESC LIMIT 10;

\echo '=== Q5 HALF NO_INDEX ==='
WITH data_pubs AS (
    SELECT ip.pubid FROM inproceedings ip
    JOIN publications pub ON ip.pubid = pub.pubid
    WHERE ip.booktitle ILIKE '%data%' AND pub.year BETWEEN 2021 AND 2025
      AND ip.pubid <= (SELECT MAX(pubid) FROM publications) / 2
    UNION
    SELECT a.pubid FROM articles a
    JOIN publications pub ON a.pubid = pub.pubid
    WHERE a.journal ILIKE '%data%' AND pub.year BETWEEN 2021 AND 2025
      AND a.pubid <= (SELECT MAX(pubid) FROM publications) / 2
)
SELECT au.name, COUNT(*) AS pub_count
FROM authored aed JOIN authors au ON aed.author_id = au.author_id
WHERE aed.pubid IN (SELECT pubid FROM data_pubs)
GROUP BY au.name ORDER BY pub_count DESC LIMIT 10;

\echo '=== Q5 QUARTER NO_INDEX ==='
WITH data_pubs AS (
    SELECT ip.pubid FROM inproceedings ip
    JOIN publications pub ON ip.pubid = pub.pubid
    WHERE ip.booktitle ILIKE '%data%' AND pub.year BETWEEN 2021 AND 2025
      AND ip.pubid <= (SELECT MAX(pubid) FROM publications) / 4
    UNION
    SELECT a.pubid FROM articles a
    JOIN publications pub ON a.pubid = pub.pubid
    WHERE a.journal ILIKE '%data%' AND pub.year BETWEEN 2021 AND 2025
      AND a.pubid <= (SELECT MAX(pubid) FROM publications) / 4
)
SELECT au.name, COUNT(*) AS pub_count
FROM authored aed JOIN authors au ON aed.author_id = au.author_id
WHERE aed.pubid IN (SELECT pubid FROM data_pubs)
GROUP BY au.name ORDER BY pub_count DESC LIMIT 10;

CREATE INDEX IF NOT EXISTS idx_inproc_booktitle ON inproceedings(booktitle);
CREATE INDEX IF NOT EXISTS idx_articles_journal  ON articles(journal);
CREATE INDEX IF NOT EXISTS idx_pub_year          ON publications(year);
CREATE INDEX IF NOT EXISTS idx_authored_pubid    ON authored(pubid);
CREATE INDEX IF NOT EXISTS idx_authored_aid      ON authored(author_id);

\echo '=== Q5 FULL WITH_INDEX ==='
WITH data_pubs AS (
    SELECT ip.pubid FROM inproceedings ip
    JOIN publications pub ON ip.pubid = pub.pubid
    WHERE ip.booktitle ILIKE '%data%' AND pub.year BETWEEN 2021 AND 2025
    UNION
    SELECT a.pubid FROM articles a
    JOIN publications pub ON a.pubid = pub.pubid
    WHERE a.journal ILIKE '%data%' AND pub.year BETWEEN 2021 AND 2025
)
SELECT au.name, COUNT(*) AS pub_count
FROM authored aed JOIN authors au ON aed.author_id = au.author_id
WHERE aed.pubid IN (SELECT pubid FROM data_pubs)
GROUP BY au.name ORDER BY pub_count DESC LIMIT 10;

\echo '=== Q5 HALF WITH_INDEX ==='
WITH data_pubs AS (
    SELECT ip.pubid FROM inproceedings ip
    JOIN publications pub ON ip.pubid = pub.pubid
    WHERE ip.booktitle ILIKE '%data%' AND pub.year BETWEEN 2021 AND 2025
      AND ip.pubid <= (SELECT MAX(pubid) FROM publications) / 2
    UNION
    SELECT a.pubid FROM articles a
    JOIN publications pub ON a.pubid = pub.pubid
    WHERE a.journal ILIKE '%data%' AND pub.year BETWEEN 2021 AND 2025
      AND a.pubid <= (SELECT MAX(pubid) FROM publications) / 2
)
SELECT au.name, COUNT(*) AS pub_count
FROM authored aed JOIN authors au ON aed.author_id = au.author_id
WHERE aed.pubid IN (SELECT pubid FROM data_pubs)
GROUP BY au.name ORDER BY pub_count DESC LIMIT 10;

\echo '=== Q5 QUARTER WITH_INDEX ==='
WITH data_pubs AS (
    SELECT ip.pubid FROM inproceedings ip
    JOIN publications pub ON ip.pubid = pub.pubid
    WHERE ip.booktitle ILIKE '%data%' AND pub.year BETWEEN 2021 AND 2025
      AND ip.pubid <= (SELECT MAX(pubid) FROM publications) / 4
    UNION
    SELECT a.pubid FROM articles a
    JOIN publications pub ON a.pubid = pub.pubid
    WHERE a.journal ILIKE '%data%' AND pub.year BETWEEN 2021 AND 2025
      AND a.pubid <= (SELECT MAX(pubid) FROM publications) / 4
)
SELECT au.name, COUNT(*) AS pub_count
FROM authored aed JOIN authors au ON aed.author_id = au.author_id
WHERE aed.pubid IN (SELECT pubid FROM data_pubs)
GROUP BY au.name ORDER BY pub_count DESC LIMIT 10;
