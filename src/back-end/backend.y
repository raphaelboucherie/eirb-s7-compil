%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#define PRINT(format, args ...) {printf(format, args);}
  int yylex ();
  int yyerror ();

  /* Symbol table part */



  int currentOffset = 0;
  struct symT* symbolTable = NULL;    

  const int type_UNDEFINED = -3;
  const int type_FLOAT = -2;
  const int type_INT = -1;
  // everything from 0 to n is a function with n parameters
/*
  struct declarator_info {
    int value;
    int size;
  };
*/
  struct list_str{
    int value;
    struct list_str *next;
  };

  struct symT
  {
    int offset;
    char* name;
    struct symT* next;
    int type;
  };

  int getOffset()
  {
    currentOffset+=4;
    return currentOffset;
  }

  int getSym(char* string)
  {
    struct symT* temp = symbolTable;
    while(temp != NULL)
    {
      if (strcmp(temp->name,string) == 0)
      {
        return temp->offset;
      }
      temp = temp->next;
    }
    return -1;
  }

  void addSym(char* string, int type)
  {
    struct symT* temp = malloc(sizeof(struct symT ) );
    strcpy(temp->name,string);
    temp->offset=getOffset();
    temp->type = type;
    temp->next = symbolTable;
    symbolTable = temp->next;
  }



  int searchOffset(char * sym) {
    int offset = getSym(sym);
    while(offset == type_UNDEFINED && symbolTable != NULL)
      symbolTable = symbolTable->next;
    if(offset==type_UNDEFINED && symbolTable == NULL)
      exit(1);
    return offset;
  }

  /* Symbol table END */ 

  /* Label managament */
  int labelNumber = 0;

  int newLabel()
  {
    labelNumber++;
    return labelNumber;
  }

  /* Label management END */
  //global
  struct list_str * list = NULL; 

  %}

%token<str> IDENTIFIER CONSTANT
%token INC_OP DEC_OP LE_OP GE_OP EQ_OP NE_OP
%token AND_OP OR_OP
%token SUB_ASSIGN MUL_ASSIGN ADD_ASSIGN
%token TYPE_NAME
%union {
  char *str;
  struct declarator_info{
    int value;
    int size;
  }dinfo;
  int integer;
}
%token INT FLOAT VOID

%token  IF ELSE GOTO RETURN

%type <str> primary_expression postfix_expression argument_expression_list unary_expression comparison_expression expression assignment_operator
%type <str> selection_statement statement unary_operator type_name 
%type<dinfo> declarator
%type <integer> parameter_list
%start program
%%

primary_expression /*OULALAH (penser à renvoyer la valeur du registre)*/
: IDENTIFIER {int o = searchOffset($1); $$=o;} 
| CONSTANT  
| IDENTIFIER '(' ')' {int o = searchOffset($1); $$=o;} 
| IDENTIFIER '(' argument_expression_list ')' {int o = searchOffset($1); $$=o;} 
| IDENTIFIER INC_OP  {int o = searchOffset($1); $$=o;} 
| IDENTIFIER DEC_OP  {int o = searchOffset($1); $$=o;} 
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
| INC_OP unary_expression {PRINT("%s %s \n", "inc", $2); $$=$2++;}
| DEC_OP unary_expression {PRINT("%s %s \n", "dec", $2); $$=$2--;}
| unary_operator unary_expression {PRINT("%s \n", $2); $$=$2;}
;

unary_operator
: '+' {$$="+";}
| '-' {$$="-";}
;

comparison_expression
: unary_expression
| primary_expression '<' primary_expression   {PRINT("%s %s %s \n", "cmp", $1, $3); $$="jge";} 
| primary_expression '>' primary_expression   {PRINT("%s %s %s \n", "cmp", $1, $3); $$="jle";}
| primary_expression LE_OP primary_expression {PRINT("%s %s %s \n", "cmp", $1, $3); $$="jg";}
| primary_expression GE_OP primary_expression {PRINT("%s %s %s \n", "cmp", $1, $3); $$="jl";} 
| primary_expression EQ_OP primary_expression {PRINT("%s %s %s \n", "cmp", $1, $3); $$="jne";} 
| primary_expression NE_OP primary_expression {PRINT("%s %s %s \n", "cmp", $1, $3); $$="jeq";} 
;

expression
: unary_expression assignment_operator unary_expression {PRINT("%s %s %s \n", $2, $1, $3); $$=$1;}
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
: declarator {
  struct list_str *list_tmp = list;
  list = list->next;
  list->next = list_tmp;
  list->value = $<dinfo.value>1; 
}
| declarator_list ',' declarator {
  struct list_str *list_tmp = list;
  list = list->next;
  list->next = list_tmp;
  list->value = $<dinfo.value>3; 
}
;

type_name
: INT {$$=type_INT;} 
| VOID 
| FLOAT
;

declarator
: IDENTIFIER {
  struct declarator_info *di = malloc(sizeof(struct declarator_info));
  di->value=$1;
  di->size = 0;
  $$=*di;
}
| '(' declarator ')' {
  struct declarator_info *di = malloc(sizeof(struct declarator_info));
  di->value=$<dinfo.value>2;
  di->size = 0;
  $$=*di;  
}
| declarator '[' CONSTANT ']'{
struct declarator_info *di = malloc(sizeof(struct declarator_info));
di->value=$<dinfo.value>1;
di->size = $3;
$$=*di;  
}
| declarator '[' ']'{
struct declarator_info *di = malloc(sizeof(struct declarator_info));
di->value=$<dinfo.value>1;
di->size = 0;
$$=*di;  
}
| declarator '(' parameter_list ')' {
  struct declarator_info *di = malloc(sizeof(struct declarator_info));
  di->value=$<dinfo.value>1;
  di->size = $3;
  $$=*di;  
}
| declarator '(' ')'{
struct declarator_info *di = malloc(sizeof(struct declarator_info));
di->value=$<dinfo.value>1;
di->size = 0;
$$=*di;  
}
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
: IF '(' comparison_expression ')'
{ 
  PRINT("%s ", $3);   
  int a = newLabel(); 
  PRINT("%d \n", a); 
} 
statement {PRINT("%s ", $6); }
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
