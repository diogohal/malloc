.section .data
    topoInicialHeap: .quad 0
.section .text
.globl _start
_start:
    call alocaMem
    # movq topoInicialHeap, %rbx
    call iniciaAlocador
    movq topoInicialHeap, %rbx
    movq $60, %rax
    movq (%rbx), %rdi
    syscall

iniciaAlocador:
    movq $12, %rax
    movq $0, %rdi
    syscall 
    movq %rax, topoInicialHeap
    ret

alocaMem:
    movq $12, %rax
    movq $100, %rdi
    syscall
    ret
