
#define PING        0x01
#define SENDCHAR    0x02
#define SENDLINE    0x03
#define SENDSTRING  0x04
#define SIZE        0x05


U0 SendSizeCOM(I64 size_str, U16 base = COM1, I64 timeout = 5){
    // Send data after the protocol

    ComWrite(base, SIZE, timeout);

    I64 i;
    for (i = 0; i<8; i++){
        //"u8[%d] = %d\n",i,size_str.u8[i];
        ComWrite(base, size_str.u8[i], timeout);
    }
}

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
    // Send lines (ended by \n) to base COM

    I64 len_line = StrLen(line);


    if (len_line == 0) return; // If the line is empty, send nothing


    U8* buffer = MAlloc(len_line*sizeof(U8)); // \0 is not obligatory at the end of the string
    U64 i_line = 0, i_buffer = 0;
    U64 char = line[i_line];


    while (i_line < len_line){

        if (char == '\n'){

            buffer[i_buffer] = char;

            ComWrite(base, SENDLINE, timeout);
            SendSizeCOM((i_buffer(I64))+1, base, timeout);
            ComWriteLine(base, buffer, timeout);

            i_buffer = 0;
            i_line++;
        }
        else {

            buffer[i_buffer] = line[i_line];
            i_line++;
            i_buffer++;
        }
        char = line[i_line];
    }
    Free(buffer);
}

U0 SendStringCOM(U8* str, U16 base = COM1, I64 timeout = 5){
    // Send a string (ended by \0) to base COM

    ComWrite(base, SENDSTRING, timeout);
    SendSizeCOM(StrLen(str), base, timeout);
    ComWriteString(base, str, timeout);
}








