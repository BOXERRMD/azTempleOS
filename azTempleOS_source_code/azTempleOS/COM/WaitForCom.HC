
Bool enable_wait_protocol = FALSE;


U64 GetSizeString(U16 base = COM1){
    // Get the data size after recive

    U64 size = 0;
    I64 i;
    for (i=0; i<8; i++){
        size.u8[i] = ComRead(base, 1);
        "SIZE u8[%d] : %d\n", i, size.u8[i];
    }
    return size;
}



U8* GetStringCOM(U16 base = COM1){
    // Get a string from the host

    I64 protocol_size = ComRead(base);

    if (protocol_size != SIZE) return NULL;

    U64 size = GetSizeString(base)+1; // +1 for the \0 (not sended by the host)
    // +1 is a 'warning' if the host forget the end line marker
    "STRING SIZE : %d\n", size;

    if (size <= 0) return NULL;

    U8* buffer = MAlloc(size); // size is the number of bytes to recive

    U64 i = 0;
    while (i<size){
      buffer[i] = ComRead(base, 1);
      i++;
    }
    buffer[i] = '\0';

  return buffer;
}


U0 WaitForCOM(U16 base = COM1, I64 timeout = 5){
  // Wait for protocol

  I64 protocol = -1;

  enable_wait_protocol = TRUE;

  while (enable_wait_protocol){

    protocol = ComReadNW(base);

    switch (protocol){

      case -1: break;
      case PING:
        break;
      case SENDCHAR:
        break;
      case SENDLINE:
        break;
      case SENDSTRING:
        "GETSTRINGCOM...\n"
        "GET STRING : %s\n", GetStringCOM(base);
        break;
    }
    Yield;
  }
}