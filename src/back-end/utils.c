#include "utils.h"

char* regOffset(char* string, int a)
{
  char* str = malloc( sizeof ( char ) * 256 );
  sprintf(str,"%d(%s)", a, string);
  return str;
}

char* constToASMConst(char* string)
{
  char* str = malloc( sizeof ( char ) * 256 );
  sprintf(str,"$%s",string);
  return str;
}
