%{
    	#include <stdlib.h>
    	#include <stdio.h>
	#include <stdarg.h>
	#include <string.h>
	#include "symtable.h"
	
	#define PRINT(format, args...) printf(format, args)

	extern int yylineno;
	int yylex();
	int yyerror();
	
	//The symbol table
	Node* symTable;
%}

%union {
	char *str;
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

%type <num> comparison_expression
%type <num> additive_expression
%type <num> multiplicative_expression
%type <num> unary_expression
%type <num> postfix_expression;
%type <ch> primary_expression
%type <ch> assignment_operator;
%type <ch> type_name;
%type <ch> declarator;
%type <ch> unary_operator;

%%

primary_expression
: IDENTIFIER												{	PRINT("%s", $1);
														if(find_in_symtable($<ch>1, symTable) == 1){
															// Le symbole doit être trouvé
															// Sinon erreur ?
														}
														$<ch>$ = $<ch>1;
													}
| CONSTANT												{PRINT("%s", $1); $<ch>$ = $<str>1;}	
| IDENTIFIER '(' ')'											{PRINT("%s()", $1);}
| IDENTIFIER '(' {PRINT("%s%s", $1, "(");} argument_expression_list ')'{PRINT("%s", ")");}		
| IDENTIFIER INC_OP											{	PRINT("%s++", $1); $<ch>$ = $<ch>1;
														// On recupère le noeud grace au nom d'identifieur dans la table des
														// symboles et on change sa valeur (++)
													}
| IDENTIFIER DEC_OP											{	PRINT("%s--", $1); $<ch>$ = $<ch>1;
														// On recupère le noeud grace au nom d'identifieur dans la table des
														// symboles et on change sa valeur (--)
													}
;

postfix_expression
: primary_expression											
| postfix_expression '[' {PRINT("%s", "[");} expression ']' {PRINT("%s", "]");}
;

argument_expression_list
: expression						
| argument_expression_list ',' {PRINT("%s", ",");} expression
;

unary_expression
: postfix_expression											{$<num>$ = $<num>1;}
| INC_OP unary_expression										{	$<num>$ = ($<num>2 + 1);
														// On recupère le noeud grace au nom d'identifieur dans la table des
														// symboles et on change sa valeur (++)
													}
| DEC_OP unary_expression										{	$<num>$ = ($<num>2 - 1);
														// On recupère le noeud grace au nom d'identifieur dans la table des
														// symboles et on change sa valeur (--)
													}
| unary_operator unary_expression									{	switch($<ch>1[0]){
														case '*': $<num>$ = 1*($<num>2); break; //Weird ?
														case '+': $<num>$ = +($<num>2); break;
														case '-': $<num>$ = -($<num>2); break;
														}
													}											
;

unary_operator
: '*'													{PRINT("%s", "*"); $<ch>$ = "*";}
| '+'													{PRINT("%s", "+"); $<ch>$ = "+";}
| '-'													{PRINT("%s", "-"); $<ch>$ = "-";}
;

multiplicative_expression
: unary_expression 											{$<num>$ = $<num>1;}
| multiplicative_expression '*' {PRINT("%s", "*");} unary_expression					{$<num>$ = ($<num>1 * $<num>4);}
| multiplicative_expression '|' {PRINT("%s", "|");} unary_expression					{$<num>$ = ($<num>1 | $<num>4);} 
;

additive_expression
: multiplicative_expression										{$<num>$ = $<num>1;/*PAREIL*/}
| additive_expression '+' {PRINT("%s", "+");} multiplicative_expression					{$<num>$ = ($<num>1 + $<num>4); /*AREIL*/}
| additive_expression '-' {PRINT("%s", "-");} multiplicative_expression					{$<num>$ = ($<num>1 - $<num>4); /*PAREIL*/}			
;

comparison_expression
: additive_expression											{$<num>$ = $<num>1;}
| additive_expression '<' {PRINT("%s", "<");} additive_expression					{$<num>$ = ($<num>1 < $<num>4);}
| additive_expression '>' {PRINT("%s", ">");} additive_expression					{$<num>$ = ($<num>1 > $<num>4);}
| additive_expression LE_OP {PRINT("%s", "<=");} additive_expression					{$<num>$ = ($<num>1 <= $<num>4);}
| additive_expression GE_OP {PRINT("%s", ">=");} additive_expression					{$<num>$ = ($<num>1 >= $<num>4);}
| additive_expression EQ_OP {PRINT("%s", "==");} additive_expression					{$<num>$ = ($<num>1 == $<num>4);}
| additive_expression NE_OP {PRINT("%s", "!=");} additive_expression					{$<num>$ = ($<num>1 != $<num>4);}
;

expression
: unary_expression assignment_operator comparison_expression 						{	if(strcmp($<ch>2, "=") == 0){
															$<num>$ = $<num>3;
														// On recupère le noeud grace au nom d'identifieur dans la table des
														// symboles et on change sa valeur (assignation)
														}else if(strcmp($<ch>2, "*=") == 0){
															$<num>$ *= $<num>3;
														// On recupère le noeud grace au nom d'identifieur dans la table des
														// symboles et on change sa valeur (*=)
														}else if(strcmp($<ch>2, "+=") == 0){
															$<num>$ += $<num>3;
														// On recupère le noeud grace au nom d'identifieur dans la table des
														// symboles et on change sa valeur (+=)
														}else if(strcmp($<ch>2, "-=") == 0){
															$<num>$ -= $<num>3;
														// On recupère le noeud grace au nom d'identifieur dans la table des
														// symboles et on change sa valeur (-=)
														}
													}
| comparison_expression											
;

assignment_operator
: '='													{PRINT("%s", "= "); $<ch>$ = "=";}
| MUL_ASSIGN												{PRINT("%s", "*= "); $<ch>$ = "*=";}
| ADD_ASSIGN												{PRINT("%s", "+= "); $<ch>$ = "+=";}
| SUB_ASSIGN												{PRINT("%s", "-= "); $<ch>$ = "-=";}
;

declaration
: type_name declarator_list ';'										{	PRINT("%s", ";\n");
														// On insère un noeud dans la table des symboles
														// S'il s'agit d'un paramètre seul ou d'une liste de paramètres
														int type;
														if(strcmp($<ch>1, "void") == 0){
															type = 1;	
														}else if(strcmp($<ch>1, "int") == 0){
															type = 2;	
														}else if(strcmp($<ch>1, "float") == 0){
															type = 3;
														}
														char* param = strtok($<ch>2, ",");
														//Single param
														if(param == NULL){
															Node newNode;
															newNode.name = $<ch>2;
															newNode.type = type;
															symTable = add_to_symtable(newNode, symTable);
														}else{
														//Param list
															while(param != NULL){
																Node newNode;
																newNode.name = param;
																newNode.type = type;
																symTable = add_to_symtable(newNode, symTable);
																param = strtok(NULL, ",");
															}
														}
													}
;

declarator_list
: declarator												{$<ch>$ = $<ch>1;}							 
| declarator_list ',' {PRINT("%s", ",");} declarator							{	sprintf($<ch>$, "%s,%s", $<ch>1, $<ch>4);
														// On construit la liste de paramètre récupérée plus haut dans l'arbre
													}
;

type_name
: VOID  												{PRINT("%s", "void "); $<ch>$="void";}
| INT   												{PRINT("%s", "int "); $<ch>$="int";}
| FLOAT													{PRINT("%s", "float "); $<ch>$="float";}
;

declarator
: IDENTIFIER  												{PRINT("%s", $1); $<ch>$ = $<ch>1;}
| '(' {PRINT("%s", "(");} declarator {PRINT("%s", ")");} ')'						{$<ch>$ = $<ch>3;}			// ?
| declarator '[' CONSTANT ']'										{PRINT("[%s]", $3); $<ch>$ = $<ch>1;}
| declarator '[' ']'											{PRINT("%s", "[]"); $<ch>$ = $<ch>1;}
| declarator '(' {PRINT("%s", "");} parameter_list ')' {PRINT("%s", ")");}				{$<ch>$ = $<ch>1;}			// ?
| declarator '(' ')'											{PRINT("%s", "()"); $<ch>$ = $<ch>1;}
;

parameter_list
: parameter_declaration														
| parameter_list ',' {PRINT("%s", ",");} parameter_declaration			
;

parameter_declaration
: type_name declarator 											{}				
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
	    printf("\nSYMTABLE : %d, %d, %d, %d, %d\n", find_in_symtable("a", symTable), find_in_symtable("b", symTable), find_in_symtable("c", symTable), find_in_symtable("r", symTable), find_in_symtable("z", symTable));
	    free_symtable(symTable);    
    }
    return 0;
}
