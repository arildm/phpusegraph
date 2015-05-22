#!/bin/bash

function phpusegraph {
DIR=$@
[ -z $DIR ] && DIR=.

echo "digraph d{"
for phpfile in $(find $DIR -iname '*.php'); do
  a=$(phpclass $phpfile)
  for dep in $(phpuses $phpfile); do
    b=$(phpbasename $dep)
    [ "$a" = "$b" ] && continue
    echo "  $a -> $b"
  done;
done
echo "}"
}

function phpuses {
cat $1 | grep -v '^namespace ' | phpmatchclass | grep 'Drupal\\collect' | sort -u
}

function phpmatchclass {
grep -o '\([A-Za-z_]\+\\\)\+[A-Za-z_]\+' $1
}

function phpns {
grep '^namespace ' $1 | phpmatchclass
}

function phpclass {
grep '^\([a-z]\+ \)*\(class\|interface\|trait\) ' $1  | sed -E 's/.*(class|interface|trait) ([A-Za-z_]*).*/\2/'
}

function phpfqn {
ns=$(phpns $1)
class=$(phpclass $1)
echo $ns\\$class
}

function phpbasename {
echo $1 | sed 's/.*\\//'
}

phpusegraph $@
