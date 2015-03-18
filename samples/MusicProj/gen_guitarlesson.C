#include <iostream>
#include <fstream>
#include <cstdlib>
#include <ctime>
#include <cmath>

using namespace std;

typedef enum {C, D, E, F, G, A, B} Base_Pitch;
typedef enum {NONE, NATURAL, SHARP, FLAT, DOUBLE_SHARP, DOUBLE_FLAT} Accidental;
typedef enum {NORMAL, CUT_TIME, COMMON_TIME, BLIND} Meter;

#define MAX_PITCHES 30
#define MAX_FRETS 15
#define MAX_LINES 100
#define MAX_BARS_PER_SYSTEM 6
#define MAX_EVENTS_PER_SYSTEM 15
#define MAX_SYSTEMS_PER_PAGE 8

const int MAX_CHARS_PER_LINE = 100;

/* A list of all pitches in a single register */
static int p_array[][3][2] = { { {C, NONE}, {B, SHARP}, {D, DOUBLE_FLAT} },
                               { {C, SHARP}, {D, FLAT}, {B, DOUBLE_SHARP} },
                               { {D, NONE}, {C, DOUBLE_SHARP}, {E, DOUBLE_FLAT} },
                               { {D, SHARP}, {E, FLAT}, {F, DOUBLE_FLAT} },
                               { {E, NONE}, {F, FLAT}, {D, DOUBLE_SHARP} },
                               { {F, NONE}, {E, SHARP}, {G, DOUBLE_FLAT} },
                               { {F, SHARP}, {G, FLAT}, {E, DOUBLE_SHARP} },
                               { {G, NONE}, {F, DOUBLE_SHARP}, {A, DOUBLE_FLAT} },
                               { {G, SHARP}, {A, FLAT}, {-1, NONE} },
                               { {A, NONE}, {G, DOUBLE_SHARP}, {B, DOUBLE_FLAT} },
                               { {A, SHARP}, {B, FLAT}, {C, DOUBLE_FLAT} },
                               { {B, NONE}, {C, FLAT}, {A, DOUBLE_SHARP} } };

struct Mus_Environment {

  int max_mult; // Maximum multiplicity for the lesson
  int mult_prob_table[6]; // 6 entries with probabilities for single notes,
                          // intervals, and n-chords

  int open_strings[6][2];

  int t_numer, t_denom;

  int key;

  int avail_pitches[MAX_PITCHES][2];
  int avail_frets[MAX_FRETS];
  int avail_strings[6];

  int num_avail_pitches, num_avail_frets, num_avail_strings;

  int min_dur, max_dur;

  int rests_allowed;

  int num_measures;

  int note_display_pref;
  Meter meter;
};

