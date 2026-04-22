-- UNIQUE
ALTER TABLE publications
ADD CONSTRAINT uq_publications_pubkey UNIQUE (pubkey);

ALTER TABLE authors
ADD CONSTRAINT uq_authors_name UNIQUE (name);

-- CHECK
ALTER TABLE publications
ADD CONSTRAINT chk_pub_type
CHECK (pub_type IN (
    'article',
    'inproceedings',
    'proceedings',
    'incollection',
    'book'
));

-- FK: subtype → publications
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

-- FK: crossref
ALTER TABLE inproceedings
ADD CONSTRAINT fk_inproc_crossref
FOREIGN KEY (crossref) REFERENCES publications(pubkey);

ALTER TABLE incollections
ADD CONSTRAINT fk_incoll_crossref
FOREIGN KEY (crossref) REFERENCES publications(pubkey);

-- FK: authored
ALTER TABLE authored
ADD CONSTRAINT fk_authored_author
FOREIGN KEY (author_id) REFERENCES authors(author_id);

ALTER TABLE authored
ADD CONSTRAINT fk_authored_pub
FOREIGN KEY (pubid) REFERENCES publications(pubid);