.section .data
    topoInicialHeap: .quad 5
.section .text
.globl _start
_start:

    call iniciaAlocador
    movq topoInicialHeap, %rbx
    movq $60, %rax
    movq topoInicialHeap, %rdi
    movq %rbx, %rdi
    syscall

iniciaAlocador:
    movq $12, %rax
    syscall 
    movq %rax, topoInicialHeap
    ret

