#ifndef STRING_LIST_H
#define STRING_LIST_H

#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <stdarg.h>
#include <assert.h>

struct string 
{
  char* str;
  struct string* next;
};

struct string* addString2(struct string* current, char* str);
struct string* addString(struct string* current, char* str, ...);
struct string* addStringList(struct string* current, struct string* new);
void printString(struct string* s);


#endif // STRING_LIST_H
