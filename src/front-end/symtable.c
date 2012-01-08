#include <stdlib.h>
#include <string.h>
#include "symtable.h"

Node* add_to_symtable(Node n, Node* list){
	Node* newNode = malloc(sizeof(Node));
	newNode->type = n.type;
	newNode->value = n.value; /* Malloc la value selon le type */
	newNode->name = strdup(n.name);
	newNode->next = list;
	return newNode;	
}

int find_in_symtable(char* n, const Node* ln){
	while(ln != NULL && ln->next != NULL){
		if(strcmp(ln->name, n) == 0){
			return 1;
		}
		ln = ln->next;
	}
	return 0;
}

void free_symtable(Node* ln){
	if(ln != NULL){
		Node* ln_tmp;
		while(ln->next != NULL){
			ln_tmp = ln->next;
			free(ln->name);
			free(ln);
			ln = ln_tmp;
		}
		free(ln);
	}
}
