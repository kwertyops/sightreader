/* This version of the program incorporates changes to the placement
   of notes overlapping beats (resolved by ties) as well as avoids
   adjacent notes whose durations differ by more than a certain # of
   levels (specified by the user).
*/

#include <iostream>
#include <fstream>
#include <cstdlib>
#include <ctime>
#include <cmath>

using namespace std;

typedef struct {
  char pitch;
  int octave;
} note;

int pmxduration(unsigned char dur){

  switch(dur){
    case 1:   return 6;
    case 2:   return 3;
    case 4:   return 1;
    case 8:   return 8;
    case 16:  return 4;
    case 32:  return 2;
    case 64:  return 0;
    case 128: return 9;
    default:  cerr << "Note duration error!"; exit(-1);
  }
}

/* Prints (to the stream 'ofs') a pmx command corresponding
   to a note with pitch 'p', octave 'oct', and duration 'dur'
   (measured in 64ths, 1..128). The flag 'tie' specifies
   whether this note is tied to the previous one (-1), not
   tied (0), tied to the next note (1), or tied at both ends (2).
   If 'oct' is 0, no octave designation is output.
*/
void print_pmxnote(ofstream& ofs, char p, int oct,
  unsigned char dur, int tie){

  bool firstnote = true, manynotes = false;
  unsigned char thisnote_dur = 0x80;
  unsigned char basenote_dur;
  int d;

  for(int i = 0; i < 8; i++, thisnote_dur >>= 1)
    if(dur & thisnote_dur){
      if(! firstnote) ofs << "t ";
      if(! firstnote && ! manynotes) manynotes = true;
      ofs << p;
      d = 0; basenote_dur = thisnote_dur;
      while((dur & (thisnote_dur >> 1)) && (d < 2)){
        d++; i++; thisnote_dur >>= 1;
        ofs << "d";
      }
      ofs << pmxduration(basenote_dur);
      if(firstnote && oct) ofs << oct;
      ofs << " ";
      if(firstnote){
        if(tie == -1 || tie == 2) ofs << "t ";
        firstnote = !firstnote;
      }
      if(manynotes) ofs << "t ";
    }

  if(tie == 1 || tie == 2) ofs << "t ";
}

