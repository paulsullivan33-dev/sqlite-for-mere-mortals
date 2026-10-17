# JSON in SQLite

**Scope:** storing documents as JSON text in a table —
and, crucially, querying *inside* them without hauling
everything into your program.

## The pattern

Some data doesn't sit naturally in fixed columns: a
message whose fields vary, a document whose shape
evolves. A common and legitimate design is a
**documents table**:

```sql
CREATE TABLE documents (id INTEGER PRIMARY KEY, doc TEXT);
INSERT INTO documents (doc) VALUES
 ('{"type":"forum_post","forum":"games","author":"paul","year":1988}'),
 ('{"type":"email","forum":null,"author":"kathy","year":1988}'),
 ('{"type":"forum_post","forum":"tech","author":"paul","year":1989}');
```

This is not a toy shape — a certain CompuServe
simulator keeps its forums' and library's mutable
content in exactly such a table (`compuserve.db`), one
JSON document per row, so the data can grow new fields
without schema surgery. The danger of the pattern is a
database you can only read by dumping it. SQLite's
JSON functions remove the danger.

## json_extract: reach inside

```sql
SELECT json_extract(doc, '$.author') AS author, COUNT(*)
FROM documents
WHERE json_extract(doc, '$.type') = 'forum_post'
GROUP BY author;
```

```
author  COUNT(*)
------  --------
paul    2
```

The `'$.author'` path is JSONPath-lite: `$` is the
document, `.key` descends. Values come back as SQL
values (text, numbers, NULL) and everything you know —
WHERE, GROUP BY, JOIN — works on them. Companions
worth meeting: `json_set(doc, '$.year', 1990)` edits a
field inside an UPDATE, `json_array_length` counts a
document's array, and `->` / `->>` are shorthand
operators for extraction in current versions.

## The judgment call

JSON-in-a-column is right when the shape genuinely
varies, and wrong when it's laziness wearing a costume:

- Fields you **filter, sort, or join on constantly**
  belong in real columns — they're faster, constrainable,
  and self-documenting. (In the simulator's documents,
  the row `id` and content type live outside the JSON
  for exactly this reason; hybrid is normal.)
- Fields that are **payload** — the content itself,
  settings blobs, imported records kept faithfully —
  are JSON's home turf.
- A middle path exists: **generated columns** can lift
  a JSON field into an indexable pseudo-column when a
  payload field becomes a frequent filter. Know the
  escape hatch exists; the SQLite docs cover it well.

Rule of thumb: columns for the questions you ask every
day, JSON for the document you carry.
