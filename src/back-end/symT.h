#ifndef SYMT_H
#define SYMT_H

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "globals.h"

struct symT
{
  int offset;
  char* name;
  struct symT* next;
  int type;
};

int getOffset();
int getSym(char* string);
void addSym(char* string, int type);

#endif // SYMT_H
