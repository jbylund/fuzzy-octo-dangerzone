#!/usr/bin/python
import json
import sys
import time
import pickle
try:
    import redis as redis_mod
except ImportError:
    redis_mod = None

class RealConn(object):
    def __init__(self, ttl=60, **kwargs):
        self.ttl = ttl
        self.conn = redis_mod.Redis(**kwargs)

    def __enter__(self):
        return self

    def __getitem__(self, key):
        cached_repr = self.conn.get(key)
        if cached_repr:
            cached_repr = pickle.loads(cached_repr)
        return cached_repr

    def __setitem__(self, key, val, ttl=None):
        self.conn.setex(key, pickle.dumps(val), ttl or self.ttl)

    def __exit__(self, error_type, error_val, error_traceback):
        pass

class DummyConn(object):
    def __init__(self, **kwargs):
        pass

    def __getitem__(self, key):
        return None

    def __setitem__(self, key, val, ttl=None):
        pass # there's nothing to do...

    def __enter__(self):
        return self

    def __exit__(self, error_type, error_val, error_traceback):
        pass


if redis_mod:
    RedisConn = RealConn
else:
    RedisConn = DummyConn

def main():
    with RedisConn(host='localhost', ttl=1) as foo:
        curr_time = time.time()
        foo['bar'] = curr_time
        print "set this val:", curr_time
        print "from cache:", foo['bar']
        assert curr_time == foo['bar']
        time.sleep(3) # give it time to expire
        assert foo['bar'] is None

if __name__ == "__main__":
    main()
