%{

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "utils.h"
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
    int type;
    struct declarator_list* next;
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
  void* list;
  int integer;
}
%token INT FLOAT VOID

%token  IF ELSE GOTO RETURN

%type <str> primary_expression postfix_expression unary_expression expression_statement declaration_list
%type <str> selection_statement unary_operator comparison_expression jump_statement
%type <str> expression assignment_operator statement compound_statement labeled_statement statement_list
%type <list> declarator declarator_list argument_expression_list
%type <integer> parameter_list parameter_declaration type_name
%start program
%%

primary_expression
: IDENTIFIER {int o = searchOffset($1,symbolTableCurrentNode,symbolTableRoot); $$=regOffset("%ebp",o);} 

| CONSTANT  {$$=constToASMConst($1);}

| IDENTIFIER '(' ')' 
{
  //TODO : search for identifier
  PRINT("%s %s\n", "\tcall\t", $1);
} 

| IDENTIFIER '(' argument_expression_list ')' // EXPERIMENTAL /!\
{ 
  struct string_list* strList = (struct string_list*)$3;
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
  PRINT("%s %s\n", "\tcall\t", $1); 
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
  $$=(void*)strList; 
}
| argument_expression_list ',' primary_expression 
{ 
  struct string_list* strList = (struct string_list*)$1;
  struct string_list* strElement = malloc( sizeof ( struct string_list ) );
  strElement->str = strdup($3);
  strElement->next = strList;
  $$=(void*)strElement;
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
| primary_expression '<' primary_expression   {PRINT("%s %s, %s \n","\tmovl\t", $3,"%eax");PRINT("%s %s, %s \n", "\tcmpl\t", "%eax", $1); $$="\tjge\t";} 
| primary_expression '>' primary_expression   {PRINT("%s %s, %s \n","\tmovl\t", $3,"%eax");PRINT("%s %s, %s \n", "\tcmpl\t", "%eax", $1); $$="\tjle\t";}
| primary_expression LE_OP primary_expression {PRINT("%s %s, %s \n","\tmovl\t", $3,"%eax");PRINT("%s %s, %s \n", "\tcmpl\t", "%eax", $1); $$="\tjg\t";}
| primary_expression GE_OP primary_expression {PRINT("%s %s, %s \n","\tmovl\t", $3,"%eax");PRINT("%s %s, %s \n", "\tcmpl\t", "%eax", $1); $$="\tjl\t";} 
| primary_expression EQ_OP primary_expression {PRINT("%s %s, %s \n","\tmovl\t", $3,"%eax");PRINT("%s %s, %s \n", "\tcmpl\t", "%eax", $1); $$="\tjne\t";} 
| primary_expression NE_OP primary_expression {PRINT("%s %s, %s \n","\tmovl\t", $3,"%eax");PRINT("%s %s, %s \n", "\tcmpl\t", "%eax", $1); $$="\tjeq\t";} 
;

expression
: unary_expression assignment_operator unary_expression 
{
PRINT("%s %s, %s \n","\tmovl\t", $3,"%eax")
PRINT("%s %s, %s \n", $2, "%eax", $1); $$=$1;
}
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
  if ( $2 != NULL )
    {
      struct declarator_list *declaratorList = (struct declarator_list*)$2;
      struct declarator_list *temp = NULL;
      do
	{
      /*
      if (declaratorList->type < 0)
	addIdentifier(declaratorList->name, $1,
		      symbolTableCurrentNode);
	
      else
	addIdentifier(declaratorList->name, declaratorList->size,
	symbolTableCurrentNode); */

      // add flag for int/float 
	  
	  declaratorList->type = $1 | declaratorList->type; 
	  if (!(declaratorList->type & type_FUNCTION))
	    addIdentifier(declaratorList->name, declaratorList->size,
			  declaratorList->type, symbolTableCurrentNode);
	  
	  temp = declaratorList->next;
	  free(declaratorList->name);
	  free(declaratorList);
	  declaratorList = temp;
	}
      while(temp != NULL);
    }
}
;

declarator_list
: declarator {$$ = $1;}

| declarator_list ',' declarator 
{
  if ($3 == NULL)
    $$ = $1;
  else
    {
      assert($3 != NULL);
      assert($1 != NULL);
      struct declarator_list *declaratorInfo = (struct declarator_list*)$3;
      struct declarator_list *declaratorList = (struct declarator_list*)$1;
      declaratorInfo->next = declaratorList;
      $$ = (void*) declaratorInfo; 
    }
}
;

type_name
: INT     { $$ = type_INT; }
| VOID    { $$ = 0; } // Function
| FLOAT   { $$ = type_FLOAT; }
;

