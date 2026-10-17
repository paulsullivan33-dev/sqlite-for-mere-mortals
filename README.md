# SQLite for Mere Mortals

**SQLite** is a database that lives in a single file.
No server to install, no accounts, no ports: you open
`library.db` and you're talking SQL to your data. It's
also, quietly, the most deployed database on Earth —
inside every phone, every browser, most apps you've
ever used, and (if you run certain projects from a
certain guide author) a BBS simulator and a Usenet
catalog or two.

This guide assumes you can use a terminal and edit a
text file. No database experience is assumed; SQL is
taught as it's used.

## What this guide covers

- [**What SQLite is**](what-sqlite-is.md) — the file that
  is a database, and where it's already running in your
  life
- [**Your first database**](first-database.md) — the
  `sqlite3` shell, dot-commands, creating and filling
  tables
- [**Querying**](querying.md) — `SELECT` with manners:
  filters, sorting, limits, aggregates
- [**Keys and constraints**](keys-and-constraints.md) —
  primary keys, uniqueness, and the foreign-key trap
- [**Joins**](joins.md) — questions that need two tables
- [**Indexes and speed**](indexes-and-speed.md) — why a
  query was slow and the one-command fix, measured
- [**Changing data safely**](changing-data-safely.md) —
  updates, deletes, and transactions that let you undo
- [**SQLite quirks**](sqlite-quirks.md) — flexible types,
  NULL's strange logic, dates that are text
- [**JSON in SQLite**](json-in-sqlite.md) — documents in
  tables, queried properly
- [**Files, backups, and care**](files-backups-and-care.md) —
  `.backup`, `.dump`, WAL, and checking a database's health
- [**From code**](from-code.md) — the same database from
  Python, with safe parameters
- [**When not to use SQLite**](when-not-sqlite.md) — one
  writer, network filesystems, and honest limits
- [**Troubleshooting**](troubleshooting.md) — symptom →
  fix, with the real error messages
- [**Glossary**](glossary.md) — the terms, collected in
  one place

## What it doesn't cover

Running a multi-user database server (that's
SQLite's cousins' job), SQL beyond the practical
middle, and database *design* theory past the
working rules given here.

## How to use this guide

Every command was run for real against SQLite 3.45 —
including a 100,000-row table built to measure an index
(0.020s → 0.000s), a transaction rolled back mid-flight,
a backup restored, JSON documents queried, and a write
refused with `database is locked` while another
connection held the file. The
[`examples/`](examples/) build the same library
database the chapters use.
