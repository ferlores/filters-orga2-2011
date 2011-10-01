#!/bin/bash

BASEIMGDIR=../data/base
TESTINDIR=../data/test-in


sizes=(800x600 16x30000 17x28234 10x48000 11x43636 18x26666 19x25263 1442x333 1443x333 1440x333 1441x333 1440x1 1440x2 1440x3 1440x3 1440x4 1440x5 1441x1 1441x2 1441x3 1441x3 1441x4 1441x5)
#sizes=(640x480 16x19200 17x1871 1871x17 19200x16 19200x1 1871x1 19200x2 1871x2)
#sizes=(1454x1 1454x50 1454x100 1454x200 1454x400 1454x800 1454x1400)
#sizes=(200x200 201x201 202x202 203x203 204x204 205x205 206x206 207x207 208x208 256x256 512x512 513x513 1023x767)

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
