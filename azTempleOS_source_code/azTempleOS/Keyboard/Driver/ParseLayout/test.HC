//#include "parseLayoutImport.HC.Z"


U0 t(){
SingleKeyMap *p = MAlloc(sizeof(SingleKeyMap));


if (!(parseLineLayout("0x2;0xF1;.;0xff;128;", p))) "ERROR, return 1\n";
else{
"SCANCODE = %u\n", p->scancode;

"NORMAL = %u\n", p->normal;

"SHIFT = %u\n", p->shift;

"ALT = %u\n", p->alt;

"CONTROL = %u\n", p->control;

Free(p);
}
}