as malloc.s -o malloc.o -g
ld malloc.o -o malloc -dynamic-linker /lib/x86_64-linux-gnu/ld-linux-x86-64.so.2 \ /usr/lib/x86_64-linux-gnu/crt1.o /usr/lib/x86_64-linux-gnu/crti.o \ /usr/lib/x86_64-linux-gnu/crtn.o -lc
./malloc
echo $?