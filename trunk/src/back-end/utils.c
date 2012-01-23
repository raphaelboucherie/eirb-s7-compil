#include "utils.h"

char* regOffset(char* string, int a)
{
  char* str = malloc( sizeof ( char ) * 256 );
  sprintf(str,"-%d(%s)", a, string);
  return str;
}

char* constToASMConst(char* string)
{
  char* str = malloc( sizeof ( char ) * 256 );
  sprintf(str,"$%s",string);
  return str;
}

char* postfixExpressionToRegister(char* postfixExpression, 
				  struct symbolTableTreeNode* currentNode,
				  struct symbolTableTreeNode* root)
{
  fprintf(stderr,"Inspecting expression\n");
  fprintf(stderr,"expression = %s\n", postfixExpression);
  assert(postfixExpression != NULL);
  if (postfixExpression[0] == '$')
    {
      fprintf(stderr,"expression type = CONSTANT\n");
      // Expresssion is CONSTANT 
      return postfixExpression;
    }
  else if (postfixExpression[0] == '%' || postfixExpression[0] == '-')
    {
      fprintf(stderr,"expression type = register\n");
      // Expression is already in a register form
      return postfixExpression;
    }
  else
    {
      fprintf(stderr,"expression type = IDENTIFIER\n");
      // Expression is an identifier name, we need to transform it to a data offset
      int offset = searchOffset(postfixExpression,
				currentNode, root);
      return regOffset("%ebp",offset);
    }
}

int isIdentifier(char* expression)
{
  return expression[0] != '%' && expression[0] != '-' && expression[0] != '$' && expression[0] != '#';
}

int getAndCheckExpressions(char** reg1, char** reg3, 
			   struct symbolTableIdentifierList* id1,
			   struct symbolTableIdentifierList* id3,
			   char* expr1, char* expr3,
			   struct symbolTableTreeNode* symbolTableCurrentNode,
			   struct symbolTableTreeNode* symbolTableRoot)
{
  if (!(id1->type & 0b1)) // type_UNDEFINED
    *reg1 = regOffset("%ebp", id1->offset);
  else if (expr1[0] == '%') // register 
    *reg1 = expr1;
  else if (expr1[0] == '#') // Array[i]
    {
      char* identifier = strtok(expr1,"@#");
      int positions[256];
      int i = 0;
      char* position = strtok(NULL,"@#");
      // get all the in from ###id@i1@@i2@@i3
      do
	{
	  positions[i] = atoi(position);
	  i++;
	  position = strtok(NULL,"@#");
	}
      while(position != NULL);
      struct symbolTableIdentifierList* idArray =
	getIdentifier(identifier,symbolTableCurrentNode,symbolTableRoot);
      assert(idArray != NULL);
      if (i < idArray->nbArrayDimension)
	{
	  positions[i] = 0;
	  i++;
	}
      int offsetSize[256];
      // calcul de l'offset dans le(s) tableau(x)
      int j;
      for (j=0;j<i;j++)
	{
	  // offset = position * sizeOfDimension n 
	  int k = 0;
	  offsetSize[j] = positions[j]; 
	  for (k=j+1;k<i;k++)
	    offsetSize[j]*=idArray->dimensionSizes[k]; 
	}
      int totalOffset = 0;
      for (j=0;j<i;j++)
	totalOffset+= offsetSize[j];
      // L'offset total est la somme de ces offset + l'offset de base du tableau
      totalOffset *= 4; // float and int take 4 Bytes in memory
      totalOffset += idArray->offset;       
      *reg1 = regOffset("%ebp", totalOffset);
      fprintf(stderr,"Calculating array offset : %d\n", totalOffset);
    }
  else
    return 0;
  if (!(id3->type & 0b1)) // type_UNDEFINED
    *reg3 = regOffset("%ebp", id3->offset);
  else if (expr3[0] == '#') // Array[i]
    {
      char* identifier = strtok(expr3,"@#");
      int positions[256];
      int i = 0;
      char* position = strtok(NULL,"@#");
      // get all the in from @@@id@i1@@i2@@i3
      do
	{
	  positions[i] = atoi(position);
	  i++;
	  position = strtok(NULL,"@#");
	}
      while(position != NULL);
      struct symbolTableIdentifierList* idArray =
	getIdentifier(identifier,symbolTableCurrentNode,symbolTableRoot);
      assert(idArray != NULL);
      if (i < idArray->nbArrayDimension)
	{
	  positions[i] = 0;
	  i++;
	}

      int offsetSize[256];
      // calcul de l'offset dans le(s) tableau(x)
      int j;
      for (j=0;j<i;j++)
	{
	  // offset = position * sizeOfDimension n 
	  int k = 0;
	  offsetSize[j] = positions[j]; 
	  for (k=j+1;k<i;k++)
	    offsetSize[j]*=idArray->dimensionSizes[k]; 
	}
      int totalOffset = 0;
      for (j=0;j<i;j++)
	totalOffset+= offsetSize[j];
      // L'offset total est la somme de ces offset + l'offset de base du tableau
      totalOffset *= 4; // float and int take 4 Bytes in memory
      totalOffset += idArray->offset;       
      *reg3 = regOffset("%ebp", totalOffset);
      fprintf(stderr,"Calculating array offset : %d\n", totalOffset);
    }
  else
    *reg3 = expr3;
  return 1;
}
		
