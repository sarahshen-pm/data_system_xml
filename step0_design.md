# SD6103 Data Systems Project — Design Document

> **Data Source**: DBLP Computer Science Bibliography (`dblp.xml`, ~5.1 GB)  
> **Database**: PostgreSQL  
> **Goal**: Load the full DBLP dataset into a relational schema, run 8 analytical queries, and benchmark the effect of index optimisation across different dataset scales.

---

## Project Overview

```
dblp.xml (raw)
    │
    ▼  Step 1: Parse (Python SAX)
CSV files (authors, publications, articles, ...)
    │
    ▼  Step 2: Import into PostgreSQL
Relational Tables
    │
    ▼  Step 3: 8 Analytical SQL Queries (benchmarked)
Query Results (Full / Half / Quarter dataset)
    │
    ▼  Step 4: Index Optimisation
Improved Index Strategy → Re-run queries for comparison
```

---

## Step 1 — XML Parsing: `step1_parse_data.py`

### Why SAX (not DOM)?

The DBLP XML file is **5.1 GB**, far too large to load into memory at once.  
A **SAX (Simple API for XML)** event-driven streaming parser reads the file node-by-node without buffering the entire tree, keeping memory usage nearly constant regardless of file size.

### Supported Publication Types

| Type | Description |
|---|---|
| `article` | Journal paper |
| `inproceedings` | Paper inside a conference |
| `proceedings` | A conference volume itself |
| `book` | A full book |
| `incollection` | A chapter inside a book |

### Output CSV Files

The parser produces **8 CSV files**, each mapping directly to a database table:

| File | Columns | Notes |
|---|---|---|
| `authors.csv` | `author_id`, `name` | Deduplicated by name; global unique ID assigned |
| `publications.csv` | `pubid`, `pubkey`, `title`, `year`, `type` | Master table for all publication types |
| `articles.csv` | `pubid`, `journal`, `volume`, `number`, `pages` | Journal papers |
| `inproceedings.csv` | `pubid`, `booktitle`, `pages`, `crossref` | Conference papers; `crossref` → `proceedings.pubkey` |
| `proceedings.csv` | `pubid`, `booktitle`, `publisher`, `isbn` | Conference volumes |
| `incollections.csv` | `pubid`, `booktitle`, `pages`, `crossref` | Book chapters |
| `books.csv` | `pubid`, `publisher`, `isbn` | Books |
| `authored.csv` | `author_id`, `pubid` | Many-to-many authorship relationship |

### Key Design Decisions

1. **Author deduplication**: An in-memory dict `name → author_id` is maintained during parsing. Each unique author name is assigned one ID; subsequent appearances reuse the existing ID.
2. **First-occurrence-only fields**: If a field (e.g. `title`) appears more than once inside a single publication element, only the first value is kept, preventing row duplication.
3. **Graceful year handling**: Invalid or missing year values are stored as `NULL` rather than raising an error.
4. **Progress reporting**: Every 100,000 publications parsed, the elapsed time is printed to stdout for monitoring long runs.
5. **DTD loading disabled**: External DTD resolution is suppressed (`feature_external_ges = False`) to avoid network requests and improve speed.

### Usage

```bash
python step1_parse_data.py \
  --input  ./dblp.xml \
  --output ./csv_output
```

### Expected Scale (Full Dataset)

| Metric | Approximate Count |
|---|---|
| Total publications | ~8,282,867 |
| Total authors | ~3,000,000+ |
| Authored relationships | ~28,566,872 |

---

## Step 2 — Database Setup: `step2_inputdata/`

Executed in order:

### `1_create_table.sql` — Create Tables (no FK yet)

Foreign keys are intentionally **omitted** at this stage. Adding FKs before data load would trigger constraint checks on every inserted row, dramatically slowing bulk import. Tables created:

- `authors(author_id PK, name)`
- `publications(pubid PK, pubkey, title, year, pub_type)`
- `articles(pubid PK → publications)`
- `inproceedings(pubid PK → publications)`
- `proceedings(pubid PK → publications)`
- `incollections(pubid PK → publications)`
- `books(pubid PK → publications)`
- `authored(author_id, pubid, PRIMARY KEY (author_id, pubid))`

### `2_load_csv.sql` — Bulk Load via COPY

