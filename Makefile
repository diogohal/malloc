FLAGS = -no-pie

all: malloc


malloc: malloc.o exemplo.o
	gcc malloc.o exemplo.o ${FLAGS} -o malloc

malloc.o: malloc.s
	as malloc.s -o malloc.o -g


exemplo.o: exemplo.c
	gcc -c exemplo.c -o exemplo.o

run: all
	./malloc

clean: 
	rm -rf *.o

purge: clean
	rm -rf malloc