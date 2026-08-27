
#define PING        0x01
#define SENDCHAR    0x02
#define SENDLINE    0x03
#define SENDSTRING  0x04

Bool PingCOM(U16 base = COM1, I64 timeout = 5){
    // Send to base COM the PING byte and wait to recive the exact PING byte

    ComFlushIn(base);
    ComFlushOut(base);

    ComWrite(base, PING);
    I64 rep = ComRead(base, timeout);

    return (rep == PING);
}

U0 SendCharCOM(U8 char, U16 base = COM1, I64 timeout = 5){
    // Send a single character to base COM

    ComWrite(base, SENDCHAR, timeout);
    ComWrite(base, char, timeout);
}

U0 SendLineCOM(U8* line, U16 base = COM1, I64 timeout = 5){
    // Send a line (ended by \n) to base COM

    ComWrite(base, SENDLINE, timeout);
    ComWriteLine(base, line, timeout);
}

U0 SendStringCOM(U8* str, U16 base = COM1, I64 timeout = 5){
    // Send a string (ended by \0) to base COM

    ComWrite(base, SENDSTRING, timeout);
    ComWriteString(base, str, timeout);
}








