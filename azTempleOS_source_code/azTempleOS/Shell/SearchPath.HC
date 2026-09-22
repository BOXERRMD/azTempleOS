
class shell_line{

  U8* line;
  I64 cursor;

};


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

  if (cur_entry == NULL || cur_entry == doc) return;


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
  while (i>=0){

    if (line[i] == '"' && i == _end){
      inquote = TRUE;
    }
    else if (line[i] == '"' && i < _end){
      find = TRUE;
      start_path = i+1;
    }
    else if (!(inquote)){

      if (line[i] == ' ' || Char2ScanCode(line[i], 0) == SC_TAB ||
          line[i] == ';' || line[i] == '(' || line[i] == ',')
        start_path = i+1;
        find = TRUE;
    }
    i++;
  }

  if (!(find)) return -1;
  return start_path;

}

U0 ShellCompletion(){

  shell_line* s = ShellLine;

  if (s == NULL) return;

  //U8* path = ShellFindPath(s);

}






