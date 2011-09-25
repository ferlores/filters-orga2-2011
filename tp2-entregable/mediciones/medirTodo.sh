#!/bin/bash

rm mediciones.csv
rm -rf ../data/test-in/*
../tests/testgen.sh

./medir.sh casoByN.in
./medir.sh casoColor.in
