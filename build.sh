#!/bin/bash

CURRENT_DIR=$(pwd)

git submodule update --init --recursive

coffee -c $(find . -type f -name '*.coffee' ! -wholename './lib/src/*')

cd src/mustachejs
rake minify

mkdir -p ../../static/lib
cd ../../static/lib
ln -fs ../../src/mustachejs/mustache.min.js

cd ${CURRENT_DIR}

