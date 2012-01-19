#include "symbolTable.h"

struct symbolTableIdentifierList* createIdentifierList(char* name, int type, int offset, int size)
{
  struct symbolTableIdentifierList* idList = malloc(sizeof (struct symbolTableIdentifierList));
  idList->name = strdup(name);
  idList->type = type;
  idList->offset = offset;
  idList->next = NULL;
  idList->size = size;
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
  node->functionName = NULL;
  return node;
}

struct symbolTableTreeNode* createFunctionTreeNode(struct symbolTableTreeNode* root, 
						   char* functionName)
{
  struct symbolTableTreeNode* node = createTreeNode(root);
  node->functionName = strdup(functionName);
  return node;
}

struct symbolTableIdentifierList* getIdentifier(char* name, struct symbolTableTreeNode* symbolTableCurrentNode,
						struct symbolTableTreeNode* symbolTableRoot )
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
      assert(node->father!=NULL);
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

void addIdentifier (char* identifier, int size, int type, 
		    struct symbolTableTreeNode* symbolTableCurrentNode)

{
  assert(!getIdentifierInList(identifier,symbolTableCurrentNode->identifierList) && 
	 "conflit avec un symbole déja présent dans la table"); 
  assert(type != 0x10000 && // 0x10000 = type_FUNCTION
	 "L'ajout de fonction dans la table ne doit pas utiliser cette fonction");
  fprintf(stderr,"Ajout de l'identifier : %s\n", identifier);
  int offset;
  offset = getOffset(size);
  struct symbolTableIdentifierList* identifierData = 
    createIdentifierList(identifier,type,offset,size);
			 
  identifierData->next = symbolTableCurrentNode->identifierList;
  symbolTableCurrentNode->identifierList = identifierData;
}

int getOffset(int size)
{
  static int currentOffset = 0;
  currentOffset+=(size*4);
  return currentOffset;
}

int searchOffset(char* identifier,
		 struct symbolTableTreeNode* symbolTableCurrentNode, 
		 struct symbolTableTreeNode* symbolTableRoot)
{
  struct symbolTableIdentifierList* identifierData = 
    getIdentifier(identifier, symbolTableCurrentNode, symbolTableRoot);
  if (identifierData != NULL)
    {
      return identifierData->offset;
    }
  else
    {
      assert(0 && "No identifier found !");
    }
}

void addSon(struct symbolTableTreeNode* node, 
	    struct symbolTableTreeNode* son)
{
  struct symbolTableTreeNodeList *nodeList = 
    createTreeNodeList(son);
  nodeList->next = node->sons;
  node->sons = nodeList;
  fprintf(stderr,"Adding son to %p\n", node);
}

void dumpSymbolTable(struct symbolTableTreeNode* root, int i)
{
  fprintf(stderr,"Node %p informations : \n", root);
  fprintf(stderr,"Current level : %d\n",i);
  fprintf(stderr,"father = %p\n",root->father);
  fprintf(stderr,"Symbol table informations : \n");
  dumpSymbolTableIdentifierList(root->identifierList);
  fprintf(stderr,"Sons list : \n");
  dumpSymbolTableTreeNodeList(root->sons);
  fprintf(stderr,"\n\n\n");
  struct symbolTableTreeNodeList* list = root->sons;
  while ( list != NULL )
    {
      dumpSymbolTable(list->data, i+1);
      list = list->next;
    }
}

void dumpSymbolTableTreeNodeList(struct symbolTableTreeNodeList* list)
{
  while(list != NULL)
    {
      fprintf(stderr,"\tnode : %p", list->data);
      list = list->next;
    }
}

void dumpSymbolTableIdentifierList(struct symbolTableIdentifierList* list)
{
  while(list != NULL)
    {
      fprintf(stderr,"\tname : %s, type : %d, offset : %d\n",
	      list->name, list->type, list->offset);
      list = list->next;
    }
}
