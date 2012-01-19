#ifndef PILE_H
#define PILE_H

#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <assert.h>

struct pile 
{
  int head;
  char** array;
  int size;
};

struct pile* createPile(int size);
void freePile(struct pile* p);
void push(char* string, struct pile* p);
char* pop(struct pile* p);

#endif // PILE_H
