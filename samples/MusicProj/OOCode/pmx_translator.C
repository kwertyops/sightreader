#include "pmx_translator.h"

const int MAX_CHARS_PER_LINE = 100;

PMX_Translator::PMX_Translator(Mus_Piece &Piece){

  int t_numer, t_denom;
  int ch_pos, ch_pos_p;
  int measures, events;
  char cmd[25]; // PMX command for a given event

  t_numer = Piece.getTNumer();
  t_denom = Piece.getTDenom();

  mtrnuml = t_numer;
  mtrdenl = denom_pmx(t_denom);

  Meter meter = Piece.getMeter();

  switch(meter){
    case NORMAL:       mtrnump = t_numer;
                       mtrdenp = t_denom;
                       break;

    case CUT_TIME:     mtrnump = 0;
                       mtrdenp = 5;
                       break;

    case COMMON_TIME:  mtrnump = 0;
                       mtrdenp = 6;
                       break;
    case BLIND:        mtrnump = 0;
                       mtrdenp = 0;
                       break;
    default:
  }

  isig = Piece.getKey();
  if(isig == 8) isig = 0;

  nv = noinst = 1; // A single instrument for now
  xmtrnum0 = 0; // No pick-up note for now

  num_lines = num_syst = num_pages = 0; // Init buffer size

  bool tied = false;
  int xtuplet = 0;

  ch_pos = 0;
  measures = events = 0;

  for(int i = 0; i < Piece.getNumBars(); i++){

    if(measures >= MAX_BARS_PER_SYSTEM ||
       events + Piece.getNumEvents(i) >= MAX_EVENTS_PER_SYSTEM){

      measures = events = 0;

      num_syst++;

      if(ch_pos == 0)
        strcpy(&buffer[num_lines - 1][ch_pos_p], " /");
      else {
        strcpy(&buffer[num_lines][ch_pos], "/");
        num_lines++;
        ch_pos = 0;
      }
      
    }

    for(int j = 0; j < Piece.getNumEvents(i); j++){

      pmx_command(Piece, i, j, cmd, tied, xtuplet);

      strcpy(&buffer[num_lines][ch_pos], cmd);
      ch_pos += strlen(cmd);

      if(ch_pos > MAX_CHARS_PER_LINE){
        buffer[num_lines][ch_pos] = '\0';
        num_lines++;
        ch_pos_p = ch_pos;
        ch_pos = 0;
      }
      else buffer[num_lines][ch_pos++] = ' ';

      events++;
    }

    if(ch_pos == 0){
      strcpy(&buffer[num_lines - 1][ch_pos_p], " |");
      ch_pos_p += 2;
    }
    else {
      strcpy(&buffer[num_lines][ch_pos], "| ");
      ch_pos += 2;
    }

    measures++;

  }

  num_syst++;
  if(ch_pos == 0)
    strcpy(&buffer[num_lines - 1][ch_pos_p], " /");
  else {
    strcpy(&buffer[num_lines][ch_pos], "/");
    num_lines++;
    ch_pos = 0;
  }

  num_pages = num_syst / MAX_SYSTEMS_PER_PAGE + 1;
  if(num_syst % MAX_SYSTEMS_PER_PAGE < MAX_SYSTEMS_PER_PAGE / 2
     && num_pages > 1)
    num_pages--;
}

void PMX_Translator::pmx_command(Mus_Piece &Piece, int i, int j, char &cmd[],
                                 bool &tied, int &xtuplet){

  int ch_pos = 0;
  int num_notes;

  if(tied){
    cmd[ch_pos++] = 't';
    cmd[ch_pos++] = ' ';
  }

  if(Piece.isNote(i, j))
    cmd[ch_pos++] = pmx_pitch(Piece.getMainPitch(i, j));
  else cmd[ch_pos++] = 'r';

  if(! xtuplet){
    cmd[ch_pos++] = itoa(pmx_duration(Piece.getBaseDur(i, j)));

    if(Piece.isDotted(i, j))
      cmd[ch_pos++] = 'd';
    if(Piece.isDoubleDotted(i, j))
      cmd[ch_pos++] = 'd';
  }

  if(Piece.isNote(i, j))
    cmd[ch_pos++] = Piece.getOctave(i, j, 0);

  if(Piece.isNote(i, j)){

    accidental = Piece.getAccidental(i, j);

    ch_pos += pmx_accidental(accidental, &cmd[ch_pos]);

    if((! xtuplet) && Piece.getXtuplet(i, j)){
      ch_pos += pmx_xtuplet(Piece.getXtuplet(i, j), &cmd[ch_pos]);
      xtuplet = atoi(cmd[ch_pos - 2]);
    }

    num_notes = Piece.getMultiplicity(i, j);

    for(int k = 1; k < num_notes; k++){
      cmd[ch_pos++] = ' ';
      cmd[ch_pos++] = 'z';
      cmd[ch_pos++] = pmx_pitch(Piece.getPitch(i, j, k));
      cmd[ch_pos++] = Piece.getOctave(i, j, k);
    }
  }

  if(Piece.isTied(i, j)){
    tied = true;
    cmd[ch_pos++] = ' ';
    cmd[ch_pos++] = 't';
  }
  else tied = false;

  if(xtuplet) xtuplet--;
}

char PMX_Translator::pmx_pitch(Base_Pitch pitch){

  switch(pitch){
    case A:   return 'a';
    case B:   return 'b';
    case C:   return 'c';
    case D:   return 'd';
    case E:   return 'e';
    case F:   return 'f';
    case G:   return 'g';
    default:  return -1;
  }
}

int PMX_Translator::pmx_accidental(Accidental accidental, char * acc){

  int len = 0;

  switch(accidental){
    case NONE:           break;
    case NATURAL:        acc[len++] = 'n'; break;
    case DOUBLE_SHARP:   acc[len++] = 's';
    case SHARP:          acc[len++] = 's'; break;
    case DOUBLE_FLAT:    acc[len++] = 'f';
    case FLAT:           acc[len++] = 'f'; break;
    default:
  }

  return len;
}

int PMX_Translator::pmx_xtuplet(Xtuplet xtuplet, char * xtupl){

  int len = 0;

  if(xtuplet == ME_SINGLE) return 0;

  xtupl[len++] = 'x';

  switch(xtuplet){
    case ME_DUPLET:        xtupl[len++] = '2'; break;
    case ME_TRIPLET:       xtupl[len++] = '3'; break;
    case ME_QUINTUPLET:    xtupl[len++] = '5'; break;
    case ME_SEPTUPLET:     xtupl[len++] = '7'; break;
    default:
  }

  return 2;
}

int PMX_Translator::denom_pmx(int denom){

  switch(denom){
    case 1:     return 0;
    case 2:     return 2;
    case 4:     return 4;
    case 8:     return 8;
    case 16:    return 1;
    case 32:    return 3;
    case 64:    return 6;
    default:
  }
}

int PMX_Translator::pmx_duration(int dur){

  switch(dur){
    case 1:     return 6;
    case 2:     return 3;
    case 4:     return 1;
    case 8:     return 8;
    case 16:    return 4;
    case 32:    return 2;
    case 64:    return 0;
    case 128:   return 9;
    default:
  }
}