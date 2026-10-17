# Keys and Constraints

**Scope:** the rules a schema enforces — identity,
uniqueness, required fields — and the foreign-key
behavior that surprises everyone the first time.

## PRIMARY KEY: a row's identity

`id INTEGER PRIMARY KEY` does three jobs: the column is
unique, never NULL, and — because SQLite uses it as the
table's internal rowid alias — lookups by it are the
fastest the engine offers. Leaving the value out of an
INSERT auto-assigns the next integer (the schema's
books rely on this: no `id` in the column list, ids
1–6 arrive on their own).

## UNIQUE and NOT NULL: rules with teeth

Verbatim, trying to shelve a second book with an
existing ISBN:

```
Error: stepping, UNIQUE constraint failed: books.isbn (19)
```

The insert is refused, the table unchanged, the error
names the exact column. That's the point of constraints:
the *database* enforces the rule for every writer,
including the script you write at 1 a.m. — instead of
every program having to remember to check. `NOT NULL`
fails the same way when a required field is left out.
Put rules in the schema wherever they're truly rules;
application-side checks are a second copy that drifts.

## FOREIGN KEY: the trap with the friendly name

`author_id REFERENCES authors(id)` *declares* that a
book's author must exist. But watch — with a fresh
connection, this succeeds:

```sql
INSERT INTO books (author_id, title) VALUES (99, 'Ghost Book');
-- author 99 does not exist. Row inserted anyway.
```

**SQLite does not enforce foreign keys unless each
connection asks:**

```sql
PRAGMA foreign_keys = ON;
```

Same insert, now:

```
Error: stepping, FOREIGN KEY constraint failed (19)
```

Why the default? History and compatibility — the
pragma exists per-connection, defaults off, and has
stayed that way for decades. The mortal rules:

1. Every application that writes must run
   `PRAGMA foreign_keys = ON` right after connecting.
2. Until you check a database's enforcement, assume
   orphaned rows may exist — and know the audit:
   `PRAGMA foreign_key_check;` lists every violation
   in the file, no enforcement needed to *detect* them.

The schema still earns its keep without enforcement
(it documents the relationships, and tools read it) —
but a REFERENCES clause is a promise SQLite only keeps
when asked.