char pmx_pitch(Base_Pitch pitch){

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

int pmx_accidental(Accidental accidental, char * acc){

  int len = 0;

  switch(accidental){
    case NONE:           break;
    case NATURAL:        acc[len++] = 'n'; break;
    case DOUBLE_SHARP:   acc[len++] = 's';
    case SHARP:          acc[len++] = 's'; break;
    case DOUBLE_FLAT:    acc[len++] = 'f';
    case FLAT:           acc[len++] = 'f'; break;
    default:             ;
  }

  acc[len] = '\0';

  return len;
}

int denom_pmx(int denom){

  switch(denom){
    case 1:     return 0;
    case 2:     return 2;
    case 4:     return 4;
    case 8:     return 8;
    case 16:    return 1;
    case 32:    return 3;
    case 64:    return 6;
    default:    ;
  }
}

char pmx_duration(int dur){

  switch(dur){
    case 1:     return '6';
    case 2:     return '3';
    case 4:     return '1';
    case 8:     return '8';
    case 16:    return '4';
    case 32:    return '2';
    case 64:    return '0';
    case 128:   return '9';
    default:    ;
  }
}

void read_fmtfile(char * fmtfile, Mus_Environment &mus_env){

  int max_num_measures, min_num_measures;
  char pitch_flag;
  int x;
  ifstream ifs;

  ifs.open(fmtfile);

  if(ifs.fail()){
    cout << "Fatal error! No such file!" << endl;
    exit(-1);
  }

  ifs >> mus_env.t_numer >> mus_env.t_denom;
  ifs >> mus_env.key >> mus_env.max_mult;

  for(int i = 0; i < 6; i++)
    ifs >> mus_env.mult_prob_table[i];

  for(int i = 1; i < 6; i++)
    mus_env.mult_prob_table[i] += mus_env.mult_prob_table[i - 1];

  if(mus_env.mult_prob_table[5] != 100){
    cout << "Error in format file! Invalid probabilities!";
    exit(-1);
  }

  ifs >> mus_env.min_dur >> mus_env.max_dur;

  ifs >> pitch_flag;

  ifs >> x;

  mus_env.num_avail_pitches = mus_env.num_avail_frets = mus_env.num_avail_strings = 0;

  switch(pitch_flag){
    case 'f':
    case 'F':  for(int i = 0; i < x; i++)
                 ifs >> mus_env.avail_frets[i];
               mus_env.num_avail_frets = x; break;
    case 's':
    case 'S':  for(int i = 0; i < x; i++)
                 ifs >> mus_env.avail_strings[i];
               mus_env.num_avail_strings = x; break;
    case 'n':
    case 'N':  for(int i = 0; i < x; i++){
                 ifs >> mus_env.avail_pitches[i][0];
                 ifs >> mus_env.avail_pitches[i][1];
               }
               mus_env.num_avail_pitches = x; break;
    default:   ;
  }

  ifs >> mus_env.rests_allowed;

  for(int i = 0; i < 6; i++){
    ifs >> mus_env.open_strings[i][0];
    ifs >> mus_env.open_strings[i][1];
  }

  ifs >> min_num_measures;
  ifs >> max_num_measures;

  mus_env.num_measures = min_num_measures + rand() % (max_num_measures - min_num_measures + 1);

  ifs >> mus_env.note_display_pref; // Can be either 1, 2, or 3 - decides which pitch representations to use
  ifs.close();

  // Static settings
  mus_env.meter = NORMAL;
}

void pmx_command(int pitch[][6], int mult, int dur, char cmd[]){

  int ch_pos = 0;

  if(dur > 0)
    cmd[ch_pos++] = pmx_pitch((Base_Pitch)pitch[0][2]);
  else cmd[ch_pos++] = 'r';

  cmd[ch_pos++] = pmx_duration(abs(dur));

  if(dur > 0){
    sprintf(&cmd[ch_pos], "%d", pitch[0][1]);
    ch_pos++;

    ch_pos += pmx_accidental((Accidental)pitch[0][3], &cmd[ch_pos]);

    for(int k = 1; k < mult; k++){
      cmd[ch_pos++] = ' ';
      cmd[ch_pos++] = 'z';
      cmd[ch_pos++] = pmx_pitch((Base_Pitch)pitch[k][2]);
      sprintf(&cmd[ch_pos], "%d", pitch[k][1]);
      ch_pos++;
      ch_pos += pmx_accidental((Accidental)pitch[k][3], &cmd[ch_pos]);
    }
  }

  cmd[ch_pos] = '\0';
}

bool isPlayable(int pitch[][6], int mult){

  int non_open_strings = mult;
  bool range_set = false;
  int min_fret, max_fret, fret_range;

  for(int i = 0; i < mult; i++)
    if(pitch[i][5] == 0) non_open_strings--;
    else {
      if(! range_set){ min_fret = max_fret = pitch[i][5]; range_set = true; }
      else if(pitch[i][5] < min_fret) min_fret = pitch[i][5];
           else if(pitch[i][5] > max_fret) max_fret = pitch[i][5];
    }

  fret_range = max_fret - min_fret;

  if(non_open_strings <= 1) return true;

  if(non_open_strings == 2){
    if(fret_range > 5) return false;
    else return true;
  }

  if(non_open_strings == 3){
    if(fret_range > 4) return false;
    else return true;
  }

  else {
    if(fret_range > 3) return false;
    else return true;
  }
}

int main(int argc, char ** argv){

  Mus_Environment mus_env;
  int nv, noinst, mtrnuml, mtrdenl, mtrnump, mtrdenp, xmtrnum0, isig;
  int num_pages, num_syst, musicsize;
  float fracindent;
  int num_lines;
  int num_beats, beat_duration, thisbeat_dur, bar_duration;
  int ch_pos, ch_pos_p;
  char pmx_buffer[MAX_LINES][128];
  int dur, mult;
  int pitch[6][6]; // Pitch value (0..11), Octave, Base pitch (C..A), Accidental, String (0..5), Fret
  int mult_prob;
  int strings[6];
  time_t t;
  int measures, events;
  char file_name[20];

  if(argc < 2){
    cout << "Insufficient number of parameters! Exiting..." << endl;
    exit(-1);
  }

  if(argc < 3){
    strcpy(&file_name[0], argv[1]);
    sprintf(&file_name[strlen(argv[1]) - 4], ".pmx");
  }
  else strcpy(&file_name[0], argv[2]);

  srand((unsigned) time(&t));

  read_fmtfile(argv[1], mus_env);

  char cmd[25]; // PMX command for a given event

  mtrnuml = mus_env.t_numer;
  mtrdenl = denom_pmx(mus_env.t_denom);

  switch(mus_env.meter){
    case NORMAL:       mtrnump = mus_env.t_numer;
                       mtrdenp = mus_env.t_denom;
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
    default:           ;
  }

  nv = noinst = 1; // One instrument
  xmtrnum0 = 0; // No pick-up note for now
  isig = mus_env.key;

  musicsize = 20; fracindent = 0.0;

  if(mtrnuml / 3 == mtrnuml / 3.0 && mtrnuml / 3 != 1){ // compound time
    num_beats = mtrnuml / 3;
    beat_duration = 3 * (64 / mtrdenl);
  }
  else {
    num_beats = mtrnuml;
    beat_duration = 64 / mtrdenl;
  }

  cout << "Lesson Environment" << endl;
  cout << "Time Signature: " << mus_env.t_numer << "/" << mus_env.t_denom << endl;
  cout << "Maximum multiplicity - ";
  switch(mus_env.max_mult){
    case 1: cout << "Single notes"; break;
    case 2: cout << "Intervals"; break;
    default: cout << mus_env.max_mult << "-chords";
  }
  cout << endl;
  cout << "Probabilities for n-pitch events: " << endl;
  cout << "1 - " << mus_env.mult_prob_table[0] << "%" << ", ";
  for(int i = 1; i < 6; i++){
    cout << i + 1 << " - " << mus_env.mult_prob_table[i] - mus_env.mult_prob_table[i - 1] << "%";
    if(i != 5) cout << ", ";
  }
  cout << endl;

  cout << "Shortest note duration: 1/" << 64 / mus_env.min_dur << endl;
  cout << "Longest note duration: 1/" << 64 / mus_env.max_dur << endl;
  cout << "Open strings are defined as ";
  char acc[3];
  for(int i = 0; i < 6; i++){
    cout << (i + 1) << " - " << pmx_pitch((Base_Pitch)p_array[mus_env.open_strings[i][0]][0][0])
         << mus_env.open_strings[i][1];
    pmx_accidental((Accidental)p_array[mus_env.open_strings[i][0]][0][1], &acc[0]);
    cout << acc;
    if(i != 5)
      cout << ", ";
  }

  cout << endl;
  cout << "Available frets: ";
  for(int i = 0; i < mus_env.num_avail_frets; i++)
    cout << "Fret #" << mus_env.avail_frets[i] << " ";
  cout << endl;

  cout << "Rests are ";
  if(mus_env.rests_allowed)
    cout << "allowed.";
  else cout << "not allowed";
  cout << endl;

  num_lines = num_syst = num_pages = 0; // Init buffer size

  ch_pos = 0;
  measures = events = 0;

  for(int i = 0; i < mus_env.num_measures; i++){

    if(measures >= MAX_BARS_PER_SYSTEM ||
       events >= MAX_EVENTS_PER_SYSTEM){

      measures = events = 0;

      num_syst++;

      if(ch_pos == 0)
        strcpy(&pmx_buffer[num_lines - 1][ch_pos_p], " /");
      else {
        strcpy(&pmx_buffer[num_lines][ch_pos], "/");
        num_lines++;
        ch_pos = 0;
      }
      
    }

    bar_duration = beat_duration * num_beats;
    thisbeat_dur = beat_duration;

    do {

      do {
        dur = (int)pow(2.0f, (int)(rand() % 7));
      } while(dur < mus_env.min_dur || dur > mus_env.max_dur);

      while(dur > bar_duration) dur /= 2;

      if(mus_env.rests_allowed){
        int rest_prob = rand() % 10;
        if(rest_prob == 9) dur *= -1;
      }

      mult_prob = rand() % 100 + 1;

      if(mult_prob <= mus_env.mult_prob_table[0]) mult = 1;
      else if(mult_prob <= mus_env.mult_prob_table[1]) mult = 2;
      else if(mult_prob <= mus_env.mult_prob_table[2]) mult = 3;
      else if(mult_prob <= mus_env.mult_prob_table[3]) mult = 4;
      else if(mult_prob <= mus_env.mult_prob_table[4]) mult = 5;
      else mult = 6;

      if(mult > mus_env.max_mult){
        cout << "Invalid multiplicity probabilities!" << endl;
        exit(-1);
      }

      // For each pitch, select fret at random from available frets,
      // followed by a random string from the set of unpicked strings,
      // followed by selecting a random representation for the pitch.

      bool playable;
      do {
        for(int j = 0; j < mult; j++){
          int fret_no = rand() % mus_env.num_avail_frets;
          bool done;
          do {
            strings[j] = rand() % 6;
            done = true;
            for(int k = 0; k < j; k++)
              if(strings[j] == strings[k]) done = false;
          } while(! done);

          pitch[j][0] = (mus_env.open_strings[strings[j]][0] + mus_env.avail_frets[fret_no]) % 12;
          pitch[j][1] = mus_env.open_strings[strings[j]][1] +
                        (mus_env.open_strings[strings[j]][0] + mus_env.avail_frets[fret_no]) / 12;

          int rand_num;
          if(pitch[j][0] != 8 || mus_env.note_display_pref < 3) rand_num = rand() % mus_env.note_display_pref;
          else rand_num = rand() % 2;

          pitch[j][2] = p_array[pitch[j][0]][rand_num][0];
          pitch[j][3] = p_array[pitch[j][0]][rand_num][1];

          pitch[j][4] = strings[j];
          pitch[j][5] = mus_env.avail_frets[fret_no];
        }
        playable = isPlayable(pitch, mult);

      } while(! playable);

      pmx_command(pitch, mult, dur, cmd);

      strcpy(&pmx_buffer[num_lines][ch_pos], cmd);
      ch_pos += strlen(cmd);

      if(ch_pos > MAX_CHARS_PER_LINE){
        pmx_buffer[num_lines][ch_pos] = '\0';
        num_lines++;
        ch_pos_p = ch_pos;
        ch_pos = 0;
      }
      else pmx_buffer[num_lines][ch_pos++] = ' ';

      bar_duration -= abs(dur);
      events++;
    } while(bar_duration > 0);

    if(ch_pos == 0){
      strcpy(&pmx_buffer[num_lines - 1][ch_pos_p], " |");
      ch_pos_p += 2;
    }
    else {
      strcpy(&pmx_buffer[num_lines][ch_pos], "| ");
      ch_pos += 2;
    }

    measures++;

  }

  num_syst++;
  if(ch_pos == 0)
    strcpy(&pmx_buffer[num_lines - 1][ch_pos_p], " /");
  else {
    strcpy(&pmx_buffer[num_lines][ch_pos], "/");
    num_lines++;
    ch_pos = 0;
  }

  num_pages = num_syst / MAX_SYSTEMS_PER_PAGE + 1;
  if(num_syst % MAX_SYSTEMS_PER_PAGE < MAX_SYSTEMS_PER_PAGE / 2
     && num_pages > 1)
    num_pages--;

  /***************** PMX Output Section ****************/

  ofstream ofs;

  ofs.open(file_name);

  ofs << nv << " " << noinst << " " << mtrnuml << " " << mtrdenl << " ";
  ofs << mtrnump << " " << mtrdenp << " " << xmtrnum0 << " " << isig << endl;

  ofs << num_pages << " " << num_syst << " " << musicsize << " " << fracindent << endl;

  ofs << endl;

  ofs << "t" << endl;

  ofs << "./" << endl;

  ofs << "Ii25" << endl;

  ofs << "Tc" << endl;
  ofs << "Lamont WebSight" << endl;

  ofs << "Tt" << endl;
  ofs << "Lesson format: " << argv[1] << endl;

  for(int i = 0; i < num_lines; i++)
    ofs << pmx_buffer[i] << endl;

  ofs.close();

  return 0;
}
