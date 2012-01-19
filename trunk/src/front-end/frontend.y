%{
    	#include <stdlib.h>
    	#include <stdio.h>
	#include <stdarg.h>
	#include <string.h>
	#include <sys/time.h>
	#include "symtable.h"
	#include "derivationtree.h"
	#include "checktype.h"
	#include "pile.h"
	#include "generate2a.h"
	
	#define PRINT(format, args...) printf(format, args)

	extern int yylineno;
	int yylex();
	int yyerror();
	static int var_identifier = 1;
	
	//The symbol table
	Node* symTable;
	// The derivation tree
	TreeNode* dt;

	void displaySymTable(const Node* list){
		Node* list_tmp = (Node*) list;
		while(list_tmp != NULL){
			char* type;
			switch(list_tmp->type){
				case TYPE_UNDEF: type = "UNDEF"; break;
				case TYPE_VOID: type = "VOID"; break;

				case TYPE_INT: type = "INT"; break;
				case TYPE_FLOAT: type = "FLOAT"; break;
				default : list_tmp = list_tmp->next; continue;
			}
			printf("Symbol : %s ", list_tmp->name);
			printf("(type = %s)", type);
			printf("(size = %d)", list_tmp->size);
			printf("(dim = %d)\n", list_tmp->dimension);
			list_tmp = list_tmp->next;
		}
	}
	
	int getNewId(){
		return var_identifier++;
	}
	
	/* Label for loops */
	static int for_label = 0;	
	static int while_label = 0;
	char label[256];
	struct pile* pile_for = NULL;
	struct pile* pile_while = NULL;
	struct pile* stack = NULL;
%}

%union {
	char *str;
	void* tn;
	void* id;
	int num;
	char* ch;
}

%token <str> IDENTIFIER CONSTANT
%token INC_OP DEC_OP LE_OP GE_OP EQ_OP NE_OP
%token SUB_ASSIGN MUL_ASSIGN ADD_ASSIGN
%token TYPE_NAME
%token INT FLOAT VOID
%token IF ELSE WHILE RETURN FOR

%start program

%type <tn> comparison_expression
%type <tn> additive_expression
%type <tn> multiplicative_expression
%type <tn> unary_expression
%type <tn> postfix_expression;
%type <tn> primary_expression
%type <ch> assignment_operator;
%type <ch> type_name;
%type <id> declarator;
%type <id> declarator_list;
%type <ch> unary_operator;

%%

primary_expression
: IDENTIFIER												
	{
		PRINT("%s", $1);
		if(find_in_symtable($<ch>1, symTable) == 0){
			yyerror("Identificateur introuvable ! \n");
			exit(1);
		}														
		$$ = (void*) create_tree_node($<ch>1);
	}
| CONSTANT
	{	
		PRINT("%s", $1); $<ch>$ = $<str>1;	
		$$ = (void*) create_tree_node($<ch>1);
	}	
| IDENTIFIER '(' ')'											
	{
		PRINT("%s()", $1);	
	}
| IDENTIFIER '(' {PRINT("%s%s", $1, "(");} argument_expression_list ')'
	{
		PRINT("%s", ")");
	}		
| IDENTIFIER INC_OP											
	{
		PRINT("%s++", $1); 
		TreeNode* op = create_tree_node("++"); 
		TreeNode* var = create_tree_node($<ch>1); 
		set_left(op, var);
		$$ = (void*) op;
	}
| IDENTIFIER DEC_OP											
	{
		PRINT("%s--", $1); 
		TreeNode* op = create_tree_node("--"); 
		TreeNode* var = create_tree_node($<ch>1); 
		set_left(op, var);
		$$ = (void*) op;
	}
;

postfix_expression
: primary_expression	
	{
		$$ = $<tn>1;
	}
| postfix_expression '[' {PRINT("%s", "[");} expression ']' 
	{	/* A Voir ? */
		PRINT("%s", "]");
	} 
;

argument_expression_list
: expression						
| argument_expression_list ',' {PRINT("%s", ",");} expression
;

unary_expression
: postfix_expression		
	{
		$$ = $<tn>1;
	}				
