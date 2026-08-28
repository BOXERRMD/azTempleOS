

Bool makeFont(){
  // make a custom font
  U64 default_font[256];
  MemCpy(default_font, text.font, FONT_SIZE);

  ExeFile("::/Demo/Graphics/FontEd");

  "Do you want save your font ?\n";

  if (!(YorN)){
    MemCpy(text.font, default_font, FONT_SIZE);
    return FALSE;
  }

  U8 *buffer = GetStr("Write the filename : ");

  while (StrLen(buffer) == 0){
    PrintErr("Filename : a filename cannot be empty !\n\n");
    Free(buffer);
    buffer = GetStr("Write the filename : ");
  }

  saveCustomFont(buffer);
  MemCpy(text.font, default_font, FONT_SIZE);
  return TRUE;
}
