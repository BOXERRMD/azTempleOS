/*
Functions in the  file check if a string is hexa or decimal numbrer
*/

Bool isHexa(U8 *buffer){
// check if the containt buffer is a hexa number
  I64 len_buffer = StrLen(buffer);

  if (len_buffer < 3) return FALSE; // if is only 0x

  // if the begining is "0x" or "0X"
  if (buffer[0] != '0' || ToUpper(buffer[1]) != 'X') return FALSE;

  U64 i = 2;
  while (i<len_buffer){

    if ((buffer[i] >= '0' && buffer[i] <= '9') || 
        (buffer[i] >= 'A' && buffer[i] <= 'Z') || 
        (buffer[i] >= 'a' && buffer[i] <= 'z')){

      i++;

    }
    else return FALSE;

  }
  return TRUE;
}

Bool isDecimal(U8 *buffer){
// check if the contain buffer is a decimal number

  I64 len_buffer = StrLen(buffer);

  if (len_buffer == 0) return FALSE;

  U64 i = 0;
  while (i<len_buffer){

    if (buffer[i] < '0' || buffer[i] > '9') return FALSE;
    i++;

  }
  return TRUE;
}

Bool isU8(I64 value){

  if (value >= 0 && value <= 255) return TRUE;

  return FALSE;
}


Bool isCorrectFormatNumber(U8* code){

  if (isHexa(code)) return TRUE;
  if (isDecimal(code)) return TRUE;
  return FALSE;
}









