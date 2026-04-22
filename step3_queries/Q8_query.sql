-- Q8: Check number of publications for each author in each type of publication

-- === Q8 FULL ===
SELECT au.name, pub.pub_type, COUNT(*) AS pub_count
FROM authors au
JOIN authored aed     ON au.author_id = aed.author_id
JOIN publications pub ON aed.pubid = pub.pubid
GROUP BY au.name, pub.pub_type
HAVING COUNT(*) >= 50
ORDER BY pub_count DESC LIMIT 20;

-- === Q8 HALF ===
SELECT au.name, pub.pub_type, COUNT(*) AS pub_count
FROM authors au
JOIN authored aed     ON au.author_id = aed.author_id
JOIN publications pub ON aed.pubid = pub.pubid
WHERE pub.pubid <= (SELECT MAX(pubid) FROM publications) / 2
GROUP BY au.name, pub.pub_type
HAVING COUNT(*) >= 25
ORDER BY pub_count DESC LIMIT 20;

-- === Q8 QUARTER ===
SELECT au.name, pub.pub_type, COUNT(*) AS pub_count
FROM authors au
JOIN authored aed     ON au.author_id = aed.author_id
JOIN publications pub ON aed.pubid = pub.pubid
WHERE pub.pubid <= (SELECT MAX(pubid) FROM publications) / 4
GROUP BY au.name, pub.pub_type
HAVING COUNT(*) >= 13
ORDER BY pub_count DESC LIMIT 20;

-- === Optimized Q8 FULL ===
-- optimized Q8 FULL
SELECT au.name, agg.pub_type, agg.pub_count
FROM (
    SELECT aed.author_id, pub.pub_type, COUNT(*) AS pub_count
    FROM authored aed
    JOIN publications pub ON aed.pubid = pub.pubid
    GROUP BY aed.author_id, pub.pub_type
    HAVING COUNT(*) >= 50
) agg
JOIN authors au ON agg.author_id = au.author_id
ORDER BY agg.pub_count DESC
LIMIT 20;

-- optimized Q8 HALF
SELECT au.name, agg.pub_type, agg.pub_count
FROM (
    SELECT aed.author_id, pub.pub_type, COUNT(*) AS pub_count
    FROM authored aed
    JOIN publications pub ON aed.pubid = pub.pubid
    WHERE pub.pubid <= (SELECT MAX(pubid) FROM publications) / 2
    GROUP BY aed.author_id, pub.pub_type
    HAVING COUNT(*) >= 25
) agg
JOIN authors au ON agg.author_id = au.author_id
ORDER BY agg.pub_count DESC
LIMIT 20;

-- optimized Q8 QUARTER
SELECT au.name, agg.pub_type, agg.pub_count
FROM (
    SELECT aed.author_id, pub.pub_type, COUNT(*) AS pub_count
    FROM authored aed
    JOIN publications pub ON aed.pubid = pub.pubid
    WHERE pub.pubid <= (SELECT MAX(pubid) FROM publications) / 4
    GROUP BY aed.author_id, pub.pub_type
    HAVING COUNT(*) >= 13
) agg
JOIN authors au ON agg.author_id = au.author_id
ORDER BY agg.pub_count DESC
LIMIT 20;