\timing on
SELECT MAX(pubid) AS max_pubid FROM publications;

-- ============================================================
-- Q2: 某年发表超1000篇论文的会议
-- ============================================================

DROP INDEX IF EXISTS idx_pub_pubkey;
DROP INDEX IF EXISTS idx_inproc_crossref;

\echo '=== Q2 FULL NO_INDEX ==='
SELECT pr.booktitle AS conference, pub.year, COUNT(ip.pubid) AS paper_count
FROM proceedings pr
JOIN publications pub ON pr.pubid = pub.pubid
JOIN inproceedings ip ON ip.crossref = pub.pubkey
GROUP BY pr.booktitle, pub.year
HAVING COUNT(ip.pubid) > 1000
ORDER BY paper_count DESC;

\echo '=== Q2 HALF NO_INDEX ==='
SELECT pr.booktitle AS conference, pub.year, COUNT(ip.pubid) AS paper_count
FROM proceedings pr
JOIN publications pub ON pr.pubid = pub.pubid
JOIN inproceedings ip ON ip.crossref = pub.pubkey
WHERE pr.pubid <= (SELECT MAX(pubid) FROM publications) / 2
GROUP BY pr.booktitle, pub.year
HAVING COUNT(ip.pubid) > 500
ORDER BY paper_count DESC;

\echo '=== Q2 QUARTER NO_INDEX ==='
SELECT pr.booktitle AS conference, pub.year, COUNT(ip.pubid) AS paper_count
FROM proceedings pr
JOIN publications pub ON pr.pubid = pub.pubid
JOIN inproceedings ip ON ip.crossref = pub.pubkey
WHERE pr.pubid <= (SELECT MAX(pubid) FROM publications) / 4
GROUP BY pr.booktitle, pub.year
HAVING COUNT(ip.pubid) > 250
ORDER BY paper_count DESC;

CREATE INDEX IF NOT EXISTS idx_pub_pubkey      ON publications(pubkey);
CREATE INDEX IF NOT EXISTS idx_inproc_crossref ON inproceedings(crossref);

\echo '=== Q2 FULL WITH_INDEX ==='
SELECT pr.booktitle AS conference, pub.year, COUNT(ip.pubid) AS paper_count
FROM proceedings pr
JOIN publications pub ON pr.pubid = pub.pubid
JOIN inproceedings ip ON ip.crossref = pub.pubkey
GROUP BY pr.booktitle, pub.year
HAVING COUNT(ip.pubid) > 1000
ORDER BY paper_count DESC;

\echo '=== Q2 HALF WITH_INDEX ==='
SELECT pr.booktitle AS conference, pub.year, COUNT(ip.pubid) AS paper_count
FROM proceedings pr
JOIN publications pub ON pr.pubid = pub.pubid
JOIN inproceedings ip ON ip.crossref = pub.pubkey
WHERE pr.pubid <= (SELECT MAX(pubid) FROM publications) / 2
GROUP BY pr.booktitle, pub.year
HAVING COUNT(ip.pubid) > 500
ORDER BY paper_count DESC;

\echo '=== Q2 QUARTER WITH_INDEX ==='
SELECT pr.booktitle AS conference, pub.year, COUNT(ip.pubid) AS paper_count
FROM proceedings pr
JOIN publications pub ON pr.pubid = pub.pubid
JOIN inproceedings ip ON ip.crossref = pub.pubkey
WHERE pr.pubid <= (SELECT MAX(pubid) FROM publications) / 4
GROUP BY pr.booktitle, pub.year
HAVING COUNT(ip.pubid) > 250
ORDER BY paper_count DESC;
