#include <stdlib.h>
#include <string.h>
#include <stdio.h>
#include "symtable.h"

/* Crée une liste pour la table des symbole à partir d'un premier élément */
Node* create_symtable(Node n){
	Node* newNode = malloc(sizeof(Node));
	if(newNode != NULL){
		newNode->type = n.type;
		newNode->addr = n.addr; /* Malloc la value selon le type */
		newNode->name = strdup(n.name);
		newNode->next = NULL;
		return newNode;
	}
	perror("Allocation error\n");
	exit(1);
}

/* Ajout un élément en début de la liste */
Node* add_start_to_symtable(Node n, Node* list){
	Node* newNode = malloc(sizeof(Node));
	if(newNode != NULL){
		newNode->type = n.type;
		newNode->addr = n.addr; /* Malloc la value selon le type */
		newNode->name = strdup(n.name);
		newNode->next = list;
		return newNode;	
	}
	perror("Allocation error");
	exit(1);
}

/* Ajoute un élément à la fin de la liste */
Node* add_end_to_symtable(Node n, Node* ln){
	Node* list = ln;
	Node* newNode = malloc(sizeof(Node));
	if(newNode != NULL){
		newNode->type = n.type;
		newNode->addr = n.addr; /* Malloc la value selon le type */
		newNode->name = strdup(n.name);
		newNode->next = NULL;
		while(list->next != NULL){
			list = list->next;
		}
		list->next = newNode;
		return ln;
	}
	perror("Allocation error");
	exit(1);
}

/* Cherche l'élément de nom n dans la liste */
int find_in_symtable(char* n, const Node* ln){
	Node* list_tmp = (Node*) ln;
	while(list_tmp != NULL && list_tmp->next != NULL){
		if(strcmp(list_tmp->name, n) == 0){
			return 1;
		}
		list_tmp = list_tmp->next;
	}
	return 0;
}

/* Retourne un pointeur vers le noeud de nom n s'il est présent dans la table des symboles, NULL sinon */
Node* get_node_from_symtable(char* n, const Node* list){
	Node* list_tmp = (Node*) list;
	while(list_tmp != NULL){
		if(!strcmp(n, list_tmp->name)){
			return list_tmp;
		}
		list_tmp = list_tmp->next;
	}
	return NULL;
}

/* destruction de la table des symbole */
void free_symtable(Node* ln){
	Node* ln_tmp;
	if(ln != NULL){
		while(ln != NULL){
			ln_tmp = ln->next;
			free(ln->name);
			free(ln);
			ln = ln_tmp;
		}
	}
}
