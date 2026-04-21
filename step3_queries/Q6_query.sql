\timing on
SELECT MAX(pubid) AS max_pubid FROM publications;

-- ============================================================
-- Q6: 曾在6月举办且当届超200篇的会议
-- ============================================================

DROP INDEX IF EXISTS idx_pub_pubkey;
DROP INDEX IF EXISTS idx_inproc_crossref;
DROP INDEX IF EXISTS idx_proc_title;

\echo '=== Q6 FULL NO_INDEX ==='
SELECT pr.booktitle AS conference, pub.year, COUNT(ip.pubid) AS paper_count
FROM proceedings pr
JOIN publications pub ON pr.pubid = pub.pubid
JOIN inproceedings ip ON ip.crossref = pub.pubkey
WHERE pub.title ILIKE '%june%' OR pub.title ILIKE '%jun %'
GROUP BY pr.booktitle, pub.year
HAVING COUNT(ip.pubid) > 200
ORDER BY paper_count DESC;

\echo '=== Q6 HALF NO_INDEX ==='
SELECT pr.booktitle AS conference, pub.year, COUNT(ip.pubid) AS paper_count
FROM proceedings pr
JOIN publications pub ON pr.pubid = pub.pubid
JOIN inproceedings ip ON ip.crossref = pub.pubkey
WHERE (pub.title ILIKE '%june%' OR pub.title ILIKE '%jun %')
  AND pr.pubid <= (SELECT MAX(pubid) FROM publications) / 2
GROUP BY pr.booktitle, pub.year
HAVING COUNT(ip.pubid) > 100
ORDER BY paper_count DESC;

\echo '=== Q6 QUARTER NO_INDEX ==='
SELECT pr.booktitle AS conference, pub.year, COUNT(ip.pubid) AS paper_count
FROM proceedings pr
JOIN publications pub ON pr.pubid = pub.pubid
JOIN inproceedings ip ON ip.crossref = pub.pubkey
WHERE (pub.title ILIKE '%june%' OR pub.title ILIKE '%jun %')
  AND pr.pubid <= (SELECT MAX(pubid) FROM publications) / 4
GROUP BY pr.booktitle, pub.year
HAVING COUNT(ip.pubid) > 50
ORDER BY paper_count DESC;

CREATE INDEX IF NOT EXISTS idx_pub_pubkey      ON publications(pubkey);
CREATE INDEX IF NOT EXISTS idx_inproc_crossref ON inproceedings(crossref);
CREATE INDEX IF NOT EXISTS idx_proc_title      ON publications(title);

\echo '=== Q6 FULL WITH_INDEX ==='
SELECT pr.booktitle AS conference, pub.year, COUNT(ip.pubid) AS paper_count
FROM proceedings pr
JOIN publications pub ON pr.pubid = pub.pubid
JOIN inproceedings ip ON ip.crossref = pub.pubkey
WHERE pub.title ILIKE '%june%' OR pub.title ILIKE '%jun %'
GROUP BY pr.booktitle, pub.year
HAVING COUNT(ip.pubid) > 200
ORDER BY paper_count DESC;

\echo '=== Q6 HALF WITH_INDEX ==='
SELECT pr.booktitle AS conference, pub.year, COUNT(ip.pubid) AS paper_count
FROM proceedings pr
JOIN publications pub ON pr.pubid = pub.pubid
JOIN inproceedings ip ON ip.crossref = pub.pubkey
WHERE (pub.title ILIKE '%june%' OR pub.title ILIKE '%jun %')
  AND pr.pubid <= (SELECT MAX(pubid) FROM publications) / 2
GROUP BY pr.booktitle, pub.year
HAVING COUNT(ip.pubid) > 100
ORDER BY paper_count DESC;

\echo '=== Q6 QUARTER WITH_INDEX ==='
SELECT pr.booktitle AS conference, pub.year, COUNT(ip.pubid) AS paper_count
FROM proceedings pr
JOIN publications pub ON pr.pubid = pub.pubid
JOIN inproceedings ip ON ip.crossref = pub.pubkey
WHERE (pub.title ILIKE '%june%' OR pub.title ILIKE '%jun %')
  AND pr.pubid <= (SELECT MAX(pubid) FROM publications) / 4
GROUP BY pr.booktitle, pub.year
HAVING COUNT(ip.pubid) > 50
ORDER BY paper_count DESC;
