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
  assert(symbolTableCurrentNode!=NULL);
  assert(symbolTableRoot!=NULL);
  struct symbolTableTreeNode* node = symbolTableCurrentNode; // récupération du noeud courant
  while(node!=symbolTableRoot)
    {
      struct symbolTableIdentifierList *result = getIdentifierInList(name, node->identifierList); // recherche de l'identifiant dans le noeud
      if (result != NULL) // si l'on trouve quelque chose
	{
	  return result;
	}
      // sinon remonter dans l'arbre
      asser(node->father!=NULL);
      node = node->father;
    }
  // dernière vérification dans les variables globales
  assert(node==symbolTableRoot);
  return getIdentifierInList(name,symbolTableRoot->identifierList);
}

struct symbolTableIdentifierList* getIdentifierInList(char* name, struct symbolTableIdentifierList* list)
{
  while(list!=NULL)
    {
      if (strcmp(list->name,name)==0)
	return list;
      list=list->next;
    }
  return NULL;
}
