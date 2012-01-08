#include "label.h"

char* newLabel(char* string)
{
  labelNumber++;
  char* str = malloc( sizeof( char ) * 256 );
  sprintf(str,".%s%d", string, labelNumber);
  return str;
}

char* gotoLabel(char* string)
{
  char* str = malloc( sizeof( char ) * 256 );
  sprintf(str,".LBL_%s", string);
  return str;
}

char* functionLabel(char* string)
{
  char* str = malloc( sizeof( char ) * 256 );
  sprintf(str,".FUNCTION_%s", string);
  return str;
}
    