| INC_OP unary_expression										
	{
		TreeNode* op = create_tree_node("++"); 
		set_left(op, (TreeNode*) $<tn>2);
		$$ = (void*) op;
	}

| DEC_OP unary_expression										
	{
		TreeNode* op = create_tree_node("--"); 
		set_left(op, (TreeNode*) $<tn>2);
		$$ = (void*) op;
	}
| unary_operator unary_expression
	{
		TreeNode* op = create_tree_node($<ch>1); 
		set_left(op, (TreeNode*) $<tn>2);
		$$ = (void*) op;									
	}
;

unary_operator
: '*'			{PRINT("%s", "*"); $<ch>$ = "*";}
| '+'			{PRINT("%s", "+"); $<ch>$ = "+";}
| '-'			{PRINT("%s", "-"); $<ch>$ = "-";}
;

multiplicative_expression
: unary_expression 			
	{
		$$ = $<tn>1;
	}
| multiplicative_expression '*' {PRINT("%s", "*");} unary_expression					
	{
		TreeNode* op = create_tree_node("*"); 
		set_right(op, (TreeNode*) $<tn>4);
		set_left(op, (TreeNode*) $<tn>1);
		$$ = (void*) op;
	}

| multiplicative_expression '|' {PRINT("%s", "|");} unary_expression
	{
		TreeNode* op = create_tree_node("|"); 
		set_right(op, (TreeNode*) $<tn>4);
		set_left(op, (TreeNode*) $<tn>1);
		$$ = (void*) op;
	}
;

additive_expression
: multiplicative_expression	
	{
		$$ = $<tn>1;
	}
| additive_expression '+' {PRINT("%s", "+");} multiplicative_expression		
	{		
		TreeNode* op = create_tree_node("+"); 
		set_right(op, (TreeNode*) $<tn>4);
		set_left(op, (TreeNode*) $<tn>1);
		$$ = (void*) op;
	}				
| additive_expression '-' {PRINT("%s", "-");} multiplicative_expression					
	{
		TreeNode* op = create_tree_node("-"); 
		set_right(op, (TreeNode*) $<tn>4);
		set_left(op, (TreeNode*) $<tn>1);
		$$ = (void*) op;
	}													
;

comparison_expression
: additive_expression	
	{
		$$ = $<tn>1;
	}
| additive_expression '<' {PRINT("%s", "<");} additive_expression
	{
		TreeNode* op = create_tree_node("<"); 
		set_right(op, (TreeNode*) $<tn>4);
		set_left(op, (TreeNode*) $<tn>1);
		$$ = (void*) op;
	}
| additive_expression '>' {PRINT("%s", ">");} additive_expression
	{
		TreeNode* op = create_tree_node(">"); 
		set_right(op, (TreeNode*) $<tn>4);
		set_left(op, (TreeNode*) $<tn>1);
		$$ = (void*) op;
	}
| additive_expression LE_OP {PRINT("%s", "<=");} additive_expression					
	{
		TreeNode* op = create_tree_node("<="); 
		set_right(op, (TreeNode*) $<tn>4);
		set_left(op, (TreeNode*) $<tn>1);
		$$ = (void*) op;
	}

| additive_expression GE_OP {PRINT("%s", ">=");} additive_expression					
	{
		TreeNode* op = create_tree_node(">="); 
		set_right(op, (TreeNode*) $<tn>4);
		set_left(op, (TreeNode*) $<tn>1);
		$$ = (void*) op;
	}

| additive_expression EQ_OP {PRINT("%s", "==");} additive_expression				
	{
		TreeNode* op = create_tree_node("=="); 
		set_right(op, (TreeNode*) $<tn>4);
		set_left(op, (TreeNode*) $<tn>1);
		$$ = (void*) op;
	}

| additive_expression NE_OP {PRINT("%s", "!=");} additive_expression					
	{
		TreeNode* op = create_tree_node("!="); 
		set_right(op, (TreeNode*) $<tn>4);
		set_left(op, (TreeNode*) $<tn>1);
		$$ = (void*) op;
	}
;
 