PostgreSQL's `COPY` command is used for maximum throughput (far faster than `INSERT`).

**Special handling for `authored`**: The raw CSV may contain duplicate `(author_id, pubid)` pairs (same author listed twice for one paper in the XML). Direct `COPY` into the PK-constrained table would fail. The solution:

1. `COPY` into a staging table `authored_staging` (no PK constraint)
2. Deduplicate with `GROUP BY author_id, pubid` into `authored_clean`
3. `INSERT INTO authored SELECT ... FROM authored_clean`
4. Drop both staging tables

Settings applied before heavy operations:
```sql
SET statement_timeout = 0;   -- disable query timeout
SET work_mem = '256MB';      -- increase sort memory
```

### `3_add_constrains.sql` — Add Constraints Post-Load

After all data is loaded, constraints are applied:

- `UNIQUE` on `publications.pubkey`
- `UNIQUE` on `authors.name`
- `FOREIGN KEY` from all sub-type tables → `publications(pubid)`
- `FOREIGN KEY` from `authored.author_id` → `authors(author_id)`
- `FOREIGN KEY` from `authored.pubid` → `publications(pubid)`

### `4_add_index.sql` — Baseline Indexes

Initial indexes created to support the 8 queries:

| Index | Table & Column | Purpose |
|---|---|---|
| `idx_pub_year` | `publications(year)` | Year-range filters (Q1, Q3) |
| `idx_pub_type` | `publications(pub_type)` | Type filters (Q1, Q3) |
| `idx_pub_pubkey` | `publications(pubkey)` | Crossref joins (Q2) |
| `idx_authored_pubid` | `authored(pubid)` | Join from pub → authors |
| `idx_authored_aid` | `authored(author_id)` | Join from author → pubs |
| `idx_inproc_booktitle` | `inproceedings(booktitle)` | Venue name search (Q4) |
| `idx_proc_booktitle` | `proceedings(booktitle)` | Venue name search |
| `idx_articles_journal` | `articles(journal)` | Journal name search (Q4) |
| `idx_inproc_crossref` | `inproceedings(crossref)` | Crossref lookup (Q2) |

---

## Step 3 — Analytical Queries: `step3_queries/`

Each query is benchmarked at **3 data scales**:

| Scale | Subset Condition |
|---|---|
| **Full** | All records |
| **Half** | `pubid <= MAX(pubid) / 2` |
| **Quarter** | `pubid <= MAX(pubid) / 4` |

Each query is run **twice** per scale: once **without index**, once **with index**. This gives 6 timed measurements per query for comparison.

### Query Summary

| Query | Description | Key Tables | Complexity |
|---|---|---|---|
| **Q1** | Count each publication type in 2016–2025 | `publications` | Simple aggregation + year range filter |
| **Q2** | Conferences where a single year had > 1000 papers | `proceedings`, `publications`, `inproceedings` | 3-table join + `crossref` key lookup |
| **Q3** | Conference paper counts grouped by decade (1976–2025, every 10 years) | `publications` | CTE with `CASE` bucketing + type filter |
| **Q4** | Top 10 authors by distinct collaborator count in venues containing "data" | `inproceedings`, `articles`, `authored`, `authors` | CTE pipeline + self-join on `authored`; heavy with `ILIKE '%data%'` |
| **Q5** | Top 10 most prolific authors (2021–2025) publishing in "data" venues | `inproceedings`, `articles`, `publications`, `authored`, `authors` | Year + venue substring filter + author aggregation |
| **Q6** | Conferences held in June with > 200 papers that year | `proceedings`, `publications`, `inproceedings` | Title `ILIKE '%june%'` + crossref join + `HAVING` filter |
| **Q7a** | Authors whose last name starts with "H" who published every year from 1996 to 2025 (30 consecutive years) | `authors`, `authored`, `publications` | `HAVING COUNT(DISTINCT year) = 30`; requires prefix index |
| **Q7b** | Authors who published in the earliest recorded year, with their total pub count | `authors`, `authored`, `publications` | Correlated subquery to find `MIN(year)` |
| **Q8** | Authors with ≥ 50 publications in a single type (Top 20) — original and optimised versions | `authors`, `authored`, `publications` | Full 3-table join with `GROUP BY name, pub_type`; optimised version aggregates on `author_id` before joining names |

---

