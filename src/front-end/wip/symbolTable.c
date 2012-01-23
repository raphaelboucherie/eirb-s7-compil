#include "symbolTable.h"

struct symbolTableIdentifierList* createIdentifierList(char* name, int type, int dimension, int size, int get_by_addr)
{
  struct symbolTableIdentifierList* idList = malloc(sizeof (struct symbolTableIdentifierList));
  idList->name = strdup(name);
  idList->type = type;
  idList->dimension = dimension;
  idList->size = size;
  idList->get_by_addr = get_by_addr;
  idList->next = NULL;
  idList->defined = 0;
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
  node->code = NULL;
  node->currentOffset = 0;
  node->parameterSize=0;
  node->defined=0;
    
  if(father != NULL) 
    {
      LOG(stderr,"Création d'un nouveau fils : %p\n", node);
      struct symbolTableTreeNodeList * sons = malloc(sizeof(struct symbolTableTreeNodeList));
      sons->data = node;
      sons->next = father->sons;
      father->sons = sons;
    }
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

void addIdentifier (char* identifier, int type, int dimension, int size, int get_by_addr, 
		    struct symbolTableTreeNode* symbolTableCurrentNode)

{
  assert(!getIdentifierInList(identifier,symbolTableCurrentNode->identifierList) && 
	 "conflit avec un symbole déja présent dans la table"); 
//  assert(type != 0x10000 && // 0x10000 = type_FUNCTION
//	 "L'ajout de fonction dans la table ne doit pas utiliser cette fonction");
  LOG(stderr,"Ajout de l'identifier : %s\n", identifier);
  struct symbolTableIdentifierList* identifierData = 
    createIdentifierList(identifier,type,dimension, size, get_by_addr);
			 
  identifierData->next = symbolTableCurrentNode->identifierList;
  symbolTableCurrentNode->identifierList = identifierData;
  LOG(stderr,"Fin de l'ajout de l'identifier : %s\n", identifier);
}
/* Deprecated  
void addParameter(char * identifier, int size, int type, struct symbolTableTreeNode* symbolTableCurrentNode) {
  addIdentifier(identifier, size, type, symbolTableCurrentNode);
  symbolTableCurrentNode->parameterSize += size;
}

int getOffset(int size, struct symbolTableTreeNode* node)
{
  node->currentOffset+=(size*4);
  return node->currentOffset;
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
*/
void addSon(struct symbolTableTreeNode* node, 
	    struct symbolTableTreeNode* son)
{
  struct symbolTableTreeNodeList *nodeList = 
    createTreeNodeList(son);
  nodeList->next = node->sons;
  node->sons = nodeList;
  LOG(stderr,"Adding son to %p\n", node);
}

void dumpSymbolTable(struct symbolTableTreeNode* root, int i)
{
  LOG(stderr,"Node %s informations : \n", root->functionName);
  LOG(stderr,"Pointer = %p\n", root);
  LOG(stderr,"Current level : %d\n",i);
  LOG(stderr,"father = %p\n",root->father);
  LOG(stderr,"Symbol table informations : %s\n", "");
  dumpSymbolTableIdentifierList(root->identifierList);
  LOG(stderr,"Sons list : %s\n", "");
  dumpSymbolTableTreeNodeList(root->sons);
  LOG(stderr,"\n\n\n%s", "");
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
      LOG(stderr,"\tnode : %p", list->data);
      list = list->next;
    }
}

void dumpSymbolTableIdentifierList(struct symbolTableIdentifierList* list)
{
  while(list != NULL)
    {
      LOG(stderr,"\tname : %s, type : %d, size : %d, dimension : %d\n",
	      list->name, list->type, list->size, list->dimension);
      list = list->next;
    }
}

struct symbolTableTreeNode * getFunctionNode(struct symbolTableTreeNode *root, char * name) 
{
  struct symbolTableTreeNodeList * sons = root->sons;
  while(sons != NULL) {
    LOG(stderr, "comparaison %s %s .\n", sons->data->functionName, name);
    if(!strcmp(sons->data->functionName, name)) {
      return sons->data;
    }
    else
      sons = sons->next;
  }
   return NULL;
}
