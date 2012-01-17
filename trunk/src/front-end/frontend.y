%{
    	#include <stdlib.h>
    	#include <stdio.h>
	#include <stdarg.h>
	#include <string.h>
	#include <sys/time.h>
	#include "symtable.h"
	#include "derivationtree.h"
	
	#define PRINT(format, args...) printf(format, args)

	extern int yylineno;
	int yylex();
	int yyerror();
	
	//The symbol table
	Node* symTable;
	
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
			printf("(%s)\n", type);
			list_tmp = list_tmp->next;
		}
	}
	
	int getNewId(){
		int id_gen;
		return abs((int)(&id_gen));
	}
%}

%union {
	char *str;
	void* tn;
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
%type <ch> declarator;
%type <ch> unary_operator;

%%

primary_expression
: IDENTIFIER												{	PRINT("%s", $1);
														if(find_in_symtable($<ch>1, symTable) == 0){
															yyerror("Indentificateur introuvable ! \n");
															exit(1);
														}
														
$$ = (void*) create_tree_node($<ch>1);

													}
| CONSTANT												{	PRINT("%s", $1); $<ch>$ = $<str>1;	}	
| IDENTIFIER '(' ')'											{	PRINT("%s()", $1);	}
| IDENTIFIER '(' {PRINT("%s%s", $1, "(");} argument_expression_list ')'{PRINT("%s", ")");}		
| IDENTIFIER INC_OP											{	PRINT("%s++", $1); $<ch>$ = $<ch>1;	}
| IDENTIFIER DEC_OP											{	PRINT("%s--", $1); $<ch>$ = $<ch>1;	}
;

postfix_expression
: primary_expression	{$$ = $<tn>1;}
| postfix_expression '[' {PRINT("%s", "[");} expression ']' {PRINT("%s", "]");}
;

argument_expression_list
: expression						
| argument_expression_list ',' {PRINT("%s", ",");} expression
;

unary_expression
: postfix_expression		{$$ = $<tn>1;}				
| INC_OP unary_expression										{PRINT("%s", "+=1");}
| DEC_OP unary_expression										{PRINT("%s", "-=1");}
| unary_operator unary_expression									
;

unary_operator
: '*'													{PRINT("%s", "*"); $<ch>$ = "*";}
| '+'													{PRINT("%s", "+"); $<ch>$ = "+";}
| '-'													{PRINT("%s", "-"); $<ch>$ = "-";}
;

multiplicative_expression
: unary_expression 			{$$ = $<tn>1;}
| multiplicative_expression '*' {PRINT("%s", "*");} unary_expression					{/*Génération de code 2 adresses*/}
| multiplicative_expression '|' {PRINT("%s", "|");} unary_expression					{/*Génération de code 2 adresses*/} 
;

additive_expression
: multiplicative_expression	{$$ = $<tn>1;}
| additive_expression '+' {PRINT("%s", "+");} multiplicative_expression		{														
//PRINT("id_%d=", getNewId());
TreeNode* op = create_tree_node("+"); 
set_right(op, (TreeNode*) $<tn>4);
set_left(op, (TreeNode*) $<tn>1);
$$ = (void*) op;
}				
| additive_expression '-' {PRINT("%s", "-");} multiplicative_expression					{/*Génération de code 2 adresses*/
														PRINT("id_%d=", getNewId());
													}
;

comparison_expression
: additive_expression	{$$ = $<tn>1;}
| additive_expression '<' {PRINT("%s", "<");} additive_expression					{/*Génération de code 2 adresses*/}
| additive_expression '>' {PRINT("%s", ">");} additive_expression					{/*Génération de code 2 adresses*/}
| additive_expression LE_OP {PRINT("%s", "<=");} additive_expression					{/*Génération de code 2 adresses*/}
| additive_expression GE_OP {PRINT("%s", ">=");} additive_expression					{/*Génération de code 2 adresses*/}
| additive_expression EQ_OP {PRINT("%s", "==");} additive_expression					{/*Génération de code 2 adresses*/}
| additive_expression NE_OP {PRINT("%s", "!=");} additive_expression					{/*Génération de code 2 adresses*/}
;

expression
: unary_expression assignment_operator comparison_expression 	
{
TreeNode* dt = (TreeNode*) $<tn>1;  

TreeNode* op = create_tree_node($<ch>2); 

set_left(dt, op);

set_right(op, (TreeNode*) $3); 

printf("\n----- TREE ------ \n"); 
	print_tree_node(dt, 0); 
printf("\n----- END TREE ------ \n");

free_tree_node(dt); 

}
| comparison_expression										
;

assignment_operator
: '='													{PRINT("%s", "="); $<ch>$ = "=";}
| MUL_ASSIGN												{PRINT("%s", "*="); $<ch>$ = "*=";}
| ADD_ASSIGN												{PRINT("%s", "+="); $<ch>$ = "+=";}
| SUB_ASSIGN												{PRINT("%s", "-="); $<ch>$ = "-=";}
;

declaration
: type_name declarator_list ';' {PRINT("%s", ";\n");}						{	
												// On insère un noeud dans la table des symboles
												// S'il s'agit d'un paramètre seul ou d'une liste de paramètres
														int type;
														if(strcmp($<ch>1, "void") == 0){
															type = TYPE_VOID;	
														}else if(strcmp($<ch>1, "int") == 0){
															type = TYPE_INT;	
														}else if(strcmp($<ch>1, "float") == 0){
															type = TYPE_FLOAT;
														}else{
															type = TYPE_UNDEF;
														}
														char* param = strtok($<ch>2, ",");
														//Single param
														if(param == NULL){
															Node newNode;
															newNode.name = $<ch>2;
															newNode.type = type;
															symTable = add_start_to_symtable(newNode, symTable);
														}else{
														//Param list
															while(param != NULL){
																Node newNode;
																newNode.name = param;
																newNode.type = type;
																symTable = add_start_to_symtable(newNode, symTable);
																param = strtok(NULL, ",");
															}
														}
													}
;

declarator_list
: declarator												{$<ch>$ =$<ch>1;}
| declarator_list ',' {PRINT("%s", ",");} declarator							{	
											// On construit la liste de paramètre récupérée plus haut dans l'arbre
														sprintf($<ch>$, "%s,%s", $<ch>1, $<ch>4);
													}
;

type_name
: VOID  												{PRINT("%s", "void "); $<ch>$="void";}
| INT   												{PRINT("%s", "int "); $<ch>$="int";}
| FLOAT													{PRINT("%s", "float "); $<ch>$="float";}
;

declarator
: IDENTIFIER  												{PRINT("%s", $1); $<ch>$ = $<ch>1;}
| '(' {PRINT("%s", "(");} declarator {PRINT("%s", ")");} ')'									
| declarator '[' CONSTANT ']'										{PRINT("[%s]", $3); $<ch>$ = $<ch>1;}
| declarator '[' ']'											{PRINT("%s", "[]"); $<ch>$ = $<ch>1;}
| declarator '(' {PRINT("%s", "(");} parameter_list ')' {PRINT("%s", ")");}							
| declarator '(' ')'											{PRINT("%s", "()"); $<ch>$ = $<ch>1;}
;

parameter_list
: parameter_declaration														
| parameter_list ',' {PRINT("%s", ",");} parameter_declaration						
;

parameter_declaration
: type_name declarator 											{	int type;
														if(strcmp($<ch>1, "void") == 0){
															type = TYPE_VOID;	
														}else if(strcmp($<ch>1, "int") == 0){
															type = TYPE_INT;	
														}else if(strcmp($<ch>1, "float") == 0){
															type = TYPE_FLOAT;
														}else{
															type = TYPE_UNDEF;
														}
														Node newNode;
														newNode.name = $<ch>2;
														newNode.type = type;
														symTable = add_start_to_symtable(newNode, symTable);
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
: ';'													{PRINT("%s", ";");}
| expression ';'											{PRINT("%s", ";");}
;

/*Fonctionnement GCC : Les blocs if et else sont gérés séparément. Quand un bloc else est évalué, il est rattaché au bloc if le plus proche*/
selection_statement
: IF '(' {PRINT("%s(", "if");} expression ')' {PRINT("%s\n", ") {");} statement {PRINT("%s\n", "}");}
| FOR '(' {PRINT("%s(", "for");} expression_statement expression_statement expression ')' {PRINT("%s\n", ") {");} statement {PRINT("%s\n", "}");}
| ELSE {PRINT("%s", "else {");} statement {PRINT("%s\n", "}");}
|
;

iteration_statement
: WHILE '(' {PRINT("%s(", "while");} expression ')' {PRINT("%s", ")");} statement
;

jump_statement
: RETURN ';'												{PRINT("%s\n", "return ;");}
| RETURN {PRINT("%s", "return ");} expression ';' {PRINT("%s\n", ";");}												
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
    
    if (argc==2) {
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
    else {
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
