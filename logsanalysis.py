"""When file run from the command line, all three operations
 are called in order."""

#!/usr/bin/env python3
import psycopg2
import datetime


def popular_article():
    """Returns most popular 3 articles along with number of views."""
    db = psycopg2.connect("dbname='news'")
    c = db.cursor()
    c.execute("select * from questionone;")
    rows = c.fetchall()
    print('The top three articles are: ')
    for row in rows:
        x, y = row
        print('\n   %s - %s views' % (x, y))
    db.close()


def popular_author():
    """Lists most popular authors and number of views in descending order."""
    db = psycopg2.connect("dbname='news'")
    c = db.cursor()
    c.execute("select * from mostpopularauthors;")
    authors = c.fetchall()
    print('\n\n The most popular authors are as follow:')
    for row in authors:
        a, b = row
        print('\n   %s - %s hits' % (a, b))
    db.close()


def error_days():
    """Lists days where more than 1% of requests were erroneously resultant."""
    db = psycopg2.connect("dbname='news'")
    c = db.cursor()
    c.execute("select * from baddays;")
    days = c.fetchall()
    print('\n These days more than 1 percent of requests resulted in error:')
    for row in days:
        a, b = row
        print('\n   %s - %s percent' % (a, b))
    db.close()


def logs_analysis():
    """Runs all three analyses consecutively"""
    popular_article()
    popular_author()
    error_days()


logs_analysis()