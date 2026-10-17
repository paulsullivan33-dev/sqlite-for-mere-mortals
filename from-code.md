# From Code

**Scope:** using the same database from a program —
Python's standard library, which ships SQLite built in
(`sqlite3` module, version-matched to the shell's
3.45.1 in the lab). The pattern transfers to every
language; only the spelling changes.

## The whole connection ritual

[`examples/library.py`](examples/library.py), run as
shipped against the guide's database:

```python
import sqlite3

con = sqlite3.connect("library.db")
for title, name, rating in con.execute(
    "SELECT b.title, a.name, b.rating FROM books b "
    "JOIN authors a ON a.id = b.author_id "
    "WHERE b.rating >= ? ORDER BY b.rating DESC",
    (4.4,),
):
    print(f"{rating:.1f}  {title} — {name}")
con.close()
```

```
4.6  Kindred — Octavia Butler
4.5  Parable of the Sower — Octavia Butler
4.4  Stories of Your Life and Others — Ted Chiang
```

`connect()` opens the file (creating it if absent —
same rule as the shell). `execute()` runs SQL and the
cursor iterates rows as tuples. There is no server
handshake because there is no server; the "connection"
is a file handle plus the engine, in-process.

## The ? — the most important character in this chapter

The rating arrives as a **parameter**: the SQL text
contains `?`, and the value travels separately in a
tuple. It is never pasted into the SQL string.

The alternative — f-string SQL — is the classic
catastrophe:

```python
# NEVER: string-built SQL
con.execute(f"SELECT * FROM books WHERE title = '{title}'")
```

A title with an apostrophe breaks the query. A title
*crafter* — `'; DROP TABLE books; --` — breaks the
database. This is SQL injection, still the cockroach of
data breaches, and the fix is not escaping or vigilance;
it's never building SQL out of strings. Parameters
make the dangerous thing structurally impossible: the
value is data, the statement is code, and they never
meet as text.

## Writing, and the transaction you already have

Writes from Python carry the shell's rules:

- Foreign keys: `con.execute("PRAGMA foreign_keys = ON")`
  after connecting — same per-connection default.
- Transactions: Python's module wraps writes in an
  implicit transaction; `con.commit()` lands them,
  `con.rollback()` discards. The idiom for real work is
  the context manager:

```python
with sqlite3.connect("library.db") as con:
    con.execute("INSERT INTO authors (name, born) VALUES (?, ?)",
                ("Samuel R. Delany", 1942))
# committed on clean exit; rolled back if an exception escaped
```

That `with` block is BEGIN/COMMIT/ROLLBACK wearing its
working clothes — the same all-or-nothing promise from
the Changing Data chapter, enforced by indentation.

## Shell vs. code, honestly

Explore, fix, and inspect in the shell — it's faster
than writing a program to ask a question. Build the
thing in code — with parameters, the pragma, and the
context manager — when the question becomes a feature.
The database doesn't care which door you used; that's
the quiet superpower of the file format.
