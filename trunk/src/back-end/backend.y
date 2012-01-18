%{

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "utils.h"
  //#include "symT.h"
#include "label.h"
#include "pile.h"
#include "symbolTable.h"
#include "globals.h"


#define PRINT(format, args ...) {printf(format, args);}
  int yylex ();
  int yyerror ();


  void globalInit();
  void globalFree();

/*
  struct declarator_info {
    int value;
    int size;
  };
*/
  struct list_str
  {
    int value;
    struct list_str* next;
  };
  
  struct string_list
  {
    char* str;
    struct string_list* next;
  };

  struct declarator_list
  {
    char* name;
    int size;
    struct delarator_list* next;
  };

  //global
 // symbolTable->offset = currentOffset;

  %}

%token<str> IDENTIFIER CONSTANT
%token INC_OP DEC_OP LE_OP GE_OP EQ_OP NE_OP
%token AND_OP OR_OP
%token SUB_ASSIGN MUL_ASSIGN ADD_ASSIGN
%token<int> TYPE_NAME
%union {
  char *str;
  int* list;
  int integer;
}
%token INT FLOAT VOID

%token  IF ELSE GOTO RETURN

%type <str> primary_expression postfix_expression unary_expression expression_statement declaration_list
%type <str> selection_statement unary_operator type_name comparison_expression jump_statement
%type <str> expression assignment_operator statement compound_statement labeled_statement statement_list
%type <list> declarator declarator_list argument_expression_list
%type <integer> parameter_list parameter_declaration
%start program
%%

primary_expression
: IDENTIFIER {int o = searchOffset($1,symbolTableCurrentNode,symbolTableRoot); $$=regOffset("%ebp",o);} 

| CONSTANT  {$$=constToASMConst($1);}

| IDENTIFIER '(' ')' {PRINT("%s %s\n", "\tcall\t", functionLabel($1));} 

| IDENTIFIER '(' argument_expression_list ')' // EXPERIMENTAL /!\
{ 
  struct string_list* strList = (struct string_list*)$1;
  struct string_list* temp = NULL;
  do
    {
      PRINT("%s %s\n", "\tpushl\t", strList->str);
      temp=strList->next;
      free(strList->str);
      free(strList);
      strList = temp;
    }
    while(temp!=NULL); 
}

| IDENTIFIER INC_OP  {int o = searchOffset($1,symbolTableCurrentNode,symbolTableRoot);
                      char* str = regOffset("%ebp", o);
                      PRINT("%s %s, %s\n", "\taddl\t", "$1", str); $$=str;}

| IDENTIFIER DEC_OP  {int o = searchOffset($1,symbolTableCurrentNode,symbolTableRoot);
                      char* str = regOffset("%ebp", o);
                      PRINT("%s %s, %s\n", "\tsubl\t", "$1", str); $$=str;} 
;

postfix_expression
: primary_expression {$$=$1;}
| postfix_expression '[' expression ']' {/* acces à une case du tableau t[i] ( calcul de l'offset *t + i )*/} 
;

argument_expression_list 
// String list ( register + offset list ) 
: primary_expression 
{ 
  struct string_list* strList = malloc( sizeof ( struct string_list ) );
  strList->str = strdup($1);
  strList->next = NULL;
  $$=(int*)strList; 
}
| argument_expression_list ',' primary_expression 
{ 
  struct string_list* strList = (struct string_list*)$1;
  struct string_list* strElement = malloc( sizeof ( struct string_list ) );
  strElement->str = strdup($3);
  strElement->next = strList;
  $$=(int*)strElement;
}
;

unary_expression
: postfix_expression {$$=$1;}
| INC_OP unary_expression {PRINT("%s %s \n", "\tinc\t", $2); $$=$2;}
| DEC_OP unary_expression {PRINT("%s %s \n", "\tdec\t", $2); $$=$2;}
| unary_operator unary_expression {PRINT("%s \n", $2); $$=$2;}
;

unary_operator
: '+' {$$="+";}
| '-' {$$="-";}
;

comparison_expression
: unary_expression                            {PRINT("%s $0, %s \n", "\tcmpl\t", $1); $$="jeq";}
| primary_expression '<' primary_expression   {PRINT("%s %s, %s \n","\tmovl\t", $3,"%eax");PRINT("%s %s, %s \n", "\tcmpl\t", $1, "%eax"); $$="\tjge\t";} 
| primary_expression '>' primary_expression   {PRINT("%s %s, %s \n","\tmovl\t", $3,"%eax");PRINT("%s %s, %s \n", "\tcmpl\t", $1, "%eax"); $$="\tjle\t";}
| primary_expression LE_OP primary_expression {PRINT("%s %s, %s \n","\tmovl\t", $3,"%eax");PRINT("%s %s, %s \n", "\tcmpl\t", $1, "%eax"); $$="\tjg\t";}
| primary_expression GE_OP primary_expression {PRINT("%s %s, %s \n","\tmovl\t", $3,"%eax");PRINT("%s %s, %s \n", "\tcmpl\t", $1, "%eax"); $$="\tjl\t";} 
| primary_expression EQ_OP primary_expression {PRINT("%s %s, %s \n","\tmovl\t", $3,"%eax");PRINT("%s %s, %s \n", "\tcmpl\t", $1, "%eax"); $$="\tjne\t";} 
| primary_expression NE_OP primary_expression {PRINT("%s %s, %s \n","\tmovl\t", $3,"%eax");PRINT("%s %s, %s \n", "\tcmpl\t", $1, "%eax"); $$="\tjeq\t";} 
;

