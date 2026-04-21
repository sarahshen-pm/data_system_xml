-- STEP 1: DROP existing tables (safe re-run) & CREATE TABLES (no foreign keys yet — faster bulk load)
-- Authored: many-to-many between authors and publications
DROP TABLE IF EXISTS authored CASCADE;
CREATE TABLE authored (
    author_id   INTEGER         NOT NULL,
    pubid       INTEGER         NOT NULL,
    PRIMARY KEY (author_id, pubid)
);

-- Article: journal papers
DROP TABLE IF EXISTS articles CASCADE;
CREATE TABLE articles (
    pubid       INTEGER         PRIMARY KEY,
    journal     TEXT,
    volume      TEXT,
    number      TEXT,
    pages       TEXT
);

-- Inproceedings: papers inside a conference
DROP TABLE IF EXISTS inproceedings CASCADE;
CREATE TABLE inproceedings (
    pubid       INTEGER         PRIMARY KEY,
    booktitle   TEXT,
    pages       TEXT,
    crossref    TEXT            -- references proceedings.pubkey
);

-- Proceedings: a conference volume itself
DROP TABLE IF EXISTS proceedings CASCADE;
CREATE TABLE proceedings (
    pubid       INTEGER         PRIMARY KEY,
    booktitle   TEXT,
    publisher   TEXT,
    isbn        TEXT
);

-- Incollections: chapters inside a book
DROP TABLE IF EXISTS incollections CASCADE;
CREATE TABLE incollections (
    pubid       INTEGER         PRIMARY KEY,
    booktitle   TEXT,
    pages       TEXT,
    crossref    TEXT
);

-- Books
DROP TABLE IF EXISTS books CASCADE;
CREATE TABLE books (
    pubid       INTEGER         PRIMARY KEY,
    publisher   TEXT,
    isbn        TEXT
);


-- Publications main table (parent of all sub-types)
DROP TABLE IF EXISTS publications CASCADE;
CREATE TABLE publications (
    pubid       INTEGER         PRIMARY KEY,
    pubkey      TEXT            NOT NULL,       -- e.g. "conf/kdd/2017"
    title       TEXT,
    year        INTEGER,
    pub_type    VARCHAR(20)     NOT NULL        -- 'article','inproceedings', etc.
);

-- Authors table
DROP TABLE IF EXISTS authors CASCADE;
CREATE TABLE authors (
    author_id   INTEGER         PRIMARY KEY,
    name        TEXT            NOT NULL
);
















