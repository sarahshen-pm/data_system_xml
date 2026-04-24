-- 5. Data analytics and data science are very popular topics. Find the top 10 authors 
-- with the largest number of publications that are published in conferences and journals 
-- whose titles contain word “Data” in the last 5 years (2021 - 2025).


-- === Q5 FULL ===
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

-- === Q5 HALF  ===
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

-- === Q5 QUARTER ===
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