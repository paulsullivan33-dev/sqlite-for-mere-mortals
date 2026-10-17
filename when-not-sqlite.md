# When Not to Use SQLite

**Scope:** the honest boundaries — because a tool you
trust needs its limits stated by its friends.

## The one-writer rule, felt

SQLite allows any number of readers and **exactly one
writer at a time**. A write transaction locks the
database file briefly; a second writer waits its
`busy_timeout`, then fails. Reproduced for real in the
lab: one connection held an exclusive transaction open
while a second tried to insert:

```
Error: in prepare, database is locked (5)
```

For mortal workloads — a personal app, a tool, a small
site's backend — writes are milliseconds and the queue
is theoretical. The rule bites when:

- **Many processes write constantly** (a fleet of
  workers all logging to one file): writes serialize,
  `database is locked` becomes a lifestyle. → a server
  database (PostgreSQL) earns its keep here.
- **A human leaves a transaction open** in the shell
  and goes to lunch: everyone else's writes queue
  behind their sandwich. (WAL mode, from the Files
  chapter, keeps readers flowing meanwhile.)

## Network filesystems: just don't

The locking SQLite relies on is implemented by the
local OS. Over NFS/SMB shares, that locking is famously
unreliable — a database shared by mounting the folder
from two machines is corruption roulette, even with
light use. If two machines must share the data live,
the data belongs in a client-server database (or behind
a small service that owns the file). One machine, one
file, many processes *on that machine* — that's the
supported shape.

## Scale lines worth respecting

- **Size**: terabyte-scale SQLite databases exist and
  work. Your practical limit arrives earlier, in
  backup windows and vacuum times, not engine limits.
- **Write throughput**: one writer ≈ thousands of
  simple transactions/sec on decent storage. Logging
  firehoses and high-churn queues outgrow it.
- **Users/permissions**: SQLite has none — file access
  is the whole access model. An app where different
  users must see different rows *enforced by the
  database* needs a server database's accounts.

## The decision in one breath

One application (or one machine's worth of them), data
that's local, writes that are human-scale → SQLite,
and it's not a compromise, it's the right tool. Many
writers, many machines, or enforced multi-user security
→ PostgreSQL, without regret: the SQL you learned here
travels with you nearly unchanged, which is the real
reason learning on SQLite is never wasted.
