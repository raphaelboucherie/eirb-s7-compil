#include "derivationtree.h"

TreeNode* create_tree_node(char* content){
	TreeNode* newTreeNode = malloc(sizeof(TreeNode));
	if(newTreeNode != NULL){
		newTreeNode->content = strdup(content);
		newTreeNode->left = NULL;
		newTreeNode->right = NULL;
		return newTreeNode;
	}
	perror("Allocation error\n");
	exit(1);
}
void set_left(TreeNode* tn, TreeNode* tleft){
	tn->left = tleft;
}

void set_right(TreeNode* tn, TreeNode* tright){
	tn->right = tright;
}

TreeNode* get_right(const TreeNode* tn){
	return tn->right;	
}

TreeNode* get_left(const TreeNode* tn){
	return tn->left;	
}

void print_tree_node(const TreeNode* tn){
	if(tn->left != NULL){
		print_tree_node(tn->left);
	}
	printf("%s\n", tn->content);
	if(tn->right != NULL){
		print_tree_node(tn->right);
	}
}

void free_tree_node(TreeNode* tn){
	if(tn->left != NULL){
		free_tree_node(tn->left);
	}
	if(tn->right != NULL){
		free_tree_node(tn->right);
	}
	free(tn->content);
	free(tn);
}
