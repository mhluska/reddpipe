#!/bin/bash

coffee -c $(find . -type f -name '*.coffee')

for slim in $(find . -type f -name '*.slim'); do

    slimrb ${slim} > ${slim%.*}.html
done

