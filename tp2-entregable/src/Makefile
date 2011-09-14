CC = gcc
ASM = nasm
DBG = gdb
CFLAGS = -ggdb -Wall -std=c99 -pedantic -m32 
#CFLAGS = -Wall -std=c99 -pedantic -m32
ASMFLAGS = -felf32 -g -F dwarf
OPENCV_LIB = `pkg-config --cflags --libs opencv`

BIN = tp2
BIN_DIR = ../bin

OBJS = tp2.o utils.o macros.o \
	invertir_c.o invertir_asm.o \
	monocromatizar_inf_c.o monocromatizar_inf_asm.o \
	monocromatizar_uno_c.o monocromatizar_uno_asm.o \
	normalizar_c.o normalizar_asm.o \
	separar_canales_c.o separar_canales_asm.o \
	suavizar_c.o suavizar_asm.o \
	umbralizar_c.o umbralizar_asm.o
	

.PHONY: all debug test clean

$(BIN): $(OBJS)
	$(CC) $(CFLAGS) $(OBJS) -o $@ $(OPENCV_LIB)
	cp $(BIN) $(BIN_DIR)/$(BIN)

tp2.o: tp2.c
	$(CC) $(CFLAGS) -c -o $@ $< $(OPENCV_LIB)

%.o: %.c
	$(CC) $(CFLAGS) -c -o $@ $<

%.o: %.asm
	$(ASM) $(ASMFLAGS) -o $@ $<

all: $(BIN)

test: $(BIN)
	../tests/test.sh

clean:
	rm -f $(OBJS)
	rm -f ./$(BIN)
	rm -f $(BIN_DIR)/$(BIN)
