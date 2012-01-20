%{

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "stringList.h"
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

%type <str> primary_expression postfix_expression unary_expression expression_statement 
%type <str> selection_statement unary_operator comparison_expression jump_statement
%type <str> expression assignment_operator statement labeled_statement statement_list
%type <list> declarator declarator_list argument_expression_list
%type <integer> parameter_list parameter_declaration type_name declaration compound_statement declaration_list
%start program
%%

primary_expression
: IDENTIFIER {int o = searchOffset($1,symbolTableCurrentNode,symbolTableRoot); $$=regOffset("%ebp",o);} 

| CONSTANT  {$$=constToASMConst($1);}

| IDENTIFIER '(' ')' 
{
  //TODO : search for identifier
  yyerror("Appel d'une fonction");
  fprintf(stderr, "%s \n", $1);
  symbolTableCurrentNode->code = addString(symbolTableCurrentNode->code,"%s %s\n", "\tcall\t", $1);
	$$="%eax";
} 

| IDENTIFIER '(' argument_expression_list ')' // EXPERIMENTAL /!\
{ 
  struct string_list* strList = (struct string_list*)$3;
  struct string_list* temp = NULL;
	int argumentSize = 0;
  do
    {
      symbolTableCurrentNode->code = addString(symbolTableCurrentNode->code,"%s %s\n", "\tpushl\t", strList->str);
      temp=strList->next;
      free(strList->str);
      free(strList);
      strList = temp;
    }
    while(temp!=NULL); 
  yyerror("Appel d'une fonction");
  fprintf(stderr, "%s \n", $1);
  symbolTableCurrentNode->code = addString(symbolTableCurrentNode->code,"%s %s\n", "\tcall\t", $1);
  argumentSize = getFunctionNode(symbolTableRoot,$1)->parameterSize;
  argumentSize *= 2;
 // symbolTableCurrentNode->code = addString(symbolTableCurrentNode->code,"%s $%d, %s\n", "\taddl\t", argumentSize, "%ebp"); 
  
	$$="%eax";
}

| IDENTIFIER INC_OP  {int o = searchOffset($1,symbolTableCurrentNode,symbolTableRoot);
                      char* str = regOffset("%ebp", o);
                      symbolTableCurrentNode->code = addString(symbolTableCurrentNode->code,"%s %s, %s\n", "\taddl\t", "$1", str); $$=str;}

| IDENTIFIER DEC_OP  {int o = searchOffset($1,symbolTableCurrentNode,symbolTableRoot);
                      char* str = regOffset("%ebp", o);
                      symbolTableCurrentNode->code = addString(symbolTableCurrentNode->code,"%s %s, %s\n", "\tsubl\t", "$1", str); $$=str;} 
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
| INC_OP unary_expression {symbolTableCurrentNode->code = addString(symbolTableCurrentNode->code,"%s %s \n", "\tinc\t", $2); $$=$2;}
| DEC_OP unary_expression {symbolTableCurrentNode->code = addString(symbolTableCurrentNode->code,"%s %s \n", "\tdec\t", $2); $$=$2;}
| unary_operator unary_expression {symbolTableCurrentNode->code = addString(symbolTableCurrentNode->code,"%s \n", $2); $$=$2;}
;

unary_operator
: '+' {$$="+";}
| '-' {$$="-";}
;

comparison_expression
: unary_expression                            {symbolTableCurrentNode->code = addString(symbolTableCurrentNode->code,"%s $0, %s \n", "\tcmpl\t", $1); $$="jeq";}
| primary_expression '<' primary_expression   {symbolTableCurrentNode->code = addString(symbolTableCurrentNode->code,"%s %s, %s \n","\tmovl\t", $3,"%ebx");symbolTableCurrentNode->code = addString(symbolTableCurrentNode->code,"%s %s, %s \n", "\tcmpl\t", "%ebx", $1); $$="\tjge\t";} 
| primary_expression '>' primary_expression   {symbolTableCurrentNode->code = addString(symbolTableCurrentNode->code,"%s %s, %s \n","\tmovl\t", $3,"%ebx");symbolTableCurrentNode->code = addString(symbolTableCurrentNode->code,"%s %s, %s \n", "\tcmpl\t", "%ebx", $1); $$="\tjle\t";}
| primary_expression LE_OP primary_expression {symbolTableCurrentNode->code = addString(symbolTableCurrentNode->code,"%s %s, %s \n","\tmovl\t", $3,"%ebx");symbolTableCurrentNode->code = addString(symbolTableCurrentNode->code,"%s %s, %s \n", "\tcmpl\t", "%ebx", $1); $$="\tjg\t";}
| primary_expression GE_OP primary_expression {symbolTableCurrentNode->code = addString(symbolTableCurrentNode->code,"%s %s, %s \n","\tmovl\t", $3,"%ebx");symbolTableCurrentNode->code = addString(symbolTableCurrentNode->code,"%s %s, %s \n", "\tcmpl\t", "%ebx", $1); $$="\tjl\t";} 
| primary_expression EQ_OP primary_expression {symbolTableCurrentNode->code = addString(symbolTableCurrentNode->code,"%s %s, %s \n","\tmovl\t", $3,"%ebx");symbolTableCurrentNode->code = addString(symbolTableCurrentNode->code,"%s %s, %s \n", "\tcmpl\t", "%ebx", $1); $$="\tjne\t";} 
| primary_expression NE_OP primary_expression {symbolTableCurrentNode->code = addString(symbolTableCurrentNode->code,"%s %s, %s \n","\tmovl\t", $3,"%ebx");symbolTableCurrentNode->code = addString(symbolTableCurrentNode->code,"%s %s, %s \n", "\tcmpl\t", "%ebx", $1); $$="\tjeq\t";} 
;

expression
: unary_expression assignment_operator unary_expression 
{
  symbolTableCurrentNode->code = addString(symbolTableCurrentNode->code,"%s %s, %s \n","\tmovl\t", $3,"%ebx");
  symbolTableCurrentNode->code = addString(symbolTableCurrentNode->code,"%s %s, %s \n", $2, "%ebx", $1); $$=$1;
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
  int listSize = 0;
  if ( $2 != NULL )
    {
      struct declarator_list *declaratorList = (struct declarator_list*)$2;
      struct declarator_list *temp = NULL;
      do
	{

      // add flag for int/float 
	  
	  declaratorList->type = $1 | declaratorList->type; 
	  if (!(declaratorList->type & type_FUNCTION))
	    addIdentifier(declaratorList->name, declaratorList->size,
			  declaratorList->type, symbolTableCurrentNode);
	  listSize+=declaratorList->size;
	  
	  temp = declaratorList->next;
	  free(declaratorList->name);
	  free(declaratorList);
	  declaratorList = temp;
	}
      while(temp != NULL);
    }
  $$ = listSize;
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
| VOID    { $$ = type_FUNCTION; } // Function
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
	fprintf(stderr,"adding function parameter %s, size = %d, type = %d\n", 
		parameterList->name, parameterList->size, parameterList->type);
  	addParameter(parameterList->name, parameterList->size, parameterList->type, newNode);
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

  if(getFunctionNode(symbolTableRoot,di->name) == NULL) 
    {
      struct symbolTableTreeNode* newNode = createFunctionTreeNode(symbolTableRoot, di->name);
      fprintf(stderr, "creation table fonction %s , %p \n", di->name, newNode);
    }
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
  di->size = di2->size;
  di->type = $1 | di2->type;
  $$=(void*)di;
}
;

statement
: labeled_statement {$$=$1;}
| 
{
  yyerror("Compound_statement");
  // Création du noeud
  struct symbolTableTreeNode* newNode = createTreeNode(symbolTableCurrentNode);
  // On change le noeud actif
  symbolTableCurrentNode = newNode;
  fprintf(stderr, "Current Table :%s \n", symbolTableCurrentNode->functionName);
}
compound_statement
{
  // on sort du statement, on ajoute le code et on remonte au père
  symbolTableCurrentNode->father->code = 
    addStringList(symbolTableCurrentNode->father->code,
		  symbolTableCurrentNode->code);
  symbolTableCurrentNode = symbolTableCurrentNode->father;
  fprintf(stderr,"Current Table :%s \n", symbolTableCurrentNode->functionName);
    $$=$2;
}
| expression_statement {$$=$1;}
| selection_statement {$$=$1;}
| jump_statement {$$=$1;}
;

labeled_statement
: IDENTIFIER ':' {symbolTableCurrentNode->code = addString(symbolTableCurrentNode->code,"%s:\n", gotoLabel($1));} statement 
;

compound_statement
: '{' '}' {$$=0;}
| '{' statement_list '}' {$$=0;} 
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
  
  $$=$3;
}
;

