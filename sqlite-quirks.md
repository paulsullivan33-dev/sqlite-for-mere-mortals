# SQLite Quirks

**Scope:** the four ways SQLite differs from the
database you may be imagining — each one a small
surprise until you know it, a tool after.

## 1. Types are suggestions (mostly)

Declare a column `INTEGER`, then:

```sql
INSERT INTO books (author_id, title, year)
  VALUES (3, 'Odd Year', 'nineteen seventy nine');
SELECT year, typeof(year) FROM books WHERE title = 'Odd Year';
```

```
nineteen seventy nine|text
```

The text went in. SQLite uses **type affinity**: a
column *prefers* its declared type and converts what it
can ('1979' the string becomes 1979 the integer), but
stores what it can't convert as-is. Only a few rules
are iron (an `INTEGER PRIMARY KEY` really must be an
integer). The design trades strictness for flexibility
— SQLite's role as a file format rewards never refusing
data. Your side of the bargain: validate in the
application where it matters, and know `typeof()` when
a query behaves as if a number weren't one.
(`STRICT` tables exist — an opt-in mode that enforces
types properly — worth knowing about, rarely needed.)

## 2. NULL is not a value; it's an absence

Verified in the lab database (6 books, one unrated):

```
COUNT(*)      → 6
COUNT(rating) → 5        (NULLs aren't counted)
WHERE rating = NULL  → 0 rows, always
WHERE rating IS NULL → the unrated book
```

NULL means "unknown/missing," so *every* comparison
with it — even `NULL = NULL` — evaluates to "unknown,"
never true. The only tests are `IS NULL` / `IS NOT
NULL`. Aggregates politely skip NULLs (that's why the
average rating was over 5 books). Every database does
this, not just SQLite; SQLite is merely where most
mortals first get bitten.

## 3. There is no date type

Dates are stored as **TEXT** in ISO format
(`'2026-10-16'`), or as numbers (unix timestamps,
julianday). This works better than it sounds, because
ISO text sorts chronologically all by itself, and the
built-in functions do the arithmetic:

```sql
SELECT date('now');                                  -- today
SELECT date('now', '+30 days');                      -- a month out
SELECT julianday('2026-11-20') - julianday('2026-10-16');  -- 35.0 days between
```

The rule that makes it all cohere: **pick ISO text,
use it everywhere, never mix formats in one column.**
Half the "SQLite dates are broken" stories are really
"this column has three formats in it" stories.

## 4. LIKE's case, and other small print

- `LIKE` matches case-insensitively for ASCII
  (`'%butler%'` finds Butler); `=` does not.
  `GLOB` is the case-sensitive pattern matcher.
- Strings use **single quotes**; double quotes are for
  identifiers — a query "working" with double-quoted
  strings is SQLite being lenient about a mistake, and
  the leniency has conditions. Use single quotes and
  never learn the conditions.
- `TRUE`/`FALSE` are 1/0. Booleans are integers in a
  trench coat, and comparisons treat them so.
