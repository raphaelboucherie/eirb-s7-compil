#include "stringList.h"
struct string* createStringList(){
  struct string* s= malloc(sizeof(struct string));
  s->str = NULL;
  s->next = NULL;
  return s;
}

struct string* addString2(struct string* current, char* str)
{
	struct string* new = malloc(sizeof(struct string));
	new->str = strdup(str);
	new->next = current;
	return new;
}
struct string* addStringEnd(struct string* current, char* str)
{
	struct string* new = malloc(sizeof(struct string));
	struct string* list =NULL;
	list = current;
	new->str = strdup(str);
	new->next = NULL;
	assert(new != NULL);
	if(list != NULL && list->str != NULL){
		while(list->next != NULL){
			list = list->next;
		}
		list->next = new;
		return current;
	}
	else if(list!= NULL) {
		list->str = new->str;
		return list;
	}
	else{
	  return new;
	}
}


struct string* addString(struct string* current, char* str, ...)
{
	va_list pa;
	va_start(pa,str);
	char line[256];
	vsprintf(line,str,pa);
	return addString2(current, line);
}

struct string* addStringList(struct string* current, struct string* new)
{
	assert(new != NULL);
	struct string* temp = new;
	while (temp->next != NULL)
	{
		assert(temp != current);
		temp = temp->next;
	}
	temp->next = current;
	return new;
}

void printString(struct string* s)
{
	struct string* temp = s;
	struct string* suivant = NULL;
	struct string* precedent = NULL;
	while(temp!=NULL)
	{
		suivant = temp->next;
		temp->next = precedent;
		precedent = temp;
		temp = suivant;
	}
	while(precedent!=NULL)
	{
		printf("%s", precedent->str);
		precedent = precedent->next;
	}
}
