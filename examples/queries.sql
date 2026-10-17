-- queries.sql: run with  sqlite3 -header -column library.db < queries.sql
-- Books rated 4.4 or better, best first:
SELECT b.title, a.name, b.rating
FROM books b JOIN authors a ON a.id = b.author_id
WHERE b.rating >= 4.4 ORDER BY b.rating DESC;

-- Books per author, with average rating:
SELECT a.name, COUNT(*) AS books, ROUND(AVG(b.rating), 2) AS avg_rating
FROM books b JOIN authors a ON a.id = b.author_id
GROUP BY a.name;
