#!/bin/bash

rm mediciones.csv
rm -rf ../data/test-in/*
../tests/testgen.sh

./medir.sh casoBase
./medir.sh casoByN-alto
./medir.sh casoColor-alto
./medir.sh casoAncho
./medir.sh predictorSaltos
