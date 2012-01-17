#include "symbolTable.h"

struct symbolTableIdentifierList* createIdentifierList(char* name, int type, int offset)
{
  struct symbolTableIdentifierList* idList = malloc(sizeof (struct symbolTableIdentifierList));
  idList->name = strdup(name);
  idList->type = type;
  idList->offset = offset;
  idList->next = NULL;
  return idList;
}

struct symbolTableTreeNodeList* createTreeNodeList(struct symbolTableTreeNode* data)
{
  struct symbolTableTreeNodeList* nodeList= malloc(sizeof (struct symbolTableTreeNodeList));
  nodeList->data = data;
  nodeList->next = NULL;
  return nodeList;
}

struct symbolTableTreeNode* createTreeNode(struct symbolTableTreeNode* father)
{
  struct symbolTableTreeNode* node = malloc(sizeof (struct symbolTableTreeNode));
  node->father=father;
  node->sons = NULL;
  node->identifierList = NULL;
  return node;
}

struct symbolTableIdentifierList* getIdentifier(char* name)
{
  // TODO
  return (void*)0;
}
