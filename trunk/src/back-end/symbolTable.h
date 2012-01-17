#ifndef SYMBOL_TABLE_H
#define SYMBOL_TABLE_H

#include <stdio.h>
#include <string.h>
#include <stdlib.h>

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

struct symbolTableIdentifierList* createIdentifierList(char* name, int type, int offset);
struct symbolTableTreeNodeList* createTreeNodeList(struct symbolTableTreeNode* data); 
struct symbolTableTreeNode* createTreeNode(struct symbolTableTreeNode* father);

struct symbolTableIdentifierList* getIdentifier(char* name);


#endif // SYMBOL_TABLE_H