expression
: unary_expression assignment_operator comparison_expression 	
	{
		TreeNode* dt = create_tree_node($<ch>2);  
		TreeNode* var = (TreeNode*) $<tn>1; 
		set_left(dt, var);
		set_right(dt, (TreeNode*) $<tn>3);
		
		printf("\n----- TREE ------ \n"); 
		print_tree_node(dt, 0); 
		printf("\n----- END TREE ------ \n");
		printf("\n----- TYPE VALIDATION ------ \n"); 
		int ret = check_type(dt, symTable);
		if(ret == TYPE_UNDEF){
			printf("Expression type : UNDEF\n");
		}else{
			switch(ret){
				case TYPE_INT: printf("Expression type : INT\n"); break;
				case TYPE_FLOAT: printf("Expression type : FLOAT\n"); break;
				case TYPE_UNDEF: printf("Expression type : UNDEF\n"); break;
				default : printf("Expression type : %d\n", ret);
			}
		}
		printf("\n----- END TYPE VALIDATION ------ \n"); 				
		printf("tree lenght : %d\n", tree_length(dt));
		tree_to_2a_code(dt, symTable);
		
		free_tree_node(dt); 
	}
| comparison_expression
	{
		
		printf("\n----- TREE ------ \n"); 
		print_tree_node($<tn>1, 0); 
		printf("\n----- END TREE ------ \n");
		
	}		
;

assignment_operator
: '='				{PRINT("%s", "="); $<ch>$ = "=";}
| MUL_ASSIGN			{PRINT("%s", "*="); $<ch>$ = "*=";}
| ADD_ASSIGN			{PRINT("%s", "+="); $<ch>$ = "+=";}
| SUB_ASSIGN			{PRINT("%s", "-="); $<ch>$ = "-=";}
;

declaration
: type_name declarator_list ';'						
	{	PRINT("%s", ";\n");
		// On insère un noeud dans la table des symboles
		// S'il s'agit d'un paramètre seul ou d'une liste de paramètres
		int type;
		if(strcmp($<ch>1, "void") == 0){
			type = TYPE_VOID;	
		}
		else if(strcmp($<ch>1, "int") == 0){
			type = TYPE_INT;	
		}
		else if(strcmp($<ch>1, "float") == 0){
			type = TYPE_FLOAT;
		}
		else{
			type = TYPE_UNDEF;
		}
		Identifier* _ids = $<id>2;
		
		//Parcours de la liste d'identifieurs (permettant de recuperer la taille d'un potentiel tableau multidimensionnel...)
		do{
			Node newNode;
			newNode.name = _ids->name;
			newNode.type = type;
			newNode.size = _ids->size;
			newNode.dimension = _ids->dimension;
			symTable = add_start_to_symtable(newNode, symTable);
			Identifier* tmp = _ids;
			_ids = _ids->next;
			free_identifier(tmp);
		}while(_ids != NULL);
	}
;

declarator_list
: declarator												
	{
		$<id>$ = $<id>1;
	}
| declarator_list ',' {PRINT("%s", ",");} declarator							
	{	
		Identifier* _id = $<id>4;
		_id->next = $<id>1;
		$<id>$ = $<id>4;
	}
;

type_name
: VOID					{PRINT("%s", "void "); $<ch>$="void";}
| INT 					{PRINT("%s", "int "); $<ch>$="int";}
| FLOAT					{PRINT("%s", "float "); $<ch>$="float";}
;

declarator
: IDENTIFIER  												
	{
		PRINT("%s", $1); 
		Identifier id;
		id.name = $1;
		id.size = 1;
		id.dimension = 0;
		$<id>$ = create_identifier(id);
	}
| '(' {PRINT("%s", "(");} declarator {PRINT("%s", ")");} ')'									
| declarator '[' CONSTANT ']'			
	{
		PRINT("[%s]", $3); 
		if($<id>1 != NULL){
			Identifier* _id = $<id>1;
			_id->size *= atoi($3);
			_id->dimension++;
			$<id>$ = _id;
		}
	}
| declarator '[' ']'											
	{
		PRINT("%s", "[]"); 
		if($<id>1 != NULL){
			Identifier* _id = $<id>1;
			$<id>$ = _id;
		}
	}
