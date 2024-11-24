INSERT INTO books (title, "year", quantity)
SELECT 
  'Книга ' || i,
  (2000 + i) % 100 + 2000,
  (i % 100) + 1
FROM generate_series(1, 500000) AS i;

INSERT INTO genres ("name", description)
SELECT 
  'Жанр ' || i,
  'Описание жанра ' || i
FROM generate_series(1, 500000) AS i;

INSERT INTO m2m_books_genres (book_id, genre_id)
SELECT 
  (i % 400000) + 1,
  (i % 400000) + 1
FROM generate_series(1, 400000) AS i;
