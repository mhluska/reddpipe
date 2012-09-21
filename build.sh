#!/bin/bash

CURRENT_DIR=$(pwd)

coffee -c $(find . -type f -name '*.coffee' ! -wholename './lib/src/*')

cd src/mustachejs
rake minify
cd ../../static/lib
ln -fs ../../src/mustachejs/mustache.min.js

cd ${CURRENT_DIR}