int main(int argc, char * argv[]){

  int num_bars, nv, noinst, mtrnum1, mtrden1, mtrnmp, mtrdnp;
  int xmtrnum0, isig, npages, nsyst, musicsize, min_duration;
  char filename[20];
  float fracindent;
  note subset[6];
  time_t t;
  unsigned char bar_duration;
  int nt, dur, dur1, nt1;
  bool second_voice = false;
  int num_beats, beat_duration;
  int syncopation, max_diff_levels;

  if(argc > 1)
    strcpy(filename, argv[1]);
  else strcpy(filename, "exercise.pmx");
  if(argc > 2)
    num_bars = atoi(argv[2]);
  else num_bars = 35;
  if(argc > 3)
    nv = atoi(argv[3]);
  else nv = 1;
  if(argc > 4)
    min_duration = atoi(argv[4]);
  else min_duration = 2; // Duration = 1 / 2^{min_duration}
  if(argc > 5 && atoi(argv[5]) != 0)
    second_voice = true;
  if(argc > 6)
    max_diff_levels = atoi(argv[6]);
  else max_diff_levels = 7;
  if(argc > 7)
    syncopation = atoi(argv[7]);
  else syncopation = 0;

  /* Open string notes */
  subset[0].pitch = 'e';
  subset[0].octave = 3;
  subset[1].pitch = 'a';
  subset[1].octave = 3;
  subset[2].pitch = 'd';
  subset[2].octave = 4;
  subset[3].pitch = 'g';
  subset[3].octave = 4;
  subset[4].pitch = 'b';
  subset[4].octave = 4;
  subset[5].pitch = 'e';
  subset[5].octave = 5;

  /* Simple init */
  noinst = nv;
  mtrnum1 = mtrden1 = 4;
  mtrnmp = 0; mtrdnp = 6; // Common time
  xmtrnum0 = 0; // No pick-up
  isig = 0; // C-major key
  if(second_voice)
    nsyst = (int)ceil(num_bars / 4.0);
  else nsyst = (int)ceil(num_bars / 4.0);
  if(syncopation)
    nsyst = (int)ceil(num_bars / 3.0);

  npages = (int)ceil(nsyst * (nv + nv - 1) / 21.0);
  musicsize = 20;
  fracindent = 0.07;
  if(mtrnum1 / 3 == mtrnum1 / 3.0 && mtrnum1 / 3 != 1){ // compound time
    num_beats = mtrnum1 / 3;
    beat_duration = 3 * (64 / mtrden1);
  }
  else {
    num_beats = mtrnum1;
    beat_duration = 64 / mtrden1;
  }

  ofstream ofs;

  ofs.open(filename);

  ofs << nv << " " << noinst << " " << mtrnum1 << " " << mtrden1 << " "
      << mtrnmp << " " << mtrdnp << " " << xmtrnum0 << " " << isig << endl;
  ofs << npages << " " << nsyst << " " << musicsize << " " << fracindent << endl;
  if(noinst > 3) ofs << "Piano" << endl;
  if(noinst > 2) ofs << "Violin" << endl;
  if(noinst > 1) ofs << "Guitar 2" << endl;
  ofs << "Guitar 1" << endl;
  for(int i = 4; i < noinst; i++)
    ofs << "Instrument" << i << endl;

  if(noinst >= 4){
    ofs << "b";
    for(int i = 0; i < noinst - 1; i++)
      ofs << "t";
  }
  if(noinst < 4)
    for(int i = 0; i < noinst; i++)
      ofs << "t";
  ofs << endl;

  ofs << "./" << endl;

  ofs << "I";
  if(noinst == 1) ofs << "i25"; // Acoustic guitar
  if(noinst > 1)
    ofs << "i25:25";
  if(noinst > 2)
  //  for(int i = 0; i < noinst - 2; i++)
  //    ofs << "vl";
    ofs << "vl";
  if(noinst > 3)
    ofs << "pi";

  ofs << endl;

  ofs << "Tc" << endl;
  ofs << "Yan Mayster" << endl;

  srand((unsigned) time(&t));

  dur1 = -1;
  nt1 = -2;
  int i = 0;

  if(second_voice) nv++;

  int thisbeat_dur;

  for(; i < num_bars * nv; i++){

    bar_duration = beat_duration * num_beats;
    thisbeat_dur = beat_duration;
    if(syncopation && i % 3 == 0 && i != 0 && i <= 3 * nv * (num_bars / 3)){
      if(second_voice && i % 3 == 0 && i % (nv * 3) != 3 && i != 0)
        ofs << " //" << endl;
      else ofs << " /" << endl;
      nt1 = -2; dur1 = -1;
    }
    else if(syncopation && i != 0){
      int k = num_bars % 3;
      for(int j = 0; j < nv; j++)
        if(i == num_bars * nv - j * k){
          nt1 = -2; dur1 = -1; ofs << " /" << endl;
        }
    }
    else if (! syncopation){
      if((second_voice && (i % 4 == 0 && i % (nv * 4) != 4) && i != 0) ||
         ((! second_voice) && i % 4 == 0 && i != 0)){
        nt1 = -2; dur1 = -1;
        ofs << " /" << endl;
      }
      else if(second_voice && i % 4 == 0 && i != 0){
        nt1 = -2; dur1 = -1;
        ofs << " //" << endl;
      }
    }

    do {
      nt = rand() % 6; // Pick one out of 6 possible notes
      do {
        dur = (int)pow(2.0f, (int)(rand() % (min_duration + 1)));
      } while( (dur < dur1 / (int)pow(2.0f, max_diff_levels)) ||
               ( (dur > dur1 * (int)pow(2.0f, max_diff_levels)) &&
                  dur1 != -1 ) );
      while((64 / dur) > bar_duration) dur *= 2;
      bar_duration -= (64 / dur);
      if(syncopation && 64 / dur > thisbeat_dur){
        int note_duration = 64 / dur;
        int tie = 1;
        while(thisbeat_dur < note_duration){
          print_pmxnote(ofs, subset[nt].pitch, subset[nt].octave,
            thisbeat_dur, tie);
          note_duration -= thisbeat_dur;
          thisbeat_dur = beat_duration;
          tie = 2;
        }
        print_pmxnote(ofs, subset[nt].pitch, subset[nt].octave,
          note_duration, -1);
        thisbeat_dur -= note_duration;
      }
      else {
        while(thisbeat_dur < 64 / dur && ! syncopation) dur *= 2;
        thisbeat_dur -= 64 / dur;

        ofs << subset[nt].pitch;
          switch(dur){
            case 1:   ofs << "0"; break;
            case 2:   ofs << "2"; break;
            case 4:   ofs << "4"; break;
            case 8:   ofs << "8"; break;
            case 16:  ofs << "1"; break;
            case 32:  ofs << "3"; break;
            case 64:  ofs << "6"; break;
            default: cerr << "Duration error!" << endl;
          }
        if(nt > nt1 + 1 || nt < nt1 - 1){

          ofs << subset[nt].octave;
        }
        ofs << " ";
      }

      if(thisbeat_dur == 0) thisbeat_dur = beat_duration;
      nt1 = nt;
      dur1 = dur;

    }
    while(bar_duration > 0);

    ofs << "| ";
  }

  ofs << " /" << endl;

  ofs << endl;

  ofs.close();

  return 0;
}
