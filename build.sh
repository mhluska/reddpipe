#!/bin/bash

CURRENT_DIR=$(pwd)

coffee -c $(find . -type f -name '*.coffee' ! -wholename './lib/src/*')

for slim in $(find . -type f -name '*.slim' ! -wholename './lib/src/*'); do

    slimrb ${slim} > ${slim%.*}.html
done

cd lib/src/mustachejs
rake minify
cd ../..
ln -fs src/mustachejs/mustache.min.js

cd ${CURRENT_DIR}


