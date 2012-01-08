%{
    	#include <stdio.h>
	#include <stdarg.h>
/*
	Ajout d'une macro pour print
*/
	
	#define PRINT(format, args...) printf(format, args)
	
/*
	Fin d'ajout
*/
    extern int yylineno;
    int yylex ();
    int yyerror ();

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
%type <num> primary_expression
%type <num> unary_expression
%type <num> postfix_expression;
%type <ch> assignment_operator;
%type <ch> type_name;
%type <ch> declarator;
%type <ch> unary_operator;

%%

primary_expression
: IDENTIFIER												{PRINT("%s", $1); $<num>$ = $<num>1;}
| CONSTANT												{PRINT("%s", $1); $<num>$ = $<num>1;}	
| IDENTIFIER '(' ')'											{PRINT("%s()", $1); $<num>$ = $<num>1;}
| IDENTIFIER '(' {PRINT("%s%s", $1, "(");} argument_expression_list ')'{PRINT("%s", ")");}		
| IDENTIFIER INC_OP											{PRINT("%s++", $1); $<num>$ = $<num>1+1;}
| IDENTIFIER DEC_OP											{PRINT("%s--", $1); $<num>$ = $<num>1-1;}
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
| INC_OP unary_expression										{$<num>$ = $<num>2+1;}
| DEC_OP unary_expression										{$<num>$ = $<num>2-1;}
| unary_operator unary_expression									{$<num>$ = $<num>1;}
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
: multiplicative_expression										{$<num>$ = $<num>1;}
| additive_expression '+' {PRINT("%s", "+");} multiplicative_expression					{$<num>$ = ($<num>1 + $<num>4); printf("\nResult is : %d\n", $<num>1 + $<num>4);}
| additive_expression '-' {PRINT("%s", "-");} multiplicative_expression					{$<num>$ = ($<num>1 - $<num>4);}			
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
: unary_expression assignment_operator comparison_expression 						
| comparison_expression											
;

assignment_operator
: '='													{PRINT("%s", "= "); $<ch>$ = "=";}
| MUL_ASSIGN												{PRINT("%s", "*= "); $<ch>$ = "*=";}
| ADD_ASSIGN												{PRINT("%s", "+= "); $<ch>$ = "+=";}
| SUB_ASSIGN												{PRINT("%s", "-= "); $<ch>$ = "-=";}
;

declaration
: type_name declarator_list ';'										{PRINT("%s", ";\n");}
;

declarator_list
: declarator																				 
| declarator_list ',' {PRINT("%s", ",");} declarator							
;

type_name
: VOID  												{PRINT("%s", "void "); $<ch>$="void";}
| INT   												{PRINT("%s", "int "); $<ch>$="int";}
| FLOAT													{PRINT("%s", "float "); $<ch>$="float";}
;

declarator
: IDENTIFIER  												{PRINT("%s", $1); $<ch>$=$<ch>1;}
| '(' {PRINT("%s", "(");} declarator {PRINT("%s", ")");} ')'						{$<ch>$ = $<ch>3;}
| declarator '[' CONSTANT ']'										{PRINT("[%s]", $3);}
| declarator '[' ']'											{PRINT("%s", "[]");}
| declarator '(' {PRINT("%s", "(");} parameter_list ')' {PRINT("%s", ")");}				
| declarator '(' ')'											{PRINT("%s", "()");}
;

parameter_list
: parameter_declaration														
| parameter_list ',' {PRINT("%s", ",");} parameter_declaration			
;

parameter_declaration
: type_name declarator 					
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
    return 0;
}
