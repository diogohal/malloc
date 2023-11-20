#include <stdio.h>
#include "malloc.h"

int main (long int argc, char** argv) {
  void *a, *b, *c;

  iniciaAlocador();               // Impressão esperada
  imprimeMapa();                  // <vazio>

  a = (void *) alocaMem(10);
  imprimeMapa();                  // ################**********
  b = (void *) alocaMem(4);
  imprimeMapa();                  // ################**********##############****
  liberaMem(a);
  imprimeMapa();                  // ################----------##############****
  liberaMem(b);                   // ################----------------------------
                                  // ou
                                  // <vazio>
  imprimeMapa();
  c = (void *) alocaMem(15);
  imprimeMapa();
  finalizaAlocador();
}
