
Bool saveCustomFont(U8 *filename){

  U8 *path = StrPrint(NULL, "::/azTempleOS/Keyboard/Fonts/CustomFonts/%s", filename);

  
  if (StrLen(path) > STR_LEN){
    PrintErr("Path : \"%s\" too long !\n", path);
    return FALSE;
  }

  if (FileFind(path)){
    PrintWarn("File font : \"%s\" already existing !\nDo you want rewrite-it ?\n", filename);
    if (!(YorN)) return FALSE;
  }
  "PATH : %s\n", path;
  FileWrite(path, text.font, FONT_SIZE);

  return TRUE;
}

Bool loadCustomFont(U8 *filename){

  U8 *path = StrPrint(NULL, "::/azTempleOS/Keyboard/Fonts/CustomFonts/%s", filename);

  if (StrLen(path) > STR_LEN){
    PrintErr("Path : \"%s\" too long !\n", path);
    return FALSE;
  }

  if (!(FileFind(path))){
    PrintErr("File font : \"%s\" not found !\n", filename);
    return FALSE;
  }

  I64 size;
  U64 *new_font = FileRead(path, &size);

  if (new_font){
    if (size == FONT_SIZE){
      MemCpy(text.font, new_font, FONT_SIZE);
    }
    else PrintErr("FILESIZE is not %d oct", FONT_SIZE);
    Free(new_font);
  }
  else PrintErr("FILEREAD ERROR !\n");

}




