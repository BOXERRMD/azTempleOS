/*
This file can be imported to change the keyboard mapping
*/


Bool changeKBD(U8 *filename, SingleKeyMap **keymaps, I64 keymaps_lenght){
  // Make all keymap with the file given.
  // This function must be call by $LK,"loadKBD",A="FA:::/azTempleOS/Keyboard/Driver/LoadKBD.HC.Z,fnc_loadKBD"$() function

  U8 *path = StrPrint(NULL, "::/azTempleOS/Keyboard/Layouts/%s", filename);

  if (!(FileFind(path))){
    PrintErr("File : \"%s\" not found !\n", path);
    return FALSE;
  }

  U8 *file = FileRead(path);
  U64 len_file = StrLen(file);

  Free(path); 

  U8 line[100]; // store each line to be parsed
  line[0] = '\0';
  U64 iline = 0;

  I64 keymaps_count = 0;
  U64 i = 0;
  while (i<len_file){

    SingleKeyMap *skm = MAlloc(sizeof(SingleKeyMap));

    if (skm == NULL){
      PrintErr("MAlloc error : SingleKeyMap class can't be malloced !\n");
      Free(file);
      return FALSE;
    }

    while (i<len_file && file[i] != '\n'){
      line[iline] = file[i];
      iline++;
      line[iline] = '\0';
      i++;
    }
    if (StrLen(line) != 0 && line[0] != '/'){ // line[0] != '/' skip comment who start at the begining of the line.
      Bool result = parseLineLayout(line, skm);
      if (!(result)){
        Free(skm);
        Free(file);
        return FALSE;
      }
      if (skm->scancode != 0){
        if (keymaps_count > keymaps_lenght){
          PrintErr("Too more line to parse in %s file !\nEnd parsing to the line : %s\n", filename, line);
          Free(skm);
          Free(file);
          return FALSE;
        }
        else{
        keymaps[skm->scancode] = skm;
        keymaps_count++;
        }
      }
      else {
      PrintWarn("Scancode 0 cannot be mapped !\n");
      Free(skm);
      }
    }
    i++;
    iline = 0;
    line[iline] = '\0';
  }

  Free(file);
  return TRUE;

}


U0 FreeTmpKBD(SingleKeyMap** tmp){
  // Free the temporary keymaps if an error occured.

  if (tmp == NULL) return;

  I64 i = 0;
  while (i < MAX_SCANCODE){
    if (tmp[i] != NULL) Free(tmp[i]);
    i++;
  }
  Free(tmp);
}


$AN,"loadKBD function",A="fnc_loadKBD"$ // do not delete this anchor !
public U0 loadKBD(U8 *filename, U8 *font_filename=NULL){
  // entry function to change the kbd mapping
  // take a .KBD filename (not absolute path)
  // Optionaly take a font filename to load a new font with new keymaps

  I64 kmc = MAX_SCANCODE;
  SingleKeyMap **p = CAlloc(sizeof(SingleKeyMap*)*kmc);

  Bool result = changeKBD(filename, p, kmc);

  if (result){
    freeCustomKbd;
    setCustomKbd(p);
    "$MA+BK,"RESET KEYBOARD",LM="freeCustomKbd();\n"$ (use $FG,4$freeCustomKbd()$FG$ to free keymaps)\n";
  }
  else{
    FreeTmpKBD(p);
  }

  if (font_filename){
    loadCustomFont(font_filename);
  }

}




















