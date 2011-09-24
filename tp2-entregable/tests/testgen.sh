#!/bin/bash

BASEIMGDIR=../data/base
TESTINDIR=../data/test-in

#sizes=(200x200)
sizes=(800x600 16x30000 17x28234 28234x17 30000x16 30000x1 28234x1 30000x2 28234x2)

rm -rf ../data/test-in/test.in
touch ../data/test-in/test.in

for f in $( ls $BASEIMGDIR );
do
	echo $f

	for s in ${sizes[*]}
	do
		echo "  *" $s		
	
		`echo  "convert -resize $s!" $BASEIMGDIR/$f ` $TESTINDIR/`echo "$f" | cut -d'.' -f1`.$s.bmp

		echo  `echo "$f" | cut -d'.' -f1`.$s.bmp >> ../data/test-in/test.in		
	done
done
