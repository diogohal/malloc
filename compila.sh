as malloc.s -g -o malloc.o
ld malloc.o -o malloc
./malloc
echo $?