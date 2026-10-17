-- schema.sql: the home-library database from the guide.
-- Build it with:  sqlite3 library.db < schema.sql
CREATE TABLE authors (
  id INTEGER PRIMARY KEY,
  name TEXT NOT NULL,
  born INTEGER
);
CREATE TABLE books (
  id INTEGER PRIMARY KEY,
  author_id INTEGER NOT NULL REFERENCES authors(id),
  title TEXT NOT NULL,
  year INTEGER,
  isbn TEXT UNIQUE,
  rating REAL
);
INSERT INTO authors VALUES
  (1, 'Octavia Butler', 1947),
  (2, 'Ursula K. Le Guin', 1929),
  (3, 'Ted Chiang', 1967);
INSERT INTO books (author_id, title, year, isbn, rating) VALUES
  (1, 'Kindred', 1979, '9780807083697', 4.6),
  (1, 'Parable of the Sower', 1993, '9780446675505', 4.5),
  (2, 'A Wizard of Earthsea', 1968, '9780547773742', 4.0),
  (2, 'The Left Hand of Darkness', 1969, '9780441478125', 4.1),
  (3, 'Stories of Your Life and Others', 2002, '9780765304193', 4.4),
  (3, 'Unrated Draft', NULL, NULL, NULL);
