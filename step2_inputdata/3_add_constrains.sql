-- STEP 3: ADD CONSTRAINTS (after data is loaded — much faster)

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
