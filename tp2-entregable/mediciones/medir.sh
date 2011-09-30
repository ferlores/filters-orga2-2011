#!/bin/sh

#. ./$1 

IMGINFILE=$1/imagenes.in
FUNCINFILE=$1/funciones.in


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
        
        
        c=`sudo nice -n 20 $BINFILE -t $ITER -i c $func $file 60 140| grep -e 'llamada' | cut -d':' -f 2  |  cut -d ' ' -f2`
    
        asm=`sudo nice -20 $BINFILE -t $ITER -i asm $func $file 60 140| grep -e 'llamada' | cut -d':' -f 2  |  cut -d ' ' -f2`
    
        echo $img,$c,$asm 
        echo $img,$c,$asm  >> $MEDOUTFILE
        
    done < $IMGINFILE
done < $FUNCINFILE
