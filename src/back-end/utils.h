#ifndef UTILS_H
#define UTILS_H

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

char* ASM_INIT();
char* ASM_CLOSE();
char* regOffset(char* string, int a);
char* constToASMConst(char* string);

#endif // UTILS_H
