/*
Contain functions to parse a single line of a kbd layout
*/


Bool parseLineLayout(U8 *buffer, SingleKeyMap *skm){
// Parse a kbd layout line and return a pointer of SingleKeyMap class (in kbdData.HC.Z)
// return 0 if an error was encountred
  // store temporary all keymap to put in skm
  U8 bufferSKM[5];
  MemSetU8(bufferSKM, 0, 5);

  U8 code[21]; // store a part of the to check if is an hexa or decimal value 
  code[0] = '\0';  

  I64 len_buffer = StrLen(buffer);

  U64 ibufferSKM = 0;
  U64 icode = 0;

  U64 i = 0;
  Bool break_loop = FALSE; // set to TRUE if got an error in the code

  while (i<len_buffer && !(break_loop)){

    switch (buffer[i]){

      case ';':

        if (ibufferSKM >= MAX_BUFFER_SKM){ 
          // if no more space in ufferSKM to store key
          PrintErr("Keymap can't store more than 4 key code !\nLINE : %s\n", buffer);
          break_loop = TRUE;
        }
        else if (icode==0) {
          // if the line is ";;"
          bufferSKM[ibufferSKM] = 0;
          ibufferSKM++;
        }
        else {
          // Parse the code
          Bool is_parsed_value = parseOneValue(buffer, bufferSKM, ibufferSKM, code, icode);

          if (!(is_parsed_value)) break_loop = TRUE;
          code[0] = '\0';
          icode = 0;
          ibufferSKM++;
        }
        break;

      case ' ': // space is omited
        break;
      
      case '/': // omited comment
        i = len_buffer;
        break;

      default:
        if (icode >= MAX_CODE-2) {
          PrintErr("Key code length can't be more than %d !\nLINE : %s\n", MAX_CODE-2, buffer);
          break_loop = TRUE;
        }
        else {
          code[icode] = buffer[i];
          icode++;
          code[icode] = '\0'; // set the new endline
        }
        break;

    }

    i++;
  }

  if (break_loop) {
    Free(skm);
    return FALSE;
  }

  skm->scancode = bufferSKM[0];
  skm->normal = bufferSKM[1];
  skm->shift = bufferSKM[2];
  skm->alt = bufferSKM[3];
  skm->control = bufferSKM[4];

  return TRUE;
}





