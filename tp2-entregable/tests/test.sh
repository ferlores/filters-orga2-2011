#!/bin/sh

VALGRIND=valgrind
TESTINFILE=../data/test-in/test.in
TESTINDIR=../data/test-in
TESTOUTDIR=../data/test-out
BINFILE=../bin/tp2

OKDIFF=1
OKVALGRIND=1

echo 'Iniciando test de memoria...'

while read f;
do
	file=$TESTINDIR/$f

	echo '\nProcesando archivo: ' $file '\n'


	# Invertir
	$VALGRIND --leak-check=yes --error-exitcode=1 -q $BINFILE -v -i c invertir $file
	if [ $? != "0" ]; then
		OKVALGRIND=0
	fi

	$VALGRIND --leak-check=yes --error-exitcode=1 -q $BINFILE -v -i asm invertir $file
	if [ $? != "0" ]; then
		OKVALGRIND=0
	fi

	diff -q $file".invertir.c.bmp" $file".invertir.asm.bmp"
	if [ $? != "0" ]; then
		OKDIFF=0
	fi


	# monocromatizar_inf
	$VALGRIND --leak-check=yes --error-exitcode=1 -q $BINFILE -v -i c monocromatizar_inf $file
	if [ $? != "0" ]; then
		OKVALGRIND=0
	fi

	$VALGRIND --leak-check=yes --error-exitcode=1 -q $BINFILE -v -i asm monocromatizar_inf $file
	if [ $? != "0" ]; then
		OKVALGRIND=0
	fi

	diff -q $file".monocromatizar_inf.c.bmp" $file".monocromatizar_inf.asm.bmp"
	if [ $? != "0" ]; then
		OKDIFF=0
	fi


	# monocromatizar_uno
	$VALGRIND --leak-check=yes --error-exitcode=1 -q $BINFILE -v -i c monocromatizar_uno $file
	if [ $? != "0" ]; then
		OKVALGRIND=0
	fi

	$VALGRIND --leak-check=yes --error-exitcode=1 -q $BINFILE -v -i asm monocromatizar_uno $file
	if [ $? != "0" ]; then
		OKVALGRIND=0
	fi

		diff -q $file".monocromatizar_uno.c.bmp" $file".monocromatizar_uno.asm.bmp"
	if [ $? != "0" ]; then
		OKDIFF=0
	fi
	

	# normalizar
	$VALGRIND --leak-check=yes --error-exitcode=1 -q $BINFILE -v -i c normalizar $file
	if [ $? != "0" ]; then
		OKVALGRIND=0
	fi

	$VALGRIND --leak-check=yes --error-exitcode=1 -q $BINFILE -v -i asm normalizar $file
	if [ $? != "0" ]; then
		OKVALGRIND=0
	fi


	# separar_canales
	$VALGRIND --leak-check=yes --error-exitcode=1 -q $BINFILE -v -i c separar_canales $file
	if [ $? != "0" ]; then
		OKVALGRIND=0
	fi

	$VALGRIND --leak-check=yes --error-exitcode=1 -q $BINFILE -v -i asm separar_canales $file
	if [ $? != "0" ]; then
		OKVALGRIND=0
	fi

	diff -q $file".separar_canales.canal-r.c.bmp" $file".separar_canales.canal-r.asm.bmp"
	if [ $? != "0" ]; then
		OKDIFF=0
	fi

	diff -q $file".separar_canales.canal-g.c.bmp" $file".separar_canales.canal-g.asm.bmp"
	if [ $? != "0" ]; then
		OKDIFF=0
	fi

	diff -q $file".separar_canales.canal-b.c.bmp" $file".separar_canales.canal-b.asm.bmp"
	if [ $? != "0" ]; then
		OKDIFF=0
	fi


	# suavizar
	$VALGRIND --leak-check=yes --error-exitcode=1 -q $BINFILE -v -i c suavizar $file
	if [ $? != "0" ]; then
		OKVALGRIND=0
	fi

	$VALGRIND --leak-check=yes --error-exitcode=1 -q $BINFILE -v -i asm suavizar $file
	if [ $? != "0" ]; then
		OKVALGRIND=0
	fi

	diff -q $file".suavizar.c.bmp" $file".suavizar.asm.bmp"
	if [ $? != "0" ]; then
		OKDIFF=0
	fi


	# umbralizar 64 128
	$VALGRIND --leak-check=yes --error-exitcode=1 -q $BINFILE -v -i c umbralizar $file 64 128
	if [ $? != "0" ]; then
		OKVALGRIND=0
	fi

	$VALGRIND --leak-check=yes --error-exitcode=1 -q $BINFILE -v -i asm umbralizar $file 64 128
	if [ $? != "0" ]; then
		OKVALGRIND=0
	fi

	diff -q $file".umbralizar.min-64.max-128.c.bmp" $file".umbralizar.min-64.max-128.asm.bmp"
	if [ $? != "0" ]; then
		OKDIFF=0
	fi


	# umbralizar 128 128
	$VALGRIND --leak-check=yes --error-exitcode=1 -q $BINFILE -v -i c umbralizar $file 128 128
	if [ $? != "0" ]; then
		OKVALGRIND=0
	fi

	$VALGRIND --leak-check=yes --error-exitcode=1 -q $BINFILE -v -i asm umbralizar $file 128 128
	if [ $? != "0" ]; then
		OKVALGRIND=0
	fi

	diff -q $file".umbralizar.min-128.max-128.c.bmp" $file".umbralizar.min-128.max-128.asm.bmp"
	if [ $? != "0" ]; then
		OKDIFF=0
	fi


	# umbralizar 1 254
	$VALGRIND --leak-check=yes --error-exitcode=1 -q $BINFILE -v -i c umbralizar $file 1 254
	if [ $? != "0" ]; then
		OKVALGRIND=0
	fi

	$VALGRIND --leak-check=yes --error-exitcode=1 -q $BINFILE -v -i asm umbralizar $file 1 254
	if [ $? != "0" ]; then
		OKVALGRIND=0
	fi

	diff -q $file".umbralizar.min-1.max-254.c.bmp" $file".umbralizar.min-1.max-254.asm.bmp"
	if [ $? != "0" ]; then
		OKDIFF=0
	fi


	# umbralizar 1 254
	$VALGRIND --leak-check=yes --error-exitcode=1 -q $BINFILE -v -i c umbralizar $file 63 129
	if [ $? != "0" ]; then
		OKVALGRIND=0
	fi

	$VALGRIND --leak-check=yes --error-exitcode=1 -q $BINFILE -v -i asm umbralizar $file 63 129
	if [ $? != "0" ]; then
		OKVALGRIND=0
	fi

	diff -q $file".umbralizar.min-63.max-129.c.bmp" $file".umbralizar.min-63.max-129.asm.bmp"
	if [ $? != "0" ]; then
		OKDIFF=0
	fi	
done < $TESTINFILE

if [ $OKVALGRIND != "0" ]; then
	echo "Tests de memoria finalizados correctamente"
fi
