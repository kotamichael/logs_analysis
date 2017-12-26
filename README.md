# Logs Analysis Project

This application will answer three questions regarding the newsdata.sql dataset.  
It utilizes PostgreSQL and psycopg2. It uses three methods: "popular_article"
(to find the three most popular articles), popular_author (which lists the most
popular authors, in terms of page views, in descending order), and error_days
(which calculates on which days more than 1% of requests led to errors).


## Getting Started

In order to run this program the user will need to have Python3, Git, Vagrant, and Virtual Box installed.
In addition, cloning [this github repository](https://github.com/udacity/fullstack-nanodegree-vm) will install files necessay to do the rest.  I've broken down the structure of the program to include several views which allows the logsanalysis.py file to be as readable as possible.

Before creating these views, the user must run their vagrant machine by ```cd```ing into their directory in Git, and issue a ```vagrant up``` command, followed by ```vagrant ssh```.  To load the data, run the command ```psql -d news -f newsdata.sql```.

Afterwards, the user must create the views spoken about before.

Finally, the user must run the python file from the vagrant command line using the command: ```python3 logsanalysis.py```

### Necessary Views:

The easiest way to create these views is by running the command ```psql -d news -f create_ views.sql```
This command will load the views directly into the 'news' database.  Alternatively, to get a more hands-on experience the user could choose to load these views themselves.  The views follow below.

```sql
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
```
