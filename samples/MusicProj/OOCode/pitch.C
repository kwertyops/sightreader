#include "pitch.h"

Pitch::Pitch(int _string, int _fret): string(_string), fret(_fret){

  int os_pitch, os_octave;
  int rand_num;

  Mus_Env.get_OpenString_PO(_string, os_pitch, os_octave);

  pitch = (os_pitch + _fret) % 12;
  octave = os_octave + (os_pitch + _fret) / 12;

  pitch_val = pitch + (octave - 1) * 12;

  if(pitch != 8) rand_num = rand() % 3;
  else rand_num = rand() % 2;

  bpitch = p_array[pitch][rand_num][0];
  acc = p_array[pitch][rand_num][1];
}