%{

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "stringList.h"
#include "utils.h"
#include "label.h"
#include "pile.h"
#include "symbolTable.h"
#include "sse.h"
#include "globals.h"



#define PRINT(format, args ...) {printf(format, args);}
	//#define LOG stderr 

	int yylex ();
	int yyerror ();

	FILE* LOG;

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
		int nbArrayDimension;
		int dimensionSizes[256];
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
%type <str> expression statement labeled_statement statement_list
%type <list> declarator declarator_list argument_expression_list
%type <integer> parameter_list parameter_declaration type_name declaration compound_statement declaration_list
%type <integer> assignment_operator 
%start program
%%

primary_expression
: IDENTIFIER 
{
	$$ = $1;
} 

| CONSTANT  {$$=constToASMConst($1);}

| IDENTIFIER '(' ')' 
{
	fprintf(LOG, "Appel d'une fonction");
	fprintf(LOG, "%s \n", $1);
	symbolTableCurrentNode->code = addString(symbolTableCurrentNode->code,"%s %s\n", "\tcall\t", $1);
	// Function return value are always stored in eax
	$$="%eax";
} 

| IDENTIFIER '(' argument_expression_list ')' 
{ // Function Call
	struct string_list* strList = (struct string_list*)$3;
	struct string_list* temp = NULL;
	int argumentSize = 0;
	fprintf(LOG, "Appel d'une fonction");
	fprintf(LOG, "%s \n", $1);

	// Arguments are given to the function by pushing on the stack
	do
	{
		symbolTableCurrentNode->code = addString(symbolTableCurrentNode->code,"%s %s\n", "\tpushl\t", strList->str);
		temp=strList->next;
		free(strList->str);
		free(strList);
		strList = temp;
	}
	while(temp!=NULL); 
	symbolTableCurrentNode->code = addString(symbolTableCurrentNode->code,"%s %s\n", "\tcall\t", $1);
	argumentSize = getFunctionNode(symbolTableRoot,$1)->parameterSize;
	argumentSize *= 2;
	// Function return value are always stored in eax
	$$="%eax";
}

| IDENTIFIER INC_OP  
{ //Identifier incrementation, add 1 to the value stared in the address returned by IDENTIFIER 
	char* str = postfixExpressionToRegister($1, symbolTableCurrentNode, symbolTableRoot);
	symbolTableCurrentNode->code = 
		addString(symbolTableCurrentNode->code,"%s %s, %s\n", "\taddl\t", "$1", str); 
	//Return the offset, value now incremented
	$$=$1;
}

| IDENTIFIER DEC_OP  
{ //Identifier decrementation, substract 1 to the value stared at the offset of IDENTIFIER
	char* str = postfixExpressionToRegister($1, symbolTableCurrentNode, symbolTableRoot);
	symbolTableCurrentNode->code = 
		addString(symbolTableCurrentNode->code,"%s %s, %s\n", "\tsubl\t", "$1", str); 
	//Return the offset, value now decreased
	$$=$1;
} 
;

postfix_expression
: primary_expression {$$=$1; /* Access to a simple value, as identifier, constant, function ...*/}
| postfix_expression '[' expression ']' 
{ // Access to a value in an array
	char str[256];
	char* str2 = malloc(sizeof(char)*256); 
	char* dbg1 = $1;
	char* dbg3 = $3;
	sprintf(str,"%s@%s",$1,strtok($3,"$"));
	sprintf(str2,"#%s",str);
	fprintf(LOG,"Generating %s for array position\n", str2);
	$$ = str2;
}
;

argument_expression_list 
: primary_expression 
{ // Argument for calling a function
	struct string_list* strList = malloc( sizeof ( struct string_list ) );
	strList->str = postfixExpressionToRegister($1,
			symbolTableCurrentNode,
			symbolTableRoot);
	strList->next = NULL;
	$$=(void*)strList; 
}
| argument_expression_list ',' primary_expression 
{ // List of argument for calling a function, by addition
	struct string_list* strList = (struct string_list*)$1;
	struct string_list* strElement = malloc( sizeof ( struct string_list ) );
	strElement->str = postfixExpressionToRegister($3,
			symbolTableCurrentNode,
			symbolTableRoot);
	strElement->next = strList;
	$$=(void*)strElement;
}
;


unary_expression
: postfix_expression 
{
	$$ = $1;
}
| INC_OP unary_expression 
{ // Access to an incremented value, not only the instruction of incrementation
	char* reg2 = postfixExpressionToRegister($2,
			symbolTableCurrentNode,
			symbolTableRoot);
	symbolTableCurrentNode->code = 
		addString(symbolTableCurrentNode->code,"%s %s, %s \n", "\taddl\t", "$1", reg2);
	// Return the offset
	$$=$2;
}
| DEC_OP unary_expression 
{ // Access to an decreased value, not only the instruction of decrementation
	char* reg2 = postfixExpressionToRegister($2,
			symbolTableCurrentNode,
			symbolTableRoot);
	symbolTableCurrentNode->code = addString(symbolTableCurrentNode->code,"%s %s, %s \n", "\tsubl\t", "$1", reg2);
	// Return the offset
	$$=$2;
}
| unary_operator unary_expression 
{
	if ($1[0] == '-')
	{
		fprintf(LOG," - operator on %s\n", $2);
		char* reg2 = NULL;
		if (isIdentifier($2))
		{
			reg2 = postfixExpressionToRegister($2,
					symbolTableCurrentNode,
					symbolTableRoot);
		}
		else if( $2[0] == '%')
		{
			reg2 = $2;
		}
		if (reg2 != NULL)
		{
			fprintf(LOG," -op on register : %s\n", reg2);
			symbolTableCurrentNode->code =
				addString(symbolTableCurrentNode->code, "%s [%s*-1], %s\n",
						"\tleal\t", reg2 , reg2);
			$$=$2;
		}
		else
		{
			fprintf(LOG," -op on constant : %s\n", $2);
			char* constant = malloc(sizeof(char) * strlen($1) + 1);
			char* temp = strdup($2);
			sprintf(constant,"$-%s", strtok(temp,"$"));
			$$=constant;
		}
	}
}
;

unary_operator
: '+' {$$="+";}
| '-' {$$="-";}
;

comparison_expression
: unary_expression                            
{ // Boolean, comparison between the expression and zero (false or true)
	char* reg1 = postfixExpressionToRegister($1,
			symbolTableCurrentNode,
			symbolTableRoot);
	symbolTableCurrentNode->code =
		addString(symbolTableCurrentNode->code,"%s $0, %s \n", "\tcmpl\t", reg1);
	$$="jeq";
}
| primary_expression '<' primary_expression   
{ // Lower than, if greater or equal jump after the conditionnal clause
	char* reg1 = postfixExpressionToRegister($1,
			symbolTableCurrentNode,
			symbolTableRoot);
	char* reg3 = postfixExpressionToRegister($3,
			symbolTableCurrentNode,
			symbolTableRoot);
	symbolTableCurrentNode->code =
		addString(symbolTableCurrentNode->code,"%s %s, %s \n","\tmovl\t", reg3,"%ebx");
	symbolTableCurrentNode->code = 
		addString(symbolTableCurrentNode->code,"%s %s, %s \n", "\tcmpl\t", "%ebx", reg1);
	$$="\tjge\t";
} 
| primary_expression '>' primary_expression   
{// Greater than, if lower or equal jump after the conditionnal clause
	char* reg1 = postfixExpressionToRegister($1,
			symbolTableCurrentNode,
			symbolTableRoot);
	char* reg3 = postfixExpressionToRegister($3,
			symbolTableCurrentNode,
			symbolTableRoot);
	symbolTableCurrentNode->code =
		addString(symbolTableCurrentNode->code,"%s %s, %s \n","\tmovl\t", reg3,"%ebx");
	symbolTableCurrentNode->code =
		addString(symbolTableCurrentNode->code,"%s %s, %s \n", "\tcmpl\t", "%ebx", reg1);
	$$="\tjle\t";
}
| primary_expression LE_OP primary_expression 
{ // Lower or equal than, if greater jump after the conditionnal clause
	char* reg1 = postfixExpressionToRegister($1,
			symbolTableCurrentNode,
			symbolTableRoot);
	char* reg3 = postfixExpressionToRegister($3,
			symbolTableCurrentNode,
			symbolTableRoot);
	symbolTableCurrentNode->code =
		addString(symbolTableCurrentNode->code,"%s %s, %s \n","\tmovl\t", reg3,"%ebx");
	symbolTableCurrentNode->code =
		addString(symbolTableCurrentNode->code,"%s %s, %s \n", "\tcmpl\t", "%ebx", reg1);
	$$="\tjg\t";
}
| primary_expression GE_OP primary_expression 
{ // Greater or equal than, if lower jump after the conditionnal clause
	char* reg1 = postfixExpressionToRegister($1,
			symbolTableCurrentNode,
			symbolTableRoot);
	char* reg3 = postfixExpressionToRegister($3,
			symbolTableCurrentNode,
			symbolTableRoot);
	symbolTableCurrentNode->code =
		addString(symbolTableCurrentNode->code,"%s %s, %s \n","\tmovl\t", reg3,"%ebx");
	symbolTableCurrentNode->code =
		addString(symbolTableCurrentNode->code,"%s %s, %s \n", "\tcmpl\t", "%ebx", reg1); 
	$$="\tjl\t";
} 
| primary_expression EQ_OP primary_expression 
{ // Equal to, if not jump after the conditionnal clause
	char* reg1 = postfixExpressionToRegister($1,
			symbolTableCurrentNode,
			symbolTableRoot);
	char* reg3 = postfixExpressionToRegister($3,
			symbolTableCurrentNode,
			symbolTableRoot);
	symbolTableCurrentNode->code =
		addString(symbolTableCurrentNode->code,"%s %s, %s \n","\tmovl\t", reg3,"%ebx");
	symbolTableCurrentNode->code = 
		addString(symbolTableCurrentNode->code,"%s %s, %s \n", "\tcmpl\t", "%ebx", reg1); 
	$$="\tjne\t";
} 
| primary_expression NE_OP primary_expression 
{ // Not equal to, if equal jump after the conditionnal clause
	char* reg1 = postfixExpressionToRegister($1,
			symbolTableCurrentNode,
			symbolTableRoot);
	char* reg3 = postfixExpressionToRegister($3,
			symbolTableCurrentNode,
			symbolTableRoot);
	symbolTableCurrentNode->code =
		addString(symbolTableCurrentNode->code,"%s %s, %s \n","\tmovl\t", reg3,"%ebx");
	symbolTableCurrentNode->code = 
		addString(symbolTableCurrentNode->code,"%s %s, %s \n", "\tcmpl\t", "%ebx", reg1); 
	$$="\tjeq\t";
} 
;

expression
: unary_expression assignment_operator unary_expression 
{ // Assignment operation
	char* dbg1 = $1;
	char* dbg3 = $3;
	fprintf(LOG,"expression, assignement operator = %d\n$1 = %s\n$3 = %s\n", $2, $1, $3);
	struct symbolTableIdentifierList* id1;
	struct symbolTableIdentifierList* id3;
	if (isIdentifier($1))
	{
		id1 = getIdentifier($1,
				symbolTableCurrentNode,
				symbolTableRoot);
	}
	else
	{
		// Creation of artificial entry for constants and predifined registers
		id1 = malloc(sizeof(struct symbolTableIdentifierList));
		id1->type = type_UNDEFINED;
	}

	if (isIdentifier($3))
	{
		id3 = getIdentifier($3,
				symbolTableCurrentNode,
				symbolTableRoot);
	}
	else
	{
		// Creation of artificial entry for constants and predifined registers
		id3 = malloc(sizeof(struct symbolTableIdentifierList));
		id3->type = type_UNDEFINED;
	}
	fprintf(LOG,"expression, operand retrieved\n");
	assert(id1 != NULL);
	assert(id3 != NULL);


	// Operator Management
	if ($2 == operator_MUL)
	{
		if (id1->type & type_ARRAY || $1[0] == '#')
		{
			if (id3->type & type_ARRAY || $3[0] == '#') // array *= array
			{
				/*
				 * t1[i] = t1[i] * t3[i];
				 * loop:
				 * movl $0, %ecx
				 * cmpl %ecx, $array1Size 
				 * jeq exit
				 *  
				 *
				 *
				 */
				fprintf(LOG,"%s *= %s\n", $1, $3);	      
				int array1Size = getArraySize($1, symbolTableCurrentNode, symbolTableRoot);
				int array3Size = getArraySize($3, symbolTableCurrentNode, symbolTableRoot);
				fprintf(LOG,"size1 = %d - size2 = %d\n", array1Size, array3Size);



				int array1StartOffset = getArrayOffset($1,symbolTableCurrentNode, symbolTableRoot);
				int array3StartOffset = getArrayOffset($3,symbolTableCurrentNode, symbolTableRoot);
				fprintf(LOG,"startOffset1 = %d - startOffset1 = %d\n", array1StartOffset, array3StartOffset);

				int i;
				int nbIter = (int)(array1Size/4);
				for(i=0;i<nbIter;i++)
				{
					sseMultStep(array1StartOffset + 4*i, array3StartOffset + 4*i,
							symbolTableCurrentNode);
				}
				for(i=0;i<array1Size%4;i++)
				{
					symbolTableCurrentNode->code = 
						addString(symbolTableCurrentNode->code,"\tmovl\t -%d(%s), %s\n", 
								array3StartOffset+(nbIter*4*4)+(i*4), "%ebp", "%eax");
					symbolTableCurrentNode->code = 
						addString(symbolTableCurrentNode->code,"\tmull\t -%d(%s)\n", array1StartOffset+(nbIter*4*4)+(i*4), "%ebp");
					symbolTableCurrentNode->code = 
						addString(symbolTableCurrentNode->code,"\tmovl\t %s, -%d(%s)\n", "%eax", array1StartOffset+(nbIter*4*4)+(i*4), "%ebp");

				}
			}
			else // array *= var
			{
				int array1Size = getArraySize($1, symbolTableCurrentNode, symbolTableRoot);

				int array1StartOffset = getArrayOffset($1,symbolTableCurrentNode, symbolTableRoot);

				int i;
				if($3[0] == '$')
				{
					fprintf(LOG, "LA %s\n", $3);
					for(i=0;i<array1Size;i++)
					{
						symbolTableCurrentNode->code = 
							addString(symbolTableCurrentNode->code,"\tmovl\t -%d(%s), %s\n", array1StartOffset+i*4, "%ebp", "%eax");
						symbolTableCurrentNode->code = 
							addString(symbolTableCurrentNode->code,"\tmull\t %s\n", $3);
						symbolTableCurrentNode->code = 
							addString(symbolTableCurrentNode->code,"\tmovl\t %s, -%d(%s)\n", "%eax",  array1StartOffset+i*4, "%ebp");
					}
				}
				else {
					for(i=0;i<array1Size;i++)
					{
						symbolTableCurrentNode->code = 
							addString(symbolTableCurrentNode->code,"\tmovl\t -%d(%s), %s\n", array1StartOffset+i*4, "%ebp", "%eax");
						symbolTableCurrentNode->code = 
							addString(symbolTableCurrentNode->code,"\tmull\t -%d(%s)\n", id3->offset,  "%ebp");
						symbolTableCurrentNode->code = 
							addString(symbolTableCurrentNode->code,"\tmovl\t %s, -%d(%s)\n", "%eax",  array1StartOffset+i*4, "%ebp");
					}
				}
			}
		}
		else
		{
			if (id3->type & type_ARRAY || $3[0] == '#') // var *= array
			{
				int array3Size = getArraySize($3, symbolTableCurrentNode, symbolTableRoot);
				int array3StartOffset = getArrayOffset($3,symbolTableCurrentNode, symbolTableRoot);

				symbolTableCurrentNode->code = 
					addString(symbolTableCurrentNode->code,"\tmovl\t $1, %s\n", "%eax");
				int i;
				for (i=0;i<array3Size;i++)
				{
					symbolTableCurrentNode->code = 
						addString(symbolTableCurrentNode->code,"\tmull\t -%d(%s)\n", array3StartOffset + 4*i, "%ebp", "%eax");
				}
				symbolTableCurrentNode->code = 
					addString(symbolTableCurrentNode->code,"\tmovl\t %s, -%d(%s)\n", "%eax", id1->offset, "%ebp");
				yyerror("Not implemented yet !");
			}
			else // var *= var 
			{
				char* reg1 = NULL, *reg3 = NULL;
				if (!getAndCheckExpressions(&reg1,&reg3,id1,id3,$1,$3,
							symbolTableCurrentNode, symbolTableRoot))
				{
					yyerror("First operand of operator cant be a constant"); 
					exit(0);
				}
				symbolTableCurrentNode->code = 
					addString(symbolTableCurrentNode->code,"%s %s, %s \n",
							"\tmovl\t", reg3,"%eax");
				symbolTableCurrentNode->code = 
					addString(symbolTableCurrentNode->code,"%s %s\n",
							"\tmull\t", reg1);
				symbolTableCurrentNode->code =
					addString(symbolTableCurrentNode->code,"%s %s, %s \n",
							"\tmovl\t", "%eax", reg1);
			}
		}
	}
	else if ($2 == operator_ADD)
	{
		if (id1->type & type_ARRAY || $1[0] == '#')
		{
			if (id3->type & type_ARRAY || $3[0] == '#') // array += array
			{
				yyerror("array += array");
				fprintf(stderr,"%s *= %s\n", $1, $3);	      
				int array1Size = getArraySize($1, symbolTableCurrentNode, symbolTableRoot);
				int array3Size = getArraySize($3, symbolTableCurrentNode, symbolTableRoot);
				fprintf(LOG,"size1 = %d - size2 = %d\n", array1Size, array3Size);



				int array1StartOffset = getArrayOffset($1,symbolTableCurrentNode, symbolTableRoot);
				int array3StartOffset = getArrayOffset($3,symbolTableCurrentNode, symbolTableRoot);
				fprintf(LOG,"startOffset1 = %d - startOffset1 = %d\n", array1StartOffset, array3StartOffset);

				int i;
				int nbIter = (int)(array1Size/4);
				for(i=0;i<nbIter;i++)
				{
					sseAddStep(array1StartOffset + 4*i, array3StartOffset + 4*i,
							symbolTableCurrentNode);
				}
				for(i=0;i<array1Size%4;i++)
				{
					symbolTableCurrentNode->code = 
						addString(symbolTableCurrentNode->code,"\tmovl\t -%d(%s), %s\n", 
								array3StartOffset+(nbIter*4*4)+(i*4), "%ebp", "%ebx");
					symbolTableCurrentNode->code = 
						addString(symbolTableCurrentNode->code,"\taddl\t %s, -%d(%s)\n", "%ebx", array1StartOffset+(nbIter*4*4)+(i*4), "%ebp");
				}
			}
			else // array += var
			{
				int array1Size = getArraySize($1, symbolTableCurrentNode, symbolTableRoot);
				int array1StartOffset = getArrayOffset($1, symbolTableCurrentNode, symbolTableRoot);
				int i;

				if($3[0] == '$') {
					for(i=0; i < array1Size; i++) {
						symbolTableCurrentNode->code = 
							addString(symbolTableCurrentNode->code,"\taddl\t %s, -%d(%s)\n", $3, array1StartOffset+(i*4), "%ebp");
					}
				}
				else {
					symbolTableCurrentNode->code = 
						addString(symbolTableCurrentNode->code,"\tmovl\t -%d(%s), %s\n", id3->offset, "%ebp", "%ebx");
					for(i=0; i < array1Size; i++) {
						symbolTableCurrentNode->code = 
						addString(symbolTableCurrentNode->code,"\taddl\t %s, -%d(%s)\n", "%ebx", array1StartOffset+(i*4), "%ebp");
					}
				}
			}
		}
		else
		{
			if (id3->type & type_ARRAY || $3[0] == '#') // var += array
			{
				int array3Size = getArraySize($3, symbolTableCurrentNode, symbolTableRoot);
				int array3StartOffset = getArrayOffset($3, symbolTableCurrentNode, symbolTableRoot);
				int i;

				symbolTableCurrentNode->code = 
					addString(symbolTableCurrentNode->code,"\tmovl\t $0, %s\n", "%ebx");
				for(i=0; i < array3Size; i++) {
					symbolTableCurrentNode->code = 
						addString(symbolTableCurrentNode->code,"\taddl\t -%d(%s), %s\n", array3StartOffset+(i*4), "%ebp", "%ebx");
				}
				symbolTableCurrentNode->code = 
					addString(symbolTableCurrentNode->code,"\tmovl\t %s, -%d(%s)\n", "%ebx", id1->offset, "%ebp");
			}
			else // var += var 
			{
				char* reg1 = NULL, *reg3 = NULL;
				if (!getAndCheckExpressions(&reg1,&reg3,id1,id3,$1,$3,
							symbolTableCurrentNode, symbolTableRoot))
				{
					yyerror("First operand of operator cant be a constant"); 
					exit(0);
				}
				char* operator = "\taddl\t";
				symbolTableCurrentNode->code = 
					addString(symbolTableCurrentNode->code,"%s %s, %s \n",
							"\tmovl\t", reg3,"%ebx");
				symbolTableCurrentNode->code = 
					addString(symbolTableCurrentNode->code,"%s %s, %s \n",
							operator, "%ebx", reg1); 
				$$=reg1;
			}
		}
	}
	else if ($2 == operator_SUB)
	{
		if (id1->type & type_ARRAY || $1[0] == '#')
		{
			if (id3->type & type_ARRAY || $3[0] == '#') // array -= array
			{
				yyerror("array -= array");
				fprintf(stderr,"%s *= %s\n", $1, $3);	      
				int array1Size = getArraySize($1, symbolTableCurrentNode, symbolTableRoot);
				int array3Size = getArraySize($3, symbolTableCurrentNode, symbolTableRoot);
				fprintf(LOG,"size1 = %d - size2 = %d\n", array1Size, array3Size);



				int array1StartOffset = getArrayOffset($1,symbolTableCurrentNode, symbolTableRoot);
				int array3StartOffset = getArrayOffset($3,symbolTableCurrentNode, symbolTableRoot);
				fprintf(LOG,"startOffset1 = %d - startOffset1 = %d\n", array1StartOffset, array3StartOffset);

				int i;
				int nbIter = (int)(array1Size/4);
				for(i=0;i<nbIter;i++)
				{
					sseSubStep(array1StartOffset + 4*i, array3StartOffset + 4*i,
							symbolTableCurrentNode);
				}
				for(i=0;i<array1Size%4;i++)
				{
					symbolTableCurrentNode->code = 
						addString(symbolTableCurrentNode->code,"\tmovl\t -%d(%s), %s\n", 
								array3StartOffset+(nbIter*4*4)+(i*4), "%ebp", "%ebx");
					symbolTableCurrentNode->code = 
						addString(symbolTableCurrentNode->code,"\tsubl\t %s, -%d(%s)\n", "%ebx", array1StartOffset+(nbIter*4*4)+(i*4), "%ebp");
				}
				yyerror("Not implemented yet !");
			}
			else // array -= var
			{
				int array1Size = getArraySize($1, symbolTableCurrentNode, symbolTableRoot);
				int array1StartOffset = getArrayOffset($1, symbolTableCurrentNode, symbolTableRoot);
				int i;

				if($3[0] == '$') {
					for(i=0; i < array1Size; i++) {
						symbolTableCurrentNode->code = 
							addString(symbolTableCurrentNode->code,"\tsubl\t %s, -%d(%s)\n", $3, array1StartOffset+(i*4), "%ebp");
					}
				}
				else {
					symbolTableCurrentNode->code = 
						addString(symbolTableCurrentNode->code,"\tmovl\t -%d(%s), %s\n", id3->offset, "%ebp", "%ebx");
					for(i=0; i < array1Size; i++) {
						symbolTableCurrentNode->code = 
							addString(symbolTableCurrentNode->code,"\tsubl\t %s, -%d(%s)\n", "%ebx", array1StartOffset+(i*4), "%ebp");
					}
				}
			}
		}
		else
		{
			if (id3->type & type_ARRAY || $3[0] == '#') // var -= array
			{
				int array3Size = getArraySize($3, symbolTableCurrentNode, symbolTableRoot);
				int array3StartOffset = getArrayOffset($3, symbolTableCurrentNode, symbolTableRoot);
				int i;

				symbolTableCurrentNode->code = 
					addString(symbolTableCurrentNode->code,"\tmovl\t $0, %s\n", "%ebx");
				for(i=0; i < array3Size; i++) {
					symbolTableCurrentNode->code = 
						addString(symbolTableCurrentNode->code,"\tsubl\t -%d(%s), %s\n", array3StartOffset+(i*4), "%ebp", "%ebx");
				}
				symbolTableCurrentNode->code = 
					addString(symbolTableCurrentNode->code,"\tmovl\t %s, -%d(%s)\n", "%ebx", id1->offset, "%ebp");
			}
			else // var -= var 
			{
				char* reg1 = NULL, *reg3 = NULL;
				if (!getAndCheckExpressions(&reg1,&reg3,id1,id3,$1,$3,
							symbolTableCurrentNode, symbolTableRoot))
				{
					yyerror("First operand of operator cant be a constant"); 
					exit(0);
				}
				char* operator = "\tsubl\t";
				symbolTableCurrentNode->code = 
					addString(symbolTableCurrentNode->code,"%s %s, %s \n", 
							"\tmovl\t", reg3,"%ebx");
				symbolTableCurrentNode->code = 
					addString(symbolTableCurrentNode->code,"%s %s, %s \n",
							operator, "%ebx", reg1);
				$$=reg1;
			}
		}
	}
	else
	{
		if (id1->type & type_ARRAY || $1[0] == '#')
		{
			if (id3->type & type_ARRAY || $3[0] == '#') // array = array
			{
				int array1Size = getArraySize($1, symbolTableCurrentNode, symbolTableRoot);
				int array3Size = getArraySize($3, symbolTableCurrentNode, symbolTableRoot);

				if(array1Size < array3Size) {
					yyerror("Size mismatch");
					exit(0);
				}

				int array1StartOffset = getArrayOffset($1, symbolTableCurrentNode, symbolTableRoot);
				int array3StartOffset = getArrayOffset($3, symbolTableCurrentNode, symbolTableRoot);
				int i;

				for(i=0; i<array3Size; i++) {
					symbolTableCurrentNode->code = 
						addString(symbolTableCurrentNode->code, "\tmovl\t -%d(%s), %s\n", array3StartOffset+i*4, "%ebp", "%eax");
					symbolTableCurrentNode->code = 
						addString(symbolTableCurrentNode->code, "\tmovl\t %s, -%d(%s)\n", "%eax", array1StartOffset+i*4, "%ebp");
				}

				yyerror("Not implemented yet !");
			}
			else // array = var
			{
				char* reg1 = NULL, *reg3 = NULL;
				if (!getAndCheckExpressions(&reg1,&reg3,id1,id3,$1,$3,
							symbolTableCurrentNode, symbolTableRoot))
				{
					yyerror("First operand of operator cant be a constant"); 
					exit(0);
				}
				symbolTableCurrentNode->code = 
					addString(symbolTableCurrentNode->code,"%s %s, %s \n",
							"\tmovl\t", reg3, reg1);
				yyerror("Not implemented yet !");
			}
		}
		else
		{
			if (id3->type & type_ARRAY || $3[0] == '#') // var = array
			{
				yyerror("Wrong operand type : array");
				return 0;
			}
			else // var = var 
			{ 
				char* reg1 = NULL, *reg3 = NULL;
				if (!getAndCheckExpressions(&reg1,&reg3,id1,id3,$1,$3,
							symbolTableCurrentNode, symbolTableRoot))
				{
					yyerror("First operand of operator cant be a constant"); 
					exit(0);
				}
				if($3[0] == '$') {
				symbolTableCurrentNode->code = 
					addString(symbolTableCurrentNode->code,"%s %s, %s \n",
							"\tmovl\t", reg3, reg1);
				}
				else {
				symbolTableCurrentNode->code = 
					addString(symbolTableCurrentNode->code,"%s %s, %s \n",
							"\tmovl\t", reg3, "%ebx");
				symbolTableCurrentNode->code = 
					addString(symbolTableCurrentNode->code,"%s %s, %s \n",
							"\tmovl\t", "%ebx", reg1);
				}
			}
		}
	}
	fprintf(LOG,"end of expression\n");
}
| unary_expression 
{
	if ($1[0] == '$' || $1[0] == '-' || $1[0] == '%')
		$$ = $1;
	else
		$$=regOffset("%ebp", searchOffset($1, symbolTableCurrentNode, symbolTableRoot));
} 
;

assignment_operator
: '='        {$$=operator_ASSIGN; fprintf(LOG,"op : %d\n", operator_ASSIGN);}
| MUL_ASSIGN {$$=operator_MUL; fprintf(LOG,"op : %d\n", operator_MUL);}
| ADD_ASSIGN {$$=operator_ADD; fprintf(LOG,"op : %d\n", operator_ADD);}
| SUB_ASSIGN {$$=operator_SUB; fprintf(LOG,"op : %d\n", operator_SUB);}
;

declaration
: type_name declarator_list ';' 
{ // Declaration of variable(s) with same type
	int listSize = 0;
	if ( $2 != NULL )
	{
		struct declarator_list *declaratorList = (struct declarator_list*)$2;
		struct declarator_list *temp = NULL;
		do
		{
			int elementSize = 0;
			// add flag for int/float 
			declaratorList->type = $1 | declaratorList->type; 
			// If array, add in current symbol table with dimension
			if (declaratorList->type & type_ARRAY)
			{
				elementSize = 
					addArrayIdentifier(declaratorList->name, declaratorList->size,
							declaratorList->type, symbolTableCurrentNode,
							declaratorList->nbArrayDimension, 
							declaratorList->dimensionSizes);
			}
			// If not function, add in current symbol table
			else if (!(declaratorList->type & type_FUNCTION))
			{
				addIdentifier(declaratorList->name, declaratorList->size,
						declaratorList->type, symbolTableCurrentNode);
				elementSize = declaratorList->size;
			}
			listSize+=elementSize;	  
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
{ // Add a declarator to the list which will be treaten
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
: IDENTIFIER 
{
	struct declarator_list *di = malloc(sizeof(struct declarator_list));
	di->name = strdup($1);
	di->size=1;
	di->type=0;
	di->next = NULL;
	$$=(void*)di;
} 
| '(' declarator ')' 
{
	struct declarator_list *di = malloc(sizeof(struct declarator_list));
	struct declarator_list *di2 = (struct declarator_list*)$2;
	di->name = strdup(di2->name);
	di->size = di2->size;
	di->type = di2->type;
	di->next = NULL;
	$$=(void*)di;  
} 
| declarator '[' CONSTANT ']'
{ 
	struct declarator_list *di = (struct declarator_list*)$1;
	if (di->type == type_ARRAY)
	{
		di->dimensionSizes[di->nbArrayDimension] = atoi($3);
		di->nbArrayDimension++;
	}
	else
	{
		di->type = type_ARRAY;
		di->dimensionSizes[di->nbArrayDimension] = atoi($3);
		di->nbArrayDimension++;
	}
	di->next = NULL;
	$$=(void*)di; 
} 
| declarator '[' ']' {}
| declarator '(' parameter_list ')'
{ //* Creation de la table de symbole de la fonction + ajout des parametres a la table

	struct declarator_list *di = malloc(sizeof(struct declarator_list));
	struct declarator_list *di2 = (struct declarator_list*)$1;
	di->name=strdup(di2->name);
	di->size = 0;
	di->type = type_FUNCTION;
	di->next = NULL;
	fprintf(LOG, "declarator ( param )");
	$$=(void*)di;  // Function is already added in symbolTable

	// If the function has not been declared before
	if(getFunctionNode(symbolTableRoot,di->name) == NULL) {
		// Function's symbol table is created
		struct symbolTableTreeNode* newNode = createFunctionTreeNode(symbolTableRoot, di->name);
		fprintf(LOG, "creation table fonction %s , %p \n", di->name, newNode);

		struct declarator_list *parameterList = (struct declarator_list*)$3;
		struct declarator_list *temp = NULL;
		do
		{
			// Add parameter in the new node
			fprintf(LOG,"adding function parameter %s, size = %d, type = %d\n", 
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
{ 

	struct declarator_list *di = malloc(sizeof(struct declarator_list));
	struct declarator_list *di2 = (struct declarator_list*)$1;
	di->name= strdup(di2->name);
	di->size = 0;
	di->next = NULL;
	di->type = type_FUNCTION;
	fprintf(LOG, "declarator ()");
	$$=(void*)di; // Function is already added in symbolTable

	// If the function has not been declared before
	if(getFunctionNode(symbolTableRoot,di->name) == NULL) 
		// Function's symbol table is created
	{
		struct symbolTableTreeNode* newNode = createFunctionTreeNode(symbolTableRoot, di->name);
		fprintf(LOG, "creation table fonction %s , %p \n", di->name, newNode);
	}
}
;


parameter_list
: parameter_declaration {
	struct declarator_list *di = malloc(sizeof(struct declarator_list));
	struct declarator_list *di2 = (struct declarator_list*)$1;
	di->name= strdup(di2->name);
	di->size = di2->size;
	$$=(void*)di;
}
| parameter_list ',' parameter_declaration 
{ // Parameters are added in a list
	struct declarator_list *parameterInfo = (struct declarator_list*)$3;
	struct declarator_list *parameterList = (struct declarator_list*)$1;
	parameterInfo->next = parameterList;
	$$ = (void*) parameterInfo; 
}
;

parameter_declaration
: type_name declarator 
{ // Function's parameters with same type declaration 
	struct declarator_list *di = malloc(sizeof(struct declarator_list));
	struct declarator_list *di2 = (struct declarator_list*)$2;
	di->name= strdup(di2->name);
	di->size = di2->size;
	di->type = $1 | di2->type;
	$$=(void*)di;
}
;

statement
: labeled_statement {$$=$1; /* Label instructions */}
| 
{
	// Statement's begin
	fprintf(LOG, "Compound_statement");
	// New symbol table (creation of a new node in the tree)
	struct symbolTableTreeNode* newNode = createTreeNode(symbolTableCurrentNode);
	// Current node became the new one's
	symbolTableCurrentNode = newNode;
	fprintf(LOG, "Current Table :%s \n", symbolTableCurrentNode->functionName);
}
compound_statement
{
	// Statement's end
	// Code's addition
	symbolTableCurrentNode->father->code = 
		addStringList(symbolTableCurrentNode->father->code,
				symbolTableCurrentNode->code);
	// Change current symbol table for father's
	symbolTableCurrentNode = symbolTableCurrentNode->father;
	fprintf(LOG,"Current Table :%s \n", symbolTableCurrentNode->functionName);
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
declaration_list statement_list '}' 
{
	// Statement's end, give the symbol list to father
	$$=$2;
}
;

declaration_list
: declaration 
{
	int dbg1 = $1;
	$$ = $1;
}
| declaration_list declaration 
{
	int dbg1 = $1, dgb2 = $2;
	$$ = $1 + $2;
}
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
: {fprintf(LOG, "lecture du IF");} 
IF '(' 
{fprintf(LOG, "lecture de la comparaison");} 
comparison_expression ')' 
{ /* Conditional statement*/ 
	// Creation of a new IF label
	char* lbl = newLabel("IF");
	symbolTableCurrentNode->code = addString(symbolTableCurrentNode->code,"%s %s\n", $5, lbl);
	push(lbl,labelPile);
	fprintf(LOG, "début du statement (IF)");
}
statement
{
	/* End of the statement */
	fprintf(LOG, "fin du statement (IF)");
	char* lbl = pop(labelPile);
	// Write label name after the statement
	symbolTableCurrentNode->code = addString(symbolTableCurrentNode->code,"%s:\n",lbl);
	fprintf(LOG, "fin lecture du IF");
}
;

jump_statement
: GOTO IDENTIFIER ';' 
{ // Go to instruction
	symbolTableCurrentNode->code = addString(symbolTableCurrentNode->code,"%s %s\n", "\tjmp\t", gotoLabel($2));
}
| RETURN ';' 
{ // Exit function without return value
	symbolTableCurrentNode->code = addString(symbolTableCurrentNode->code,"\t%s\n \t%s\n", "leave", "ret");
}
| RETURN expression ';' 
{ // Exit function with return value
	fprintf(LOG, "retour expression %s \n", $2);
	symbolTableCurrentNode->code = addString(symbolTableCurrentNode->code,"\t%s \t%s, %s\n", "movl", $2, "%eax");
	symbolTableCurrentNode->code = addString(symbolTableCurrentNode->code,"\t%s\n \t%s\n", "leave", "ret");
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
	/* Function declaration */
	struct declarator_list* decl = (struct declarator_list*)$2;
	char* functionName = decl->name;
	fprintf(LOG,"Declaration of function : %s\n", functionName);
	struct declarator_list * f = (struct declarator_list *) $2;

	// Symbol table is created in the "declarator" rule
	// Searching for the good node in order to put it as current symbol table
	symbolTableCurrentNode = getFunctionNode(symbolTableRoot, f->name);
	fprintf(LOG, "Current Table :%s \n", symbolTableCurrentNode->functionName);
	fprintf(LOG, "%s %p \n", f->name, symbolTableCurrentNode);
}
compound_statement 
{
	struct declarator_list* decl = (struct declarator_list*)$2;
	char* functionName = decl->name;
	int stackSize = $4;
	stackSize += getFunctionNode(symbolTableRoot,functionName)->parameterSize;

	// Function's initialization (Stack)
	fprintf(LOG,"Ajout du code d'init, stackSize = %d\n", stackSize);
	asmCode = addString(asmCode,
			"\n.globl %s\n\t.type\t %s, @function\n%s:\n\tpushl\t %s\n\tmovl\t %s, %s\n\tsubl\t $%d, %s\n",functionName, functionName, functionName, "%ebp", "%esp", "%ebp", (stackSize+1)*4, "%esp"); // USE GCC init

	// Function's body
	fprintf(LOG,"Ajout du code du corps : %s\n", symbolTableCurrentNode->code->str);
	asmCode = addStringList(asmCode, symbolTableCurrentNode->code);
	asmCode = addString(asmCode,"\t%s\n\t%s\n","leave","ret");

	// End of the instructions
	// Current symbol table comes back to father's
	symbolTableCurrentNode = symbolTableCurrentNode->father;
	assert(symbolTableCurrentNode != NULL);



	fprintf(LOG,"End of declaration of function : %s\n", functionName);
}
;

%%


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
	LOG = fopen("log","w");
	labelPile = createPile(100);
	symbolTableRoot = createTreeNode(NULL); // la racine n'a pas de père (father = NULL)
	symbolTableRoot->functionName = "_root";
	symbolTableCurrentNode = symbolTableRoot; 
}

void globalFree()
{
	freePile(labelPile);
	fclose(LOG);
}
