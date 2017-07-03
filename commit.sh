#!/bin/bash

description="version["$(date +%Y)"."$(date +%m)"."$(date +%d)"#"$(date +%H:%M:%S)"]"

git add .
git commit -m $description
git push origin master:master