| declarator '(' {PRINT("%s", "(");} parameter_list ')' 
	{
		PRINT("%s", ")");
	}							
| declarator '(' ')'											
	{
		PRINT("%s", "()"); 
	}
;

parameter_list
: parameter_declaration														
| parameter_list ',' {PRINT("%s", ",");} parameter_declaration						
;

parameter_declaration
: type_name declarator 											
	{	
		int type;
		if(strcmp($<ch>1, "void") == 0){
			type = TYPE_VOID;	
		}
		else if(strcmp($<ch>1, "int") == 0){
			type = TYPE_INT;
		}
		else if(strcmp($<ch>1, "float") == 0){
			type = TYPE_FLOAT;
		}
		else{
			type = TYPE_UNDEF;
		}
		Identifier* _id = $<id>2;
		Node newNode;
		newNode.name = _id->name;
		newNode.type = type;
		newNode.size = _id->size;
		newNode.dimension = _id->dimension;
		symTable = add_start_to_symtable(newNode, symTable);
		free_identifier(_id);
	}
;

statement
: compound_statement											
| expression_statement {PRINT("%s", "\n");}
| selection_statement
| iteration_statement
| jump_statement
;

compound_statement
: '{' '}'
| '{' statement_list '}' 
| '{' declaration_list statement_list '}'
;

declaration_list
: declaration																			
| declaration_list declaration
;

statement_list
: statement												
| statement_list statement
;

expression_statement
: ';'				{PRINT("%s", ";");}
| expression ';'		{PRINT("%s", ";");}
;

/*Fonctionnement GCC : Les blocs if et else sont gérés séparément. Quand un bloc else est évalué, il est rattaché au bloc if le plus proche*/
selection_statement /* TODO Refaire le traitement des if else ! */
: IF '('  expression ')'  statement {PRINT("%s\n", "if only");}
| IF '(' expression ')'  statement  ELSE statement {PRINT("%s\n", "if else");}
/* STRCAT SEGFAULT ! */
| FOR '(' {sprintf(label, "%s_%d", ".for", for_label); push(label, pile_for); PRINT("%s:\n", label); for_label++; } expression_statement expression_statement expression  ')' {PRINT("%s\n", ")");} statement {PRINT("goto %s\n", pop(pile_for));}
;

iteration_statement
: WHILE '('{sprintf(label, "%s_%d", ".while", while_label); push(label, pile_while); PRINT("%s:\n", label); while_label++; } expression ')' {PRINT("%s", ")");} statement {PRINT("goto %s\n", pop(pile_while));}
;

jump_statement
: RETURN ';'												
	{
		PRINT("%s\n", "return ;");
	}
| RETURN {PRINT("%s", "return ");} expression ';' 
	{
		PRINT("%s\n", ";");
	}
;

program
: external_declaration
| program external_declaration
;

external_declaration
: function_definition
| declaration
;

function_definition
: type_name declarator {PRINT("%s\n", "{");} compound_statement {PRINT("%s\n", "}");}
;

%%
#include <stdio.h>
#include <string.h>

extern char yytext[];
extern int column;
extern int yylineno;
extern FILE *yyin;

char *file_name = NULL;

int yyerror (char *s) {
    fflush (stdout);
    fprintf (stderr, "%s:%d:%d: %s\n", file_name, yylineno, column, s);
    return 0;
}

int main (int argc, char *argv[]) {
    FILE *input = NULL;
    
    //SymTable Creation
    Node n;
	n.name = "";
    symTable = create_symtable(n);
	pile_for = createPile(100);
	stack = createPile(100);
	pile_while = createPile(100);
    
    if(argc==2) {
		input = fopen (argv[1], "r");
		file_name = strdup (argv[1]);
		if (input) {
	    	yyin = input;
		}
		else {
	    	fprintf (stderr, "Could not open %s\n", argv[1]);
	    	return 1;
		}
    }
    else{
		fprintf (stderr, "%s: error: no input file\n", *argv);
		return 1;
    }
    yyparse ();
    free (file_name);
    
    //SymTable Memory Free
    if(symTable != NULL){
	    displaySymTable(symTable);
	    free_symtable(symTable);    
    }
    return 0;
}
