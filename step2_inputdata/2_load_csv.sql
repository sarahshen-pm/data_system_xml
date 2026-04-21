-- ============================================================
-- STEP 3: LOAD DATA FROM CSV
-- (Update the file paths to match your actual csv_output folder)
-- ============================================================

-- Load authors (1 time input done)
copy authors (author_id, name)
FROM '/Users/shen/Documents/NTU LECTURE/SD6103 Data System/DS_project/csv_output/authors.csv' 
DELIMITER ',' 
CSV HEADER;

-- Load publications（canceling statement due to statement timeout）⭐️
copy publications (pubid, pubkey, title, year, pub_type)
FROM '/Users/shen/Documents/NTU LECTURE/SD6103 Data System/DS_project/csv_output/publications.csv' 
DELIMITER ',' 
CSV HEADER;

SELECT COUNT(*) FROM publications; -- 8282867

-- Load articles（1 time input done）
copy articles (pubid, journal, volume, number, pages)
FROM '/Users/shen/Documents/NTU LECTURE/SD6103 Data System/DS_project/csv_output/articles.csv' 
DELIMITER ',' 
CSV HEADER;

-- Load inproceedings（1 time input done）
copy inproceedings (pubid, booktitle, pages, crossref)
FROM '/Users/shen/Documents/NTU LECTURE/SD6103 Data System/DS_project/csv_output/inproceedings.csv' 
DELIMITER ',' 
CSV HEADER;

-- Load proceedings（1 time input done）
copy proceedings (pubid, booktitle, publisher, isbn)
FROM '/Users/shen/Documents/NTU LECTURE/SD6103 Data System/DS_project/csv_output/proceedings.csv' 
DELIMITER ',' 
CSV HEADER;

-- Load incollections（1 time input done）
copy incollections (pubid, booktitle, pages, crossref)
FROM '/Users/shen/Documents/NTU LECTURE/SD6103 Data System/DS_project/csv_output/incollections.csv' 
DELIMITER ',' 
CSV HEADER;

-- Load books（1time input done）
copy books (pubid, publisher, isbn)
FROM '/Users/shen/Documents/NTU LECTURE/SD6103 Data System/DS_project/csv_output/books.csv' 
DELIMITER ',' 
CSV HEADER;

-- Load authored (many-to-many)，cuase authored table has double PK, directly input tips:duplicate key value violates unique constraint "authored_pkey"
--copy authored (author_id, pubid)
-- FROM '/Users/shen/Documents/NTU LECTURE/SD6103 Data System/DS_project/csv_output/authored.csv' 
-- DELIMITER ',' 
-- CSV HEADER;
DROP TABLE IF EXISTS authored_staging CASCADE;
CREATE TABLE authored_staging (
    author_id   INTEGER         NOT NULL,
    pubid       INTEGER         NOT NULL
);

COPY authored_staging FROM '/Users/shen/Documents/NTU LECTURE/SD6103 Data System/DS_project/csv_output/authored.csv' 
DELIMITER ',' 
CSV HEADER; -- 
SELECT COUNT(*) FROM authored_staging; -- 28567156

SET statement_timeout = 0; -- cancel timeout, default always canceling queries
SET work_mem = '256MB'; -- increase memory for sorting

CREATE TABLE authored_clean AS
SELECT author_id, pubid
FROM authored_staging
GROUP BY author_id, pubid;
SELECT COUNT(*) FROM authored_clean; --28566872

SET statement_timeout = 0; -- cancel timeout, default always canceling queries
SET work_mem = '256MB'; 
INSERT INTO authored (author_id, pubid)
SELECT author_id, pubid
FROM authored_clean; -- canceling statement due to statement timeout
SELECT COUNT(*) FROM authored; --28566872

DROP TABLE authored_staging;
DROP TABLE authored_clean;

-- CREATE TABLE authored_clean AS
-- SELECT DISTINCT author_id, pubid
-- FROM authored_staging;

-- INSERT INTO authored SELECT * FROM authored_staging ON CONFLICT (author_id, pubid) DO NOTHING; -- canceling statement due to statement timeout



