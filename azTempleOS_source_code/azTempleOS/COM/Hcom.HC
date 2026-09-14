
#define COM1 0x3F8
#define RBR 0 // Read (DLAB=0)
#define THR 0 // Write (DLAB=0)
#define DLL 0 // Write (DLAB=1)
#define IER 1 // (DLAB=0)
#define DLM 1 // (DLAB=1)
#define FCR 2 // Write
#define LCR 3
#define MCR 4
#define LSR 5


// HCOM protocol
#define PING        0x01
#define SENDCHAR    0x02
#define SENDLINE    0x03
#define SENDSTRING  0x04
#define SIZE        0x05


// Base functions to interact with COM serial ports

U0 ComWrite(U16 base, U8 b, I64 timeout = 5){

  CDate goal = Now() + (CDATE_FREQ * timeout);

  // wait transmission register empty
  while (!(InU8(base + LSR) & 0x20)){
    if (goal - Now() < 0){
      PrintWarn("COM %d : Write byte %d timeout exceeded !\n");
    }
    else Yield;
  }
  OutU8(base + THR, b);
}

I64 ComRead(U16 base, I64 timeout = 5){
  /*
  read an octet (wait a value)
  */

  CDate goal = Now() + (CDATE_FREQ * timeout);


  // wait data
  while (!(InU8(base + LSR) & 0x01)){
    if (goal - Now() < 0){
      PrintWarn("COM %d : Read byte timeout exceeded !\n", base);
      return -1;
    }
    else Yield;
  }
  return InU8(base + RBR);
}

I64 ComReadNW(U16 base){
  /*
  read an octet instantly (no wait)
  */

  if (InU8(base + LSR) & 0x01){
    return InU8(base + RBR);
  }
  return -1; // nothing available
}

U0 ComFlushOut(U16 base){
  /*
  Flush all values in FIFO output list
  */

  OutU8(base + FCR, 0xC4);
}

U0 ComFlushIn(U16 base){
  /*
  Flush all values in FIFO input list
  */

  OutU8(base + FCR, 0xC2); 
}

U0 ComReadLine(U16 base, U8* buffer, I64 len_buffer, I64 timeout = 5){
  /*
  read a line until reach \n or the size limit buffer (wait values)
  */

  I64 i = 0;
  U64 char = ComRead(base, timeout);
  while (i < len_buffer-2 && char != '\n' && char != -1){

    if (char != '\r'){
      buffer[i] = char;
      i++;
    }
    char = ComRead(base, timeout);
  }
  buffer[i] = '\n';
  buffer[i+1] = '\0';
  if (char == -1){
      PrintErr("COM %d : Read line timeout exceeded !\n");
  }
}

U0 ComWriteLine(U16 base, U8* value, I64 timeout = 5){
  /*
  write a line in the serial port "base"
  */

  I64 i = 0;
  while (value[i] != '\n'){

    ComWrite(base, value[i], timeout);
    i++;

  }
  ComWrite(base, '\n', timeout); // send the end line
}

U0 ComReadString(U16 base, U8* buffer, I64 len_buffer, I64 timeout = 5){
  /*
  Read a string in the serial port "base"
  */

  I64 i = 0;
  U64 char = ComRead(base, timeout);
  while (i < len_buffer-1 && char != '\0' && char != -1){

    buffer[i] = char;
    i++;
    char = ComRead(base, timeout);
  }
  buffer[i] = '\0';
  if (char == -1){
      PrintErr("COM %d : Read string timeout exceeded !\n");
  }
}

U0 ComWriteString(U16 base, U8* value, I64 timeout = 5){
  /*
  Write a string in the serial port "base"
  */  

  I64 i = 0;
  while (value[i] != '\0'){

    ComWrite(base, value[i], timeout);
    i++;

  }
  ComWrite(base, '\0', timeout);
}


U0 ComInit(U16 base){

  // disbale interrupt
  OutU8(base + IER, 0x00);

  // Set DLAB=1 to access divisor latches
  OutU8(base + LCR, 0x80);

  // Divisor for 115200 (classic pc) : 115200/115200 = 1
  OutU8(base + DLL, 0x01);
  OutU8(base + DLM, 0x00);

  // 8n1 and DLAB=0
  OutU8(base + LCR, 0x03);

  // Enable FIFO, clear RX/TX, trigger level = 14 bytes (0XC7 is common)
  OutU8(base + FCR, 0xC7);

  // Modem control : DTR + RTS + OUT2 (often used; OUT2 matters mainly for IRQ setups)
  OutU8(base + MCR, 0x0B);

  InU8(base + LSR);
  InU8(base + RBR);
}

ComInit(COM1);