#! /bin/bash

git status
java -Djava.ext.dirs=./lib org.liuyehcf.format.markdown.FormatEngine . $1
