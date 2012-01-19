#include "generate2a.h"
char* addr_left;
char* addr_right;
char* addr_left_tmp;

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

char* tree_to_2a_code(TreeNode* tn, Node* symtable, char* code_2a){
	if(tree_length(tn->left) > tree_length(tn->right)){
		if(tn->left != NULL){
		  addr_left = tree_to_2a_code(tn->left, symtable, code_2a);
		}

		if(tn->right != NULL){
		  addr_right = tree_to_2a_code(tn->right, symtable, code_2a);
		}
	}

	else{
		if(tn->right != NULL){
		  addr_right = tree_to_2a_code(tn->right, symtable, code_2a);
		}

		if(tn->left != NULL){
		  addr_left = tree_to_2a_code(tn->left, symtable,code_2a);
		}
	}
	if(!strcmp(tn->content, "+")){
	        addr_left_tmp=strdup(addr_left);
	        strcat(addr_left_tmp,"_tmp");	 
          	while(find_in_symtable(addr_left_tmp, symtable))
		  sprintf(addr_left_tmp, "%s_tmp", addr_left_tmp);
		 
		sprintf(code_2a,"%s %s = %s;\n", code_2a, addr_left_tmp,  addr_left);
		sprintf(code_2a,"%s %s += %s;\n", code_2a, addr_left_tmp,  addr_right);
	
		sprintf(addr_left,"%s",addr_left_tmp);
		set_tree_node_content(addr_left, tn);
		return addr_left;
	}
	else if(!strcmp(tn->content, "-")){
	       
         	addr_left_tmp = strdup(addr_left);
	        strcat(addr_left_tmp,"_tmp");	 
          	while(find_in_symtable(addr_left_tmp, symtable))
		  sprintf(addr_left_tmp, "%s_tmp", addr_left_tmp);

		sprintf(code_2a,"%s %s = %s;\n", code_2a, addr_left_tmp,  addr_left);
		sprintf(code_2a,"%s %s -= %s;\n", code_2a, addr_left_tmp,  addr_right);
		
		sprintf(addr_left,"%s",addr_left_tmp);
		set_tree_node_content(addr_left, tn);
		return addr_left;
	}
	else if(!strcmp(tn->content, "*")){
	        
	        addr_left_tmp = strdup(addr_left);
		strcat(addr_left_tmp,"_tmp");	 
          	while(find_in_symtable(addr_left_tmp, symtable))
		  sprintf(addr_left_tmp, "%s_tmp", addr_left_tmp);

		sprintf(code_2a,"%s %s = %s;\n", code_2a, addr_left_tmp,  addr_left);
		sprintf(code_2a,"%s %s *= %s;\n", code_2a, addr_left_tmp,  addr_right);
		
		sprintf(addr_left,"%s",addr_left_tmp);
		set_tree_node_content(addr_left, tn);
		return addr_left;
	}
	else if(!strcmp(tn->content, "=")){
		sprintf(code_2a,"%s %s = %s;\n",code_2a, addr_left, addr_right);
		return addr_left;
	}
	else if(!strcmp(tn->content, "+=")){
		sprintf(code_2a,"%s %s += %s;\n",code_2a, addr_left, addr_right);
		return addr_left;
	}
	else if(!strcmp(tn->content, "*=")){
		sprintf(code_2a,"%s %s *= %s;\n",code_2a, addr_left, addr_right);
		return addr_left;
	}
	else if(!strcmp(tn->content, "-=")){
		sprintf(code_2a,"%s %s -= %s;\n",code_2a, addr_left, addr_right);
		return addr_left;
	}
	else if(!strcmp(tn->content, "<")){
		sprintf(code_2a,"%s if(%s < %s)\n",code_2a, tn->left->content, tn->right->content);

		sprintf(code_2a,"%s %s = 1;\n",code_2a, addr_left);
		sprintf(code_2a,"%s if(%s >= %s)\n",code_2a, tn->left->content, tn->right->content);
		
		sprintf(code_2a,"%s %s = 0;\n",code_2a, addr_left);
		set_tree_node_content(addr_left, tn);
		return addr_left;
	}
	else if(!strcmp(tn->content, ">")){
		sprintf(code_2a,"%s if(%s > %s)\n", code_2a, tn->left->content, tn->right->content);
		
		sprintf(code_2a,"%s %s = 1;\n",code_2a, addr_left);
		sprintf(code_2a,"%s if(%s <= %s)\n",code_2a, tn->left->content, tn->right->content);
		
		sprintf(code_2a,"%s %s = 0;\n",code_2a, addr_left);
		set_tree_node_content(addr_left, tn);
		return addr_left;
	}
	else if(!strcmp(tn->content, "<=")){
		sprintf(code_2a,"%s if(%s <= %s)\n",code_2a, tn->left->content, tn->right->content);
		
		
		sprintf(code_2a,"%s %s = 1;\n",code_2a, addr_left);
		sprintf(code_2a,"%s if(%s > %s)\n",code_2a, tn->left->content, tn->right->content);
		
		sprintf(code_2a,"%s %s = 0;\n",code_2a, addr_left);
		set_tree_node_content(addr_left, tn);
		return addr_left;
	}
	else if(!strcmp(tn->content, ">=")){
		sprintf(code_2a,"%s if(%s >= %s)\n",code_2a, tn->left->content, tn->right->content);
		
		sprintf(code_2a,"%s %s = 1;\n",code_2a, addr_left);
		sprintf(code_2a,"%s if(%s < %s)\n",code_2a, tn->left->content, tn->right->content);
		
		sprintf(code_2a,"%s %s = 0;\n",code_2a, addr_left);
		set_tree_node_content(addr_left, tn);
		return addr_left;
	}
	else if(!strcmp(tn->content, "!=")){
		sprintf(code_2a,"%s %s -= %s;\n",code_2a, tn->left->content, tn->right->content);

		
		set_tree_node_content(addr_left, tn);
		return addr_left;
	}
	else if(!strcmp(tn->content, "==")){
		sprintf(code_2a,"%s if(%s == %s)\n",code_2a, tn->left->content, tn->right->content);
		
		
		sprintf(code_2a,"%s %s = 1;\n", code_2a, addr_left);
		sprintf(code_2a,"%s if(%s != %s)\n",code_2a, tn->left->content, tn->right->content);
		
		sprintf(code_2a,"%s %s = 0;\n",code_2a, addr_left);
		set_tree_node_content(addr_left, tn);
		return addr_left;
	}
	else if(!strcmp(tn->content, "|")){

           	  /* Cas du Pipe */
		/* Idée By Z. :
			On créé un vecteur tmp = v1
			On fait tmp *= v2
			Puis pour le moment on voit pas comment faire l'addition des composantes
		*/
	         addr_left_tmp = strdup(addr_left);
		 strcat(addr_left_tmp,"_tmp");	 
          	while(find_in_symtable(addr_left_tmp, symtable))
		  sprintf(addr_left_tmp, "%s_tmp", addr_left_tmp);
	        
		sprintf(code_2a,"%s %s = %s | %s;\n", code_2a, addr_left_tmp,  tn->left->content, tn->right->content);
		
		sprintf(addr_left,"%s",addr_left_tmp);
		set_tree_node_content(addr_left, tn);
		return addr_left;
	}
//	printf("ddr_left = %s\n", addr_left);
//	printf("addr_right = %s\n", addr_right);
/*	printf("content : %s\n", tn->content); */
	return tn->content;
}
