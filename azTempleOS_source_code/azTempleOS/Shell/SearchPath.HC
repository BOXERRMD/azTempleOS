#define MAX_SPIC_PATH 300 // don't include terminator zero
#define LINE_SIZE 1000    // don't include terminator zero

U0 ShellEnterKey();

class spic{ // for "shell path input completion"

  U8* line;
  I64 line_size;
  I64 pos, i_endline;

  U8 dir[MAX_SPIC_PATH+1];
  U8 filename[CDIR_FILENAME_LEN];
  I64 i_dir, i_filename;

  //Bool is_path;

};

// set global spic class and init data
spic* shell_spic = MAlloc(sizeof(spic));
shell_spic->line = MAlloc(sizeof(U8)*LINE_SIZE+1);
shell_spic->line[0] = '\0';
shell_spic->line_size = LINE_SIZE+1;
shell_spic->pos = 0;
shell_spic->i_endline = 0;
shell_spic->dir[0] = '\0';
shell_spic->filename[0] = '\0';
shell_spic->i_dir = 0;
shell_spic->i_filename = 0;
//shell_spic->is_path = FALSE;



U0 PutKeyInBuffer(I64 ch){
  // Put the key pressed in spic class.
  // If the filename or directory is too long, a warning is triggered in Adam task.


  if (ch != '/'){
    // add the caracter to the filename for a futur completion
    if (shell_spic->i_filename < CDIR_FILENAME_LEN){

      shell_spic->filename[shell_spic->i_filename] = ch;
      shell_spic->i_filename++;
      shell_spic->filename[shell_spic->i_filename] = '\0';
    }
    else{
      Adam("PrintWarn(\"Shell completion : filename too long to complete !\nPlease, use <= %d caracter for file name.\n\")", MAX_SPIC_PATH);
      return;
    }
  }
  else{
    // if the user add a (sub)directory before asking a completion
    if ((StrLen(shell_spic->dir) + StrLen(shell_spic->filename)) < CDIR_FILENAME_LEN){

      CatPrint(shell_spic->dir, "%s/", shell_spic->filename);
      shell_spic->filename[0] = '\0';
      shell_spic->i_dir += shell_spic->i_filename;
      shell_spic->i_filename = 0;
    }
    else{
      Adam("PrintWarn(\"Shell completion : path too long to complete !\nPlease, use <= %d caracter for path.\")", MAX_SPIC_PATH);
      return;
    }
  }
}


I64 FindStartPath(I64 ident_start_path = -2, I64 preview_ch = -1){
  // Find the begining of the path at the cursor position.
  // return an ident on shell_spic->line.
  // if the returned value is = -1, he not found a path

  I64 i_start_path;

  if (ident_start_path != -2) i_start_path = ident_start_path;
  else i_start_path = shell_spic->pos-1;

  while (i_start_path >= 0){
    Yield;
    "I_START_PATH : %d\n", i_start_path;
    
    switch (shell_spic->line[i_start_path]){

      case '"':
        return i_start_path;
      case '/':
        return FindStartPath(i_start_path-1, '/');
      case ':':
        if (preview_ch == ':') return i_start_path;
        return FindStartPath(i_start_path-1, ':');
      case '.':
        if (preview_ch == '/') return i_start_path;
        break;
      case ' ':
        
        switch (preview_ch){

          case '/': return i_start_path;
          case '.': return i_start_path;
        }
    }
    i_start_path--;
  }
  return i_start_path;
}


U0 ShellKeyBuffer(I64 ch, Bool inser){
  // handler called by $LK,"ShellHookGetKey",A="FI:/azTempleOS/Shell/ShellHook.HC.Z"$() for each caracter pressed

  if (shell_spic->i_endline < LINE_SIZE){

    if (shell_spic->pos == shell_spic->i_endline){
      shell_spic->line[shell_spic->pos] = ch;
      shell_spic->line[shell_spic->pos+1] = '\0';

    }
    // if the current cursor position is not at the end of the line
    else if (shell_spic->pos < shell_spic->i_endline){

      U64 ch_tmp = shell_spic->line[shell_spic->pos], ch_tmptwo;
      I64 pos_tmp = shell_spic->pos;

      if (inser) shell_spic->line[pos_tmp] = ch; // is INSER is active, replace the current caracter with the new one
      else {
        // right shift all caracters after the current cursor pos for the new caracter
        while (pos_tmp != shell_spic->i_endline+1){
          ch_tmptwo = shell_spic->line[pos_tmp+1];
          shell_spic->line[pos_tmp+1] = ch_tmp;
          ch_tmp = ch_tmptwo;
          pos_tmp++;
        }
        shell_spic->line[shell_spic->pos] = ch; // place the caracter in current cursor position
      }
    }
    shell_spic->pos++;
    shell_spic->i_endline++;

  }
  //"%s\n", shell_spic->line;
}


