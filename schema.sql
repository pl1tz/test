DROP TABLE IF EXISTS m2m_books_genres;
DROP TABLE IF EXISTS genres;
DROP TABLE IF EXISTS books;
DROP TABLE IF EXISTS books1;

CREATE TABLE IF NOT EXISTS books (
    id SERIAL PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    "year" INTEGER NOT NULL,
    quantity INTEGER NOT NULL
);

-- Добавление B-tree индекса на столбец title в таблице books
CREATE INDEX idx_books_title ON books USING BTREE (title);

CREATE TABLE IF NOT EXISTS books1 (
    id SERIAL PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    "year" INTEGER NOT NULL,
    quantity INTEGER NOT NULL
);

-- Добавление хэш индекса на столбец title в таблице books1
CREATE INDEX idx_books1_title ON books1 USING HASH (title);

CREATE TABLE IF NOT EXISTS genres (
    id SERIAL PRIMARY KEY,
    "name" VARCHAR(255) NOT NULL UNIQUE,
    description VARCHAR(255)
);

CREATE TABLE IF NOT EXISTS m2m_books_genres (
    id SERIAL PRIMARY KEY,
    book_id INTEGER NOT NULL,
    genre_id INTEGER NOT NULL,
    FOREIGN KEY (book_id) REFERENCES books(id),
    FOREIGN KEY (genre_id) REFERENCES genres(id)
);