#ifndef __CHECK_TYPE_H__
#define __CHECK_TYPE_H__

#include <stdio.h>
#include "globals.h"
#include "checktype.h"
#include "derivationtree.h"
#include "symbolTable.h"

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
int type_left = -1, type_right = -1;
	
int check_type(TreeNode* tn, struct symbolTableTreeNode* symtable, struct symbolTableTreeNode* symtable_root){
	int i = 0;
	struct symbolTableIdentifierList* operand;
	if(type_left == TYPE_UNDEF || type_right == TYPE_UNDEF){
		return TYPE_UNDEF;
	}
	if(tree_length(tn->left) < tree_length(tn->right)){
		if(tn->right != NULL){
			type_right = check_type(tn->right, symtable, symtable_root);
		}
		if(tn->left != NULL){
			type_left = check_type(tn->left, symtable, symtable_root);
		}
	}
	else{	
		if(tn->left != NULL){
			type_left = check_type(tn->left, symtable, symtable_root);
		}
		if(tn->right != NULL){
			type_right = check_type(tn->right, symtable, symtable_root);
		}
	}
	/* Validation du type */
	while(i < NB_OP && strcmp(tn->content, operator[i]))
		i++;
	if(i != NB_OP){
		/* C'est un opérateur */
		printf("Operator : %s, type_left = %d, type_right = %d\n", operator[i], type_left, type_right);
		switch(i){
			case 2 : /* <= */
				if((type_left == TYPE_INT || type_left == TYPE_FCTN_INT) && (type_right == TYPE_INT || type_right == TYPE_FCTN_INT)){
					return TYPE_INT;
				}
				else if(type_left == TYPE_FLOAT && type_right == TYPE_FLOAT){
					return TYPE_INT;
				}
				else if(type_left == TYPE_FLOAT && type_right == TYPE_CONSTANT){
					return TYPE_INT;
				}
				else if(type_left == TYPE_CONSTANT && type_right == TYPE_FLOAT){
				  return TYPE_INT;
				}
				else if(type_left == TYPE_CONSTANT && type_right == TYPE_CONSTANT){
					return TYPE_INT;
				}	
				else if(type_left == TYPE_INT && type_right == TYPE_CONSTANT){
					return TYPE_INT;
				}
				else if(type_left == TYPE_CONSTANT && type_right == TYPE_INT){
				  return TYPE_INT;
				}
				else {
				  return TYPE_UNDEF;
				}
			break;

			case 3 : /* >= */
				if((type_left == TYPE_INT || type_left == TYPE_FCTN_INT) && (type_right == TYPE_INT || type_right == TYPE_FCTN_INT)){
					return TYPE_INT;
				}
				else if(type_left == TYPE_FLOAT && type_right == TYPE_FLOAT){
					return TYPE_INT;
				}
				else if(type_left == TYPE_FLOAT && type_right == TYPE_CONSTANT){
					return TYPE_INT;
				}
				else if(type_left == TYPE_CONSTANT && type_right == TYPE_FLOAT){
				  return TYPE_INT;
				}
				else if(type_left == TYPE_CONSTANT && type_right == TYPE_CONSTANT){
					return TYPE_INT;
				}	
				else if(type_left == TYPE_INT && type_right == TYPE_CONSTANT){
					return TYPE_INT;
				}
				else if(type_left == TYPE_CONSTANT && type_right == TYPE_INT){
				  return TYPE_INT;
				}
				else {
				  return TYPE_UNDEF;
				}
				break;
				
			case 4 : /* == */
			  if((type_left == TYPE_INT || type_left == TYPE_FCTN_INT) && (type_right == TYPE_INT || type_right == TYPE_FCTN_INT)){
			    return TYPE_INT;
			  }
			  else if(type_left == TYPE_FLOAT && type_right == TYPE_FLOAT){
			    return TYPE_INT;
			  }
			  else if(type_left == TYPE_FLOAT && type_right == TYPE_CONSTANT){
			    return TYPE_INT;
			  }
			  else if(type_left == TYPE_CONSTANT && type_right == TYPE_FLOAT){
			    return TYPE_INT;
			  }
			  else if(type_left == TYPE_CONSTANT && type_right == TYPE_CONSTANT){
			    return TYPE_INT;
			  }	
			  else if(type_left == TYPE_INT && type_right == TYPE_CONSTANT){
			    return TYPE_INT;
			  }
			  else if(type_left == TYPE_CONSTANT && type_right == TYPE_INT){
			    return TYPE_INT;
			  }
			  else {
			    return TYPE_UNDEF;
			  }
			  break;
		case 5 : /* != */
			  if((type_left == TYPE_INT || type_left == TYPE_FCTN_INT) && (type_right == TYPE_INT || type_right == TYPE_FCTN_INT)){
			    return TYPE_INT;
			  }
			  else if(type_left == TYPE_FLOAT && type_right == TYPE_FLOAT){
			    return TYPE_INT;
			  }
			  else if(type_left == TYPE_FLOAT && type_right == TYPE_CONSTANT){
			    return TYPE_INT;
			  }
			  else if(type_left == TYPE_CONSTANT && type_right == TYPE_FLOAT){
			    return TYPE_INT;
			  }
			  else if(type_left == TYPE_CONSTANT && type_right == TYPE_CONSTANT){
			    return TYPE_INT;
			  }	
			  else if(type_left == TYPE_INT && type_right == TYPE_CONSTANT){
			    return TYPE_INT;
			  }
			  else if(type_left == TYPE_CONSTANT && type_right == TYPE_INT){
			    return TYPE_INT;
			  }
			  else {
			    return TYPE_UNDEF;
			  }
			  break;
			
			case 6 : /* = */
			  if(type_left == type_right){
			    return type_left;
			  }
			  else if(((type_left == TYPE_INT || type_left == TYPE_FCTN_INT) || type_left == TYPE_FLOAT) && type_right == TYPE_CONSTANT){
			    return type_left;
			  }
			  else {
			    return TYPE_UNDEF;
			  }
			  break;
				
			case 7 : /* + */
				if((type_left == TYPE_INT || type_left == TYPE_FCTN_INT) && (type_right == TYPE_INT || type_right == TYPE_FCTN_INT)){
					return TYPE_INT;
				}
				else if(type_left == TYPE_FLOAT && type_right == TYPE_FLOAT){
					return TYPE_FLOAT;
				}
				else if(type_left == TYPE_CONSTANT){
					if(type_right == TYPE_CONSTANT){
						return TYPE_CONSTANT;
					}
					if((type_right == TYPE_INT || type_right == TYPE_FCTN_INT)){
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
					if((type_left == TYPE_INT || type_left == TYPE_FCTN_INT)){
						return TYPE_INT;
					}
					if(type_left == TYPE_FLOAT){
						return TYPE_FLOAT;
					}
				}else{
					//Si meme types à gauche et à droite (float, float ou int, int)
					if(((type_left == TYPE_INT || type_left == TYPE_FCTN_INT) && (type_right == TYPE_INT || type_right == TYPE_FCTN_INT)) 
						|| (type_left == TYPE_FLOAT && type_right == TYPE_FLOAT)
						|| (type_left == TYPE_CONSTANT && (type_right == TYPE_INT || type_right == TYPE_FCTN_INT))
						|| (type_left == TYPE_CONSTANT && type_right == TYPE_FLOAT)
						|| ((type_left == TYPE_INT || type_left == TYPE_FCTN_INT) && type_right == TYPE_CONSTANT)
						|| (type_left == TYPE_FLOAT && type_right == TYPE_CONSTANT)){
						
						struct symbolTableIdentifierList* left = getIdentifier(tn->left->content, symtable, symtable_root);
						struct symbolTableIdentifierList* right = getIdentifier(tn->right->content, symtable, symtable_root);
						// Si les symboles récupérés sont valides
						if(left == NULL || right == NULL){
							return TYPE_UNDEF;
						}
						// Si les 2 operandes sont un vecteur (tableau de dimension 1)
						if(left->dimension == 1 && right->dimension == 1){
							return TYPE_ARRAY;
						}
					}
				}
			break;
			case 8 : /* - */
				if((type_left == TYPE_INT || type_left == TYPE_FCTN_INT) && (type_right == TYPE_INT || type_right == TYPE_FCTN_INT)){
					return TYPE_INT;
				}
				else if(type_left == TYPE_FLOAT && type_right == TYPE_FLOAT){
					return TYPE_FLOAT;
				}
				else if(type_left == TYPE_CONSTANT){
					if(type_right == TYPE_CONSTANT){
						return TYPE_CONSTANT;
					}
					if((type_right == TYPE_INT || type_right == TYPE_FCTN_INT)){
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
					if((type_left == TYPE_INT || type_left == TYPE_FCTN_INT)){
						return TYPE_INT;
					}
					if(type_left == TYPE_FLOAT){
						return TYPE_FLOAT;
					}
				}else{
					//Si memes types à gauche et à droite (float, float ou int, int)
					if(((type_left == TYPE_INT || type_left == TYPE_FCTN_INT) && (type_left == TYPE_INT || type_left == TYPE_FCTN_INT)) 
						|| (type_left == TYPE_FLOAT && type_left == TYPE_FLOAT)
						|| (type_left == TYPE_CONSTANT && (type_right == TYPE_INT || type_right == TYPE_FCTN_INT))
						|| (type_left == TYPE_CONSTANT && type_right == TYPE_FLOAT)
						|| ((type_left == TYPE_INT || type_left == TYPE_FCTN_INT) && type_right == TYPE_CONSTANT)
						|| (type_left == TYPE_FLOAT && type_right == TYPE_CONSTANT)){
						
						struct symbolTableIdentifierList* left = getIdentifier(tn->left->content, symtable, symtable_root);
						struct symbolTableIdentifierList* right = getIdentifier(tn->right->content, symtable, symtable_root);
						// Si les symboles récupérés sont valides
						if(left == NULL || right == NULL){
							return TYPE_UNDEF;
						}
						// Si les 2 operandes sont des vecteurs (tableau de dimension 1)
						if(left->dimension == 1 && right->dimension == 1){
							return TYPE_ARRAY;
						}
					}
				}
			break;
			
			case 9 : /* * */
				if((type_left == TYPE_INT || type_left == TYPE_FCTN_INT) && (type_right == TYPE_INT || type_right == TYPE_FCTN_INT)){
					return TYPE_INT;
				}
				else if(type_left == TYPE_FLOAT && type_right == TYPE_FLOAT){
					return TYPE_FLOAT;
				}
				else if(type_left == TYPE_CONSTANT){
					if(type_right == TYPE_CONSTANT){
						return TYPE_CONSTANT;
					}
					if((type_right == TYPE_INT || type_right == TYPE_FCTN_INT)){
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
					if((type_left == TYPE_INT || type_left == TYPE_FCTN_INT)){
						return TYPE_INT;
					}
					if(type_left == TYPE_FLOAT){
						return TYPE_FLOAT;
					}
				}else{
					//Si meme types à gauche et à droite (float, float ou int, int)
					if(((type_left == TYPE_INT || type_left == TYPE_FCTN_INT) && (type_left == TYPE_INT || type_left == TYPE_FCTN_INT)) 
						|| (type_left == TYPE_FLOAT && type_left == TYPE_FLOAT)
						|| (type_left == TYPE_CONSTANT && (type_right == TYPE_INT || type_right == TYPE_FCTN_INT))
						|| (type_left == TYPE_CONSTANT && type_right == TYPE_FLOAT)
						|| ((type_left == TYPE_INT || type_left == TYPE_FCTN_INT) && type_right == TYPE_CONSTANT)
						|| (type_left == TYPE_FLOAT && type_right == TYPE_CONSTANT)){
						
						struct symbolTableIdentifierList* left = getIdentifier(tn->left->content, symtable, symtable_root);
						struct symbolTableIdentifierList* right = getIdentifier(tn->right->content, symtable, symtable_root);
						// Si les symboles récupérés sont valides
						if(left == NULL || right == NULL){
							return TYPE_UNDEF;
						}
						// Si l'une des operandes et un vecteur (tableau de dimension 1)
						if(left->dimension == 1 || right->dimension == 1){
							return TYPE_ARRAY;
						}
					}
				}
			break;
			
			case 10 : /* < */
	if((type_left == TYPE_INT || type_left == TYPE_FCTN_INT) && (type_right == TYPE_INT || type_right == TYPE_FCTN_INT)){
					return TYPE_INT;
				}
				else if(type_left == TYPE_FLOAT && type_right == TYPE_FLOAT){
					return TYPE_INT;
				}
				else if(type_left == TYPE_FLOAT && type_right == TYPE_CONSTANT){
					return TYPE_INT;
				}
				else if(type_left == TYPE_CONSTANT && type_right == TYPE_FLOAT){
				  return TYPE_INT;
				}
				else if(type_left == TYPE_CONSTANT && type_right == TYPE_CONSTANT){
					return TYPE_INT;
				}	
				else if(type_left == TYPE_INT && type_right == TYPE_CONSTANT){
					return TYPE_INT;
				}
				else if(type_left == TYPE_CONSTANT && type_right == TYPE_INT){
				  return TYPE_INT;
				}
				else {
				  return TYPE_UNDEF;
				}
				break;
			
			case 11 : /* > */
	if((type_left == TYPE_INT || type_left == TYPE_FCTN_INT) && (type_right == TYPE_INT || type_right == TYPE_FCTN_INT)){
					return TYPE_INT;
				}
				else if(type_left == TYPE_FLOAT && type_right == TYPE_FLOAT){
					return TYPE_INT;
				}
				else if(type_left == TYPE_FLOAT && type_right == TYPE_CONSTANT){
					return TYPE_INT;
				}
				else if(type_left == TYPE_CONSTANT && type_right == TYPE_FLOAT){
				  return TYPE_INT;
				}
				else if(type_left == TYPE_CONSTANT && type_right == TYPE_CONSTANT){
					return TYPE_INT;
				}	
				else if(type_left == TYPE_INT && type_right == TYPE_CONSTANT){
					return TYPE_INT;
				}
				else if(type_left == TYPE_CONSTANT && type_right == TYPE_INT){
				  return TYPE_INT;
				}
				else {
				  return TYPE_UNDEF;
				}
				break;

			case 12 : /* | */
				//Si meme types à gauche et à droite (float, float ou int, int)
				if(type_left == TYPE_ARRAY && type_right == TYPE_ARRAY){
						struct symbolTableIdentifierList* left = getIdentifier(tn->left->content, symtable, symtable_root);
						struct symbolTableIdentifierList* right = getIdentifier(tn->right->content, symtable, symtable_root);
					// Si les symboles récupérés sont valides
					if(left == NULL || right == NULL){
						return TYPE_UNDEF;
					}
					// Si les 2 operandes sont de type vecteur (tableau de dimension 1)
					if(left->dimension != 1 || right->dimension != 1){
						return TYPE_UNDEF;
					}
					return TYPE_ARRAY;
				}
			break;
		}
	}else{
		/* C'est une opérande */
		operand =  getIdentifier(tn->content, symtable, symtable_root);
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
