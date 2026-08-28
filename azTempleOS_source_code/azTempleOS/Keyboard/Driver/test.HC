#include "LoadKBD"

I64 kmc = 256;
SingleKeyMap **p = CAlloc(sizeof(SingleKeyMap*)*kmc);

"RESULT : %d\n",changeKBD("French.KBD", p, kmc);

I64 i = 0;
while (i<kmc){

  if (p[i] != NULL){
    "%d,%c,%c,%c,%c\n",p[i]->scancode, 
    p[i]->normal, p[i]->shift, p[i]->alt, p[i]->control;
  }
  i++;
}
Free(p);