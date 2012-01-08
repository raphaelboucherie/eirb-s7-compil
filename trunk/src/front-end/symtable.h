#ifndef __SYMTABLEH__
#define __SYMTABLEH__
typedef struct Node{
	int type;
	void* value;
	char* name;
	struct Node* next;
} Node;


Node* add_to_symtable(Node n, Node* list);
int find_in_symtable(char* n,const Node* ln);
void free_symtable(Node* ln);
#endif
