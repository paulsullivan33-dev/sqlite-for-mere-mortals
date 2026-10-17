# Indexes and Speed

**Scope:** the most satisfying fix in databases — a
query that's slow because the engine reads everything,
and the index that teaches it where to look. Measured
for real on a 100,000-row table.

## The experiment

A table of sensor events, 100,000 rows, and one
innocent question — *how many events came from
sensor-42?*

```
sqlite> .timer on
sqlite> SELECT COUNT(*) FROM events WHERE device='sensor-42';
200
Run Time: real 0.020 user 0.006190 sys 0.001474
```

Correct answer, 20 milliseconds. Not bad — until the
table has ten million rows and the query runs every
second. Ask the engine *how* it answered:

```
sqlite> EXPLAIN QUERY PLAN SELECT * FROM events WHERE device='sensor-42';
QUERY PLAN
`--SCAN events
```

**`SCAN`** is the confession: it read every row and
checked each one. Now:

```sql
CREATE INDEX idx_events_device ON events(device);
```

```
QUERY PLAN
`--SEARCH events USING INDEX idx_events_device (device=?)

Run Time: real 0.000 user 0.000000 sys 0.000286
```

**`SEARCH`** — the engine walked the index straight to
the matching rows. Same answer (200), no measurable
time. At 100k rows that's a parlor trick; at real-world
sizes it's the difference between "the report runs" and
"the report is why the app hangs."

## What an index is

A sorted lookup structure the engine maintains beside
the table — the book's index, not its table of
contents. For each value of the indexed column(s), it
records which rows carry it. Lookups, joins on indexed
columns, and `ORDER BY` on them all get fast; the
table itself is untouched.

## The costs, honestly

- **Space**: the index is additional data. On the
  experiment's table it took the file from 3.6 MB to
  5.4 MB — one short text column's index cost about
  half the table's size again. Indexes on wide text
  cost more.
- **Write speed**: every INSERT/UPDATE must also
  update each index. Three indexes, three extra
  bookkeeping writes per insert. Index what you *query
  by*, not what you merely have.
- **One index, one order**: `idx_events_device` serves
  `device = ?` and `device > ?`; a query filtering on
  `code` still scans. Composite indexes
  (`ON events(device, code)`) serve queries filtering
  on both, in that order.

## The workflow to keep

1. Query feels slow → `EXPLAIN QUERY PLAN` it.
2. `SCAN <table>` on a big table + a `WHERE` on one
   column → `CREATE INDEX` on that column.
3. Re-run the plan: expect `SEARCH ... USING INDEX`.
4. Name indexes by table and column
   (`idx_events_device`) so `.schema` reads like
   documentation.

No other performance topic in SQLite gives this much
for this little. Start here before anywhere else.
