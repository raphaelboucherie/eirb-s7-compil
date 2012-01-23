%{
    #include <stdlib.h>
    #include <stdio.h>
	#include <stdarg.h>
	#include <string.h>
	#include <sys/time.h>
	
	/* Variables globales */
	#include "globals.h"
	

	/* Module de pile */
	#include "pile.h"	
	
	/* Module de génération de code à 2 adresses */
	#include "generate2a.h"

	/* Table des symboles */
	#include "symbolTable.h"

	/* Arbre syntaxique */
	#include "derivationtree.h"
	
	/* Vérification de type */
	#include "checktype.h"


	/* Macro de PRINT */
	#define PRINT(format, args...) printf(format, args)

	extern int yylineno;
	int yylex();
	int yyerror();
	static int var_identifier = 1;
	
	// The derivation tree
	TreeNode* dt;

	
	int getNewId(){
		return var_identifier++;
	}
	
	/* Label for loops */
	static int for_label = 0;	
	static int while_label = 0;
	char label[256];
%}

%union {
	char *str;
	void* tn;
	void* id;
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
%type <id> declarator;
%type <id> declarator_list;
%type <ch> unary_operator;

%%

primary_expression
: IDENTIFIER												
	{
		//PRINT("%s", $<ch>1);
		if(getIdentifier($<ch>1, symbol_table_current, symbol_table_root) == NULL){
			yyerror("Identificateur introuvable ! \n");
			exit(1);
		}			
		/* Création d'un noeud pour l'arbre syntaxique */											
		$$ = (void*) create_tree_node($<ch>1);
	}
| CONSTANT
	{	
		//PRINT("%s", $1); 
		$<ch>$ = $<str>1;
		if(getIdentifier($<ch>1, symbol_table_root, symbol_table_root) == NULL)
			addIdentifier($<ch>1, TYPE_CONSTANT, 0, 1, 0, symbol_table_root);
		/* Création d'un noeud pour l'arbre syntaxique */	
		$$ = (void*) create_tree_node($<ch>1);
	}	
| IDENTIFIER '(' ')'											
	{
		PRINT("%s()", $1);	
	}
| IDENTIFIER '(' {PRINT("%s%s", $1, "(");} argument_expression_list ')'
	{
		PRINT("%s", ")");
		TreeNode * tn = create_tree_node($<ch>1);
	}		
| IDENTIFIER INC_OP											
	{

		char decvar[256];
		sprintf(decvar, "%s%s", $<ch>1, "++");
		TreeNode* op = create_tree_node(decvar); 
		$$ = (void*) op;
	}
| IDENTIFIER DEC_OP											
	{
		char decvar[256];
		sprintf(decvar, "%s%s", $<ch>1, "--");
		TreeNode* op = create_tree_node(decvar); 
		$$ = (void*) op;
	}
;

postfix_expression
: primary_expression	
	{
		$$ = $<tn>1;
	}
| postfix_expression '[' 
  
 expression ']' 
	{	/* A Voir ? */
		//LOG(stderr,"%s", "]");
	  struct string* l = list_tmp;
	  while(l!=NULL)
	    {
	      PRINT("%s",l->str);
	      l= l->next;
	    }

		  TreeNode* tn =(TreeNode*) $<tn>1;
		  TreeNode* t = (TreeNode*) $<tn>3;
		  
		  char* tmp;
		  while(list_tmp->next != NULL)
		    list_tmp = list_tmp->next;
		  tmp = strtok(list_tmp->str, " ");
		  sprintf(tn->content,"%s[%s]", tn->content, tmp);
		  list_tmp = createStringList();
		  $<tn>$=(void*) tn;
	} 
;

argument_expression_list
: expression						
| argument_expression_list ',' {PRINT("%s", ",");} expression
		
;

unary_expression
: postfix_expression		
	{
		$$ = $<tn>1;
	}				
| INC_OP unary_expression										
	{
		char decvar[256];
		sprintf(decvar, "%s%s", "++", $<ch>1);
		TreeNode* op = create_tree_node(decvar); 
		$$ = (void*) op;
	}

| DEC_OP unary_expression										
	{
		char decvar[256];
		sprintf(decvar, "%s%s", "--", $<ch>1);
		TreeNode* op = create_tree_node(decvar); 
		$$ = (void*) op;
	}
| unary_operator unary_expression
	{
		TreeNode* op = create_tree_node($<ch>1); 
		set_left(op, (TreeNode*) $<tn>2);
		$$ = (void*) op;									
	}
;

unary_operator
: '*'			{PRINT("%s", "*"); $<ch>$ = "*";}
| '+'			{PRINT("%s", "+"); $<ch>$ = "+";}
| '-'			{PRINT("%s", "-"); $<ch>$ = "-";}
;

multiplicative_expression
: unary_expression 			
	{
		$$ = $<tn>1;
	}
| multiplicative_expression '*' {LOG(stderr,"%s", "*");} unary_expression					
	{
		TreeNode* op = create_tree_node("*"); 
		set_right(op, (TreeNode*) $<tn>4);
		set_left(op, (TreeNode*) $<tn>1);
		$$ = (void*) op;
	}

| multiplicative_expression '|' {LOG(stderr,"%s", "|");} unary_expression
	{
		TreeNode* op = create_tree_node("|"); 
		set_right(op, (TreeNode*) $<tn>4);
		set_left(op, (TreeNode*) $<tn>1);
		$$ = (void*) op;
	}
;

additive_expression
: multiplicative_expression	
	{
		$$ = $<tn>1;
	}
| additive_expression '+' {LOG(stderr,"%s", "+");} multiplicative_expression		
	{		
		TreeNode* op = create_tree_node("+"); 
		set_right(op, (TreeNode*) $<tn>4);
		set_left(op, (TreeNode*) $<tn>1);
		$$ = (void*) op;
	}				
| additive_expression '-' {LOG(stderr,"%s", "-");} multiplicative_expression					
	{
		TreeNode* op = create_tree_node("-"); 
		set_right(op, (TreeNode*) $<tn>4);
		set_left(op, (TreeNode*) $<tn>1);
		$$ = (void*) op;
	}													
;

comparison_expression
: additive_expression	
	{
		$$ = $<tn>1;
	}
| additive_expression '<' {LOG(stderr,"%s", "<");} additive_expression
	{
		TreeNode* op = create_tree_node("<"); 
		set_right(op, (TreeNode*) $<tn>4);
		set_left(op, (TreeNode*) $<tn>1);
		$$ = (void*) op;
	}
| additive_expression '>' {LOG(stderr,"%s", ">");} additive_expression
	{
		TreeNode* op = create_tree_node(">"); 
		set_right(op, (TreeNode*) $<tn>4);
		set_left(op, (TreeNode*) $<tn>1);
		$$ = (void*) op;
	}
| additive_expression LE_OP {LOG(stderr,"%s", "<=");} additive_expression					
	{
		TreeNode* op = create_tree_node("<="); 
		set_right(op, (TreeNode*) $<tn>4);
		set_left(op, (TreeNode*) $<tn>1);
		$$ = (void*) op;
	}

| additive_expression GE_OP {LOG(stderr,"%s", ">=");} additive_expression					
	{
		TreeNode* op = create_tree_node(">="); 
		set_right(op, (TreeNode*) $<tn>4);
		set_left(op, (TreeNode*) $<tn>1);
		$$ = (void*) op;
	}

| additive_expression EQ_OP {LOG(stderr,"%s", "==");} additive_expression				
	{
		TreeNode* op = create_tree_node("=="); 
		set_right(op, (TreeNode*) $<tn>4);
		set_left(op, (TreeNode*) $<tn>1);
		$$ = (void*) op;
	}

| additive_expression NE_OP {LOG(stderr,"%s", "!=");} additive_expression					
	{
		TreeNode* op = create_tree_node("!="); 
		set_right(op, (TreeNode*) $<tn>4);
		set_left(op, (TreeNode*) $<tn>1);
		$$ = (void*) op;
	}
;
 
expression
: unary_expression assignment_operator comparison_expression 	
	{
		TreeNode* dt = create_tree_node($<ch>2);  
		TreeNode* var = (TreeNode*) $<tn>1; 
		set_left(dt, var);
		set_right(dt, (TreeNode*) $<tn>3);
		
		/*printf("\n----- TREE ------ \n"); 
		print_tree_node(dt, 0); 
		printf("\n----- END TREE ------ \n");
		*/
		//printf("\n----- TYPE VALIDATION ------ \n"); 
		/*int ret = check_type(dt, symbol_table_current, symbol_table_root);
		if(ret == TYPE_UNDEF){
			printf("Expression type : UNDEF\n"); yyerror("Uncompatible types !"); exit(1); break;
		}else{
			switch(ret){
				case TYPE_INT: printf("Expression type : INT\n"); break;
				case TYPE_FLOAT: printf("Expression type : FLOAT\n"); break;
				default : printf("Expression type : %d\n", ret);
			}
		}*/
		//printf("\n----- END TYPE VALIDATION ------ \n"); 				
		//printf("tree lenght : %d\n", tree_length(dt));
		char code_2a[4096] = "";
		list_tmp = createStringList();
		tree_to_2a_code(dt, symbol_table_current, symbol_table_root, list_tmp);
		struct symbolTableIdentifierList* id = symbol_table_current->identifierList;
		while(list_tmp != NULL){
			PRINT("%s", list_tmp->str);
			list_tmp = list_tmp->next;
		}
		list_tmp = createStringList();
		LOG(stderr,"%s\n", "------------------- CODE 2 ADRESSES CORRESPONDANT -----------------------");
//		printf("%s", code_2a);
		/*while(list_tmp!=NULL)
		  {
		    PRINT("%s", list_tmp->str);
		    list_tmp= list_tmp->next;
		  }*/
		LOG(stderr,"%s\n", "------------------- FIN CODE 2 ADRESSES CORRESPONDANT -----------------------");
		//free_tree_node(dt); 
	}
| comparison_expression
	{
		
		/*
		printf("\n----- TREE ------ \n"); 
		print_tree_node($<tn>1, 0); 

		printf("\n----- END TREE ------ \n");
		*/
		char code_2a[4096] = "";
		//list_tmp = createStringList();
		tree_to_2a_code($<tn>1, symbol_table_current, symbol_table_root, list_tmp);
		LOG(stderr,"%s\n", "------------------- CODE 2 ADRESSES CORRESPONDANT -----------------------");
//		printf("%s", code_2a);
		/*while(list_tmp!=NULL)
		  {
		    PRINT("%s", list_tmp->str);
		    list_tmp= list_tmp->next;
		  }*/
		LOG(stderr,"%s\n", "------------------- FIN CODE 2 ADRESSES CORRESPONDANT -----------------------");
	//	free_tree_node($<tn>1); 

		$<ch>$ = $<ch>1;
		
	}		
;

assignment_operator
: '='					{LOG(stderr,"%s", "="); $<ch>$ = "=";}
| MUL_ASSIGN			{LOG(stderr,"%s", "*="); $<ch>$ = "*=";}
| ADD_ASSIGN			{LOG(stderr,"%s", "+="); $<ch>$ = "+=";}
| SUB_ASSIGN			{LOG(stderr,"%s", "-="); $<ch>$ = "-=";}
;

declaration
: type_name declarator_list ';'						
	{	PRINT("%s", ";\n");
		if(symbol_table_current->functionName != NULL && symbol_table_current->father != NULL){
			LOG(stderr,"FUNCTION NAME = %s\n", symbol_table_current->functionName);
			symbol_table_current = symbol_table_current->father;
		}
		/* On récupère le type type_name d'une variable ou d'une liste de variables */
		int type;
		if(strcmp($<ch>1, "void") == 0){
			type = TYPE_VOID;	
		}
		else if(strcmp($<ch>1, "int") == 0){
			type = TYPE_INT;	
		}
		else if(strcmp($<ch>1, "float") == 0){			type = TYPE_FLOAT;
		}
		else{
			type = TYPE_UNDEF;
		}
		/*Identifier* _ids = $<id>2;
		
		//Parcours de la liste d'identifieurs (permettant de recuperer la taille d'un potentiel tableau multidimensionnel...)
		do{
			Node newNode;
			newNode.name = _ids->name;
			newNode.type = type;
			newNode.size = _ids->size;
			newNode.dimension = _ids->dimension;
			symTable = add_start_to_symtable(newNode, symTable);
			Identifier* tmp = _ids;
			_ids = _ids->next;
			free_identifier(tmp);
		}while(_ids != NULL);*/
		
		/* On parcours la liste des variables et on leur associe le type type_name */
		struct symbolTableIdentifierList* list = (struct symbolTableIdentifierList*) $<id>2;
		while(list != NULL){
			if(list->type == TYPE_UNDEF){
				list->type = type;
			}
			else if(list->type == TYPE_FCTN_UNDEF){
				if(type == TYPE_INT){
					list->type = TYPE_FCTN_INT;
				}
				else if(type == TYPE_VOID){
					list->type = TYPE_FCTN_VOID;
				}
			}
			list = list->next;
		}
	}
;

declarator_list
: declarator												
	{
		$<id>$ = $<id>1;
	}
| declarator_list ',' {PRINT("%s", ",");} declarator							
	{	
		/* Construction de la liste des variables d'un certain type */
		struct symbolTableIdentifierList* id = (struct symbolTableIdentifierList*) $<id>4;
		id->next = (struct symbolTableIdentifierList*) $<id>1;
		$<id>$ = (void*) id;
	}
;

type_name
: VOID					{PRINT("%s", "void "); $<ch>$="void";}
| INT 					{PRINT("%s", "int "); $<ch>$="int";}
| FLOAT					{PRINT("%s", "float "); $<ch>$="float";}
;

declarator
: IDENTIFIER  												
	{
		PRINT("%s", $1);
		/* On ajoute le symbole à la table courante */
		struct symbolTableIdentifierList* list = getIdentifier($<ch>1, symbol_table_current, symbol_table_root);
		struct symbolTableTreeNode* fnode = getFunctionNode(symbol_table_root, $<ch>1);
		if(fnode != NULL){
			if(fnode->functionName != NULL && fnode->defined == 0){
				symbol_table_current = fnode;
			}
		}
		else if(list != NULL){
			if(list->defined == 0){
				symbol_table_current = createFunctionTreeNode(symbol_table_root, $<ch>1);
			}
		}
		else{
			addIdentifier($1, TYPE_UNDEF, 0, 1, 0, symbol_table_current);
		}
		/* On renvoie un élément de la liste de la table des symboles (symbolTableIdentifierList*) */
		$<id>$ = (void*) getIdentifier($<ch>1, symbol_table_current, symbol_table_root);
	}
| '(' {PRINT("%s", "(");} declarator {PRINT("%s", ")");} ')'									
| declarator '[' CONSTANT ']'			
	{
		PRINT("[%s]", $3); 
		/*if($<id>1 != NULL){
			Identifier* _id = $<id>1;
			_id->size *= atoi($3);
			_id->dimension++;
			$<id>$ = _id;
		}*/

		/* Cas d'un tableau */
		struct symbolTableIdentifierList* id = (struct symbolTableIdentifierList*) $<id>1;
		if(id->name != NULL){
			struct symbolTableIdentifierList* stid = getIdentifier(id->name, symbol_table_current, symbol_table_root);
			if(stid != NULL){
				stid->type = TYPE_ARRAY;
				stid->size *= atoi($3);
				stid->dimension++;
				stid->get_by_addr = 1;
			}
			$<id>$ = (void*) stid;
		}
	}
| declarator '[' ']'											
	{
		PRINT("%s", "[]"); 
		/* if($<id>1 != NULL){
			Identifier* _id = $<id>1;
			$<id>$ = _id;
		} */
		/* Idem que le cas précédent mais on ne peut pas set la taille */
		struct symbolTableIdentifierList* id = (struct symbolTableIdentifierList*) $<id>1;
		if(id->name != NULL){
			struct symbolTableIdentifierList* stid = getIdentifier(id->name, symbol_table_current, symbol_table_root);
			if(stid != NULL){
				stid->type = TYPE_ARRAY;
				stid->dimension++;
				stid->get_by_addr = 1;
			}
			$<id>$ = (void*) stid;
	 	}
	}
/* Cas des fonction avec paramètres */
| declarator '(' 
	{
		PRINT("%s", "(");
		struct symbolTableIdentifierList* id = (struct symbolTableIdentifierList*) $<id>1; /* Pas d'ajout car ceci est déjà fait dans IDENTIFIER */
		/* On crée le noeud dans l'arbre de la table des symboles */
		struct symbolTableTreeNode* tn	= createFunctionTreeNode(symbol_table_root, id->name);
		/* La table courante devient la table de la fonction */
		symbol_table_current = tn;
	} 
parameter_list ')' 
	{
		PRINT("%s", ")");
		/* TODO Probleme lors de l'écriture de l'entête puis de la définition de la fonction */
		/* On récupère l'identifieur de la fonction et on modifie son nombre de paramètres */
		struct symbolTableIdentifierList* id = (struct symbolTableIdentifierList*) $<id>1;
		if(id->name != NULL){
			struct symbolTableIdentifierList* stid = getIdentifier(id->name, symbol_table_current, symbol_table_root);
			if(stid != NULL){
				stid->type = TYPE_FCTN_UNDEF;
				stid->size = $<num>4;
			}
			//symbol_table_current = symbol_table_current->father;
			$<id>$ = (void*) stid;
		}		
	}		
/* Cas des fonctions sans paramètres */
| declarator '(' ')'											
	{
		/* TODO Probleme lors de l'écriture de l'entête puis de la définition de la fonction */
		PRINT("%s", "()");
		/* Idem que le cas précédent mais la size est à 0 */
		struct symbolTableIdentifierList* id = (struct symbolTableIdentifierList*) $<id>1;
		if(id->name != NULL){
			struct symbolTableIdentifierList* stid = getIdentifier(id->name, symbol_table_current, symbol_table_root);
			if(stid != NULL){
				stid->type = TYPE_FCTN_UNDEF;
				stid->size = 0;
			}
			$<id>$ = (void*) stid;
		}		
	}
;
/* Calcul du nombre de paramètres d'une fonction */
parameter_list
: parameter_declaration		{$<num>$ = 1;}												
| parameter_list ',' {PRINT("%s", ",");} parameter_declaration	{$<num>$ = $<num>1 + 1;}			
;

parameter_declaration
: type_name
/*{		struct symbolTableTreeNode* tn = createTreeNode(symbol_table_current);
		symbol_table_current = tn;
}*/	
declarator 											
	{	
		/* Récupération du type d'un paramètre */
		// TODO à revoir pour la gestion d'erreur 
		int type;
		if(strcmp($<ch>1, "void") == 0){
			//type = TYPE_VOID;	
			yyerror("Function parameter type must be int or array ! \n"); exit(1);
		}
		else if(strcmp($<ch>1, "int") == 0){
			type = TYPE_INT;
		}
		else if(strcmp($<ch>1, "float") == 0){
			type = TYPE_ARRAY;
		}
		else{
			type = TYPE_UNDEF;
		}
		/*Identifier* _id = $<id>2;
		Node newNode;
		newNode.name = _id->name;
		newNode.type = type;
		newNode.size = _id->size;
		newNode.dimension = _id->dimension;
		symTable = add_start_to_symtable(newNode, symTable);
		free_identifier(_id);
		*/
		/* On récupère la liste des paramètres et on lui assigne le type qu'on a trouvé */
		struct symbolTableIdentifierList* list = (struct symbolTableIdentifierList*) $<id>2;
		while(list != NULL){
			if(list->type == TYPE_UNDEF){
				list->type = type;
			}
			/* TODO Générer une erreur */
			list = list->next;
		}
		
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
| '{' 
	{	/* Ouverture d'un nouveau bloc */
		struct symbolTableTreeNode* tn = createTreeNode(symbol_table_current);
		//addSon(symbol_table_current, tn);
		symbol_table_current = tn;
	}
	declaration_list statement_list '}' 
	{	
		/* A la fin du bloc on remonte d'un étage */
		symbol_table_current = symbol_table_current->father;
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

/*Fonctionnement GCC : Les blocs if et else sont gérés séparément. Quand un bloc else est évalué, il est rattaché au bloc if le plus proche*/
selection_statement /* TODO Refaire le traitement des if else ! */
: IF  '('  expression ')' 
	{
		while(list_tmp->next != NULL){
			PRINT("%s", list_tmp->str);
			list_tmp = list_tmp->next;
		}
		PRINT("%s", "if(");
		PRINT("%s", list_tmp->str);
		PRINT("%s", "){\n");
		list_if_tmp = addString2(list_if_tmp, list_tmp->str);
		list_tmp = createStringList();
	}
statement
	{
		PRINT("%s\n", "}");
	}
| ELSE 
	{
		PRINT("%s%s%s", "if(", reverse_operator(list_if_tmp->str), "){\n");
		list_if_tmp = list_if_tmp->next;
	}
statement
	{
		PRINT("%s\n", "}");
	}
| FOR '(' 
	{
		sprintf(label, "%s_%d", ".for", for_label); 
		push(label, stack_for); 
		/* LOG(stderr,"%s:\n", label); */
		for_label++; 
		
	} 
	expression_statement 
	expression_statement 
	expression  
	')' 
	{
	  //	PRINT("%s\n", list_tmp->str);
	  //	list_tmp = list_tmp->next;
		PRINT("%s :\n", label);
		while(list_tmp->next->next != NULL){
			PRINT("%s", list_tmp->str);
			list_tmp = list_tmp->next;
		}
		PRINT("if(%s){\n", list_tmp->str);
		list_tmp = list_tmp->next;
	} 
	statement 
	{	
		//PRINT("%s\n", list_tmp->str);
		PRINT("goto %s}\n", pop(stack_for));
		list_tmp = createStringList();
	}
;

iteration_statement
: WHILE '(' 
	{
		sprintf(label, "%s_%d", ".while", while_label); 
		push(label, stack_while); 
		PRINT("%s :\n", label); 
		while_label++;	
	} 
expression 
	')' 
	{
		while(list_tmp->next != NULL){
			PRINT("%s", list_tmp->str);
			list_tmp = list_tmp->next;
		}
		PRINT("%s", "if(");
		PRINT("%s", list_tmp->str);
		PRINT("%s", "){\n");
	}
statement 
	{
		PRINT("%s %s;\n}\n","goto",  pop(stack_while));
		list_tmp = createStringList();
	}
;

jump_statement
: RETURN ';'												
	{
		PRINT("%s\n", "return ;");
	}
| RETURN {PRINT("%s", "return ");} expression ';' 
	{
		PRINT("%s\n", ";");
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
: type_name declarator 
	{
		PRINT("%s\n", "{");
		/* On récupère l'identifier au dessus */
		struct symbolTableIdentifierList* list = (struct symbolTableIdentifierList*) $<id>2;
		struct symbolTableTreeNode* fnode = getFunctionNode(symbol_table_root, list->name);
		fnode->defined = 1;
		list->defined = 1;
	} 
compound_statement 
	{
		PRINT("%s\n", "}");
		int type;
		if(strcmp($<ch>1, "void") == 0){
			type = TYPE_VOID;	
		}
		else if(strcmp($<ch>1, "int") == 0){
			type = TYPE_INT;	
		}
		else if(strcmp($<ch>1, "float") == 0){
			type = TYPE_FLOAT;
		}
		else{
			type = TYPE_UNDEF;
		}
		struct symbolTableIdentifierList* list = (struct symbolTableIdentifierList*) $<id>2;
		while(list != NULL){
			if(list->type == TYPE_FCTN_UNDEF){
				if(type == TYPE_INT){
					list->type = TYPE_FCTN_INT;
				}
				else if(type == TYPE_VOID){
					list->type = TYPE_FCTN_VOID;
				}
			}
			list = list->next;
		}
		symbol_table_current = symbol_table_current->father;
	}
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

void globalInit()
{
	symbol_table_root = createTreeNode(NULL); // la racine n'a pas de père (father = NULL)
	symbol_table_root->functionName = "_root";
	symbol_table_current = symbol_table_root; 

	stack_for = createPile(100);
	stack_while = createPile(100);
	//stack_tmp = createPile(100);
	list_tmp = createStringList();
	list_if_tmp = createStringList();
}

int main (int argc, char *argv[]) {
    FILE *input = NULL;
    
    if(argc==2) {
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
    else{
		fprintf (stderr, "%s: error: no input file\n", *argv);
		return 1;
    }
	/* Initialisation */
	globalInit();
	/* Début du parsing */
    yyparse ();
	dumpSymbolTable(symbol_table_root, 0);
    free (file_name);
    
    /*SymTable Memory Free
    if(symTable != NULL){
	    displaySymTable(symTable);
	    free_symtable(symTable);    
    }*/
    return 0;
}
