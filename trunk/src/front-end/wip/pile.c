#include "pile.h"

struct pile* createPile(int size)
{
  struct pile* p = malloc( sizeof (struct pile*) );
  p->size = size;
  p->head = -1;
  p->array = malloc( sizeof (char*) * p->size );
  int i;
  for (i=0;i<p->size;i++)
    {
      p->array[i] = NULL;
    }
  return p;
}

void freePile(struct pile* p)
{
  int i;
  for (i=0;i<p->size;i++)
    {
      if(p->array[i]!=NULL)
	{
	  free(p->array[i]);
	}
    }
  free(p);
  p = NULL;
}

void push(char* string, struct pile* p)
{
  assert(p->head+1 < p->size);
  p->head++;
  p->array[p->head] = strdup(string);
}

char* pop(struct pile* p)
{
  assert(p->head!=-1);
  p->head--;
  return p->array[p->head+1];
}
