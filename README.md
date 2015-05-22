phpusegraph
===========

Bash script for generating a GraphViz dependency graph for OOP PHP projects.

Usage
-----

    phpusegraph.sh myproject/src/ | dot -Tpng > /tmp/phpusegraph.png && open /tmp/phpusegraph.png

Todo
----

* Include mentions of classes in same namespace.
