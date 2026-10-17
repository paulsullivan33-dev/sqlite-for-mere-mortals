# Your First Database

**Scope:** the `sqlite3` command-line shell end to end —
creating the guide's library, looking around, and the
dot-commands that aren't SQL.

## Opening (and creating) a database

```
sqlite3 library.db
```

If the file doesn't exist, SQLite creates it — empty,
zero bytes, until you define something. You're in the
shell; the prompt is `sqlite>`. Two vocabularies live
here, and knowing which is which prevents most beginner
confusion:

- **SQL** — statements ending in `;`: `SELECT`, `CREATE
  TABLE`, `INSERT`...
- **Dot-commands** — shell orders starting with `.`,
  no semicolon: `.tables`, `.schema`, `.quit`.

## The schema: two tables

[`examples/schema.sql`](examples/schema.sql) defines
and seeds the whole example; run any SQL file like so:

```
sqlite3 library.db < schema.sql
```

The shape, by hand, is:

```sql
CREATE TABLE authors (
  id INTEGER PRIMARY KEY,
  name TEXT NOT NULL,
  born INTEGER
);
CREATE TABLE books (
  id INTEGER PRIMARY KEY,
  author_id INTEGER NOT NULL REFERENCES authors(id),
  title TEXT NOT NULL,
  year INTEGER,
  isbn TEXT UNIQUE,
  rating REAL
);
```

A `CREATE TABLE` names the **columns** and their
**types** (more flexible than they look — the
[Quirks](sqlite-quirks.md) chapter), plus rules:
`PRIMARY KEY` (the row's identity), `NOT NULL` (no
empty), `UNIQUE` (no duplicates), `REFERENCES` (this
column points at another table's row — the
[Keys](keys-and-constraints.md) chapter).

Adding rows:

```sql
INSERT INTO authors VALUES (1, 'Octavia Butler', 1947);
INSERT INTO books (author_id, title, year, isbn, rating)
  VALUES (1, 'Kindred', 1979, '9780807083697', 4.6);
```

Naming the columns (second example) is the habit to
keep: the statement survives schema changes and reads
like what it means.

## Looking around

```
sqlite> .tables
authors  books
sqlite> .schema books
CREATE TABLE books (
  id INTEGER PRIMARY KEY,
  author_id INTEGER NOT NULL REFERENCES authors(id),
  ...
);
```

`.schema` is the memory aid — the exact `CREATE` that
built the table, whenever you've forgotten your own
design. And the first query worth making readable:

```
sqlite> .headers on
sqlite> .mode column
sqlite> SELECT * FROM books LIMIT 2;
id  author_id  title                year  isbn           rating
--  ---------  -------------------  ----  -------------  ------
1   1          Kindred              1979  9780807083697  4.6
2   1          Parable of the Sower 1993  9780446675505  4.5
```

Default output is pipe-separated lists — fine for
scripts (and see `.mode csv` in the Files chapter for
exports). For human eyes, `column` + `headers` is the
pair to type on entry. `.mode box` and `.mode markdown`
exist for showing off; no judgement.

One more habit: `.timer on` makes the shell report each
statement's runtime. The Indexes chapter lives by it.
