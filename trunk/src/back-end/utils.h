#ifndef UTILS_H
#define UTILS_H

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <assert.h>
#include "symbolTable.h"

char* ASM_INIT();
char* ASM_CLOSE();
char* regOffset(char* string, int a);
char* constToASMConst(char* string);
char* postfixExpressionToRegister(char* postfixExpression, 
				  struct symbolTableTreeNode* currentNode,
				  struct symbolTableTreeNode* root);
int isIdentifier(char* expression);

#endif // UTILS_H
