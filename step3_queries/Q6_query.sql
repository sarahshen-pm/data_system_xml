-- 6. List the name of the conferences such that it has ever been held in June, 
-- and the corresponding proceedings (in the year where the conference was held 
-- in June) contain more than 200 publications.

-- === Q6 FULL ===
SELECT pr.booktitle AS conference, pub.year, COUNT(ip.pubid) AS paper_count
FROM proceedings pr
JOIN publications pub ON pr.pubid = pub.pubid
JOIN inproceedings ip ON ip.crossref = pub.pubkey
WHERE pub.title ILIKE '%june%' OR pub.title ILIKE '%jun %'
GROUP BY pr.booktitle, pub.year
HAVING COUNT(ip.pubid) > 200
ORDER BY paper_count DESC;

-- === Q6 HALF ===
SELECT pr.booktitle AS conference, pub.year, COUNT(ip.pubid) AS paper_count
FROM proceedings pr
JOIN publications pub ON pr.pubid = pub.pubid
JOIN inproceedings ip ON ip.crossref = pub.pubkey
WHERE (pub.title ILIKE '%june%' OR pub.title ILIKE '%jun %')
  AND pr.pubid <= (SELECT MAX(pubid) FROM publications) / 2
GROUP BY pr.booktitle, pub.year
HAVING COUNT(ip.pubid) > 100
ORDER BY paper_count DESC;

-- === Q6 QUARTER ===
SELECT pr.booktitle AS conference, pub.year, COUNT(ip.pubid) AS paper_count
FROM proceedings pr
JOIN publications pub ON pr.pubid = pub.pubid
JOIN inproceedings ip ON ip.crossref = pub.pubkey
WHERE (pub.title ILIKE '%june%' OR pub.title ILIKE '%jun %')
  AND pr.pubid <= (SELECT MAX(pubid) FROM publications) / 4
GROUP BY pr.booktitle, pub.year
HAVING COUNT(ip.pubid) > 50
ORDER BY paper_count DESC;