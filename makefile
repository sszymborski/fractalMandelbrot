CC = gcc
CFLAGS = -Wall -m64 -lglut -lGLU -lGL -lm

all: main.o mandel.o
	$(CC) $(CFLAGS) -o output main.o mandel.o -lglut -lGLU -lGL -lm

mandel.o: mandel.s
	nasm -f elf64 -o mandel.o mandel.s

main.o: main.c mandel.h
	$(CC) $(CFLAGS) -c -o main.o main.c

clean:
	rm -f *.o


