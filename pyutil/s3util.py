#!/usr/bin/python
"""deal with objects on s3 as if they were files..."""
import errno
import os
import re
import subprocess
import sys
import tempfile

import boto3
import boto3.s3
import botocore.session


def mkdir_p(path):
    """..."""
    try:
        os.makedirs(path)
    except OSError as exc: # Python >2.5
        if exc.errno == errno.EEXIST and os.path.isdir(path):
            pass
        else:
            raise

def get_methods():
    """figure out which download programs are available"""
    available_methods = []
    for method in ['axel', 'aria2c', 'curl']:
        try:
            subprocess.check_call([method, '--version'], stderr=open("/dev/null", 'w'), stdout=open("/dev/null", 'w'))
            available_methods.append(method)
        except OSError as oops:
            pass
    available_methods += ['boto', 'wget'] # just assume wget is ok?
    return available_methods

def get_s3_file(bucket=None, key=None, local_path=None, method="boto"):
    """get a file from s3 (quickly)"""
    local_dir = local_path.rpartition('/')[0]
    if local_dir:
        mkdir_p(local_dir)
    conn = boto3.client('s3')
    if method == "boto":
        # TODO: this method hasn't been tested at all, and is
        # probably broken since I never moved it from boto to boto3
        bbucket = conn.get_bucket(bucket, validate=False)
        bkey = bbucket.get_key(key)
        with open(local_path, 'w') as local_log:
            tries = 5
            while True:
                try:
                    bkey.get_contents_to_file(local_log)
                    break
                except Exception as oops:
                    tries -= 1
                    if __debug__:
                        print >> sys.stderr, "Getting {}:{} failed with {}".format(bbucket.name, bkey.name, oops)
                    if not tries:
                        raise
    else:
        failures = 0
        session = botocore.session.get_session()
        client = session.create_client('s3')
        s3_url = client.generate_presigned_url(
            'get_object',
            Params={
                'Bucket': bucket,
                'Key': key
            }
        )
        if method == "axel":
            command = 'axel --num-connections 8 --quiet --output {} {}'.format(local_path, s3_url).split()
        elif method == "aria":
            command = 'aria2c --min-split-size=20M --max-connection-per-server=8 --split=8 --out={} {}'.format(local_path, s3_url).split()
        elif method == "wget":
            command = 'wget --quiet --output-document={} {}'.format(local_path, s3_url).split()
        elif method == "curl":
            command = 'curl --fail --silent --speed-limit 5000 --speed-time 20 --output {} {}'.format(local_path, s3_url).split()
        have_file = False
        while not have_file:
            try:
                subprocess.check_call('/bin/rm -rf {}'.format(local_path).split())
            except Exception as oops:
                pass # this should fail since we often won't have the file
            try:
                subprocess.check_call(command, stderr=open(os.devnull, 'w'), stdout=open(os.devnull, 'w'))
                have_file = True
                return
            except Exception as oops:
                failures += 1
                if failures >= 20:
                    print >> sys.stderr, "get failed (after {} attempts):".format(failures), oops
                    print >> sys.stderr, " ".join(command)
                    raise


def key_exists(bucket=None, key=None):
    """return boolean true/false for key exists on s3"""
    conn = boto3.client('s3')
    try:
        conn.head_object(
            Bucket=bucket,
            Key=key,
        )
        return True
    except botocore.exceptions.ClientError as oops:
        if oops.response['Error']['Code'] == '404':
            return False
        else:
            raise


class S3Key(object):
    """a file like object representing a key on s3"""
    valid_modes = ['r', 'w', 'a']
    valid_modes += ['{}+'.format(x) for x in valid_modes]
    pattern = re.compile('s3://([^/]*)/(.*)')
    def __init__(self, path=None, bucket=None, key=None, mode='r'):
        self.conn = boto3.client('s3')
        if path:
            match = self.pattern.search(path)
            bucket, key = match.groups()
        self.key = key
        self.bucket = bucket
        self.filehandle = tempfile.NamedTemporaryFile(delete=False, mode=mode)
        self.filehandle.close()
        if "w" in mode:
            pass # don't need to download the file
        else:
            if key_exists(bucket=bucket, key=key):
                get_s3_file(bucket=bucket, key=key, local_path=self.filehandle.name, method='axel')
        self.filehandle = open(self.filehandle.name, mode=mode)

    def __enter__(self):
        return self.filehandle

    def __exit__(self, error_type, error_val, error_traceback):
        self.filehandle.close()
        self.filehandle = open(self.filehandle.name)
        self.conn.put_object(
            Body=self.filehandle,
            Bucket=self.bucket,
            Key=self.key
        )
        self.filehandle.close()
        os.remove(self.filehandle.name)

def test():
    """test the behavior of an s3key object"""
    with S3Key("s3://fuzzy-octo-dangerzone/test.txt", mode='w') as foobar:
        for _ in xrange(1):
            print >> foobar, "goodbye"
    with S3Key(bucket="fuzzy-octo-dangerzone", key="test.txt", mode='r') as foobar:
        for line in foobar:
            print line.strip()

if __name__ == "__main__":
    test()
