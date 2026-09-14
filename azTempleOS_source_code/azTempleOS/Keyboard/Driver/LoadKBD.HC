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

  U8 line[100]; // store each line to be parsed
  line[0] = '\0';
  U64 iline = 0;

  I64 keymaps_count = 0;
  U64 i = 0;
  while (i<len_file){

    SingleKeyMap *skm = MAlloc(sizeof(SingleKeyMap));

    while (i<len_file && file[i] != '\n'){
      line[iline] = file[i];
      iline++;
      line[iline] = '\0';
      i++;
    }
    if (StrLen(line) != 0 && line[0] != '/'){ // line[0] != '/' skip comment who start at the begining of the line.
      Bool result = parseLineLayout(line, skm);
      if (!(result)) return FALSE;
      if (skm->scancode != 0){
        if (keymaps_count > keymaps_lenght){
          PrintErr("Too more line to parse in %s file !\nEnd parsing to the line : %s\n", filename, line);
          Free(skm);
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
  return TRUE;
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
    freeCustomKbd();
    setCustomKbd(p);
    "$MA+BK,"RESET KEYBOARD",LM="freeCustomKbd();\n"$\n";
  }
  else Free(p);

  if (font_filename){
    loadCustomFont(font_filename);
  }

}




















