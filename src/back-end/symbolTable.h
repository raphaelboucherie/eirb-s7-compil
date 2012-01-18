#ifndef SYMBOL_TABLE_H
#define SYMBOL_TABLE_H

#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <assert.h>


struct symbolTableIdentifierList
{
  struct symbolTableIdentifierList* next;
  char* name;
  int type;
  int offset;
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
};

struct symbolTableIdentifierList* 
createIdentifierList(char* name,
		     int type,
		     int offset);

struct symbolTableTreeNodeList*
createTreeNodeList(struct symbolTableTreeNode* data); 

struct symbolTableTreeNode* 
createTreeNode(struct symbolTableTreeNode* father);

struct symbolTableIdentifierList* 
getIdentifier(char* name,
	      struct symbolTableTreeNode* symbolTableCurrentNode,
	      struct symbolTableTreeNode* symbolTableRoot );

struct symbolTableIdentifierList* 
getIdentifierInList(char* name,
		    struct symbolTableIdentifierList* list);

void 
addIdentifier (char* identifier, int size, 
		    struct symbolTableTreeNode* symbolTableCurrentNode);

int getOffset();

int searchOffset(char* identifier,
		 struct symbolTableTreeNode* symbolTableCurrentNode, 
		 struct symbolTableTreeNode* symbolTableRoot);

#endif // SYMBOL_TABLE_H
