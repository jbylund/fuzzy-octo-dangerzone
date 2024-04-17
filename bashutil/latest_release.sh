#!/bin/bash
set -eu

function get_latest_release () {
    res=$(
        curl --fail --output /dev/null --verbose https://github.com/$1/releases/latest 2>&1  |
          grep Location |
          rev |
          cut -f 1 -d/ |
          tail -c +2 | rev
    )
    if [[ "$res" != 'releases' ]]
    then
        echo $res
        return
    fi

    fallback_get_release $1
}

function fallback_get_release () {
    echo "Falling back for $1" > /dev/stderr
    curl --silent https://github.com/$1/releases | 
      grep "/$1/releases/tag/" |
      cut -f 2 -d\" |
      grep -v -w -e rc -e alpha |
      grep -v -E 'rc[1-9]' |
      sort -n | tail -n 1 | rev |
      cut -f 1 -d/ | rev
}
