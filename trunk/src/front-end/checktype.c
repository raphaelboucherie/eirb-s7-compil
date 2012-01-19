#ifndef __CHECK_TYPE_H__
#define __CHECK_TYPE_H__

#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <regex.h>
#include "derivationtree.h"
#include "symtable.h"
#include "checktype.h"

#define NB_OP 13

char* operator[NB_OP] = { 	
				"++", 	/* 0 */
				"--", 	/* 1 */
				"<=", 	/* 2 */
				">=", 	/* 3 */
				"==", 	/* 4 */
				"!=", 	/* 5 */
				"=", 	/* 6 */
				"+", 	/* 7 */
				"-", 	/* 8 */
				"*", 	/* 9 */
				"<", 	/* 10 */
				">", 	/* 11 */
				"|" 	/* 12 */
};
int type_left = 0, type_right = 0;
const char *var_regex = "";
	
int check_type(TreeNode* tn, const Node* symtable){
	int i = 0;
	Node* operand;
	if(type_left == TYPE_UNDEF || type_right == TYPE_UNDEF){
		return TYPE_UNDEF;
	}
	if(tn->right != NULL){
		type_right = check_type(tn->right, symtable);
	}
	if(tn->left != NULL){
		type_left = check_type(tn->left, symtable);
	}
	/* Validation du type */
	while(i < NB_OP && strcmp(tn->content, operator[i]))
		i++;
	if(i != NB_OP){
		/* C'est un opérateur */
		printf("Operator : %s, type_left = %d, type_right = %d\n", operator[i], type_left, type_right);
		switch(i){
			case 2 : /* <= */
				if(type_left == TYPE_INT && type_right == TYPE_INT){
					return TYPE_INT;
				}
				else if(type_left == TYPE_FLOAT && type_right == TYPE_FLOAT){
					return TYPE_INT;
				}
				else if(type_left == TYPE_FLOAT && type_right == TYPE_CONSTANT){
					return TYPE_INT;
				}
				else if(type_left == TYPE_CONSTANT && type_right == TYPE_CONSTANT){
					return TYPE_INT;
				}
				else{
					return TYPE_UNDEF;
				}
			break;

			case 3 : /* >= */
				if(type_left == TYPE_INT && type_right == TYPE_INT){
					return TYPE_INT;
				}
				else if(type_left == TYPE_FLOAT && type_right == TYPE_FLOAT){
					return TYPE_INT;
				}
				else if(type_left == TYPE_FLOAT && type_right == TYPE_CONSTANT){
					return TYPE_INT;
				}
				else if(type_left == TYPE_CONSTANT && type_right == TYPE_CONSTANT){
					return TYPE_INT;
				}
				else{
					return TYPE_UNDEF;
				}
			break;

			case 4 : /* == */
				if(type_left == TYPE_INT && type_right == TYPE_INT){
					return TYPE_INT;
				}
				else if(type_left == TYPE_FLOAT && type_right == TYPE_FLOAT){
					return TYPE_INT;
				}
				else if(type_left == TYPE_FLOAT && type_right == TYPE_CONSTANT){
					return TYPE_INT;
				}
				else if(type_left == TYPE_CONSTANT && type_right == TYPE_CONSTANT){
					return TYPE_INT;
				}
				else{
					return TYPE_UNDEF;
				}
			break;

			case 5 : /* != */
				if(type_left == TYPE_INT && type_right == TYPE_INT){
					return TYPE_INT;
				}
				else if(type_left == TYPE_FLOAT && type_right == TYPE_FLOAT){
					return TYPE_INT;
				}
				else if(type_left == TYPE_FLOAT && type_right == TYPE_CONSTANT){
					return TYPE_INT;
				}
				else if(type_left == TYPE_CONSTANT && type_right == TYPE_CONSTANT){
					return TYPE_INT;
				}
				else{
					return TYPE_UNDEF;
				}
			break;
			
			case 6 : /* = */
				if(type_left == type_right){
					printf("Affectation OK\n");
					return type_left;
				}
				else if((type_left == TYPE_INT || type_left == TYPE_FLOAT) && type_right == TYPE_CONSTANT){
					return type_left;
				}
				else{
					printf("Affectation impossible \n");
					return TYPE_UNDEF;
				}
			break;

			case 7 : /* + */
				if(type_left == TYPE_INT && type_right == TYPE_INT){
					return TYPE_INT;
				}
				else if(type_left == TYPE_FLOAT && type_right == TYPE_FLOAT){
					return TYPE_FLOAT;
				}
				else if(type_left == TYPE_CONSTANT){
					if(type_right == TYPE_CONSTANT){
						return TYPE_CONSTANT;
					}
					if(type_right == TYPE_INT){
						return TYPE_INT;
					}
					if(type_right == TYPE_FLOAT){
						return TYPE_FLOAT;
					}
				}
				else if(type_right == TYPE_CONSTANT){
					if(type_left == TYPE_CONSTANT){
						return TYPE_CONSTANT;
					}
					if(type_left == TYPE_INT){
						return TYPE_INT;
					}
					if(type_left == TYPE_FLOAT){
						return TYPE_FLOAT;
					}
				}
				else{
					return TYPE_UNDEF;
				}
			break;
			
			case 8 : /* - */
				if(type_left == TYPE_INT && type_right == TYPE_INT){
					return TYPE_INT;
				}
				else if(type_left == TYPE_FLOAT && type_right == TYPE_FLOAT){
					return TYPE_FLOAT;
				}
				else if(type_left == TYPE_CONSTANT){
					if(type_right == TYPE_CONSTANT){
						return TYPE_CONSTANT;
					}
					if(type_right == TYPE_INT){
						return TYPE_INT;
					}
					if(type_right == TYPE_FLOAT){
						return TYPE_FLOAT;
					}
				}
				else if(type_right == TYPE_CONSTANT){
					if(type_left == TYPE_CONSTANT){
						return TYPE_CONSTANT;
					}
					if(type_left == TYPE_INT){
						return TYPE_INT;
					}
					if(type_left == TYPE_FLOAT){
						return TYPE_FLOAT;
					}
				}
				else{
					return TYPE_UNDEF;
				}
			break;
			
			case 9 : /* * */
				if(type_left == TYPE_INT && type_right == TYPE_INT){
					return TYPE_INT;
				}
				else if(type_left == TYPE_FLOAT && type_right == TYPE_FLOAT){
					return TYPE_FLOAT;
				}
				else if(type_left == TYPE_CONSTANT){
					if(type_right == TYPE_CONSTANT){
						return TYPE_CONSTANT;
					}
					if(type_right == TYPE_INT){
						return TYPE_INT;
					}
					if(type_right == TYPE_FLOAT){
						return TYPE_FLOAT;
					}
				}
				else if(type_right == TYPE_CONSTANT){
					if(type_left == TYPE_CONSTANT){
						return TYPE_CONSTANT;
					}
					if(type_left == TYPE_INT){
						return TYPE_INT;
					}
					if(type_left == TYPE_FLOAT){
						return TYPE_FLOAT;
					}
				}
				else{
					return TYPE_UNDEF;
				}
			break;
			
			case 10 : /* < */
				if(type_left == TYPE_INT && type_right == TYPE_INT){
					return TYPE_INT;
				}
				else if(type_left == TYPE_FLOAT && type_right == TYPE_FLOAT){
					return TYPE_INT;
				}
				else if(type_left == TYPE_CONSTANT && (type_right == TYPE_CONSTANT || type_right == TYPE_INT || type_right == TYPE_FLOAT)){
					return TYPE_INT;
				}
				else if(type_right == TYPE_CONSTANT && (type_left == TYPE_CONSTANT || type_left == TYPE_INT || type_left == TYPE_FLOAT)){
					return TYPE_INT;
				}
				else{
					return TYPE_UNDEF;
				}
			break;
			
			case 11 : /* > */
				if(type_left == TYPE_INT && type_right == TYPE_INT){
					return TYPE_INT;
				}
				else if(type_left == TYPE_FLOAT && type_right == TYPE_FLOAT){
					return TYPE_INT;
				}
				else if(type_left == TYPE_CONSTANT && (type_right == TYPE_CONSTANT || type_right == TYPE_INT || type_right == TYPE_FLOAT)){
					return TYPE_INT;
				}
				else if(type_right == TYPE_CONSTANT && (type_left == TYPE_CONSTANT || type_left == TYPE_INT || type_left == TYPE_FLOAT)){
					return TYPE_INT;
				}
				else{
					return TYPE_UNDEF;
				}
			break;
		}
	}else{
		/* C'est une opérande */
		operand =  get_node_from_symtable(tn->content, symtable);
		// Constante
		if(operand == NULL){		
			return TYPE_CONSTANT;
		}
		// Variable
		return operand->type;
	}
	return TYPE_UNDEF;
}

#endif /* __CHECK_TYPE_H__ */