U0 ShellBackOrForward(I64 sc){
  // handler called by $LK,"ShellHookGetKey",A="FI:/azTempleOS/Shell/ShellHook.HC.Z"$() if the cursor is step back/forward
  // "sc" is only the key scancode (sc.u8[0])

  if (sc == SC_CURSOR_LEFT && shell_spic->pos > 0)
    shell_spic->pos--;

  if (sc == SC_CURSOR_RIGHT && shell_spic->pos < shell_spic->i_endline)
    shell_spic->pos++;
  
}


U0 ShellUpOrDown(I64 sc){
  // handler called by $LK,"ShellHookGetKey",A="FI:/azTempleOS/Shell/ShellHook.HC.Z"$() if the cursor is step up/down
  // "sc" is only the key scancode (sc.u8[0])

  ShellEnterKey;
}


U0 ShellEnterKey(){
  // handler called by $LK,"ShellHookGetKey",A="FI:/azTempleOS/Shell/ShellHook.HC.Z"$() each time the ENTER key is pressed

  // reset all data for the new line path completion available
  shell_spic->line[0] = '\0';
  shell_spic->pos = 0;
  shell_spic->i_endline = 0;
  shell_spic->dir[0] = '\0';
  shell_spic->i_dir = 0;
  shell_spic->filename[0] = '\0';
  shell_spic->i_filename = 0;
}


U8* ShellFindFile(CDirEntry* search){
  // Search if a file is a candidate for the completion
  // the result must be Free after be used !

  I64 nbr_file = 0;
  CDirEntry* count_tmp = search;
  while (count_tmp != NULL){
    nbr_file++;
    count_tmp = count_tmp->next;
  }

  if (nbr_file == 0) return NULL;
  
  U8* common_pattern = MAlloc(CDIR_FILENAME_LEN);
  common_pattern[0] = '\0';

  CDirEntry* tmp = search;
  I64 i;
  while (tmp != NULL){

    if (!(StrCmp(tmp->name, ".")) || !(StrCmp(tmp->name, ".."))){
      //"SKIP : %s\n", tmp->name;
      tmp = tmp ->next;
    }
    else{

      if (!(StrNCmp(tmp->name, shell_spic->filename, shell_spic->i_filename+1))){
        if (StrLen(common_pattern) == 0){
          CatPrint(common_pattern, "%s", tmp->name);
        }
        else{
          i = 0;
          while (i<StrLen(common_pattern) && i<StrLen(tmp->name)){
            if (tmp->name[i] != common_pattern[i]){
              common_pattern[i] = '\0';
              break;
            }
            i++;
          }
        }

      }
    }
  }
  
  return common_pattern;
}


U0 ShellCompletion(){
  // handler called by $LK,"ShellHookGetKey",A="FI:/azTempleOS/Shell/ShellHook.HC.Z"$() to complete path.

  I64 start_path = FindStartPath;
  I64 end_path = shell_spic->pos;
  I64 len_path = ((end_path+1) - (start_path+1))+1;

  I64 i;
  for (i = 0; i<len_path; i++){
    PutKeyInBuffer(shell_spic->line[start_path+i]);
  }
  U8 buffer[MAX_SPIC_PATH+2];
  buffer[0] = '\0';
  CatPrint(buffer, "%s%s*", shell_spic->dir, shell_spic->filename);
  //DirEntryDel(search);

  CDirEntry *search = FilesFind(buffer);

  if (search == NULL){
    AdamErr("DirContextNew return NULL in FilesFind function.");
    return;
  }

  ShellFindFile(search);

}






