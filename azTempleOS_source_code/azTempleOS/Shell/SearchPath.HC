
class shell_line{

  U8* line;
  I64 cursor;

};


class shell_path{

  U8* dir;
  U8* filename;

};

U0 ShellLineFree(shell_line* s){
 // Free a shell_line class

 if (s == NULL) return;

 Free(s->line);
 Free(s);
}

U0 ShellPathFree(shell_path* sp){
  // Free a shell_path class

  if (sp == NULL) return;

  Free(sp->dir);
  Free(sp->filename);
  Free(sp);
}

shell_line* ShellLine(){

  // Get the last line of a shell.

  CDoc *doc;
  CDocEntryBase *cur_entry;
  U8 *line;
  I64 cursor_col;

  doc = DocPut;

  if (doc == NULL) return NULL;

  if (doc->doc_signature != DOC_SIGNATURE_VAL) return NULL;


  cur_entry = doc->cur_entry;

  if (cur_entry == NULL) return NULL;

  if (cur_entry == doc) cur_entry = doc->head.last;

  if (cur_entry == NULL || cur_entry == doc) return NULL;

  if (cur_entry->type_u8 == DOCT_NEW_LINE ||
      cur_entry->type_u8 == DOCT_PMT){
    cur_entry = cur_entry->next;
    if (cur_entry == doc) return NULL;

    goto doscanline;
  }

  while (cur_entry != doc &&
         cur_entry->last != doc && 
         cur_entry->last->type_u8 != DOCT_NEW_LINE &&
         cur_entry->last->type_u8 != DOCT_PMT){
    cur_entry = cur_entry->last;
  }

  if (cur_entry == NULL || cur_entry == doc) return NULL;


  doscanline:

    line = DocScanLine(doc, cur_entry, &cursor_col, NULL);

    if (line == NULL){
      AdamErr("MAlloc error : current shell line can't be malloced !\n");
      return NULL;
    }

    shell_line* s = MAlloc(sizeof(shell_line));

    if (s == NULL){
      Free(line);
      AdamErr("MAlloc error : shell_line class can't be malloced !\n");
      return NULL;
    }

    s->line = line;
    s->cursor = cursor_col;

    return s;
}

I64 ShellFindPath(shell_line* s){
  // find the begining of the path and return an ident

  Bool find = FALSE, inquote = FALSE;
  U8* line = s->line;
  I64 i = s->cursor;
  I64 _end = s->cursor, start_path = 0;
  while (i>=0 && !(find)){

    if (line[i] == '"' && i == _end){
      inquote = TRUE;
    }
    else if (line[i] == '"' && i < _end){
      find = TRUE;
      start_path = i+1;
    }
    else if (!(inquote)){

      I64 sc;

      if (line[i] == ' ' || line[i] == ';' || line[i] == '(' || 
          line[i] == ',' || Char2ScanCode(line[i], 0) == SC_TAB){
        start_path = i+1;
        find = TRUE;
      }
    }
    i--;
  }

  if (i==-1) return start_path;
  if (!(find)) return -1;
  return start_path;

}


shell_path* ShellSplitDirFilename(shell_line* s, I64 start_path){
  // Return a shell_path class if he find a dir and a filename

  shell_path* sp = MAlloc(sizeof(shell_path));

  if (sp == NULL){
    AdamErr("MAlloc error : shell_path class can't be malloced !\n");
    return NULL;
  }

  I64 start_filename = s->cursor-1;

  while (start_filename>=start_path){

    if (s->line[start_filename] == '/' && start_filename<s->cursor){
      start_filename = start_filename+1;
      break;
    }
    start_filename--;
  }

  if (start_filename == -1) start_filename++;

  U8* dir = NULL;
  U8* filename = NULL;  

  if (start_filename > start_path){
    dir = MAlloc(sizeof(U8)*(start_filename - start_path)+1);
    if (dir == NULL){
      AdamErr("MAlloc error : path directory can't be malloced !\n");
      Free(sp);
      return NULL;
    }
    dir[0] = '\0';
  }
  if (start_filename < s->cursor){
    filename = MAlloc(sizeof(U8)*(s->cursor - start_filename)+1);
    if (filename == NULL){
      AdamErr("MAlloc error : filename can't be malloced !\n");
      Free(sp);
      Free(dir);
      return NULL;
    }
    filename[0] = '\0';
  }

  I64 i = start_path;

  if (dir != NULL){

    while (i<start_filename){
      dir[i-start_path] = s->line[i];
      i++;
    }
    dir[i-start_path] = '\0';
  }

  if (filename != NULL){

    i = start_filename;
    while (i<s->cursor){
      filename[i-start_filename] = s->line[i];
      i++;
    }
    filename[i-start_filename] = '\0';
  }

  sp->dir = dir;
  sp->filename = filename;

  return sp;
}


U8* ShellFileCompletion(shell_path* sp){
  // Find a file to complete the filename given by the user

  CDirEntry* files;
  U8* full_path;
  Bool full_path_malloced = TRUE;

  if (sp->dir != NULL && sp->filename != NULL)
    full_path = StrPrint(NULL, "%s%s*", sp->dir, sp->filename);

  else if (sp->dir != NULL){
    full_path = sp->dir;
    full_path_malloced = FALSE;
  }

  else
    full_path = StrPrint(NULL, "./%s*", sp->filename);

  if (!(IsSilent)) Silent(ON);

  files = FilesFind(full_path);

  if (IsSilent) Silent(OFF);

  if (files == NULL) return NULL;

  if (full_path_malloced)
    Free(full_path);

  U8* completion = MAlloc(CDIR_FILENAME_LEN);
  
  if (completion == NULL){
    AdamErr("MAlloc error : name completion can't be malloced !\n");
    DirEntryDel(files);
    return NULL;
  }

  completion[0] = '\0';
  CatPrint(completion, "%s", files->name);

  if (files->next != NULL){

    I64 i;
    files = files->next;
    while (files != NULL){
      i = 0;
      while (files->name[i] == completion[i] && i < StrLen(completion)){
        i++;
      }
      completion[i] = '\0';
      files = files->next;
    }
  }
  return completion;
}


U0 ShellCompletion(){
  // Complete the path if possible.
  // Trigger by ALT-TAB combo key

  shell_line* s = ShellLine;

  if (s == NULL) return;

  I64 start_path = ShellFindPath(s);

  if (start_path == -1){
    ShellLineFree(s);
    return;
  }

  shell_path* sp = ShellSplitDirFilename(s, start_path);

  if (sp == NULL){
    ShellLineFree(s);
    return;
  }

  //if (sp->dir != NULL) "DIR : %s\n", sp->dir;
  //if (sp->filename != NULL) "FILE : %s\n", sp->filename;

  U8* completion = ShellFileCompletion(sp);

  if (completion != NULL){

    I64 i = 0;
    while (completion[i] != '\0'){

      if (sp->filename != NULL){
        if (StrLen(sp->filename) <= i || completion[i] != sp->filename[i])
          PutKey(completion[i]);
      }
      else PutKey(completion[i]);
      i++;
    }
    Free(completion);
  }

  ShellLineFree(s);
  ShellPathFree(sp);
  
}






