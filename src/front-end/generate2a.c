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
	if(!strcmp(tn->content, "+")){
		printf("%s_tmp = %s;\n", addr_left, addr_left);
		printf("%s_tmp += %s;\n", addr_left, addr_right);
		sprintf(addr_left, "%s_tmp", addr_left);
		set_tree_node_content(addr_left, tn);
		return addr_left;
	}
	else if(!strcmp(tn->content, "-")){
		printf("%s_tmp = %s;\n", addr_left, addr_left);
		printf("%s_tmp -= %s;\n", addr_left, addr_right);
		sprintf(addr_left, "%s_tmp", addr_left);
		set_tree_node_content(addr_left, tn);
		return addr_left;
	}
	else if(!strcmp(tn->content, "*")){
		printf("%s_tmp = %s;\n", addr_left, addr_left);
		printf("%s_tmp *= %s;\n", addr_left, addr_right);
		sprintf(addr_left, "%s_tmp", addr_left);
		set_tree_node_content(addr_left, tn);
		return addr_left;
	}
	else if(!strcmp(tn->content, "=")){
		printf("%s = %s;\n", addr_left, addr_right);
		sprintf(addr_left, "%s_tmp", addr_left);
		return addr_left;
	}
	else if(!strcmp(tn->content, "+=")){
		printf("%s += %s;\n", addr_left, addr_right);
		sprintf(addr_left, "%s_tmp", addr_left);
		return addr_left;
	}
	else if(!strcmp(tn->content, "*=")){
		printf("%s *= %s;\n", addr_left, addr_right);
		sprintf(addr_left, "%s_tmp", addr_left);
		return addr_left;
	}
	else if(!strcmp(tn->content, "-=")){
		printf("%s -= %s;\n", addr_left, addr_right);
		sprintf(addr_left, "%s_tmp", addr_left);
		return addr_left;
	}
	else if(!strcmp(tn->content, "<")){
		printf("if(%s < %s)\n", tn->left->content, tn->right->content);
		sprintf(addr_left, "%s_tmp", addr_left);
		printf("%s = 1;\n", addr_left);
		printf("if(%s >= %s)\n", tn->left->content, tn->right->content);
		
		printf("%s = 0;\n", addr_left);
		set_tree_node_content(addr_left, tn);
		return addr_left;
	}
	else if(!strcmp(tn->content, ">")){
		printf("if(%s > %s)\n", tn->left->content, tn->right->content);
		sprintf(addr_left, "%s_tmp", addr_left);
		printf("%s = 1;\n", addr_left);
		printf("if(%s <= %s)\n", tn->left->content, tn->right->content);
		
		printf("%s = 0;\n", addr_left);
		set_tree_node_content(addr_left, tn);
		return addr_left;
	}
	else if(!strcmp(tn->content, "<=")){
		printf("if(%s <= %s)\n", tn->left->content, tn->right->content);
		sprintf(addr_left, "%s_tmp", addr_left);
		printf("%s = 1;\n", addr_left);
		printf("if(%s > %s)\n", tn->left->content, tn->right->content);
		
		printf("%s = 0;\n", addr_left);
		set_tree_node_content(addr_left, tn);
		return addr_left;
	}
	else if(!strcmp(tn->content, ">=")){
		printf("if(%s >= %s)\n", tn->left->content, tn->right->content);
		sprintf(addr_left, "%s_tmp", addr_left);
		printf("%s = 1;\n", addr_left);
		printf("if(%s < %s)\n", tn->left->content, tn->right->content);
		
		printf("%s = 0;\n", addr_left);
		set_tree_node_content(addr_left, tn);
		return addr_left;
	}
	else if(!strcmp(tn->content, "!=")){
		printf("%s -= %s;\n", tn->left->content, tn->right->content);
		sprintf(addr_left, "%s_tmp", addr_left);
		set_tree_node_content(addr_left, tn);
		return addr_left;
	}
	else if(!strcmp(tn->content, "==")){
		printf("if(%s == %s)\n", tn->left->content, tn->right->content);
		sprintf(addr_left, "%s_tmp", addr_left);
		printf("%s = 1;\n", addr_left);
		printf("if(%s != %s)\n", tn->left->content, tn->right->content);
		
		printf("%s = 0;\n", addr_left);
		set_tree_node_content(addr_left, tn);
		return addr_left;
	}
	else if(!strcmp(tn->content, "|")){
		/* Cas du Pipe */
		printf("%s_tmp = %s | %s;\n", addr_left, tn->left->content, tn->right->content);
				
		sprintf(addr_left, "%s_tmp", addr_left);
		set_tree_node_content(addr_left, tn);
		return addr_left;
	}
//	printf("addr_left = %s\n", addr_left);
//	printf("addr_right = %s\n", addr_right);
/*	printf("content : %s\n", tn->content); */
	return tn->content;
}