## Step 4 — Index Optimisation: `step4_index_improvement/index.sql`

After running the baseline queries, the initial indexes were evaluated as insufficient for certain queries (Q2, Q4, Q7a, Q8). The strategy was revised:

### Revised Index Strategy

| Index | Type | Purpose |
|---|---|---|
| `idx_authored_pubid_author_id` | B-Tree composite | Reverse lookup: pub → authors (avoids sort) |
| `idx_publications_year_pubid` | B-Tree composite | Year range filter + pubid join in one pass |
| `idx_publications_pub_type_year` | B-Tree composite | Combined type + year filter (Q3) |
| `idx_inproceedings_crossref` | B-Tree | Crossref join (Q2) |
| `idx_authors_lower_name_pattern` | B-Tree `text_pattern_ops` | Case-insensitive prefix search on author name (Q7a) |
| `idx_publications_title_trgm` | GIN trigram | Substring search on title (Q4, Q5, Q6) |
| `idx_inproceedings_booktitle_trgm` | GIN trigram | Substring search on booktitle (Q4) |
| `idx_articles_journal_trgm` | GIN trigram | Substring search on journal name (Q4) |

> **Note**: `pg_trgm` extension must be enabled before creating trigram indexes:  
> `CREATE EXTENSION IF NOT EXISTS pg_trgm;`

### Key Observations

- Standard B-Tree indexes do **not** accelerate `ILIKE '%keyword%'` patterns because the wildcard prefix prevents index use. Trigram (GIN) indexes solve this.
- `authors(name)` already has a unique index from the constraint in Step 2; a separate functional index on `lower(name)` with `text_pattern_ops` is needed for case-insensitive prefix queries.
- `authored(author_id, pubid)` already has a PK index in `(author_id, pubid)` order; the reverse `(pubid, author_id)` composite index is needed for queries that start from a pubid and fetch authors.

---

## File Structure

```
DS_project/
├── step0_design.md              ← This document
├── step1_parse_data.py          ← SAX XML parser → CSV
├── step2_inputdata/
│   ├── 1_create_table.sql       ← Create all tables (no FK)
│   ├── 2_load_csv.sql           ← COPY data in; handle authored deduplication
│   ├── 3_add_constrains.sql     ← Add FK and UNIQUE constraints
│   └── 4_add_index.sql          ← Baseline indexes
├── step3_queries/
│   ├── Q1_query.sql             ← Publication type counts (2016–2025)
│   ├── Q2_query.sql             ← High-volume conference years
│   ├── Q3_query.sql             ← Decade distribution of conference papers
│   ├── Q4_query.sql             ← Top collaborators in "data" venues
│   ├── Q5_query.sql
│   ├── Q6_query.sql
│   ├── Q7_query.sql
│   └── Q8_query.sql
├── step4_index_improvement/
│   └── index.sql                ← Optimised index strategy (trigram + composite)
├── csv_output/                  ← Generated CSVs (not committed to git)
├── dblp.xml                     ← Source data (not committed to git, 5.1 GB)
├── dblp.dtd                     ← XML schema definition
└── Project description.pdf
```

---

## Execution Order

```
1. python step1_parse_data.py          # Generate CSVs (~5–10 min)
2. psql -f step2_inputdata/1_create_table.sql
3. psql -f step2_inputdata/2_load_csv.sql      # Bulk load (~30–60 min)
4. psql -f step2_inputdata/3_add_constrains.sql
5. psql -f step2_inputdata/4_add_index.sql     # Baseline indexes
6. psql -f step3_queries/Q1_query.sql          # Benchmark each query
   psql -f step3_queries/Q2_query.sql
   ...
   psql -f step3_queries/Q8_query.sql
7. psql -f step4_index_improvement/index.sql   # Apply optimised indexes
8. Re-run step3 queries for comparison
```

---

## References

### Dataset

[1] Dataset download: https://dblp.org/xml/
[2] Python Software Foundation. *xml.sax — Support for SAX2 parsers*, Python 3 Documentation. Available: https://docs.python.org/3/library/xml.sax.html
[3] The PostgreSQL Global Development Group. *F.35 pg_trgm — support for similarity of text using trigram matching*, PostgreSQL 16 Documentation. Available: https://www.postgresql.org/docs/16/pgtrgm.html


