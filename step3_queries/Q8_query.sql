\timing on
SELECT MAX(pubid) AS max_pubid FROM publications;

-- ============================================================
-- Q8: 每位作者在每种文献类型的发表数（自定义JOIN查询）
-- ============================================================

DROP INDEX IF EXISTS idx_authored_pubid;
DROP INDEX IF EXISTS idx_authored_aid;
DROP INDEX IF EXISTS idx_pub_type;

\echo '=== Q8 FULL NO_INDEX ==='
SELECT au.name, pub.pub_type, COUNT(*) AS pub_count
FROM authors au
JOIN authored aed     ON au.author_id = aed.author_id
JOIN publications pub ON aed.pubid = pub.pubid
GROUP BY au.name, pub.pub_type
HAVING COUNT(*) >= 50
ORDER BY pub_count DESC LIMIT 20;

\echo '=== Q8 HALF NO_INDEX ==='
SELECT au.name, pub.pub_type, COUNT(*) AS pub_count
FROM authors au
JOIN authored aed     ON au.author_id = aed.author_id
JOIN publications pub ON aed.pubid = pub.pubid
WHERE pub.pubid <= (SELECT MAX(pubid) FROM publications) / 2
GROUP BY au.name, pub.pub_type
HAVING COUNT(*) >= 25
ORDER BY pub_count DESC LIMIT 20;

\echo '=== Q8 QUARTER NO_INDEX ==='
SELECT au.name, pub.pub_type, COUNT(*) AS pub_count
FROM authors au
JOIN authored aed     ON au.author_id = aed.author_id
JOIN publications pub ON aed.pubid = pub.pubid
WHERE pub.pubid <= (SELECT MAX(pubid) FROM publications) / 4
GROUP BY au.name, pub.pub_type
HAVING COUNT(*) >= 13
ORDER BY pub_count DESC LIMIT 20;

CREATE INDEX IF NOT EXISTS idx_authored_pubid ON authored(pubid);
CREATE INDEX IF NOT EXISTS idx_authored_aid   ON authored(author_id);
CREATE INDEX IF NOT EXISTS idx_pub_type       ON publications(pub_type);

\echo '=== Q8 FULL WITH_INDEX ==='
SELECT au.name, pub.pub_type, COUNT(*) AS pub_count
FROM authors au
JOIN authored aed     ON au.author_id = aed.author_id
JOIN publications pub ON aed.pubid = pub.pubid
GROUP BY au.name, pub.pub_type
HAVING COUNT(*) >= 50
ORDER BY pub_count DESC LIMIT 20;

\echo '=== Q8 HALF WITH_INDEX ==='
SELECT au.name, pub.pub_type, COUNT(*) AS pub_count
FROM authors au
JOIN authored aed     ON au.author_id = aed.author_id
JOIN publications pub ON aed.pubid = pub.pubid
WHERE pub.pubid <= (SELECT MAX(pubid) FROM publications) / 2
GROUP BY au.name, pub.pub_type
HAVING COUNT(*) >= 25
ORDER BY pub_count DESC LIMIT 20;

\echo '=== Q8 QUARTER WITH_INDEX ==='
SELECT au.name, pub.pub_type, COUNT(*) AS pub_count
FROM authors au
JOIN authored aed     ON au.author_id = aed.author_id
JOIN publications pub ON aed.pubid = pub.pubid
WHERE pub.pubid <= (SELECT MAX(pubid) FROM publications) / 4
GROUP BY au.name, pub.pub_type
HAVING COUNT(*) >= 13
ORDER BY pub_count DESC LIMIT 20;
