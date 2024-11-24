CREATE TABLE IF NOT EXISTS books (
    id SERIAL PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    "year" INTEGER NOT NULL,
    quantity INTEGER NOT NULL
);

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
