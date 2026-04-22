SELECT 'authors'       AS tbl, COUNT(*) FROM authors
UNION ALL
SELECT 'publications'  AS tbl, COUNT(*) FROM publications
UNION ALL
SELECT 'articles'      AS tbl, COUNT(*) FROM articles
UNION ALL
SELECT 'inproceedings' AS tbl, COUNT(*) FROM inproceedings
UNION ALL
SELECT 'proceedings'   AS tbl, COUNT(*) FROM proceedings
UNION ALL
SELECT 'incollections' AS tbl, COUNT(*) FROM incollections
UNION ALL
SELECT 'books'         AS tbl, COUNT(*) FROM books
UNION ALL
SELECT 'authored'      AS tbl, COUNT(*) FROM authored;




SELECT p.pubkey, p.title, a.journal
FROM articles a
JOIN publications p ON a.pubid = p.pubid
WHERE a.journal IS NULL OR a.journal = ''
LIMIT 20;