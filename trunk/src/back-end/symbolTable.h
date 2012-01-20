#ifndef SYMBOL_TABLE_H
#define SYMBOL_TABLE_H

#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <assert.h>
#include "stringList.h"


struct symbolTableIdentifierList
{
  struct symbolTableIdentifierList* next;
  char* name;
  int type;
  int offset;
  int size;
};

struct symbolTableTreeNodeList
{
  struct symbolTableTreeNodeList* next;
  struct symbolTableTreeNode* data;
};

struct symbolTableTreeNode
{
  struct symbolTableTreeNodeList* sons;
  struct symbolTableTreeNode* father; 
  struct symbolTableIdentifierList* identifierList;
  char* functionName;
  struct string* code; 
  int currentOffset;
  int parameterSize;
};

struct symbolTableIdentifierList* 
createIdentifierList(char* name,
		     int type,
		     int offset,
		     int size);

struct symbolTableTreeNodeList*
createTreeNodeList(struct symbolTableTreeNode* data); 

struct symbolTableTreeNode* 
createTreeNode(struct symbolTableTreeNode* father);

struct symbolTableTreeNode* 
createFunctionTreeNode(struct symbolTableTreeNode* root, 
		       char* functionName);

struct symbolTableIdentifierList* 
getIdentifier(char* name,
	      struct symbolTableTreeNode* symbolTableCurrentNode,
	      struct symbolTableTreeNode* symbolTableRoot );

struct symbolTableIdentifierList* 
getIdentifierInList(char* name,
		    struct symbolTableIdentifierList* list);

void 
addIdentifier (char* identifier, int size, int type,
	       struct symbolTableTreeNode* symbolTableCurrentNode);

void addParameter(char * identifier, int size, int type, 
         struct symbolTableTreeNode* symbolTableCurrentNode);
	     

int getOffset(int size, struct symbolTableTreeNode* node);

int searchOffset(char* identifier,
		 struct symbolTableTreeNode* symbolTableCurrentNode, 
		 struct symbolTableTreeNode* symbolTableRoot);

void addSon(struct symbolTableTreeNode* node, 
	    struct symbolTableTreeNode* son);

void dumpSymbolTable(struct symbolTableTreeNode* root, int i);

void dumpSymbolTableTreeNodeList(struct symbolTableTreeNodeList* list);

void dumpSymbolTableIdentifierList(struct symbolTableIdentifierList* list);

struct symbolTableTreeNode * getFunctionNode(struct symbolTableTreeNode *root, char * name);

#endif // SYMBOL_TABLE_H
