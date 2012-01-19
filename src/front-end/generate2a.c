#include "generate2a.h"

void tree_to_2a_code(TreeNode* tn){
	if(tn->right != NULL){
		type_right = check_type(tn->right, symtable);
	}
	if(tn->left != NULL){
		type_left = check_type(tn->left, symtable);
	}

	/* Traitement de la génération de code */


}
