#ifndef LABEL_H
#define LABEL_H

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

static int labelNumber = 0; // might change

char* gotoLabel(char* string);
char* newLabel(char* string);
char* functionLabel(char* string);

#endif // LABEL_H
