Bool parseOneValue(U8* buffer, U8* bufferSKM, U64 ibufferSKM, U8* code, U64 icode){  
  /* parse a single key code*/

  if (ibufferSKM >= MAX_BUFFER_SKM){ 
    // if no more space in ufferSKM to store key
    PrintErr("Keymap can't store more than 4 key code !\nLINE : %s\n", buffer);
    return FALSE;
  }
  else 
  if (icode==0) {
    // if the line is ";;"
    bufferSKM[ibufferSKM] = 0;
  }
  else {
    // Parse the code

    if (ibufferSKM > 1 && icode == 1 && StrCmp(code, ".") == 0){
      bufferSKM[ibufferSKM] = bufferSKM[1];
      return TRUE;
    }

    if (!(isCorrectFormatNumber(code))){
      PrintErr("\"%s\" is not base 10 or 16 !\n", code);
      return FALSE;
    }

    I64 conversion = Str2I64(code);

    if (!(isU8(conversion))){

      PrintErr("\"%s\" is not a valide key code ! (0-255)\nLINE : %s\n", code, buffer);
      return FALSE;

    }
    else {
      bufferSKM[ibufferSKM] = conversion(U8); // ... yes I know
    }
  } // end else base comparator
  return TRUE;
}




