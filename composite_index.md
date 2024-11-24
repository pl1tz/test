# two indexes

```explain analyse SELECT * FROM books WHERE year=2005 and books.title = 'f';```
```--CREATE INDEX idx_books_year ON books USING BTREE ("year");```
```--CREATE INDEX idx_books_title ON books USING BTREE (title);```

"Index Scan using idx_books_title on books  (cost=0.43..8.45 rows=1 width=30) (actual time=0.064..0.065 rows=0 loops=1)"
"  Index Cond: ((title)::text = 'f'::text)"
"  Filter: (year = 2005)"
"Planning Time: 0.262 ms"
"Execution Time: 0.112 ms"


```explain analyse SELECT * FROM books WHERE year=2005 or books.title = 'f';```


"Bitmap Heap Scan on books  (cost=259.53..15989.22 rows=22334 width=30) (actual time=8.450..22.381 rows=20000 loops=1)"
"  Recheck Cond: ((year = 2005) OR ((title)::text = 'f'::text))"
"  Heap Blocks: exact=14706"
"  ->  BitmapOr  (cost=259.53..259.53 rows=22334 width=0) (actual time=4.251..4.252 rows=0 loops=1)"
"        ->  Bitmap Index Scan on idx_books_year  (cost=0.00..243.93 rows=22333 width=0) (actual time=4.228..4.228 rows=20000 loops=1)"
"              Index Cond: (year = 2005)"
"        ->  Bitmap Index Scan on idx_books_title  (cost=0.00..4.44 rows=1 width=0) (actual time=0.022..0.022 rows=0 loops=1)"
"              Index Cond: ((title)::text = 'f'::text)"
"Planning Time: 0.130 ms"
"Execution Time: 23.060 ms"


# without indexes

```explain analyse SELECT * FROM books WHERE year=2005 or books.title = 'f';```

"Gather  (cost=1000.00..30439.40 rows=22334 width=30) (actual time=0.253..123.871 rows=20000 loops=1)"
"  Workers Planned: 2"
"  Workers Launched: 2"
"  ->  Parallel Seq Scan on books  (cost=0.00..27206.00 rows=9306 width=30) (actual time=0.023..114.112 rows=6667 loops=3)"
"        Filter: ((year = 2005) OR ((title)::text = 'f'::text))"
"        Rows Removed by Filter: 660000"
"Planning Time: 0.138 ms"
"Execution Time: 125.191 ms"



```CREATE INDEX idx_books_year ON books USING BTREE ("year", title);```
# Эффективные
```SELECT * FROM books WHERE year = 2005 AND title = 'f';```
В этом случае индекс будет использоваться для быстрого поиска строк, соответствующих обоим условиям.
// вообще не принципиально ж.
два индекса лучше чем составной

```SELECT * FROM books WHERE year = 2005;```
Индекс также будет полезен, так как он начинается с year, что позволяет эффективно находить все записи за 2005 год.

```SELECT * FROM books WHERE year = 2005 ORDER BY title;```
Индекс может помочь в сортировке, так как он уже отсортирован по title для каждой группы year.
# Не эффективные
```SELECT * FROM books WHERE title = 'f';```
В этом случае индекс не будет полезен, так как он не начинается с title.

```SELECT * FROM books WHERE year = 2005 OR title = 'f';```
Индекс не будет эффективен, так как он не может оптимально обрабатывать условия OR, особенно если одно из условий не соответствует первому полю индекса.

```SELECT * FROM books WHERE title = 'f' ORDER BY year;```
Индекс не поможет в этом случае, так как он не отсортирован по year для всех значений title.


```CREATE INDEX idx_books_year ON books USING BTREE ( title, "year");```
# Эффективные

```SELECT * FROM books WHERE title = 'f' AND year = 2005;```
В этом случае индекс будет использоваться для быстрого поиска строк, соответствующих обоим условиям.

```SELECT * FROM books WHERE title = 'f';```
Индекс будет полезен, так как он начинается с title, что позволяет эффективно находить все записи с указанным заголовком.

```SELECT * FROM books WHERE title = 'f' ORDER BY year```
Индекс может помочь в сортировке, так как он уже отсортирован по year для каждой группы title.

# Не эффективные
```SELECT * FROM books WHERE year = 2005;```
этом случае индекс не будет полезен, так как он не начинается с year.

```SELECT * FROM books WHERE title = 'f' OR year = 2005;```
Индекс не будет эффективен, так как он не может оптимально обрабатывать условия OR, особенно если одно из условий не соответствует первому полю индекса.

```SELECT * FROM books WHERE year = 2005 ORDER BY title;```
Индекс не поможет в этом случае, так как он не отсортирован по title для всех значений year.


СТРАТЕГИИ для OR
1.
--explain analyse SELECT * FROM books WHERE year=2005 and books.title = 'f'
--union SELECT * FROM books WHERE title = 'f';
--CREATE INDEX idx_books_year ON books USING BTREE ( title);


explain analyse SELECT * FROM books WHERE year=2005 or books.title = 'f';

С годами будет работать медленеее потому что 2005года много в базе

2. 2 индекса для or лучше чем один
// либо 2 индекса либо запрос с union

3. Явно сделать индекс для конкретных значений.
CREATE INDEX idx_books_combined ON books ((year = 2020 OR title = 'Harry Potter'));

// составные индексы полезны для order_by