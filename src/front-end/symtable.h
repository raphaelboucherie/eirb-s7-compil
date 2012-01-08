#ifndef __SYMTABLEH__
#define __SYMTABLEH__

/* Define const for types */
#define TYPE_UNDEF -4
#define TYPE_VOID -3
#define TYPE_INT -2
#define TYPE_FLOAT -1
//Every type >= 0 is a function with n parameters


typedef struct Node{
	int type;
	void* addr;
	char* name;
	struct Node* next;
} Node;


Node* create_symtable(Node n);
Node* add_start_to_symtable(Node n, Node* list);
Node* add_end_to_symtable(Node n, Node* list);
int find_in_symtable(char* n,const Node* ln);
void free_symtable(Node* ln);
#endif
