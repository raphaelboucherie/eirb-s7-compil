#include "derivationtree.h"
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

void set_tree_node_content(char* content, TreeNode* tn){
	if(tn != NULL && tn->content != NULL){
		free(tn->content);
		tn->content = strdup(content);
	}	
}

TreeNode* create_tree_node(char* content){
	TreeNode* newTreeNode = malloc(sizeof(TreeNode));
	if(newTreeNode != NULL){
		newTreeNode->content = strdup(content);
		newTreeNode->left = NULL;
		newTreeNode->right = NULL;
		newTreeNode->next = NULL;
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

void print_tree_node(const TreeNode* tn, int spaces){
	int i;
	for(i = 0; i < spaces; i++)
		printf("  ");
	printf("%s\n", tn->content);
	if(tn->left != NULL){
		print_tree_node(tn->left, spaces+1);
	}
	if(tn->right != NULL){
		print_tree_node(tn->right, spaces+1);
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

void add_to_left(TreeNode* newNode, TreeNode* tn){
	while(tn->left != NULL)	
		tn = tn->left;

	tn->left = newNode;
}

TreeNode* add_end_list_tree_node(TreeNode* start, TreeNode* new){
	TreeNode* s = start;
	if(s != NULL){
		while(s->next != NULL){
			s = s->next;
		}
		s->next = new;
		return start;
	}
	else{
		return new;
	}

}
