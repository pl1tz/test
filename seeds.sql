INSERT INTO books (title, "year", quantity)
SELECT 
  'Книга ' || i,
  (2000 + i) % 100 + 2000,
  (i % 100) + 1
FROM generate_series(1, 2000000) AS i;

INSERT INTO genres ("name", description)
SELECT 
  'Жанр ' || i,
  'Описание жанра ' || i
FROM generate_series(1, 2000000) AS i;

INSERT INTO m2m_books_genres (book_id, genre_id)
SELECT 
  (i % 1000000) + 1,
  (i % 1000000) + 1
FROM generate_series(1, 1000000) AS i;
