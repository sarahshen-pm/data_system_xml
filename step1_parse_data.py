"""
DBLP XML SAX Parser
turning dblp.xml into several CSV documents，for PostgreSQL import.

output document:
  - authors.csv         : (id, name)
  - publications.csv    : (pubid, pubkey, title, year, type)
  - articles.csv        : (pubid, journal, volume, number, pages)
  - inproceedings.csv   : (pubid, booktitle, pages, crossref)
  - proceedings.csv     : (pubid, booktitle, publisher, isbn)
  - incollections.csv   : (pubid, booktitle, pages, crossref)
  - authored.csv        : (author_id, pubid)

usage:
  python dblp_parser.py --input dblp.xml --output ./csv_output
"""

import xml.sax
import xml.sax.handler
import csv
import os
import argparse
import time

# ──────────────────────────────────────────────
# support pub types
# ──────────────────────────────────────────────
PUB_TYPES = {"article", "inproceedings", "proceedings", "book", "incollection"}

# pub types' subfields
FIELD_MAP = {
    "article":       ["title", "year", "journal", "volume", "number", "pages", "ee"],
    "inproceedings": ["title", "year", "booktitle", "pages", "crossref", "ee"],
    "proceedings":   ["title", "year", "booktitle", "publisher", "isbn", "ee"],
    "book":          ["title", "year", "publisher", "isbn", "ee"],
    "incollection":  ["title", "year", "booktitle", "pages", "crossref", "ee"],
}


# ──────────────────────────────────────────────
# SAX Handler
# ──────────────────────────────────────────────
class DBLPHandler(xml.sax.handler.ContentHandler):

    def __init__(self, writers, author_index):
        """
        writers      : dict, each CSV writer
        author_index : dict, used for author name deduplication and id assignment
        """
        super().__init__()
        self.writers = writers
        self.author_index = author_index  # name -> author_id

        # ── current parsing status ──
        self.cur_type = None        # current pub type
        self.cur_key  = None        # current pub key
        self.cur_field = None       # current field
        self.cur_chars = []         # current chars

        # current pub data
        self.cur_data = {}
        self.cur_authors = []       # current pub authors

        # global counter
        self.pub_id_counter = 0
        self.author_id_counter = len(author_index)  # continue existing id

        # progress tracking
        self.pub_count = 0
        self.start_time = time.time()

    # ── assign/find author id ──────────────
    def _get_author_id(self, name):
        if name not in self.author_index: 
            self.author_id_counter += 1
            self.author_index[name] = self.author_id_counter
            self.writers["authors"].writerow([self.author_id_counter, name])
        return self.author_index[name]

    # ── SAX callback: startElement ─────────────────────
    def startElement(self, name, attrs):
        if name in PUB_TYPES:
            # start a new publication record
            self.cur_type = name
            self.cur_key  = attrs.get("key", "")
            self.cur_data = {}
            self.cur_authors = []

        elif self.cur_type is not None:
            # start reading a sub-field within a publication
            wanted = FIELD_MAP.get(self.cur_type, [])
            if name in wanted or name == "author":
                self.cur_field = name
                self.cur_chars = []

    # ── SAX callback: text content ────────────────────
    def characters(self, content):
        if self.cur_field is not None:
            self.cur_chars.append(content)

    # ── SAX callback: end tag ────────────────────
    def endElement(self, name):
        # end of a sub-field
        if self.cur_field is not None and name == self.cur_field:
            value = "".join(self.cur_chars).strip()

            if name == "author":
                self.cur_authors.append(value)
            else:
                # 🔥 only keep the first occurrence (handle duplicate fields)
                if name not in self.cur_data:
                    self.cur_data[name] = value

            self.cur_field = None
            self.cur_chars = []

        # end of a publication record
        elif name == self.cur_type and self.cur_type is not None:
            self._flush_publication()
            self.cur_type = None

    # ── write publication to CSV ────────────────────
    def _flush_publication(self):
        self.pub_id_counter += 1
        pubid  = self.pub_id_counter
        pubkey = self.cur_key
        title  = self.cur_data.get("title", "")
        year_s = self.cur_data.get("year", "")

        # convert year to integer, invalid if empty
        try:
            year = int(year_s) if year_s else None
        except ValueError:
            year = None

        # write publications main table
        self.writers["publications"].writerow([
            pubid, pubkey, title, year, self.cur_type
        ])

        # write sub-type tables
        t = self.cur_type
        if t == "article":
            self.writers["articles"].writerow([
                pubid,
                self.cur_data.get("journal", ""),
                self.cur_data.get("volume", ""),
                self.cur_data.get("number", ""),
                self.cur_data.get("pages", ""),
            ])
        elif t == "inproceedings":
            self.writers["inproceedings"].writerow([
                pubid,
                self.cur_data.get("booktitle", ""),
                self.cur_data.get("pages", ""),
                self.cur_data.get("crossref", ""),
            ])
        elif t == "proceedings":
            self.writers["proceedings"].writerow([
                pubid,
                self.cur_data.get("booktitle", ""),
                self.cur_data.get("publisher", ""),
                self.cur_data.get("isbn", ""),
            ])
        elif t == "incollection":
            self.writers["incollections"].writerow([
                pubid,
                self.cur_data.get("booktitle", ""),
                self.cur_data.get("pages", ""),
                self.cur_data.get("crossref", ""),
            ])
        elif t == "book":
            self.writers["books"].writerow([
                pubid,
                self.cur_data.get("publisher", ""),
                self.cur_data.get("isbn", ""),
            ])

        # write authored table
        for author_name in self.cur_authors:
            if author_name:
                author_id = self._get_author_id(author_name)
                self.writers["authored"].writerow([author_id, pubid])

        # Output progress
        self.pub_count += 1
        if self.pub_count % 100_000 == 0:
            elapsed = time.time() - self.start_time
            print(f"  Processed {self.pub_count:,} publications, time: {elapsed:.1f}s")


