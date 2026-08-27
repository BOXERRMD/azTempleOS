//0 no nothing
U0 Song()
{
  Fs->task_end_cb=&SndTaskEndCB;
  MusicSettingsRst;
  music.tempo= 4.846;
  music.stacatto_factor= 0.660;
  try {
    while (!ScanKey) {
	Play("4eEEGGFFAA5CCCCCCCC");
	Play("CCCCCCCCC4BAFG");
    }
  } catch
    PutExcept;
  Snd;
}

Song;
