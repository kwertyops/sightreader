#ifndef MUS_PIECE_H
#define MUS_PIECE_H

#include "mus_event.h"

#define MAX_BARS 50

typedef enum {NORMAL, CUT_TIME, COMMON_TIME, BLIND} Meter;

class Mus_Piece {

  private:
    int key;
    int t_numer;
    int t_denom;

    Meter m;

    Mus_Measure * mus_piece[MAX_BARS];

    int num_bars;
    int num_events;

};

#endif