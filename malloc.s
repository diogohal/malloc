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

    movq $100, %rdi
    call alocaMem
    movq %rax, %r9

    movq $100, %rdi
    call alocaMem
    movq %rax, %r10

    movq %r8, %rdi
    call liberaMem

    movq %r10, %rdi
    call liberaMem

    movq %r9, %rdi
    call liberaMem

    movq $300, %rdi
    call alocaMem
    movq %rax, %r12


    # Desaloca o espaço de memória alocado
    call finalizaAlocador

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
    call fusaoBlocos
    ret
# --------------------------------------------------


# Função que faz a fusão de nós livres, se houver
# %rdi = endereço de memória do bloco liberado
# %rax = endereço do bloco da frente
# %rbx = o endereço do bloco de trás
# --------------------------------------------------
fusaoBlocos:
    movq topoInicialHeap, %rbx

# Loop para achar o bloco da esquerda
while_FusaoBlocos:
    cmpq %rbx, %rdi
    jle juncaoEsquerda # Se passar o endereço do parâmetro, o bloco anterior é o da esquerda
    movq %rbx, %rcx # Salva o bloco anterior
    addq $8, %rbx
    movq (%rbx), %rdx
    addq %rdx, %rbx
    addq $8, %rbx
    jmp while_FusaoBlocos

juncaoEsquerda:
    # Verifica se é possível fazer a junção
    cmpq %rdi, topoInicialHeap
    je juncaoDireita # Se o bloco da esquerda for o topo inicial, não existe junção
    movq %rcx, %rbx
    cmpq $1, (%rbx) 
    je juncaoDireita # Se o bloco da esquerda estiver ocupado, não faz a junção

    # Faz a junção com o bloco da esquerda
    addq $8, %rdi
    addq $8, %rbx
    movq (%rdi), %rdx
    addq %rdx, (%rbx)
    addq $16, (%rbx)
    subq $8, %rdi
    subq $8, %rbx

juncaoDireita:
    # Pega o valor do topo atual da heap
    pushq %rdi
    pushq %rax
    call topoHeap
    movq %rax, %rdx # rdx = topo atual da heap
    popq %rax
    popq %rdi
    
    # Verifica se é possível fazer a junção
    movq %rdi, %rax
    addq $16, %rax
    addq $8, %rdi
    addq (%rdi), %rax
    cmpq %rax, %rdx
    je retorno # Se ultrapassar o topo da heap, não existe a direita
    cmpq $1, (%rax) 
    je retorno # Se o bloco da direita não estiver livre, pula para o retorno

    # Faz a junção com o bloco da direita
    addq $8, %rax
    addq $8, %rbx
    movq (%rax), %rdx
    addq %rdx, (%rbx)
    addq $(16), (%rbx)
    subq $8, %rbx
retorno:
    ret
# --------------------------------------------------
