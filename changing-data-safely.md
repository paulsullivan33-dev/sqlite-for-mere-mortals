# Changing Data Safely

**Scope:** UPDATE and DELETE — the statements that can
ruin a database in one line, and the transaction
mechanism that makes them safe to attempt.

## UPDATE and the WHERE that saves you

```sql
UPDATE books SET rating = 4.7 WHERE title = 'Kindred';
```

The `WHERE` is not decoration. `UPDATE books SET
rating = 4.7;` is perfectly legal and sets *every
book's* rating. Same shape for the shredder:

```sql
DELETE FROM books WHERE id = 6;
DELETE FROM books;            -- every row. Legal. Gone.
```

The professional habits cost nothing:

1. **SELECT it first.** Run the same WHERE as a
   `SELECT` and eyeball the rows about to be hit.
2. **Check the count.** The shell reports how many
   rows a change touched; a number you didn't expect
   is the alarm.
3. Work inside a transaction when the change is big or
   nervous-making (next section).

## Transactions: all-or-nothing, with an undo

Wrap related changes in `BEGIN ... COMMIT` and they
apply as one atomic unit. End with `ROLLBACK` instead
and it's as if they never happened — demonstrated live:

```sql
BEGIN;
UPDATE books SET rating = 1.0 WHERE title = 'Kindred';
SELECT rating FROM books WHERE title = 'Kindred';   -- 1.0 (inside)
ROLLBACK;
SELECT rating FROM books WHERE title = 'Kindred';   -- 4.6 (as if nothing happened)
```

Two things mortals trip on:

- **Inside the transaction, you see your own changes**
  (that 1.0 was real, for you). Other connections
  still see 4.6 until you COMMIT — that's the isolation
  doing its job.
- **A forgotten transaction is a lock.** An open write
  transaction holds the database; other writers wait,
  then fail with `database is locked` (the When Not To
  chapter shows it verbatim). `COMMIT` or `ROLLBACK` —
  always land the plane.

Programmers meet the same machinery in code
(`con.execute("BEGIN")`, or context managers that
commit on success and roll back on exception) — the
shell just makes it visible.

## The safety net beneath everything

Transactions protect a *session*. For everything else
— the typo'd DELETE that committed before you blinked
— the protection is a backup file made *before* the
change, which is the next chapter's subject and the
cheapest insurance in all of computing:

```
sqlite3 library.db ".backup library-before-surgery.db"
```
