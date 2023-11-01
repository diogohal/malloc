.section .data
    topoInicialHeap: .quad 0
.section .text
.globl _start
_start:

# Obtém o valor original do topo da heap
# -------------------------------------------------
    call topoHeap
    movq %rax, topoInicialHeap
    
# Aloca um espaço de 100 bytes na heap
# -------------------------------------------------
    movq $100, %rdi
    call alocaMem
    call topoHeap
    
# Desaloca o espaço de memória alocado
# -------------------------------------------------
    call finalizaAlocador
    call topoHeap

# Sai do programa
# -------------------------------------------------
    movq $60, %rax
    movq $0, %rdi
    syscall


# Função que obtém o endereço atual do topo da heap 
# e armazena em topoInicialHeap
# -------------------------------------------------
iniciaAlocador:
    movq $12, %rax
    movq $0, %rdi
    syscall
    movq %rax, topoInicialHeap
    ret

# Função que obtém o endereço atual do topo da heap
# --------------------------------------------------
topoHeap:
    movq $12, %rax
    movq $0, %rdi
    syscall 
    ret

# Função que restaura o valor original da heap
# --------------------------------------------------
finalizaAlocador:
    movq $12, %rax
    movq topoInicialHeap, %rdi
    syscall
    ret

# Função que aloca n bytes de memória na heap
# --------------------------------------------------
alocaMem:
    pushq %rdi # salva o valor de rdi na pilha
    call topoHeap
    popq %rdi # recupera o valor de rdi da pilha
    movq %rax, %rbx
    addq %rdi, %rbx # soma o valor passado como argumento com o valor atual do topo
    movq $12, %rax
    movq %rbx, %rdi
    syscall
    ret
