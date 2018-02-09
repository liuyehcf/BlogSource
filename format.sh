#! /bin/bash

git status
java -Djava.ext.dirs=./lib org.liuyehcf.markdown.format.hexo.MarkdownFormatter . $1