declarator
: IDENTIFIER //*
{
  struct declarator_list *di = malloc(sizeof(struct declarator_list));
  di->name = strdup($1);
  di->size=1;
  di->type=0;
  yyerror("identifier");
  $$=(void*)di;
} //*/
| '(' declarator ')' 
{ //*
  struct declarator_list *di = malloc(sizeof(struct declarator_list));
  struct declarator_list *di2 = (struct declarator_list*)$2;
  di->name = strdup(di2->name);
  di->size = di2->size;
  di->type = di2->type;
  $$=(void*)di;  //*/
} // ARRAY NOT HANDLED YET
| declarator '[' CONSTANT ']'
{ //*
    struct declarator_list *di = (struct declarator_list*)$1;
    //di->size = $3; //TODO $3 is string not int
    di->type = type_ARRAY;
    $$=(void*)di; //*/  
} 
| declarator '[' ']' { /*
struct declarator_info *di = malloc(sizeof(struct declarator_info));
di->value=$<dinfo.value>1;
di->size = 0;
$$=*di;  //*/
}
| declarator '(' parameter_list ')'
{ //* Creation de la table de symbole de la fonction + ajout des parametres a la table
  // A REFAIRE
  struct declarator_list *di = malloc(sizeof(struct declarator_list));
  struct declarator_list *di2 = (struct declarator_list*)$1;
  di->name=strdup(di2->name);
  di->size = 0; //*/
  di->type = type_FUNCTION;
  yyerror("declarator ( param )");
  $$=(void*)di;  // Function is already added in symbolTable

  if(getFunctionNode(symbolTableRoot,di->name) == NULL) {
    struct symbolTableTreeNode* newNode = createFunctionTreeNode(symbolTableRoot, di->name);
		fprintf(stderr, "creation table fonction %s , %p \n", di->name, newNode);

    struct declarator_list *parameterList = (struct declarator_list*)$3;
    struct declarator_list *temp = NULL;
    do
      {
        if (parameterList->size < 0)
  	  addIdentifier(parameterList->name, parameterList->size, parameterList->type, newNode);
	
        else
	  addIdentifier(parameterList->name, parameterList->size, parameterList->type, newNode);
	
        temp = parameterList->next;
        free(parameterList->name);
        free(parameterList);
        parameterList = temp;
      }
    while(temp != NULL);
   }
}
| declarator '(' ')' 
{ //* Creation de la table de symbole de la fonction
  // A REFAIRE
  struct declarator_list *di = malloc(sizeof(struct declarator_list));
  struct declarator_list *di2 = (struct declarator_list*)$1;
  di->name= strdup(di2->name);
  di->size = 0;
  di->type = type_FUNCTION;
  yyerror("declarator ()"); //*/
  $$=(void*)di; // Function is already added in symbolTable
}
;


parameter_list
: parameter_declaration {//$$=$1;}
  struct declarator_list *di = malloc(sizeof(struct declarator_list));
  struct declarator_list *di2 = (struct declarator_list*)$1;
  di->name= strdup(di2->name);
  di->size = di2->size;
  $$=(void*)di;
}
| parameter_list ',' parameter_declaration 
{
  struct declarator_list *parameterInfo = (struct declarator_list*)$3;
  struct declarator_list *parameterList = (struct declarator_list*)$1;
  parameterInfo->next = parameterList;
  $$ = (void*) parameterInfo; 
}
;

parameter_declaration
: type_name declarator {
  struct declarator_list *di = malloc(sizeof(struct declarator_list));
  struct declarator_list *di2 = (struct declarator_list*)$2;
  di->name= strdup(di2->name);
  di->size = 0;
  $$=(void*)di;
}
;

statement
: labeled_statement {$$=$1;}
| compound_statement {fprintf(stderr,"Compound statement\n");$$=$1;
  yyerror("Compound_statement");
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
| expression_statement {$$=$1;}
| selection_statement {$$=$1;}
| jump_statement {$$=$1;}
;

labeled_statement
: IDENTIFIER ':' {PRINT("%s:\n", gotoLabel($1));} statement 
;

compound_statement
: '{' '}' {$$="";}
| '{' statement_list '}' 
| '{' 
{ /*// Nouveau statement, on crée une liste de symbole pour ce statement
  yyerror("Compound_statement");
  struct symbolTableTreeNode* newNode =
    createTreeNode(symbolTableCurrentNode);
  fprintf(stderr,"Création d'un nouveau fils : %p\n", newNode);
  struct symbolTableTreeNodeList *nodeList = 
    createTreeNodeList(newNode);
  nodeList->next = symbolTableCurrentNode->sons;
  symbolTableCurrentNode->sons = nodeList;
  // cette liste est la nouvelle liste active
  symbolTableCurrentNode = newNode;
  */
}
declaration_list statement_list '}' 
{
  // Fin du statement, on remonte à la liste de symbole du statement père
  symbolTableCurrentNode = symbolTableCurrentNode->father;
  $$="";
}
;

declaration_list
: {yyerror("test");} declaration 
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
| RETURN ';' //{PRINT("\t%s\n \t%s\n", "leave", "ret");}
| RETURN expression ';' //{PRINT("\t%s\n \t%s\n", "leave", "ret");} // TODO
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
: type_name 
declarator 
{
  struct declarator_list* decl = (struct declarator_list*)$2;
  char* functionName = decl->name;
  yyerror("Declaration of function : ");
  int stackSize = 256;
  //PRINT("\n.globl %s\n\t.type\t %s, @function\n%s:\n\tenter\t $%d, $0\n",functionName,functionName,functionName,stackSize); // USE ENTER
  PRINT("\n.globl %s\n\t.type\t %s, @function\n%s:\n\tpushl\t %s\n\tmovl\t %s, %s\n\tsubl\t $%d, %s\n", 
	functionName, functionName, functionName, "%ebp", "%esp", "%ebp", stackSize, "%esp"); // USE GCC init
	struct declarator_list * f = (struct declarator_list *) $2;
	symbolTableCurrentNode = getFunctionNode(symbolTableRoot, f->name);
	yyerror("CurrentNode");
	fprintf(stderr, "%s %p \n", f->name, symbolTableCurrentNode);
}
compound_statement 
{
  PRINT("\t%s\n\t%s\n","leave","ret");
}
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
