#exe{Cd(__DIR__);};
#include "SearchPath"

#define STR_SIZE 50

U8 a[STR_SIZE] = "/azTempleOS/";

I64 i = 0;

while (a[i] != '\0'){

  ShellKeyBuffer(a[i], FALSE);
  i++;
}



ShellCompletion;

