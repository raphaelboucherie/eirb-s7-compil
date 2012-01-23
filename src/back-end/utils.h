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
int getAndCheckExpressions(char** reg1, char** reg3, 
			   struct symbolTableIdentifierList* id1,
			   struct symbolTableIdentifierList* id3,
			   char* expr1, char* expr3,
			   struct symbolTableTreeNode* symbolTableCurrentNode,
			   struct symbolTableTreeNode* symbolTableRoot);
int getArraySize(char* array, struct symbolTableTreeNode* symbolTableCurrentNode, 
		 struct symbolTableTreeNode* symbolTableRoot);	   
int getArrayOffset(char* array, struct symbolTableTreeNode* symbolTableCurrentNode, 
		   struct symbolTableTreeNode* symbolTableRoot);
#endif // UTILS_H
