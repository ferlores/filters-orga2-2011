#!/bin/bash

BASEIMGDIR=../data/base
TESTINDIR=../data/test-in

sizes=(200x200 201x201 202x202 203x203 204x204 205x205 206x206 207x207 208x208 256x256 512x512 513x513 1023x767)

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
