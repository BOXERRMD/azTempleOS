/*
Hook function to get ALT+TAB
*/


CKeyDevEntry *shellKeyDevEntry = NULL;

Bool ShellHookGetKey(I64 ch, I64 sc){
  // Hook entry for shell completion

  I64 scancode = sc.u8[0];

  if (sc&SCF_CTRL || sc&SCF_SHIFT) return FALSE; // completion work only with ALT

  if (scancode == SC_TAB && sc&SCF_ALT){

    if (sc&SCF_KEY_DESC)
      KeyDescSet("Shell path completion");

    else{
      ShellCompletion;
      return TRUE;
    }
  }
  else if (scancode == SC_CURSOR_LEFT || scancode == SC_CURSOR_RIGHT){
    ShellBackOrForward(scancode);
  }
  else if (scancode == SC_CURSOR_UP || scancode == SC_CURSOR_DOWN){
    ShellUpOrDown(scancode);
  }
  else if (scancode == SC_ENTER){
    ShellEnterKey;
  }
  //else ShellKeyBuffer(ch, sc&SCF_INS);

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
