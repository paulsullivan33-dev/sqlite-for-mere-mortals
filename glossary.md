# Glossary

**Affinity** — a column's *preferred* type. SQLite
converts values toward it when it can and stores the
rest as-is: types as suggestions, not laws.

**Aggregate** — a function over a set of rows:
`COUNT`, `SUM`, `AVG`, `MIN`, `MAX`; paired with
`GROUP BY` for per-group summaries.

**busy_timeout** — how long a blocked writer waits
before failing with `database is locked`.

**Constraint** — a schema rule the engine enforces:
`NOT NULL`, `UNIQUE`, `PRIMARY KEY`, `CHECK`, foreign
keys (when the pragma is on).

**Dot-command** — a `sqlite3` shell order beginning
with `.` (`.tables`, `.schema`, `.dump`). Not SQL.

**Foreign key** — a column that references another
table's primary key. Declared with `REFERENCES`;
*enforced* only when `PRAGMA foreign_keys = ON`.

**Index** — a sorted lookup structure beside a table;
turns `SCAN` into `SEARCH`. Costs space and write time.

**Journal / WAL** — how SQLite keeps transactions
atomic: a rollback journal, or write-ahead logging that
also lets readers and a writer coexist.

**NULL** — the absence of a value. Never equal to
anything, including itself; test with `IS NULL`.

**Parameter (`?`)** — a placeholder in SQL whose value
is supplied separately by code — the safe way to put
data in queries, immune to injection.

**PRAGMA** — SQLite's settings/inspection statements:
`foreign_keys`, `journal_mode`, `integrity_check`.

**Primary key** — a row's unique, non-null identity;
in SQLite, `INTEGER PRIMARY KEY` doubles as the rowid.

**Query plan** — how the engine will execute a query;
`EXPLAIN QUERY PLAN` shows it (`SCAN` vs `SEARCH`).

**Rowid** — every table's hidden internal row number,
unless replaced by an `INTEGER PRIMARY KEY` alias.

**Transaction** — BEGIN…COMMIT/ROLLBACK: a group of
changes applied atomically, or not at all.