# ──────────────────────────────────────────────
# main function
# ──────────────────────────────────────────────
def parse_dblp(input_path: str, output_dir: str):
    os.makedirs(output_dir, exist_ok=True)

    # define all output files and their headers
    file_defs = {
        "authors":       (["author_id", "name"],),
        "publications":  (["pubid", "pubkey", "title", "year", "type"],),
        "articles":      (["pubid", "journal", "volume", "number", "pages"],),
        "inproceedings": (["pubid", "booktitle", "pages", "crossref"],),
        "proceedings":   (["pubid", "booktitle", "publisher", "isbn"],),
        "incollections": (["pubid", "booktitle", "pages", "crossref"],),
        "books":         (["pubid", "publisher", "isbn"],),
        "authored":      (["author_id", "pubid"],),
    }

    file_handles = {}
    writers = {}

    try:
        for key, (header,) in file_defs.items():
            path = os.path.join(output_dir, f"{key}.csv")
            fh = open(path, "w", newline="", encoding="utf-8")
            file_handles[key] = fh
            writer = csv.writer(fh, quoting=csv.QUOTE_MINIMAL)
            writer.writerow(header)
            writers[key] = writer

        author_index = {}  # name -> id, global deduplication

        handler = DBLPHandler(writers, author_index)
        parser  = xml.sax.make_parser()
        parser.setContentHandler(handler)

        # close external DTD loading (speed up, avoid network requests)
        parser.setFeature(xml.sax.handler.feature_external_ges, False)
        parser.setFeature(xml.sax.handler.feature_external_pes, False)

        print(f"Start parsing: {input_path}")
        print(f"Output directory: {output_dir}")
        print("-" * 40)

        start = time.time()
        parser.parse(input_path)
        elapsed = time.time() - start

        print("-" * 40)
        print(f"✅ Parsing completed!")
        print(f"   Total publications: {handler.pub_count:,}")
        print(f"   Total authors: {handler.author_id_counter:,}")
        print(f"   Total time:   {elapsed:.1f}s")

    finally:
        for fh in file_handles.values():
            fh.close()

    # print the size of each file
    print("\nOutput files:")
    for key in file_defs:
        path = os.path.join(output_dir, f"{key}.csv")
        size = os.path.getsize(path) / (1024 * 1024)
        print(f"  {key}.csv  →  {size:.1f} MB")


# ──────────────────────────────────────────────
# entry point
# ──────────────────────────────────────────────
if __name__ == "__main__":
    ap = argparse.ArgumentParser(description="DBLP XML → CSV Parser")
    ap.add_argument("--input",  default="/Users/shen/Documents/NTU LECTURE/SD6103 Data System/DS_project/dblp.xml", help="dblp.xml path")
    ap.add_argument("--output", default="/Users/shen/Documents/NTU LECTURE/SD6103 Data System/DS_project/csv_output", help="CSV output directory")
    args = ap.parse_args()

    parse_dblp(args.input, args.output)

