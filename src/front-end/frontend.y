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

%token <str> IDENTIFIER CONSTANT
%token INC_OP DEC_OP LE_OP GE_OP EQ_OP NE_OP
%token SUB_ASSIGN MUL_ASSIGN ADD_ASSIGN
%token TYPE_NAME
%token INT FLOAT VOID
%token IF ELSE WHILE RETURN FOR
%union {
	char *str;
}
%start program
%%

primary_expression
: IDENTIFIER												{PRINT("%s", $1);}
| CONSTANT												{PRINT("%s", $1);}	
| IDENTIFIER '(' ')'											{PRINT("%s()", $1);}											
| IDENTIFIER '(' {PRINT("%s%s", $1, "(");} argument_expression_list ')'{PRINT("%s", ")");}					
| IDENTIFIER INC_OP											
| IDENTIFIER DEC_OP											
;

postfix_expression
: primary_expression
| postfix_expression '[' expression ']'
;

argument_expression_list
: expression												
| argument_expression_list ',' expression
;

unary_expression
: postfix_expression
| INC_OP unary_expression
| DEC_OP unary_expression
| unary_operator unary_expression
;

unary_operator
: '*'													{PRINT("%s", "*");}
| '+'													{PRINT("%s", "+");}
| '-'													{PRINT("%s", "-");}
;

multiplicative_expression
: unary_expression
| multiplicative_expression '*' unary_expression
| multiplicative_expression '|' unary_expression
;

additive_expression
: multiplicative_expression
| additive_expression '+' multiplicative_expression
| additive_expression '-' multiplicative_expression
;

comparison_expression
: additive_expression
| additive_expression '<' additive_expression
| additive_expression '>' additive_expression
| additive_expression LE_OP additive_expression
| additive_expression GE_OP additive_expression
| additive_expression EQ_OP additive_expression
| additive_expression NE_OP additive_expression
;

expression
: unary_expression assignment_operator comparison_expression
| comparison_expression
;

assignment_operator
: '='													{PRINT("%s", "= ");}
| MUL_ASSIGN												{PRINT("%s", "*= ");}
| ADD_ASSIGN												{PRINT("%s", "+= ");}
| SUB_ASSIGN												{PRINT("%s", "-= ");}
;

declaration
: type_name declarator_list ';'										{PRINT("%s", ";\n");}
;

declarator_list
: declarator												 
| declarator_list ',' declarator
;

type_name
: VOID  												{PRINT("%s", "void ");}
| INT   												{PRINT("%s", "int ");}
| FLOAT													{PRINT("%s", "float ");}
;

declarator
: IDENTIFIER  												{PRINT("%s", $1);}
| '(' declarator ')'						
| declarator '[' CONSTANT ']'										{PRINT("[%s]", $3);}
| declarator '[' ']'											{PRINT("%s", "[]");}
| declarator '(' {PRINT("%s", "(");} parameter_list ')' {PRINT("%s", ")");}									
| declarator '(' ')'											{PRINT("%s", "()");}
;

parameter_list
: parameter_declaration						
| parameter_list ',' parameter_declaration			
;

parameter_declaration
: type_name declarator						
;

statement
: compound_statement											
| expression_statement 
| selection_statement
| iteration_statement
| jump_statement
;

compound_statement
: '{' '}'{PRINT("%s\n", "{}");}
| '{' {PRINT("%s\n", "{");} statement_list '}'	{PRINT("%s\n", "}");}
| '{' {PRINT("%s\n", "{");} declaration_list statement_list '}'	{PRINT("%s\n", "}");}
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
: ';'													{PRINT("%s\n", ";");}
| expression ';'											{PRINT("%s\n", ";");}
;

selection_statement
: IF '(' expression ')' statement
| IF '(' expression ')' statement ELSE statement
| FOR '(' expression_statement expression_statement expression ')' statement
;

iteration_statement
: WHILE '(' expression ')' statement
;

jump_statement
: RETURN ';'												{PRINT("%s\n", "return ;");}
| RETURN expression ';'												
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
: type_name declarator compound_statement
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
