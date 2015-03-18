#ifndenf MUS_EVENT_H
#define MUS_EVENT_H

#include "pitch.h"

#define MAX_EVENTS_PER_MEASURE 30

typedef enum {ME_SINGLE, ME_DUPLET, ME_TRIPLET, ME_QUINTUPLET, ME_SEPTUPLET} Xtuplet;

typedef enum {NOT_TIED, TIED} Tied;
typedef enum {NO_DOT, DOTTED, DOUBLE_DOTTED} Dotted;
typedef enum {NOTE, REST} Event_Type;

class Mus_Event {

  private:
    int event_id;

    Event_Type type;

    Pitch * p[NUM_STRINGS];

    int multiplicity;

    int act_dur;

    int base_dur;
    Tied tied;
    Dotted dotted;

    Xtuplet xtuplet;

};

class Mus_Measure {

  private:
    Mus_Event * m[MAX_EVENTS_PER_MEASURE];

};

#endif