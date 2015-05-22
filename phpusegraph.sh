#!/bin/bash

# Finds occurrences of class names in the PHP files of given directories, and
# prints them as GraphViz source code.
#
# -f <nsprefix>: a namespace prefix to filter dependencies by. This can be used
#                to only include dependencies from your own project. Use
#                quadruple backslashes.
main() {
# Parse options.
NSPREFIX=""
while getopts "f:" opt; do
  case $opt in
    f)
      NSPREFIX="$OPTARG"
      ;;

    \?)
      echo "usage: $0 [-f <nsprefix>] [dir ...]"
      exit
      ;;
  esac
done
shift $((OPTIND - 1))
# Remaining arguments are directories to search. If empty, default to current
# directory.
DIR=$@
[ -z "$DIR" ] && DIR=.

echo "digraph g{"
# Find all classes mentioned in each PHP file.
for phpfile in $(find $DIR -iname '*.php'); do
  a=$(phpclass $phpfile)
  for dep in $(phpuses $phpfile | grep ^$NSPREFIX); do
    b=$(phpbasename $dep)
    # Skip reflexive references.
    [ "$a" = "$b" ] && continue
    # Print an edge for the dependency.
    echo "  $a -> $b"
  done;
done
echo "}"
}

# Find class names in a file.
# $1 - filename
phpuses() {
cat $1 | grep -v '^namespace ' | phpmatchclass | sort -u
}

# Find a class name in a line.
# $1 - line of PHP code
phpmatchclass() {
grep -o '\([A-Za-z_]\+\\\)\+[A-Za-z_]\+' $1
}

# Find the namespace of a file.
# $1 - filename
phpns() {
grep '^namespace ' $1 | phpmatchclass
}

# Find the class name of a file.
# $1 - filename
phpclass() {
grep '^\([a-z]\+ \)*\(class\|interface\|trait\) ' $1  | sed -E 's/.*(class|interface|trait) ([A-Za-z_]*).*/\2/'
}

# Find the fully qualified class name of a file.
# $1 - filename
phpfqn() {
ns=$(phpns $1)
class=$(phpclass $1)
echo $ns\\$class
}

# Find the class name of a fqn.
# $1 - fully qualified name (namespace + class name)
phpbasename() {
echo $1 | sed 's/.*\\//'
}

# Run that thing.
main $@
