%{
    #include <stdio.h>
    #include <string.h>
    #define PRINT(format, args ...) {printf(format, args);}
    int yylex ();
    int yyerror ();
%}

%token<str> IDENTIFIER CONSTANT
%token INC_OP DEC_OP LE_OP GE_OP EQ_OP NE_OP
%token AND_OP OR_OP
%token SUB_ASSIGN MUL_ASSIGN ADD_ASSIGN
%token TYPE_NAME
%union {
	char *str;
}
%token INT FLOAT VOID

%token  IF ELSE GOTO RETURN

%start program
%%

primary_expression
: IDENTIFIER  
| CONSTANT 
| IDENTIFIER '(' ')' 
| IDENTIFIER '(' argument_expression_list ')' 
| IDENTIFIER INC_OP 
| IDENTIFIER DEC_OP 
;

postfix_expression
: primary_expression
| postfix_expression '[' expression ']' 
;

argument_expression_list
: primary_expression 
| argument_expression_list ',' primary_expression 
;

unary_expression
: postfix_expression
| INC_OP unary_expression {PRINT("%s %s", "inc", $2); $$=$2++;}
| DEC_OP unary_expression {PRINT("%s %s", "dec", $2); $$=$2--;}
| unary_operator unary_expression
;

unary_operator
: '+'
| '-'
;

comparison_expression
: unary_expression
| primary_expression '<' primary_expression   {PRINT("%s %s %s", "cmp", $1, $3); $$="jge";} 
| primary_expression '>' primary_expression   {PRINT("%s %s %s", "cmp", $1, $3); $$="jle";}
| primary_expression LE_OP primary_expression {PRINT("%s %s %s", "cmp", $1, $3); $$="jg";}
| primary_expression GE_OP primary_expression {PRINT("%s %s %s", "cmp", $1, $3); $$="jl";} 
| primary_expression EQ_OP primary_expression {PRINT("%s %s %s", "cmp", $1, $3); $$="jne";} 
| primary_expression NE_OP primary_expression {PRINT("%s %s %s", "cmp", $1, $3); $$="jeq";} 
;

expression
: unary_expression assignment_operator unary_expression {PRINT("%s %s %s", $2, $1, $3); $$=$1;}
| unary_expression
;

assignment_operator
: '='        {$$="mov";}
| MUL_ASSIGN {$$="mul";}
| ADD_ASSIGN {$$="add";}
| SUB_ASSIGN {$$="sub";}
;

declaration
: type_name declarator_list ';' 
;

declarator_list
: declarator
| declarator_list ',' declarator
;

type_name
: INT
| VOID
| FLOAT
;

declarator
: IDENTIFIER
| '(' declarator ')'
| declarator '[' CONSTANT ']'
| declarator '[' ']'
| declarator '(' parameter_list ')'
| declarator '(' ')'
;


parameter_list
: parameter_declaration
| parameter_list ',' parameter_declaration
;

parameter_declaration
: type_name declarator
;

statement
: labeled_statement
| compound_statement
| expression_statement
| selection_statement
| jump_statement
;

labeled_statement
: IDENTIFIER ':' statement
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
: ';'
| expression ';'
;

selection_statement
: IF '(' comparison_expression ')' statement {printf("\n"); PRINT("%s ", $3); int a = NEW_LABEL(); PRINT("%d ", a); printf("\n"); PRINT("%s ", $5); PRINT("%s : \n", a);}
;

jump_statement
: GOTO IDENTIFIER ';' {PRINT("%s %s", "jump", $2);}
| RETURN ';' {PRINT("%s", "pop");}
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
