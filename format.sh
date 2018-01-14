#! /bin/bash

git status
java -Djava.ext.dirs=./lib org.liuyehcf.markdownformat.MarkdownFormatter . $1
