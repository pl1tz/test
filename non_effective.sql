SELECT * FROM books WHERE title LIKE '%Potter%';
SELECT * FROM books WHERE title ~ 'Potter';
SELECT * FROM books WHERE id = 1 OR year = 2020;
SELECT * FROM books WHERE LOWER(title) = 'harry potter';
SELECT * FROM books WHERE year + 1 = 2021;
