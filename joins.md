# Joins

**Scope:** answering questions that live in two tables
— which is most real questions, and the reason data is
split into tables at all.

## Why two tables in the first place

The library *could* store the author's name on every
book row. Then Octavia Butler's name would exist twice
(or two hundred times), a typo would create a second
implicit author, and correcting her birth year would
mean hunting every row. Splitting — facts about authors
in `authors`, facts about books in `books`, connected
by `author_id` — means each fact lives once. The cost
of that tidiness is that questions span tables. Joins
are how you pay it, gladly.

## The inner join, read aloud

```sql
SELECT b.title, a.name, b.rating
FROM books b
JOIN authors a ON a.id = b.author_id
WHERE b.rating >= 4.4
ORDER BY b.rating DESC;
```

```
title                            name            rating
-------------------------------  --------------  ------
Kindred                          Octavia Butler  4.6
Parable of the Sower             Octavia Butler  4.5
Stories of Your Life and Others  Ted Chiang      4.4
```

Reading it: *for each book, find the author whose `id`
matches the book's `author_id`, and present columns
from both as if one table.* The `b`/`a` aliases are
just shorthand for the table names — needed when column
names collide (`both` tables have an `id`), welcome
everywhere else for brevity. `ON` is the matching rule;
joining without the right `ON` produces every pairing
(a *cross join*) — hundreds of nonsense rows from a
small library, millions from a real one. A join with
an absurd row count is a wrong `ON` until proven
otherwise.

## The left join: keeping the unmatched

An inner join drops rows with no match. `LEFT JOIN`
keeps the left table's rows and fills the right side
with NULLs:

```sql
SELECT a.name, COUNT(b.id) AS books
FROM authors a LEFT JOIN books b ON b.author_id = a.id
GROUP BY a.name;
```

An author with no books appears with a count of 0 —
that's the "who has none?" question (find silent
customers, empty forums, sensors that never reported).
Note `COUNT(b.id)`, not `COUNT(*)`: the joined row for
a bookless author is one row of NULLs, and `COUNT(*)` would
count it as a book it doesn't have. (And the flip
side, from the Keys chapter: a *book* whose author_id
points nowhere simply vanishes from inner joins — the
Ghost Book is invisible to exactly the queries you'd
run to notice it. `PRAGMA foreign_key_check;` is the
detector.)

## The working rules

- Join on the declared relationship (`id` ↔
  `author_id`); if you're joining on names or titles,
  the schema wants another look.
- Filter with `WHERE` as usual — it applies to the
  joined rows, from either table.
- Reach for `LEFT JOIN` the moment the question is
  "all of X, and their Y if any."
