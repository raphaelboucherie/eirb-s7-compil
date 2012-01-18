#ifndef SYMT_H
#define SYMT_H

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

static int currentOffset = 0;

struct symT
{
  int offset;
  char* name;
  struct symT* next;
  int type;
};

int getOffset();
int getSym(char* string, struct symT* symbolTable);
void addSym(char* string, int type, struct symT* symbolTable);


#endif // SYMT_H
