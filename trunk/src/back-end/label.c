#include "label.h"

char* newLabel(char* string)
{
  labelNumber++;
  char* str = malloc( sizeof( char ) * 256 );
  sprintf(str,"0_%s%d", string, labelNumber);
  return str;
}

char* functionLabel(char* string)
{
  char* str = malloc( sizeof( char ) * 256 );
  sprintf(str,"0_FUNCTION_%s", string);
  return str;
}
    
