#include "label.h"

char* newLabel(char* string)
{
  labelNumber++;
  char* str = malloc( sizeof( char ) * 256 );
  sprintf(str,"%s%d", string, labelNumber);
  return str;
}
