# Files, Backups, and Care

**Scope:** living with a database that's a file —
copying it *correctly*, dumping it to SQL, write-ahead
logging, and the two health checks.

## The one rule of copying

A **closed** database is one file; copy it however you
like. A **live** database — an application running,
mid-write — cannot be safely `cp`'d: you can catch it
between the write of a page and the write of its index,
and own a tidy, corrupt snapshot. The correct tool is
built in:

```
sqlite3 library.db ".backup library-copy.db"
sqlite3 library-copy.db "PRAGMA integrity_check;"
```

```
ok
```

`.backup` uses SQLite's own online-backup machinery:
it produces a consistent copy *while* the source is in
use. And `PRAGMA integrity_check;` answering `ok` is
the verification — the Backups guide's rule applies
here too: an unverified backup is a hope, not a backup.

## .dump: the database as SQL text

```
sqlite3 library.db .dump > library.sql
sqlite3 restored.db < library.sql
```

`.dump` emits the whole database as the CREATE and
INSERT statements that would rebuild it (round trip
verified in the lab: restored.db answered its queries
identically). Text form is the right choice for:
version control of a schema, moving between SQLite
versions, human-eyeballing a small database, and
last-resort forensics. For pure backup of a big file,
`.backup`'s binary copy is faster and exact.

Related export: `.mode csv` + `.output file.csv` +
a SELECT gives spreadsheet-ready output with quoting
handled:

```
title,rating
Kindred,4.6
"Parable of the Sower",4.5
```

## WAL: the -wal file explained

Databases run in one of two journal modes. The classic
rollback journal writes a `-journal` file during a
transaction and deletes it after. **WAL** (write-ahead
log) keeps changes in a persistent `-wal` sidecar file
(readers consult it transparently) until a *checkpoint*
folds them into the main file:

```
sqlite> PRAGMA journal_mode=WAL;
wal
```

While a WAL database is open you'll see `name.db`,
`name.db-wal`, `name.db-shm` — **the database is all
three**. Copying just the `.db` from a live WAL
database silently abandons everything still in the
-wal: the modern form of the copying mistake above.
`.backup` remains the answer; a cleanly closed database
checkpoints and removes the sidecars itself.

Why WAL at all: readers no longer block the writer,
writers don't block readers — it softens the one-writer
rule from "everyone queues" to "writes queue, reads
flow." Most applications that serve concurrent use
should enable it (it's per-database, persistent once
set).

## Occasional care

- `VACUUM;` — rebuilds the file, returning space freed
  by deletions. Databases don't shrink on their own;
  a file that's mostly tombstones gets noticeably
  smaller and slightly faster.
- `PRAGMA integrity_check;` — the health check (above).
  Run it on any database that survived a crash, a
  power cut, or a filesystem you don't trust.
- The file is the unit of everything: put it on a
  filesystem you back up, with permissions like the
  data matters (it does) — the database has no users
  or passwords of its own; file access *is* the access
  control.