int getArraySize(char* array, struct symbolTableTreeNode* symbolTableCurrentNode, 
		 struct symbolTableTreeNode* symbolTableRoot)	   
{
  int i = 0;
  char* temp = strdup(array);
  char* identifier = strtok(temp,"@#");
  if(temp[0]=='#')
    {
      char* position = strtok(NULL,"@#");
      // get all the in from @@@id@i1@@i2@@i3
      do
	{
	  i++;
	  position = strtok(NULL,"@#");
	}
      while(position != NULL);
    }
  struct symbolTableIdentifierList* idArray =
    getIdentifier(identifier,symbolTableCurrentNode,symbolTableRoot);
  assert(idArray != NULL);
  return idArray->dimensionSizes[i];
}

int getArrayOffset(char* array, struct symbolTableTreeNode* symbolTableCurrentNode, 
		   struct symbolTableTreeNode* symbolTableRoot)
{
  if(array[0] != '#')
      return searchOffset(array,symbolTableCurrentNode,symbolTableRoot);      
  char* temp = strdup(array);
  char* identifier = strtok(temp,"@#");
  int positions[256];
  int i = 0;
  char* position = strtok(NULL,"@#");
  // get all the in from @@@id@i1@@i2@@i3
  do
    {
      positions[i] = atoi(position);
      i++;
      position = strtok(NULL,"@#");
    }
  while(position != NULL);
  struct symbolTableIdentifierList* idArray =
    getIdentifier(identifier,symbolTableCurrentNode,symbolTableRoot);
  assert(idArray != NULL);
  if (i < idArray->nbArrayDimension)
    {
      positions[i] = 0;
      i++;
    }

  int offsetSize[256];
  // calcul de l'offset dans le(s) tableau(x)
  int j;
  for (j=0;j<i;j++)
    {
      // offset = position * sizeOfDimension n 
      int k = 0;
      offsetSize[j] = positions[j]; 
      for (k=j+1;k<i;k++)
	offsetSize[j]*=idArray->dimensionSizes[k]; 
    }
  int totalOffset = 0;
  for (j=0;j<i;j++)
    totalOffset+= offsetSize[j];
  // L'offset total est la somme de ces offset + l'offset de base du tableau
  totalOffset *= 4; // float and int take 4 Bytes in memory
  totalOffset += idArray->offset;
  return totalOffset;
}

char* ASM_INIT()
{
  //  return "BITS 32\nSECTION .data\nSECTION .text\n\tGLOBAL _start\n\n_start:\n";
  return "\t.text\n";//.globl main\n\t.type	main, @function\nmain:\n\tpushl\t %ebp\n\tmovl\t %esp, %ebp\n\tsubl\t $16, %esp\n";
}

char* ASM_CLOSE()
{
  return "";//mov eax, 1\nint 0x80\n";
}

