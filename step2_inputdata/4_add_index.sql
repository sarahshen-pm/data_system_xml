
-- ============================================================
-- STEP 4: ADD CONSTRAINTS (after data is loaded — much faster)
-- ============================================================

-- Unique constraint on pubkey
ALTER TABLE publications
    ADD CONSTRAINT uq_publications_pubkey UNIQUE (pubkey);

-- Unique constraint on author name
ALTER TABLE authors
    ADD CONSTRAINT uq_authors_name UNIQUE (name);

-- Foreign keys: sub-type tables → publications
ALTER TABLE articles
    ADD CONSTRAINT fk_articles_pubid
    FOREIGN KEY (pubid) REFERENCES publications(pubid);

ALTER TABLE inproceedings
    ADD CONSTRAINT fk_inproceedings_pubid
    FOREIGN KEY (pubid) REFERENCES publications(pubid);

ALTER TABLE proceedings
    ADD CONSTRAINT fk_proceedings_pubid
    FOREIGN KEY (pubid) REFERENCES publications(pubid);

ALTER TABLE incollections
    ADD CONSTRAINT fk_incollections_pubid
    FOREIGN KEY (pubid) REFERENCES publications(pubid);

ALTER TABLE books
    ADD CONSTRAINT fk_books_pubid
    FOREIGN KEY (pubid) REFERENCES publications(pubid);

-- Foreign keys: authored → authors and publications
ALTER TABLE authored
    ADD CONSTRAINT fk_authored_author
    FOREIGN KEY (author_id) REFERENCES authors(author_id);

ALTER TABLE authored
    ADD CONSTRAINT fk_authored_pub
    FOREIGN KEY (pubid) REFERENCES publications(pubid);


-- ============================================================
-- STEP 5: CREATE INDEXES (speed up queries)
-- ============================================================

-- Speed up year-based filters (Q1, Q3, Q5)
CREATE INDEX idx_pub_year       ON publications(year);

-- Speed up type-based filters (Q1)
CREATE INDEX idx_pub_type       ON publications(pub_type);

-- Speed up joining authored → publications
CREATE INDEX idx_authored_pubid ON authored(pubid);

-- Speed up joining authored → authors
CREATE INDEX idx_authored_aid   ON authored(author_id);

-- Speed up conference/journal name searches with LIKE (Q2, Q4, Q5, Q6)
CREATE INDEX idx_inproc_booktitle   ON inproceedings(booktitle);
CREATE INDEX idx_proc_booktitle     ON proceedings(booktitle);
CREATE INDEX idx_articles_journal   ON articles(journal);

-- Speed up crossref lookups (joining inproceedings ↔ proceedings)
CREATE INDEX idx_inproc_crossref    ON inproceedings(crossref);

-- Speed up pubkey lookups (used in crossref joins)
CREATE INDEX idx_pub_pubkey         ON publications(pubkey);
