#ifndef PITCH_H
#define PITCH_H

#include "environ.h"

#define BASE_PITCH_VALUE 0 // Value assigned to note 'C' of octave 1

typedef enum {C, D, E, F, G, A, B} Base_Pitch;
typedef enum {NONE, NATURAL, SHARP, FLAT, DOUBLE_SHARP, DOUBLE_FLAT} Accidental;

/* A list of all pitches in a single register */
static int p_array[][3][2] = { { {B, SHARP}, {C, NONE}, {D, DOUBLE_FLAT} },
                             { {B, DOUBLE_SHARP}, {C, SHARP}, {D, FLAT} },
                             { {C, DOUBLE_SHARP}, {D, NONE}, {E, DOUBLE_FLAT} },
                             { {D, SHARP}, {E, FLAT}, {F, DOUBLE_FLAT} },
                             { {D, DOUBLE_SHARP}, {E, NONE}, {F, FLAT} },
                             { {E, SHARP}, {F, NONE}, {G, DOUBLE_FLAT} },
                             { {E, DOUBLE_SHARP}, {F, SHARP}, {G, FLAT} },
                             { {F, DOUBLE_SHARP}, {G, NONE}, {A, DOUBLE_FLAT} },
                             { {G, SHARP}, {A, FLAT}, {-1, NONE} },
                             { {G, DOUBLE_SHARP}, {A, NONE}, {B, DOUBLE_FLAT} },
                             { {A, SHARP}, {B, FLAT}, {C, DOUBLE_FLAT} },
                             { {A, DOUBLE_SHARP}, {B, NONE}, {C, FLAT} } };

class Pitch {

  private:

    // String-Fret pair
    // {1..6}-{0..17} with Fret 0 corresponding to open strings
    int string;
    int fret;

    // Pitch-Register pair
    // {0..11}-{1..7}
    int pitch;
    int octave;

    // Pitch value in total order = pitch + (octave - 1) * 12
    int pitch_val;

    // BasePitch-Accidental pair determines how the note is to be displayed
    Base_Pitch bpitch;
    Accidental acc;

  public:
    Pitch(int _string, int _fret);
    Pitch(int _pitch, int _octave);
    Pitch(int _pval);
    Pitch(Base_Pitch _bpitch, Accidental _acc);
};

#endif