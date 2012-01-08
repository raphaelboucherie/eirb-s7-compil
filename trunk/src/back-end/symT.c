#include "symT.h"

int getOffset()
{
  currentOffset+=4;
  return currentOffset;
}

int getSym(char* string)
{
  fprintf(stderr,"SEARCHING FOR SYMT ELEMENT : %s\n", string);
  struct symT* temp = symbolTable;
  while(temp != NULL)
    {
      fprintf(stderr,"%s = %s ??\n", string, temp->name);
      if (strcmp(temp->name,string) == 0)
	{
	  fprintf(stderr,"FOUND ! Returning offset : %d\n\n", temp->offset);
	  return temp->offset;
	}
      temp = temp->next;
    }
  fprintf(stderr,"NOT FOUND ! Returning -1\n\n");
  return -1;
}

void addSym(char* string, int type)
{
  struct symT* temp = malloc(sizeof(struct symT ) );
  fprintf(stderr,"CREATING SYMT ELEMENT\n");
  temp->name = strdup(string);
  fprintf(stderr,"name = %s\n", temp->name);
  if (type < 0)
    temp->offset=getOffset();
  else
    temp->offset=-1;
  fprintf(stderr,"offset = %d\n", temp->offset);
  temp->type = type;
  fprintf(stderr,"type = %d\n", temp->type);
  temp->next = symbolTable;
  symbolTable = temp;
  fprintf(stderr,"symbolTable = %p\n", symbolTable);
}
