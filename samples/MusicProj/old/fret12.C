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

int main(int argc, char * argv[]){

  int num_bars, nv, noinst, mtrnum1, mtrden1, mtrnmp, mtrdnp;
  int xmtrnum0, isig, npages, nsyst, musicsize, min_duration;
  char filename[20];
  float fracindent;
  note subset[6];
  time_t t;
  unsigned char bar_duration;
  int nt, dur, dur1, nt1;

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

  /* Fret 12 notes */
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
  nsyst = (int)ceil(num_bars / 5.0);
  npages = (int)ceil(nsyst * (nv + 1) / 21.0);
  musicsize = 20;
  fracindent = 0.07;

  ofstream ofs;

  ofs.open(filename);

  ofs << nv << " " << noinst << " " << mtrnum1 << " " << mtrden1 << " "
      << mtrnmp << " " << mtrdnp << " " << xmtrnum0 << " " << isig << endl;
  ofs << npages << " " << nsyst << " " << musicsize << " " << fracindent << endl;
  for(int i = 0; i < noinst; i++)
    ofs << "Instrument" << i << endl;
  if(noinst == 1) ofs << "t" << endl;
  else {
    ofs << "b";
    for(int i = 0; i < noinst - 1; i++)
      ofs << "t";
    ofs << endl;
  }
  ofs << "./" << endl;

  ofs << "I";
  if(noinst > 1)
    ofs << "ihaor";
  if(noinst > 2)
    for(int i = 0; i < noinst - 2; i++)
      ofs << "vl";
  ofs << endl;

  ofs << "Tc" << endl;
  ofs << "Janus Flavius Maisterus" << endl;

  srand((unsigned) time(&t));

  dur1 = -1;
  nt1 = -2;
  int i = 0;

  for(; i < num_bars * nv; i++){

    bar_duration = 64;
    if(i % 5 == 0 && i != 0){
      nt1 = -2; dur1 = -1;
      ofs << " /" << endl;
    }

    do {
      nt = rand() % 6; // Pick one out of 6 possible notes
      dur = (int)pow(2.0f, (int)(rand() % (min_duration + 1)));
      while((64 / dur) > bar_duration) dur *= 2;
      bar_duration -= (64 / dur);

      ofs << subset[nt].pitch;
      if(dur != dur1)
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
      // accidental = rand() % 3;
      // switch(accidental){
        // case 0:  break;
        // case 1:  ofs << "s"; << break;
        // case 2:  ofs << "f"; << break;
        // default: 
      // }

      if(nt > nt1 + 1 || nt < nt1 - 1){
        if(dur == dur1)
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
        ofs << subset[nt].octave;
      }
      nt1 = nt;
      dur1 = dur;

      ofs << " ";
    }
    while(bar_duration > 0);

    ofs << "| ";
  }
  
  ofs << " /" << endl;

  ofs << endl;

  ofs.close();

  return 0;
}
