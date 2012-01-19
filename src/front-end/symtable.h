#ifndef __SYMTABLEH__
#define __SYMTABLEH__

/* Define const for types */
#define TYPE_CONSTANT -5
#define TYPE_UNDEF -4
#define TYPE_VOID -3
#define TYPE_INT -2
#define TYPE_FLOAT -1
/* Every type >= 0 is a function with n parameters */


typedef struct Identifier{
	char* name;
	int size;
	int dimension;
	struct Identifier* next;
} Identifier;

typedef struct Node{
	int type;
	void* addr;
	char* name;
	int size;
	int dimension;
	struct Node* next;
	struct Node* parent;
} Node;


Node* create_symtable(Node n);
Node* add_start_to_symtable(Node n, Node* list);
Node* add_end_to_symtable(Node n, Node* list);
int find_in_symtable(char* n, const Node* ln);
Node* get_node_from_symtable(char* n, const Node* list);
void free_symtable(Node* ln);

Identifier* create_identifier(Identifier id);
void free_identifier(Identifier* id);
#endif
