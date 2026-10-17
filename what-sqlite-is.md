# What SQLite Is

**Scope:** the mental model — how a database can be a
file, and why that trade is right far more often than
people expect.

## A database with no server

Most databases (PostgreSQL, MySQL) are *programs*: a
server process owns the data, and your program connects
to it over a socket, authenticates, and asks politely.
SQLite inverts that. **SQLite is a library** — code
linked into your program (or into the `sqlite3` shell)
that reads and writes one ordinary file:

```
library.db      ← your entire database: tables, data, indexes
```

Copy the file, you've copied the database. Email the
file, you've shared the database. Delete the file...
you've deleted the database. This is not a toy
arrangement: SQLite is the most widely deployed
database engine in existence precisely because "the
data is a file" fits so many real jobs.

## Where it already lives in your life

- **Your phone and browser** keep messages, history,
  and app state in SQLite files.
- **Applications** that need structured local storage —
  photo managers, note apps, finance tools — embed it.
- **Your own projects, possibly**: the CompuServe
  simulator stores its mutable world (forums, file
  library entries, periodicals) in a `documents` table
  inside `compuserve.db`; a Usenet catalog tool keeps
  its whole index in one. Files you can back up with
  one `cp` — once you know the live-database caveat in
  the Files chapter.

## The honest shape of the trade

What the file buys you: zero administration, atomic
transactions (the real, ACID kind), real SQL, and
astonishing reliability — SQLite's test suite is
legendary. What it costs: **one writer at a time**
(many readers, but writes serialize), no network
protocol of its own, and size limits you'll likely
never see (databases into the terabytes exist; the
practical ceiling is usually the one-writer rule, hit
long before bytes run out).

The [When not to use SQLite](when-not-sqlite.md)
chapter draws that line in detail. The short version:
for one application, one machine, and data that's
*yours* — the overwhelming majority of mortal software
— the file wins.
