# Logs Analysis Project

This application will answer three questions regarding the newsdata.sql dataset.  
It utilizes PostgreSQL and psycopg2. It uses three methods: "popular_article"
(to find the three most popular articles), popular_author (which lists the most
popular authors, in terms of page views, in descending order), and error_days
(which calculates on which days more than 1% of requests led to errors).


## Getting Started

In order to run this program the user will need to have access to newsdata.sql,
psycopg2, python (preferable 3.0 or newer), in addition to several views which need to be 
created in the database. The structure of the queries (breaking them into views) allows
the logsanalysis.py file to be as readable as possible.

### Necessary Views:

As stated above, the user must create these views in order to run the analysis: popularthree, questionone,
mostviews, 

```sql
popularthree:
	CREATE VIEW popularthree AS
		SELECT (regexp_split_to_array(path, E'/article/'))[2], COUNT(*) AS views FROM log
		WHERE path != '/' GROUP BY (regexp_split_to_array(path, E'/article/'))[2] 
		ORDER BY views DESC LIMIT 3;

questionone:
	CREATE VIEW questionone AS
		SELECT articles.title, popularthree.views from articles, popularthree
		WHERE articles.slug = popularthree.regexp_split_to_array
		ORDER BY views DESC;

mostviews:
	CREATE VIEW mostviews AS
		SELECT (regexp_split_to_array(path, E'/article/'))[2] AS title, COUNT(*) AS views FROM log
		WHERE path != '/' AND status != '404 NOT FOUND' GROUP BY title ORDER BY views DESC;

popularauthor:
	CREATE VIEW popularauthor AS
		SELECT articles.author, SUM(mostviews.views) AS articleViews FROM articles, mostviews
		WHERE articles.slug = mostviews.title GROUP BY author ORDER BY articleViews desc;

 mostpopularauthors:
	CREATE VIEW mostpopularauthors AS
		SELECT authors.name, popularauthor.articleViews FROM authors, popularauthor
		WHERE authors.id = popularauthor.author ORDER BY popularauthor.articleViews DESC;

days:
	CREATE VIEW days AS
		SELECT time ::TIMESTAMP::DATE, status FROM log ORDER BY time;

okrsts:
	CREATE VIEW okrqsts AS
		SELECT time, COUNT(status) AS ok FROM days
		WHERE status = '200 OK' GROUP BY time ORDER BY time;

badrqsts:
	CREATE VIEW badrqsts AS
		SELECT time, COUNT(status) AS bad FROM days
		WHERE status = '404 NOT FOUND' GROUP BY time ORDER BY time;

dailyerrors:
	CREATE VIEW dailyerrors AS
		SELECT okrqsts.time, CAST(badrqsts.bad AS FLOAT) / CAST(okrqsts.ok AS FLOAT) * 100 AS percent
		FROM okrqsts, badrqsts WHERE okrqsts.time = badrqsts.time;

baddays:
	CREATE VIEW baddays AS
		SELECT time, percent FROM dailyerrors WHERE percent > 1;
```
