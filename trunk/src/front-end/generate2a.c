#include "generate2a.h"
char* addr_left;
char* addr_right;

int max(int i , int j){
	return (i < j) ? j : i;
}

int tree_length(TreeNode* tn){
	int left = 0;
	int right = 0;
	if(tn == NULL){
		return 0;
	}
	else{
		if(tn->left != NULL){
			left = tree_length(tn->left);
		}
		if(tn->right != NULL){
			right = tree_length(tn->right);
		}
		return 1 + max(left,right);
	}

}

char* tree_to_2a_code(TreeNode* tn, Node* symtable){
	if(tree_length(tn->left) > tree_length(tn->right)){
		if(tn->left != NULL){
			addr_left = tree_to_2a_code(tn->left, symtable);
		}

		if(tn->right != NULL){
			addr_right = tree_to_2a_code(tn->right, symtable);
		}
	}

	else{
		if(tn->right != NULL){
			addr_right = tree_to_2a_code(tn->right, symtable);
		}

		if(tn->left != NULL){
			addr_left = tree_to_2a_code(tn->left, symtable);
		}
	}
	printf("addr_left = %s\n", addr_left);
	printf("addr_right = %s\n", addr_right);
/*	printf("content : %s\n", tn->content); */
	return tn->content;
}
