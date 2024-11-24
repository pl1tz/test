```explain analyze SELECT * FROM books WHERE title LIKE '%Potter%';```

no index

"Gather  (cost=1000.00..26142.67 rows=200 width=30) (actual time=394.260..399.880 rows=0 loops=1)"
"  Workers Planned: 2"
"  Workers Launched: 2"
"  ->  Parallel Seq Scan on books  (cost=0.00..25122.67 rows=83 width=30) (actual time=93.704..93.705 rows=0 loops=3)"
"        Filter: ((title)::text ~~ '%Potter%'::text)"
"        Rows Removed by Filter: 666667"
"Planning Time: 0.167 ms"
"Execution Time: 399.907 ms"

Btree
```CREATE INDEX idx_books_title ON books USING BTREE (title);```

"Gather  (cost=1000.00..26142.67 rows=200 width=30) (actual time=88.866..91.882 rows=0 loops=1)"
"  Workers Planned: 2"
"  Workers Launched: 2"
"  ->  Parallel Seq Scan on books  (cost=0.00..25122.67 rows=83 width=30) (actual time=83.452..83.454 rows=0 loops=3)"
"        Filter: ((title)::text ~~ '%Potter%'::text)"
"        Rows Removed by Filter: 666667"
"Planning Time: 0.140 ms"
"Execution Time: 91.920 ms"

GiST
```CREATE INDEX idx_books_title_gist ON books USING GiST (title gist_trgm_ops);```

"Bitmap Heap Scan on books  (cost=13.96..743.02 rows=200 width=30) (actual time=72.766..72.766 rows=0 loops=1)"
"  Recheck Cond: ((title)::text ~~ '%Potter%'::text)"
"  ->  Bitmap Index Scan on idx_books_title_gist  (cost=0.00..13.91 rows=200 width=0) (actual time=72.757..72.757 rows=0 loops=1)"
"        Index Cond: ((title)::text ~~ '%Potter%'::text)"
"Planning Time: 0.169 ms"
"Execution Time: 72.804 ms"

GIN
```CREATE INDEX idx_books_title_trgm_gin ON books USING gin (title gin_trgm_ops);```

"Bitmap Heap Scan on books  (cost=118.28..847.33 rows=200 width=30) (actual time=0.033..0.034 rows=0 loops=1)"
"  Recheck Cond: ((title)::text ~~ '%Potter%'::text)"
"  ->  Bitmap Index Scan on idx_books_title_trgm_gin  (cost=0.00..118.23 rows=200 width=0) (actual time=0.025..0.025 rows=0 loops=1)"
"        Index Cond: ((title)::text ~~ '%Potter%'::text)"
"Planning Time: 0.519 ms"
"Execution Time: 0.069 ms"


```explain analyze SELECT * FROM books WHERE title ~ 'Potter';```

GIN
"Bitmap Heap Scan on books  (cost=118.28..847.33 rows=200 width=30) (actual time=0.072..0.072 rows=0 loops=1)"
"  Recheck Cond: ((title)::text ~ 'Potter'::text)"
"  ->  Bitmap Index Scan on idx_books_title_trgm_gin  (cost=0.00..118.23 rows=200 width=0) (actual time=0.066..0.066 rows=0 loops=1)"
"        Index Cond: ((title)::text ~ 'Potter'::text)"
"Planning Time: 0.229 ms"
"Execution Time: 0.091 ms"

```explain analyze SELECT * FROM books WHERE LOWER(title) = 'harry potter';```

GIN
CREATE INDEX idx_books_title_trgm ON books USING GIN (LOWER(title) gin_trgm_ops);

"Bitmap Heap Scan on books  (cost=429.37..14481.98 rows=10000 width=30) (actual time=0.077..0.078 rows=0 loops=1)"
"  Recheck Cond: (lower((title)::text) = 'harry potter'::text)"
"  ->  Bitmap Index Scan on idx_books_title_trgm  (cost=0.00..426.87 rows=10000 width=0) (actual time=0.065..0.066 rows=0 loops=1)"
"        Index Cond: (lower((title)::text) = 'harry potter'::text)"
"Planning Time: 0.515 ms"
"Execution Time: 0.125 ms"

no index
"Gather  (cost=1000.00..29206.00 rows=10000 width=30) (actual time=388.435..392.801 rows=0 loops=1)"
"  Workers Planned: 2"
"  Workers Launched: 2"
"  ->  Parallel Seq Scan on books  (cost=0.00..27206.00 rows=4167 width=30) (actual time=385.236..385.237 rows=0 loops=3)"
"        Filter: (lower((title)::text) = 'harry potter'::text)"
"        Rows Removed by Filter: 666667"
"Planning Time: 0.115 ms"
"Execution Time: 392.841 ms"

```explain analyze SELECT * FROM books WHERE LOWER(title) = 'harry potter' or LOWER(title) = 'harry potter1';```

