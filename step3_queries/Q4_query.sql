\timing on
SELECT MAX(pubid) AS max_pubid FROM publications;

-- ============================================================
-- Q4: 在含"data"的会议/期刊中合作者最多的作者
-- ============================================================

DROP INDEX IF EXISTS idx_inproc_booktitle;
DROP INDEX IF EXISTS idx_articles_journal;
DROP INDEX IF EXISTS idx_authored_pubid;
DROP INDEX IF EXISTS idx_authored_aid;

\echo '=== Q4 FULL NO_INDEX ==='
WITH data_pubs AS (
    SELECT ip.pubid FROM inproceedings ip WHERE ip.booktitle ILIKE '%data%'
    UNION
    SELECT a.pubid  FROM articles a       WHERE a.journal   ILIKE '%data%'
),
data_authors AS (
    SELECT au.author_id, au.pubid FROM authored au
    WHERE au.pubid IN (SELECT pubid FROM data_pubs)
),
coauthors AS (
    SELECT DISTINCT a1.author_id, a2.author_id AS coauthor_id
    FROM data_authors a1
    JOIN data_authors a2 ON a1.pubid = a2.pubid AND a1.author_id <> a2.author_id
)
SELECT au.name, COUNT(*) AS collaborator_count
FROM coauthors c JOIN authors au ON c.author_id = au.author_id
GROUP BY au.name ORDER BY collaborator_count DESC LIMIT 10;

\echo '=== Q4 HALF NO_INDEX ==='
WITH data_pubs AS (
    SELECT ip.pubid FROM inproceedings ip WHERE ip.booktitle ILIKE '%data%'
      AND ip.pubid <= (SELECT MAX(pubid) FROM publications) / 2
    UNION
    SELECT a.pubid  FROM articles a WHERE a.journal ILIKE '%data%'
      AND a.pubid <= (SELECT MAX(pubid) FROM publications) / 2
),
data_authors AS (
    SELECT au.author_id, au.pubid FROM authored au
    WHERE au.pubid IN (SELECT pubid FROM data_pubs)
),
coauthors AS (
    SELECT DISTINCT a1.author_id, a2.author_id AS coauthor_id
    FROM data_authors a1
    JOIN data_authors a2 ON a1.pubid = a2.pubid AND a1.author_id <> a2.author_id
)
SELECT au.name, COUNT(*) AS collaborator_count
FROM coauthors c JOIN authors au ON c.author_id = au.author_id
GROUP BY au.name ORDER BY collaborator_count DESC LIMIT 10;

\echo '=== Q4 QUARTER NO_INDEX ==='
WITH data_pubs AS (
    SELECT ip.pubid FROM inproceedings ip WHERE ip.booktitle ILIKE '%data%'
      AND ip.pubid <= (SELECT MAX(pubid) FROM publications) / 4
    UNION
    SELECT a.pubid  FROM articles a WHERE a.journal ILIKE '%data%'
      AND a.pubid <= (SELECT MAX(pubid) FROM publications) / 4
),
data_authors AS (
    SELECT au.author_id, au.pubid FROM authored au
    WHERE au.pubid IN (SELECT pubid FROM data_pubs)
),
coauthors AS (
    SELECT DISTINCT a1.author_id, a2.author_id AS coauthor_id
    FROM data_authors a1
    JOIN data_authors a2 ON a1.pubid = a2.pubid AND a1.author_id <> a2.author_id
)
SELECT au.name, COUNT(*) AS collaborator_count
FROM coauthors c JOIN authors au ON c.author_id = au.author_id
GROUP BY au.name ORDER BY collaborator_count DESC LIMIT 10;

CREATE INDEX IF NOT EXISTS idx_inproc_booktitle ON inproceedings(booktitle);
CREATE INDEX IF NOT EXISTS idx_articles_journal  ON articles(journal);
CREATE INDEX IF NOT EXISTS idx_authored_pubid    ON authored(pubid);
CREATE INDEX IF NOT EXISTS idx_authored_aid      ON authored(author_id);

\echo '=== Q4 FULL WITH_INDEX ==='
WITH data_pubs AS (
    SELECT ip.pubid FROM inproceedings ip WHERE ip.booktitle ILIKE '%data%'
    UNION
    SELECT a.pubid  FROM articles a       WHERE a.journal   ILIKE '%data%'
),
data_authors AS (
    SELECT au.author_id, au.pubid FROM authored au
    WHERE au.pubid IN (SELECT pubid FROM data_pubs)
),
coauthors AS (
    SELECT DISTINCT a1.author_id, a2.author_id AS coauthor_id
    FROM data_authors a1
    JOIN data_authors a2 ON a1.pubid = a2.pubid AND a1.author_id <> a2.author_id
)
SELECT au.name, COUNT(*) AS collaborator_count
FROM coauthors c JOIN authors au ON c.author_id = au.author_id
GROUP BY au.name ORDER BY collaborator_count DESC LIMIT 10;

\echo '=== Q4 HALF WITH_INDEX ==='
WITH data_pubs AS (
    SELECT ip.pubid FROM inproceedings ip WHERE ip.booktitle ILIKE '%data%'
      AND ip.pubid <= (SELECT MAX(pubid) FROM publications) / 2
    UNION
    SELECT a.pubid  FROM articles a WHERE a.journal ILIKE '%data%'
      AND a.pubid <= (SELECT MAX(pubid) FROM publications) / 2
),
data_authors AS (
    SELECT au.author_id, au.pubid FROM authored au
    WHERE au.pubid IN (SELECT pubid FROM data_pubs)
),
coauthors AS (
    SELECT DISTINCT a1.author_id, a2.author_id AS coauthor_id
    FROM data_authors a1
    JOIN data_authors a2 ON a1.pubid = a2.pubid AND a1.author_id <> a2.author_id
)
SELECT au.name, COUNT(*) AS collaborator_count
FROM coauthors c JOIN authors au ON c.author_id = au.author_id
GROUP BY au.name ORDER BY collaborator_count DESC LIMIT 10;

\echo '=== Q4 QUARTER WITH_INDEX ==='
WITH data_pubs AS (
    SELECT ip.pubid FROM inproceedings ip WHERE ip.booktitle ILIKE '%data%'
      AND ip.pubid <= (SELECT MAX(pubid) FROM publications) / 4
    UNION
    SELECT a.pubid  FROM articles a WHERE a.journal ILIKE '%data%'
      AND a.pubid <= (SELECT MAX(pubid) FROM publications) / 4
),
data_authors AS (
    SELECT au.author_id, au.pubid FROM authored au
    WHERE au.pubid IN (SELECT pubid FROM data_pubs)
),
coauthors AS (
    SELECT DISTINCT a1.author_id, a2.author_id AS coauthor_id
    FROM data_authors a1
    JOIN data_authors a2 ON a1.pubid = a2.pubid AND a1.author_id <> a2.author_id
)
SELECT au.name, COUNT(*) AS collaborator_count
FROM coauthors c JOIN authors au ON c.author_id = au.author_id
GROUP BY au.name ORDER BY collaborator_count DESC LIMIT 10;
