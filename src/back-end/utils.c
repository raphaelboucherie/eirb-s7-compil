#include "utils.h"

char* regOffset(char* string, int a)
{
  char* str = malloc( sizeof ( char ) * 256 );
  sprintf(str,"-%d(%s)", a, string);
  return str;
}

char* constToASMConst(char* string)
{
  char* str = malloc( sizeof ( char ) * 256 );
  sprintf(str,"$%s",string);
  return str;
}

char* ASM_INIT()
{
  //  return "BITS 32\nSECTION .data\nSECTION .text\n\tGLOBAL _start\n\n_start:\n";
  return "\t.text\n.globl main\n\t.type	main, @function\nmain:\n";
}
char* ASM_CLOSE()
{
  return "";//mov eax, 1\nint 0x80\n";
}