gin
"Bitmap Heap Scan on books  (cost=893.03..16778.78 rows=19950 width=30) (actual time=0.048..0.049 rows=0 loops=1)"
"  Recheck Cond: ((lower((title)::text) = 'harry potter'::text) OR (lower((title)::text) = 'harry potter1'::text))"
"  ->  BitmapOr  (cost=893.03..893.03 rows=20000 width=0) (actual time=0.044..0.045 rows=0 loops=1)"
"        ->  Bitmap Index Scan on idx_books_title_trgm  (cost=0.00..426.87 rows=10000 width=0) (actual time=0.025..0.025 rows=0 loops=1)"
"              Index Cond: (lower((title)::text) = 'harry potter'::text)"
"        ->  Bitmap Index Scan on idx_books_title_trgm  (cost=0.00..456.18 rows=10000 width=0) (actual time=0.018..0.018 rows=0 loops=1)"
"              Index Cond: (lower((title)::text) = 'harry potter1'::text)"
"Planning Time: 0.203 ms"
"Execution Time: 0.073 ms"

```explain analyze SELECT * FROM books WHERE title = 'Potter';```

hash index
"Index Scan using idx_hash_string on books  (cost=0.00..8.02 rows=1 width=30) (actual time=0.018..0.018 rows=0 loops=1)"
"  Index Cond: ((title)::text = 'Potter'::text)"
"Planning Time: 0.109 ms"
"Execution Time: 0.041 ms"

SELECT 
    i.relname AS index_name,
    pg_size_pretty(pg_relation_size(i.oid)) AS index_size,
    ix.indisunique AS is_unique,
    ix.indisprimary AS is_primary,
    a.attname AS indexed_column
FROM 
    pg_class t
JOIN 
    pg_index ix ON t.oid = ix.indrelid
JOIN 
    pg_class i ON i.oid = ix.indexrelid
JOIN 
    pg_attribute a ON a.attnum = ANY(ix.indkey) AND a.attrelid = t.oid
WHERE 
    t.relname = 'books' AND t.relkind = 'r'  -- 'r' означает обычную таблицу
ORDER BY 
    index_name;


"books_pkey"        	    "43 MB"	    true	true	"id"
"idx_books_title_btree"     "77 MB"	    false	false	"title"
"idx_books_title_gist"	    "164 MB"	false	false	"title"
"idx_books_title_trgm_gin"	"48 MB"	    false	false	"title"
"idx_hash_string"	        "64 MB"	    false	false	"title"

explain analyze insert into books (title, "year" ,quantity)
VALUES('test1', 2013, 1);

no index

"Insert on books  (cost=0.00..0.01 rows=0 width=0) (actual time=0.182..0.182 rows=0 loops=1)"
"  ->  Result  (cost=0.00..0.01 rows=1 width=528) (actual time=0.016..0.017 rows=1 loops=1)"
"Planning Time: 0.087 ms"
"Execution Time: 0.215 ms"

btree
CREATE INDEX idx_books_title ON books USING BTREE (title);

"Insert on books  (cost=0.00..0.01 rows=0 width=0) (actual time=0.295..0.296 rows=0 loops=1)"
"  ->  Result  (cost=0.00..0.01 rows=1 width=528) (actual time=0.010..0.011 rows=1 loops=1)"
"Planning Time: 0.048 ms"
"Execution Time: 0.320 ms"

hash
CREATE INDEX idx_hash_string ON books USING HASH (title);

"Insert on books  (cost=0.00..0.01 rows=0 width=0) (actual time=0.123..0.123 rows=0 loops=1)"
"  ->  Result  (cost=0.00..0.01 rows=1 width=528) (actual time=0.014..0.014 rows=1 loops=1)"
"Planning Time: 0.023 ms"
"Execution Time: 0.134 ms"

GIN
CREATE INDEX idx_books_title_trgm_gin ON books USING gin (title gin_trgm_ops);

"Insert on books  (cost=0.00..0.01 rows=0 width=0) (actual time=0.224..0.225 rows=0 loops=1)"
"  ->  Result  (cost=0.00..0.01 rows=1 width=528) (actual time=0.008..0.008 rows=1 loops=1)"
"Planning Time: 0.050 ms"
"Execution Time: 0.242 ms"

GiST
CREATE INDEX idx_books_title_gist ON books USING GiST (title gist_trgm_ops);

"Insert on books  (cost=0.00..0.01 rows=0 width=0) (actual time=0.509..0.510 rows=0 loops=1)"
"  ->  Result  (cost=0.00..0.01 rows=1 width=528) (actual time=0.028..0.029 rows=1 loops=1)"
"Planning Time: 0.049 ms"
"Execution Time: 0.538 ms"

all indexes

"Insert on books  (cost=0.00..0.01 rows=0 width=0) (actual time=0.317..0.317 rows=0 loops=1)"
"  ->  Result  (cost=0.00..0.01 rows=1 width=528) (actual time=0.025..0.025 rows=1 loops=1)"
"Planning Time: 0.023 ms"
"Execution Time: 0.331 ms"

