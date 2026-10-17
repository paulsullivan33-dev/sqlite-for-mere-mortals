# Querying

**Scope:** `SELECT` in its working clothes — choosing
columns, filtering, sorting, and asking summary
questions with aggregates.

## The shape of a SELECT

```sql
SELECT title, rating FROM books
WHERE rating >= 4.4
ORDER BY rating DESC
LIMIT 3;
```

Read it as a pipeline: **from** this table, **keep**
rows matching the filter, **sort** them, **take** the
first few, and show these columns. `SELECT *` (all
columns) is for exploring; real queries name their
columns, for the same reason named INSERTs are better.

Filters you'll use constantly:

| Pattern | Meaning |
|---|---|
| `WHERE year = 1979` | equality (one `=`, not two) |
| `WHERE year BETWEEN 1968 AND 1979` | inclusive range |
| `WHERE title LIKE '%Darkness%'` | pattern: `%` = any run of characters |
| `WHERE author_id IN (1, 3)` | any of a set |
| `WHERE rating IS NULL` | the missing-value test (never `= NULL` — [Quirks](sqlite-quirks.md)) |
| `AND` / `OR` / `NOT` | combine; parentheses keep you honest |

One verified subtlety for your notebook: `LIKE` is
case-insensitive for ASCII by default — `'%kindred%'`
finds Kindred. (Case-insensitive *matching* is common;
assuming it for `=` comparisons is not — `=` is exact.)

## Aggregates: questions about sets

```sql
SELECT COUNT(*) FROM books;                  -- 6 (rows)
SELECT COUNT(rating) FROM books;             -- 5 (non-NULL ratings)
SELECT ROUND(AVG(rating), 2) FROM books;     -- 4.32
SELECT a.name, COUNT(*) AS books FROM books b
  JOIN authors a ON a.id = b.author_id GROUP BY a.name;
```

| Function | Answers |
|---|---|
| `COUNT(*)`, `COUNT(col)` | how many rows / non-NULL values |
| `SUM`, `AVG` | totals and means over a numeric column |
| `MIN`, `MAX` | the extremes |
| `GROUP BY col` | "run the aggregate once per group" |

`GROUP BY` is the one that changes how you think:
without it, aggregates summarize the whole table; with
it, you get one summary row per group — books per
author, posts per forum, readings per sensor. The
`AS` aliases name the output columns; `ROUND(x, 2)`
keeps averages presentable. Add `HAVING` when the
*group's summary* needs filtering (`HAVING COUNT(*) > 1`)
— WHERE filters rows before grouping, HAVING filters
groups after. That one sentence resolves the classic
confusion between them.
