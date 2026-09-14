



U64 WaitSizeString(U16 base = COM1){
    // Wait for the data size after recive

    U64 size = 0;
    I64 i;
    for (i=0; i<8; i++){
        size.u8[i] = ComRead(base, 1);
    }
    return size;
}



U8* WaitStringCOM(U16 base = COM1){
    // Wait a string from the host

    

}