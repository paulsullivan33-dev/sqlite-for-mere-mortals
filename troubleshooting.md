# Troubleshooting

**Scope:** the errors you'll actually meet, symptom →
fix. Messages are verbatim from real runs (SQLite
3.45.1).

## "Error: in prepare, no such table: nope"

```
Error: in prepare, no such table: nope
```

**Symptom:** a query fails instantly.

**Fix:** the table doesn't exist *in this database*.
Three usual causes: you opened the wrong file (an
absent filename makes SQLite create a brand-new empty
one — the most common self-own in all of SQLite, since
"connecting" to a typo succeeds silently), the CREATE
never ran (or ran on another file), or a typo. `.tables`
lists what this file actually holds.

## "Error: stepping, UNIQUE constraint failed: books.isbn (19)"

**Symptom:** an INSERT is refused.

**Fix:** the value duplicates an existing row in a
UNIQUE column (or primary key). Find the incumbent:
`SELECT * FROM books WHERE isbn = '...';` — then decide
whether you're looking at a data-entry duplicate (fix
the input) or a wrongly-declared constraint (fix the
schema — which in SQLite means rebuilding the table:
create new, copy, drop, rename; the one genuinely
annoying schema operation).

## "Error: stepping, FOREIGN KEY constraint failed (19)"

**Symptom:** an insert/update/delete is refused on a
relationship.

**Fix:** with enforcement on, the referenced row must
exist (insert the author first), and a referenced row
can't be deleted while children point at it. The mirror
problem — orphans that already exist from unenforced
days — is found with `PRAGMA foreign_key_check;`.

## "Error: in prepare, database is locked (5)"

**Symptom:** writes fail, reads may still work.

**Fix:** another connection holds a write transaction.
Find it: an application running long, a forgotten
`BEGIN` in someone's shell session (check your *other*
terminal first), or a crashed process that left things
held (the lock clears when the process truly dies).
Set `PRAGMA busy_timeout = 5000;` in applications so
brief contention retries instead of erroring. And
COMMIT or ROLLBACK your own transactions — always land
the plane.

## "It returned nothing and that's wrong"

**Symptom:** a query that should match doesn't.

**Fix, the checklist of classics:**
- `= NULL` instead of `IS NULL` — never matches, ever.
- Text in a numeric column (affinity) comparing as a
  string; `typeof()` exposes it.
- A JOIN quietly hiding rows: inner joins drop
  unmatched rows — orphans (FK never enforced) vanish
  from joined queries. Try `LEFT JOIN` and compare
  counts.
- Dates in mixed formats in one TEXT column — sorting
  and ranges then follow string rules, not calendar
  rules.

## "The database file is huge but the tables aren't"

**Fix:** deleted rows free pages *inside* the file, not
the file itself. `VACUUM;` rebuilds it compactly.
Check first with `PRAGMA page_count;` vs
`PRAGMA freelist_count;` — the difference is the
reclaimable space.

## "database disk image is malformed"

**Fix:** the serious one — real corruption (bad
storage, a live `cp`, a network share). Restore from
the `.backup` copy you made (the Files chapter), after
running `PRAGMA integrity_check;` on both files to see
which one is whole. `.recover` exists as a salvage
tool for when no good copy exists; treat anything it
produces as evidence to re-enter, not a database to
trust. (Documented — the lab made backups and verified
them, but did not stage a corruption to recover from.)
