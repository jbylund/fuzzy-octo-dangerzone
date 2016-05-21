#!/usr/bin/python
import hashlib
import json
import psycopg2
import psycopg2.extras
import sys
from redisutil import RedisConn
import re


class DBCursor(object):
    def __init__(self, **kwargs):
        self.__uncachable = {
            "COPY",
            "DELETE",
            "GRANT",
            "INSERT",
            "TRUNCATE",
            "UPDATE",
            "NOW",
            "CURRENT_TIME"
        }
        self.splitter = re.compile('[^A-Z_]')
        self.last_result = None
        self.redis = RedisConn(**kwargs.pop('redis', {}))
        dbargs = kwargs
        dbargs.setdefault('host', 'localhost')
        self.conn = psycopg2.connect(**dbargs)
        self.cursor = self.conn.cursor(cursor_factory=psycopg2.extras.DictCursor)
        for i in dir(self.cursor):
            if i.startswith("__"):
                continue
            if i == 'execute': # don't passthrough the execute function...
                continue
            setattr(self, i, getattr(self.cursor, i))

    def __iter__(self):
        if self.last_result is None:
            raise Exception("Haven't executed a query!")
        if self.last_result:
            for row in self.last_result:
                yield row
        self.last_result = None


    def query_is_cachable(self, query):
        # need to split on not just whitespace but everything but letters and underscore
        query_words = set(self.splitter.split(query.upper()))
        return not(query_words & self.__uncachable)

    def execute(self, query, params=None):
        cached_val = None
        is_cachable = self.query_is_cachable(query)
        if is_cachable:
            cache_key = hashlib.sha512(json.dumps([query, params], indent=4, sort_keys=True)).hexdigest()
            cached_val = self.redis[cache_key]
            if cached_val is None:
                pass # cache miss
            else:
                self.last_result = cached_val
        if cached_val is None:
            self.cursor.execute(query, params)
            res = [dict(row) for row in self.cursor.fetchall()] # could this be painful?
            self.last_result = res
            if is_cachable:
                self.redis[cache_key] = res
            return res
        else:
            return cached_val

    def __enter__(self):
        return self

    def __exit__(self, error_type, error_val, error_traceback):
        if error_type:
            self.conn.rollback()
        else:
            self.conn.commit()
        self.conn.close()


def test():
    with DBCursor() as dbc:
        dbc.execute("select 1 as foo")
        for row in dbc:
            print row


if __name__ == "__main__":
    test()