expression
: unary_expression assignment_operator unary_expression {PRINT("%s %s, %s \n", $2, $3, $1); $$=$1;}
| unary_expression {$$=$1;}
;

assignment_operator
: '='        {$$="\tmovl\t";}
| MUL_ASSIGN {$$="\tmull\t";}
| ADD_ASSIGN {$$="\taddl\t";}
| SUB_ASSIGN {$$="\tsubl\t";}
;

declaration
: type_name declarator_list ';' 
{
  struct declarator_list *declaratorList = (struct declarator_list*)$2;
  struct declarator_list *temp = NULL;
  do
    {
      if (declaratorList->size < 0)
	addIdentifier(declaratorList->name, $1,
		      symbolTableCurrentNode);
      else
	addIdentifier(declaratorList->name, declaratorList->size,
		      symbolTableCurrentNode);
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
: IDENTIFIER {} //*
{
  struct declarator_list *di = malloc(sizeof(struct declarator_list));
  di->name = strdup($1);
  di->size=-1;
  $$=(int*)di;
} //*/
| '(' declarator ')' 
{ //*
  struct declarator_list *di = malloc(sizeof(struct declarator_list));
  struct declarator_list *di2 = (struct declarator_list*)$2;
  di->name = strdup(di2->name);
  di->size = di2->size;
  $$=(int*)di;  //*/
} // ARRAY NOT HANDLED YET
| declarator '[' CONSTANT ']'
{ /*
struct declarator_info *di = malloc(sizeof(struct declarator_info));
di->value=$<dinfo.value>1;
di->size = $3;
$$=*di; */  
} 
| declarator '[' ']' { /*
struct declarator_info *di = malloc(sizeof(struct declarator_info));
di->value=$<dinfo.value>1;
di->size = 0;
$$=*di;  //*/
}
| declarator '(' parameter_list ')'
{ //*
  struct declarator_list *di = malloc(sizeof(struct declarator_list));
  struct declarator_list *di2 = (struct declarator_list*)$1;
  di->name=strdup(di2->name);
  di->size = $3;
  $$=(int*)di;  //*/
 }
| declarator '(' ')' 
{ //*
  struct declarator_list *di = malloc(sizeof(struct declarator_list));
  struct declarator_list *di2 = (struct declarator_list*)$1;
  di->name= strdup(di2->name);
  di->size = 0;
  $$=(int*)di;  //*/
}
;


parameter_list
: parameter_declaration {$$=$1;}
| parameter_list ',' parameter_declaration {$$=$1+$3;}
;

parameter_declaration
: type_name declarator {$$=1;}
;

statement
: labeled_statement {$$=$1;}
| compound_statement {$$=$1;}
| expression_statement {$$=$1;}
| selection_statement {$$=$1;}
| jump_statement {$$=$1;}
;

labeled_statement
: IDENTIFIER ':' {PRINT("%s:\n", gotoLabel($1));} statement 
;

compound_statement
: '{' '}' {$$="";}
| '{' statement_list '}' {$$=$2;}
| '{' 
{ // Nouveau statement, on crée une liste de symbole pour ce statement
  struct symbolTableTreeNode* newNode =
    createTreeNode(symbolTableCurrentNode);
  fprintf(stderr,"Création d'un nouveau fils : %p\n", newNode);
  struct symbolTableTreeNodeList *nodeList = 
    createTreeNodeList(newNode);
  nodeList->next = symbolTableCurrentNode->sons;
  symbolTableCurrentNode->sons = nodeList;
  // cette liste est la nouvelle liste active
  symbolTableCurrentNode = newNode;
}
declaration_list statement_list '}' 
{
  // Fin du statement, on remonte à la liste de symbole du statement père
  symbolTableCurrentNode = symbolTableCurrentNode->father;
  $$="";
}
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
  {char* lbl = newLabel("IF");
  PRINT("%s %s\n", $3, lbl);
  push(lbl,labelPile);}
statement
  {char* lbl = pop(labelPile);
   PRINT("%s:\n",lbl);}
;

jump_statement
: GOTO IDENTIFIER ';' {PRINT("%s %s\n", "\tjmp\t", gotoLabel($2));}
| RETURN ';' {PRINT("%s\n", "ret");}
| RETURN expression ';' {PRINT("%s\n", "ret");}
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
  /****** INIT ***************/
  globalInit();
  PRINT("%s",ASM_INIT());
  /***************************/
  yyparse ();
  dumpSymbolTable(symbolTableRoot,0);
  free (file_name);
  /****** /INIT *************/
  
  PRINT("%s",ASM_CLOSE());
  globalFree();

  /**************************/
  return 0;
}

void globalInit()
{
  labelPile = createPile(100);
  symbolTableRoot = createTreeNode(NULL); // la racine n'a pas de père (father = NULL)
  symbolTableCurrentNode = symbolTableRoot; 
}

void globalFree()
{
  freePile(labelPile);
  // TOTO free ROOT !
}
