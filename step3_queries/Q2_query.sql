-- Q2: 2. Find all the conferences that have ever published more than 1000 papers 
-- in one year. Note that one conference may be held every year (e.g., KDD runs 
-- many years, and each year the conference has a number of papers). 

-- === Q2 FULL ===
SELECT pr.booktitle AS conference, pub.year, COUNT(ip.pubid) AS paper_count
FROM proceedings pr
JOIN publications pub ON pr.pubid = pub.pubid
JOIN inproceedings ip ON ip.crossref = pub.pubkey
GROUP BY pr.booktitle, pub.year
HAVING COUNT(ip.pubid) > 1000
ORDER BY paper_count DESC;

-- === Q2 HALF ===
SELECT pr.booktitle AS conference, pub.year, COUNT(ip.pubid) AS paper_count
FROM proceedings pr
JOIN publications pub ON pr.pubid = pub.pubid
JOIN inproceedings ip ON ip.crossref = pub.pubkey
WHERE pr.pubid <= (SELECT MAX(pubid) FROM publications) / 2
GROUP BY pr.booktitle, pub.year
HAVING COUNT(ip.pubid) > 500
ORDER BY paper_count DESC;

-- === Q2 QUARTER ===
SELECT pr.booktitle AS conference, pub.year, COUNT(ip.pubid) AS paper_count
FROM proceedings pr
JOIN publications pub ON pr.pubid = pub.pubid
JOIN inproceedings ip ON ip.crossref = pub.pubkey
WHERE pr.pubid <= (SELECT MAX(pubid) FROM publications) / 4
GROUP BY pr.booktitle, pub.year
HAVING COUNT(ip.pubid) > 250
ORDER BY paper_count DESC;