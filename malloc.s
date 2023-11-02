.section .data
    topoInicialHeap: .quad 0
.section .text
.globl _start
_start:

    # Obtém o valor original do topo da heap
    call topoHeap
    movq %rax, topoInicialHeap
    
    # Testes
    movq $100, %rdi
    call alocaMem
    movq %rax, %r8

    movq $200, %rdi
    call alocaMem
    movq %rax, %r9

    movq $300, %rdi
    call alocaMem
    movq %rax, %r10

    movq %r8, %rdi
    call liberaMem

    movq %r9, %rdi
    call liberaMem

    movq $350, %rdi
    call alocaMem
    movq %rax, %r13

    
    # Desaloca o espaço de memória alocado
    call finalizaAlocador
    call topoHeap

    # Sai do programa
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
# --------------------------------------------------

# Função que obtém o endereço atual do topo da heap
# --------------------------------------------------
topoHeap:
    movq $12, %rax
    movq $0, %rdi
    syscall 
    ret
# --------------------------------------------------

# Função que restaura o valor original da heap
# --------------------------------------------------
finalizaAlocador:
    movq $12, %rax
    movq topoInicialHeap, %rdi
    syscall
    ret
# --------------------------------------------------


# Função que aloca n bytes de memória na heap
# Variáveis se não tiver blocos livres:
# %rdi = quantidade de bytes a ser alocado
# %rax = posição do topo corrente da pilha
# %rbx = %rdi + 16 das variáveis de controle ocupado e tamanho
# retorno = %rax
# --------------------------------------------------
alocaMem:
    # Se tiver blocos livres, aloca esse espaço :)
    pushq %rdi
    call procuraBlocoLivre
    popq %rdi
    cmpq $0, %rax
    jne alocaBlocoLivre

    # Define o valor de %rax
    pushq %rdi # salva o valor de rdi na pilha
    call topoHeap
    popq %rdi # recupera o valor de rdi da pilha
    movq %rax, %rbx

    # Define o valor de %rbx
    addq %rdi, %rbx 
    addq $16, %rbx

    # Aloca um novo bloco na heap
    pushq %rdi # salva o valor de rdi na pilha
    pushq %rax # salva o valor de rax na pilha
    movq $12, %rax
    movq %rbx, %rdi
    syscall
    popq %rax # recupera o valor de rax da pilha
    popq %rdi # recupera o valor de rdi da pilha

    # Define os valores das variáveis de controle
    movq $1, (%rax) # bloco ocupado
    movq %rax, %rcx
    addq $8, %rcx
    movq %rdi, (%rcx) # tamanho do bloco
    ret
# --------------------------------------------------

# Função que procura um bloco na heap livre
# %rdi = quantidade de bytes necessários
# %rax = variável iterativa topoInicialHeap até topo atual
# %rbx = auxiliar
# %rcx = topo atual da heap
# retorno %rax = endereço do bloco livre
# --------------------------------------------------
procuraBlocoLivre:
    pushq %rdi # salva o valor de rdi na pilha
    call topoHeap
    popq %rdi # recupera o valor de rdi da pilha
    movq %rax, %rcx
    movq topoInicialHeap, %rax

# Loop que procura blocos livres na heap
loop_ProcuraBlocoLivre:
    # Se ultrapassou o topoInicialHeap
    cmpq %rcx, %rax
    jge fimLoopNaoAchou_ProcuraBlocoLivre
    # Se bloco está ocupado
    cmpq $1, (%rax)
    je loopOcupado_ProcuraBlocoLivre
    # Se bloco é menor
    addq $8, %rax
    cmpq %rdi, (%rax)
    movq (%rax), %rdx
    jl loopEspacoMenor_ProcuraBlocoLivre
    # Senao, achou
    jmp fimLoopAchou_ProcuraBlocoLivre

# Se estiver ocupado, verifica qual o tamanho do bloco atual e pula para o próximo
loopOcupado_ProcuraBlocoLivre:
    addq $8, %rax
    movq (%rax), %rbx
    addq $8, %rax # pula a variável de controle
    addq %rbx, %rax
    jmp loop_ProcuraBlocoLivre

# Se o espaço do bloco for menor que o necessário, pula para o próximo bloco
loopEspacoMenor_ProcuraBlocoLivre:
    movq (%rax), %rbx
    addq $8, %rax # pula a variável de controle
    addq %rbx, %rax
    jmp loop_ProcuraBlocoLivre

# Se não achou bloco livre, retorna -1
fimLoopNaoAchou_ProcuraBlocoLivre:
    movq $0, %rax
    ret

# Achou bloco livre, retorna o endereço de memória
fimLoopAchou_ProcuraBlocoLivre:
    subq $8, %rax
    ret
# --------------------------------------------------

# Função que aloca um bloco livre já existente
# rax = endereço inicial do bloco livre
# --------------------------------------------------
alocaBlocoLivre:
    movq $1, (%rax)
    ret
# --------------------------------------------------

# Função que libera um bloco de memória
# rdi = endereço do bloco de memória
# --------------------------------------------------
liberaMem:
    movq $0, (%rdi)
    ret
