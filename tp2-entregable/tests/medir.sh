#!/bin/sh

. ./$1 

IMGINDIR=../data/test-in
MEDOUTFILE=./mediciones.csv

BINFILE=../bin/tp2
ITER=1000


#echo 'Realizando mediciones...'

while read func
do 
    echo $func
    echo $func >> $MEDOUTFILE
    echo '#pixels,ciclosC,ciclosASM'
    echo '#pixels,ciclosC,ciclosASM' >> $MEDOUTFILE
    
    while read f;
    do
        file=$IMGINDIR/$f
        
        
        img=`echo $file | cut -d'.' -f4`
        
        
        c=`$BINFILE -t $ITER -i c $func $file 60 140| grep -e 'llamada' | cut -d':' -f 2  |  cut -d ' ' -f2`
    
        asm=`$BINFILE -t $ITER -i asm $func $file 60 140| grep -e 'llamada' | cut -d':' -f 2  |  cut -d ' ' -f2`
    
        echo $img,$c,$asm 
        echo $img,$c,$asm  >> $MEDOUTFILE
        
    done < $IMGINFILE
done < $FUNCINFILE
