	CREATE VIEW popularthree AS
		SELECT (regexp_split_to_array(path, E'/article/'))[2], COUNT(*) AS views FROM log
		WHERE path != '/' GROUP BY (regexp_split_to_array(path, E'/article/'))[2] 
		ORDER BY views DESC LIMIT 3;

	CREATE VIEW questionone AS
		SELECT articles.title, popularthree.views from articles, popularthree
		WHERE articles.slug = popularthree.regexp_split_to_array
		ORDER BY views DESC;

	CREATE VIEW mostviews AS
		SELECT (regexp_split_to_array(path, E'/article/'))[2] AS title, COUNT(*) AS views FROM log
		WHERE path != '/' AND status != '404 NOT FOUND' GROUP BY title ORDER BY views DESC;

	CREATE VIEW popularauthor AS
		SELECT articles.author, SUM(mostviews.views) AS articleViews FROM articles, mostviews
		WHERE articles.slug = mostviews.title GROUP BY author ORDER BY articleViews desc;

	CREATE VIEW mostpopularauthors AS
		SELECT authors.name, popularauthor.articleViews FROM authors, popularauthor
		WHERE authors.id = popularauthor.author ORDER BY popularauthor.articleViews DESC;

	CREATE VIEW totalrqsts AS
		SELECT time ::TIMESTAMP::DATE, COUNT(status) AS all FROM log
		GROUP BY time ORDER BY time;

	CREATE VIEW badrqsts AS
		SELECT time, COUNT(status) AS bad FROM days
		WHERE status = '404 NOT FOUND' GROUP BY time ORDER BY time;

	CREATE VIEW dailyerrors AS
		SELECT totalkrqsts.time, CAST(badrqsts.bad AS FLOAT) / CAST(totalrqsts.all AS FLOAT) * 100 AS percent
		FROM totalrqsts, badrqsts WHERE totalrqsts.time = badrqsts.time;

	CREATE VIEW baddays AS
		SELECT time, percent FROM dailyerrors WHERE percent > 1;