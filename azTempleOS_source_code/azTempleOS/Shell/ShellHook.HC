/*
Hook function to get ALT+TAB
*/


CKeyDevEntry *shellKeyDevEntry = NULL;

Bool ShellHookGetKey(I64 ch, I64 sc){
  // Hook entry for shell completion

  if (sc.u8[0] == SC_TAB){
    //"Is tabulation !";
  }  

  return FALSE;
}


Bool ShellPutS(U8 *){
  // obligate function to KeyDevAdd
  return FALSE;
}


// Remove hook if existing (reset to remove bugs)
if (shellKeyDevEntry != NULL)
  KeyDevRem(shellKeyDevEntry);


KeyDevAdd(&ShellHookGetKey, &ShellPutS, 0x1);
