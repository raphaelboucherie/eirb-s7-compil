%{



#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "utils.h"
#include "symT.h"

#define PRINT(format, args ...) {printf(format, args);}
  int yylex ();
  int yyerror ();

  

/*
  struct declarator_info {
    int value;
    int size;
  };
*/
  struct list_str
  {
    int value;
    struct list_str *next;
  };
  
  struct declarator_list
  {
    char* name;
    int size;
    struct delarator_list* next;
  };

 int searchOffset(char* sym) {
    int offset = getSym(sym);
    while(offset == type_UNDEFINED && symbolTable != NULL)
      symbolTable = symbolTable->next;
    if(offset==type_UNDEFINED && symbolTable == NULL)
      exit(1);
    return offset;
  }


  //global
  struct list_str * list = NULL; 

  %}

%token<str> IDENTIFIER CONSTANT
%token INC_OP DEC_OP LE_OP GE_OP EQ_OP NE_OP
%token AND_OP OR_OP
%token SUB_ASSIGN MUL_ASSIGN ADD_ASSIGN
%token<int> TYPE_NAME
%union {
  char *str;
  int* dinfo;
  int integer;
}
%token INT FLOAT VOID

%token  IF ELSE GOTO RETURN

%type <str> primary_expression postfix_expression argument_expression_list unary_expression 
%type <str> selection_statement statement unary_operator type_name comparison_expression
%type <str> expression assignment_operator
%type <dinfo> declarator declarator_list
%type <integer> parameter_list
%start program
%%

primary_expression
: IDENTIFIER {int o = searchOffset($1); $$=regOffset("%esp",o);} 

| CONSTANT  {$$=constToASMConst($1);}

| IDENTIFIER '(' ')' //{int o = searchOffset($1); $$="";} 

| IDENTIFIER '(' argument_expression_list ')' //{int o = searchOffset($1); $$="";} 

| IDENTIFIER INC_OP  {int o = searchOffset($1);
                      char* str = regOffset("%esp", o);
                      PRINT("%s %s \n", "inc", str); $$=str;}

| IDENTIFIER DEC_OP  {int o = searchOffset($1);
                      char* str = regOffset("%esp", o);
                      PRINT("%s %s \n", "dec", str); $$=str;} 
;

postfix_expression
: primary_expression {$$=$1;}
| postfix_expression '[' expression ']' 
;

argument_expression_list
: primary_expression 
| argument_expression_list ',' primary_expression 
;

unary_expression
: postfix_expression {$$=$1;}
| INC_OP unary_expression {PRINT("%s %s \n", "inc", $2); $$=$2;}
| DEC_OP unary_expression {PRINT("%s %s \n", "dec", $2); $$=$2;}
| unary_operator unary_expression {PRINT("%s \n", $2); $$=$2;}
;

unary_operator
: '+' {$$="+";}
| '-' {$$="-";}
;

comparison_expression
: unary_expression                            {PRINT("%s $0 %s \n", "cmp", $1); $$="jeq";} // NOT SURE ABOUT THIS ONE ( IF ( var ) => IF ( var != 0 ) ?  )
| primary_expression '<' primary_expression   {PRINT("%s %s %s \n", "cmp", $1, $3); $$="jge";} 
| primary_expression '>' primary_expression   {PRINT("%s %s %s \n", "cmp", $1, $3); $$="jle";}
| primary_expression LE_OP primary_expression {PRINT("%s %s %s \n", "cmp", $1, $3); $$="jg";}
| primary_expression GE_OP primary_expression {PRINT("%s %s %s \n", "cmp", $1, $3); $$="jl";} 
| primary_expression EQ_OP primary_expression {PRINT("%s %s %s \n", "cmp", $1, $3); $$="jne";} 
| primary_expression NE_OP primary_expression {PRINT("%s %s %s \n", "cmp", $1, $3); $$="jeq";} 
;

expression
: unary_expression assignment_operator unary_expression {PRINT("%s %s %s \n", $2, $3, $1); $$=$1;}
| unary_expression {$$=$1;}
;

assignment_operator
: '='        {$$="mov";}
| MUL_ASSIGN {$$="mul";}
| ADD_ASSIGN {$$="add";}
| SUB_ASSIGN {$$="sub";}
;

declaration
: type_name declarator_list ';' 
{
  struct declarator_list *declaratorList = (struct declarator_list*)$2;
  struct declarator_list *temp = NULL;
  do
    {
      addSym(declaratorList->name, $1);
      temp = declaratorList->next;
      free(declaratorList->name);
      free(declaratorList);
      declaratorList = temp;
    }
  while(temp != NULL);
}
;

declarator_list
: declarator {$$ = $1;}

| declarator_list ',' declarator 
{
  struct declarator_list *declaratorInfo = (struct declarator_list*)$3;
  struct declarator_list *declaratorList = (struct declarator_list*)$1;
  declaratorInfo->next = declaratorList;
  $$ = (int*) declaratorInfo; 
}
;

type_name
: INT     { $$ = type_INT; }
| VOID    { $$ = 0; } // Function
| FLOAT   { $$ = type_FLOAT; }
;

declarator
: IDENTIFIER {} //*/
{
  struct declarator_list *di = malloc(sizeof(struct declarator_list));
  di->name = strdup($1);
  di->size=0;
  $$=(int*)di;
} //*/
| '(' declarator ')' /*{
  struct declarator_info *di = malloc(sizeof(struct declarator_info));
  di->value=$<dinfo.value>2;
  di->size = 0;
  $$=*di;  
  }*/
| declarator '[' CONSTANT ']'/*{
struct declarator_info *di = malloc(sizeof(struct declarator_info));
di->value=$<dinfo.value>1;
di->size = $3;
$$=*di;  
}*/
| declarator '[' ']' /*{
struct declarator_info *di = malloc(sizeof(struct declarator_info));
di->value=$<dinfo.value>1;
di->size = 0;
$$=*di;  
}*/
| declarator '(' parameter_list ')'/* {
  struct declarator_info *di = malloc(sizeof(struct declarator_info));
  di->value=$<dinfo.value>1;
  di->size = $3;
  $$=*di;  
  }*/
| declarator '(' ')' /*{
struct declarator_info *di = malloc(sizeof(struct declarator_info));
di->value=$<dinfo.value>1;
di->size = 0;
$$=*di;  
}*/
;


parameter_list
: parameter_declaration {$$=0;}
| parameter_list ',' parameter_declaration {$$=0;}
;

parameter_declaration
: type_name declarator
;

statement
: labeled_statement {$$="1";}
| compound_statement {$$="1";}
| expression_statement {$$="1";}
| selection_statement {$$="1";}
| jump_statement {$$="1";}
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
: IF '(' comparison_expression ')' statement
 {char* lbl = newLabel("IF"); PRINT("%s %s\n", $3, lbl); PRINT("%s\n%s:\n", $5, lbl );}
;

jump_statement
: GOTO IDENTIFIER ';' {PRINT("%s %s", "jump", $2);}
| RETURN ';' 
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
