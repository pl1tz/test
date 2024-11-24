with join

--CREATE INDEX idx_m2m_book_id ON m2m_books_genres(book_id);
--CREATE INDEX idx_m2m_genre_id ON m2m_books_genres(genre_id);

explain analyse SELECT * from books 
  join m2m_books_genres
  on books.id = m2m_books_genres.book_id
  join genres
  on m2m_books_genres.genre_id = genres.id;


without index 
  
  QUERY PLAN
  Gather  (cost=68016.78..222825.23 rows=1000000 width=97) (actual time=880.099..1382.624 rows=1000000 loops=1)
    Workers Planned: 2
    Workers Launched: 2
    ->  Parallel Hash Join  (cost=67016.78..121825.23 rows=416667 width=97) (actual time=870.444..1145.264 rows=333333 loops=3)
          Hash Cond: (genres.id = m2m_books_genres.genre_id)
          ->  Parallel Seq Scan on genres  (cost=0.00..30006.33 rows=833333 width=55) (actual time=0.032..70.263 rows=666667 loops=3)
          ->  Parallel Hash  (cost=58145.45..58145.45 rows=416667 width=42) (actual time=657.264..657.868 rows=333333 loops=3)
                Buckets: 131072  Batches: 16  Memory Usage: 5952kB
                ->  Parallel Hash Join  (cost=16816.00..58145.45 rows=416667 width=42) (actual time=252.053..537.013 rows=333333 loops=3)
                      Hash Cond: (books.id = m2m_books_genres.book_id)
                      ->  Parallel Seq Scan on books  (cost=0.00..23039.33 rows=833333 width=30) (actual time=0.027..48.865 rows=666667 loops=3)
                      ->  Parallel Hash  (cost=9572.67..9572.67 rows=416667 width=12) (actual time=83.862..83.863 rows=333333 loops=3)
                            Buckets: 262144  Batches: 8  Memory Usage: 7936kB
                            ->  Parallel Seq Scan on m2m_books_genres  (cost=0.00..9572.67 rows=416667 width=12) (actual time=0.015..21.916 rows=333333 loops=3)
  Planning Time: 0.431 ms
  JIT:
    Functions: 57
    Options: Inlining false, Optimization false, Expressions true, Deforming true
    Timing: Generation 2.691 ms (Deform 1.531 ms), Inlining 0.000 ms, Optimization 1.866 ms, Emission 34.292 ms, Total 38.849 ms
  Execution Time: 1425.062 ms


with 2 indexes b-tree

--CREATE INDEX idx_books_book_id ON m2m_books_genres  USING BTREE(book_id);
--CREATE INDEX idx_books_genre_id ON m2m_books_genres  USING BTREE (genre_id);


"QUERY PLAN"
"Hash Join  (cost=73380.48..196234.39 rows=1000000 width=97) (actual time=447.235..2043.956 rows=1000000 loops=1)"
"  Hash Cond: (m2m_books_genres.book_id = books.id)"
"  ->  Merge Join  (cost=2.48..83121.39 rows=1000000 width=67) (actual time=15.731..686.238 rows=1000000 loops=1)"
"        Merge Cond: (m2m_books_genres.genre_id = genres.id)"
"        ->  Index Scan using idx_books_genre_id on m2m_books_genres  (cost=0.42..31389.42 rows=1000000 width=12) (actual time=0.038..186.964 rows=1000000 loops=1)"
"        ->  Index Scan using genres_pkey on genres  (cost=0.43..73620.43 rows=2000000 width=55) (actual time=0.039..199.109 rows=1000000 loops=1)"
"  ->  Hash  (cost=34706.00..34706.00 rows=2000000 width=30) (actual time=430.898..430.899 rows=2000000 loops=1)"
"        Buckets: 131072  Batches: 32  Memory Usage: 4948kB"
"        ->  Seq Scan on books  (cost=0.00..34706.00 rows=2000000 width=30) (actual time=0.015..140.522 rows=2000000 loops=1)"
"Planning Time: 1.097 ms"
"JIT:"
"  Functions: 14"
"  Options: Inlining false, Optimization false, Expressions true, Deforming true"
"  Timing: Generation 1.444 ms (Deform 0.789 ms), Inlining 0.000 ms, Optimization 0.938 ms, Emission 14.782 ms, Total 17.164 ms"
"Execution Time: 2076.807 ms"


// два хеш индекса два бтри индекса хуета