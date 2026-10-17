#!/usr/bin/env python3
"""library.py: query the guide's library.db from Python.
Usage: python3 library.py [min_rating]   (default 4.4)
Build the database first:  sqlite3 library.db < schema.sql
"""
import sqlite3
import sys

min_rating = float(sys.argv[1]) if len(sys.argv) > 1 else 4.4

con = sqlite3.connect("library.db")
# The ? is a parameter placeholder: the value is never spliced
# into the SQL text, so it can't break (or hijack) the query.
for title, name, rating in con.execute(
    "SELECT b.title, a.name, b.rating FROM books b "
    "JOIN authors a ON a.id = b.author_id "
    "WHERE b.rating >= ? ORDER BY b.rating DESC",
    (min_rating,),
):
    print(f"{rating:.1f}  {title} — {name}")
con.close()
