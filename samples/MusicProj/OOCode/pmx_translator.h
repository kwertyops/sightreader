#ifndef PMX_TRANSLATOR_H
#define PMX_TRANSLATOR_H

#include "mus_piece.h"

#define MAX_LINES 100
#define MAX_BARS_PER_SYSTEM 6
#define MAX_EVENTS_PER_SYSTEM 15
#define MAX_SYSTEMS_PER_PAGE 8

class PMX_Translator {

  public:
    PMX_Translator(Mus_Piece * Piece);
    ~PMX_Translator(){}

    write_pmx(char * file_name);

    set_instrument(char * _instrument);

  private:
    char pmx_buffer[MAX_LINES][128];

    int num_lines;

    int nv, noinst, mtrnuml, mtrdenl,
        mtrnump, mtrdenp, xmtrnum0, isig;

    int num_syst, num_pages;

    bool midi_gen;

    char clef;

    char * instrument;
};

#endif