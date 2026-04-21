-- Index processing 1: Add Index for speed up the query
-- Table: publications
CREATE INDEX IF NOT EXISTS idx_pub_pubkey      ON publications(pubkey); --Q2
CREATE INDEX IF NOT EXISTS idx_pub_year      ON publications(year); --Q7-a
CREATE INDEX IF NOT EXISTS idx_pub_type       ON publications(pub_type); --Q8
    
-- Table: authored
CREATE INDEX IF NOT EXISTS idx_authored_pubid ON authored(pubid); --Q4,Q7-a, Q8
CREATE INDEX IF NOT EXISTS idx_authored_aid   ON authored(author_id); --Q4,Q7-a,Q8

-- Table: authors
CREATE INDEX IF NOT EXISTS idx_authors_name   ON authors(name); --Q7-a

-- Table: inproceedings
CREATE INDEX IF NOT EXISTS idx_inproc_booktitle ON inproceedings(booktitle); --Q4
CREATE INDEX IF NOT EXISTS idx_inproc_crossref ON inproceedings(crossref); --Q2

-- Table: articles
CREATE INDEX IF NOT EXISTS idx_articles_journal  ON articles(journal); --Q4

-- after run some queries for Q2, Q4, Q7-a, Q8, the result is not ideal, 
-- so drop all the index and try another way
DROP INDEX IF EXISTS idx_pub_pubkey;
DROP INDEX IF EXISTS idx_pub_year;
DROP INDEX IF EXISTS idx_pub_type;
DROP INDEX IF EXISTS idx_authored_pubid;
DROP INDEX IF EXISTS idx_authored_aid;
DROP INDEX IF EXISTS idx_authors_name;
DROP INDEX IF EXISTS idx_inproc_booktitle;
DROP INDEX IF EXISTS idx_inproc_crossref;
DROP INDEX IF EXISTS idx_articles_journal;

-- ============================================================
-- OPTIMIZED INDEXES_version FOR QUERY BENCHMARKS
-- ============================================================
-- Notes:
-- 1. publications(pubkey) already has a unique index through uq_publications_pubkey.
-- 2. authors(name) already has a unique index through uq_authors_name.
-- 3. authored(author_id, pubid) already has a primary-key index, so the missing
--    access path is the reverse order starting from pubid.

CREATE EXTENSION IF NOT EXISTS pg_trgm;
-- Reverse lookup for queries that start from publication IDs and then fetch authors.
CREATE INDEX IF NOT EXISTS idx_authored_pubid_author_id
    ON authored(pubid, author_id);

-- Range filters on year, plus joins that still need pubid afterwards.
CREATE INDEX IF NOT EXISTS idx_publications_year_pubid
    ON publications(year, pubid);

-- Combined filter used by Q3.
CREATE INDEX IF NOT EXISTS idx_publications_pub_type_year
    ON publications(pub_type, year);

-- Crossref join from inproceedings to proceedings/publications.
CREATE INDEX IF NOT EXISTS idx_inproceedings_crossref
    ON inproceedings(crossref);

-- Prefix search for author names in Q7a.
CREATE INDEX IF NOT EXISTS idx_authors_lower_name_pattern
    ON authors(lower(name) text_pattern_ops);

-- Trigram indexes for substring matching in Q4/Q5/Q6.
CREATE INDEX IF NOT EXISTS idx_publications_title_trgm
    ON publications USING GIN(title gin_trgm_ops);

CREATE INDEX IF NOT EXISTS idx_inproceedings_booktitle_trgm
    ON inproceedings USING GIN(booktitle gin_trgm_ops);

CREATE INDEX IF NOT EXISTS idx_articles_journal_trgm
    ON articles USING GIN(journal gin_trgm_ops);
