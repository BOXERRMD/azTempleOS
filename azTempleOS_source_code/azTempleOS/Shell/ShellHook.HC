/*
Hook function to get ALT+TAB
*/


CKeyDevEntry *shellKeyDevEntry = NULL;


Bool ShellHookGetKey(I64, I64 sc){
  // Hook entry for shell completion

  I64 scancode = sc.u8[0];

  //if (sc&SCF_CTRL || sc&SCF_SHIFT) return FALSE; // completion work only with ALT

  if (scancode == SC_TAB && sc&SCF_ALT){

    if (sc&SCF_KEY_DESC)
      KeyDescSet("Shell path completion");

    else{
      ShellCompletion;
      return TRUE;
    }
  }

  return FALSE;
}


Bool ShellPutS(U8 *){
  // obligate function to KeyDevAdd
  return FALSE;
}

if (shellKeyDevEntry == NULL)
  shellKeyDevEntry = KeyDevAdd(&ShellHookGetKey, &ShellPutS, 0x1);