declaration_list
: declaration {$$ = $1;}
| declaration_list declaration {$$ = $1 + $2;}
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
: {yyerror("lecture du IF");} IF '(' {yyerror("lecture de la comparaison");} comparison_expression ')' 
  {char* lbl = newLabel("IF");
  symbolTableCurrentNode->code = addString(symbolTableCurrentNode->code,"%s %s\n", $5, lbl);
  push(lbl,labelPile);
  yyerror("début du statement (IF)");}
statement
  {
    yyerror("fin du statement (IF)");
    char* lbl = pop(labelPile);
    symbolTableCurrentNode->code = addString(symbolTableCurrentNode->code,"%s:\n",lbl);
    yyerror("fin lecture du IF");}
;

jump_statement
: GOTO IDENTIFIER ';' {symbolTableCurrentNode->code = addString(symbolTableCurrentNode->code,"%s %s\n", "\tjmp\t", gotoLabel($2));}
| RETURN ';' {symbolTableCurrentNode->code = addString(symbolTableCurrentNode->code,"\t%s\n \t%s\n", "leave", "ret");}
| RETURN expression ';' {
	fprintf(stderr, "retour expression %s \n", $2);
	symbolTableCurrentNode->code = addString(symbolTableCurrentNode->code,"\t%s \t%s, %s\n", "movl", $2, "%eax");
	symbolTableCurrentNode->code = addString(symbolTableCurrentNode->code,"\t%s\n \t%s\n", "leave", "ret");// TODO
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
: type_name 
declarator 
{
  struct declarator_list* decl = (struct declarator_list*)$2;
  char* functionName = decl->name;
  fprintf(stderr,"Declaration of function : %s\n", functionName);
  struct declarator_list * f = (struct declarator_list *) $2;
  symbolTableCurrentNode = getFunctionNode(symbolTableRoot, f->name);
  fprintf(stderr, "Current Table :%s \n", symbolTableCurrentNode->functionName);
  fprintf(stderr, "%s %p \n", f->name, symbolTableCurrentNode);
}
compound_statement 
{
  struct declarator_list* decl = (struct declarator_list*)$2;
  char* functionName = decl->name;
  int stackSize = $4;
  stackSize += getFunctionNode(symbolTableRoot,functionName)->parameterSize;

  fprintf(stderr,"Ajout du code d'init, stackSize = %d\n", stackSize);
  asmCode = addString(asmCode,
		      "\n.globl %s\n\t.type\t %s, @function\n%s:\n\tpushl\t %s\n\tmovl\t %s, %s\n\tsubl\t $%d, %s\n",functionName, functionName, functionName, "%ebp", "%esp", "%ebp", (stackSize+1)*4, "%esp"); // USE GCC init

  fprintf(stderr,"Ajout du code du corps : %s\n", symbolTableCurrentNode->code->str);
  asmCode = addStringList(asmCode, symbolTableCurrentNode->code);
//  fprintf(stderr,"Ajout du code de fin\n");
//  asmCode = addString(asmCode,"\t%s\n\t%s\n","leave","ret");
  // On retourne au père
  symbolTableCurrentNode = symbolTableCurrentNode->father;
  assert(symbolTableCurrentNode != NULL);


  //asmCode = addString(asmCode,"\n.globl %s\n\t.type\t %s, @function\n%s:\n\tenter\t $%d, $0\n",functionName,functionName,functionName,stackSize); // USE ENTER
  
  
  fprintf(stderr,"End of declaration of function : %s\n", functionName);
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
  asmCode = addString(NULL,"%s",ASM_INIT());
  /***************************/
  yyparse ();
  asmCode = addString(asmCode,"%s",ASM_CLOSE());
  dumpSymbolTable(symbolTableRoot,0);
  printString(asmCode);
  free (file_name);
  /****** /INIT *************/
  


  globalFree();

  /**************************/
  return 0;
}

void globalInit()
{
  labelPile = createPile(100);
  symbolTableRoot = createTreeNode(NULL); // la racine n'a pas de père (father = NULL)
  symbolTableRoot->functionName = "_root";
  symbolTableCurrentNode = symbolTableRoot; 
}

void globalFree()
{
  freePile(labelPile);
  // TOTO free ROOT !
}
