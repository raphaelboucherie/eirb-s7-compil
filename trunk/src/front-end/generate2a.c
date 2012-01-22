#include "generate2a.h"
char* addr_left;
char* addr_right;
char* addr_left_tmp;
char* scalar_product_name = "res_ps";
char* scalar_product_name_tmp = NULL;
//Node* symtable_tmp = NULL;

char* tree_to_2a_code(TreeNode* tn, struct symbolTableTreeNode* symtable, struct symbolTableTreeNode* symtable_root, char* code_2a){
	if(tree_length(tn->left) > tree_length(tn->right)){
		if(tn->left != NULL){
		  addr_left = tree_to_2a_code(tn->left, symtable, symtable_root, code_2a);
		}

		if(tn->right != NULL){
		  addr_right = tree_to_2a_code(tn->right, symtable, symtable_root, code_2a);
		}
	}

	else{
		if(tn->right != NULL){
		  addr_right = tree_to_2a_code(tn->right, symtable, symtable_root, code_2a);
		}

		if(tn->left != NULL){
		  addr_left = tree_to_2a_code(tn->left, symtable, symtable_root, code_2a);
		}
	}
	if(!strcmp(tn->content, "+")){
	        addr_left_tmp=strdup(addr_left);
		sprintf(addr_left_tmp, "tmp_%s", addr_left);
          	while(getIdentifier(addr_left_tmp, symtable, symtable_root)  !=  NULL)
		  sprintf(addr_left_tmp, "tmp_%s", addr_left_tmp);
		 
		sprintf(code_2a,"%s %s = %s;\n", code_2a, addr_left_tmp,  tn->left->content);
		sprintf(code_2a,"%s %s += %s;\n", code_2a, addr_left_tmp,  tn->right->content);
	
		sprintf(addr_left,"%s",addr_left_tmp);
		set_tree_node_content(addr_left, tn);
		return addr_left;
	}
	else if(!strcmp(tn->content, "-")){
	       
         	addr_left_tmp = strdup(addr_left);
	       sprintf(addr_left_tmp,"tmp_%s", addr_left);	 
          	while(getIdentifier(addr_left_tmp, symtable, symtable_root)  !=  NULL)
		  sprintf(addr_left_tmp, "tmp_%s", addr_left_tmp);

		sprintf(code_2a,"%s %s = %s;\n", code_2a, addr_left_tmp,  tn->left->content);
		sprintf(code_2a,"%s %s -= %s;\n", code_2a, addr_left_tmp,  tn->right->content);
		
		sprintf(addr_left,"%s",addr_left_tmp);
		set_tree_node_content(addr_left, tn);
		return addr_left;
	}
	else if(!strcmp(tn->content, "*")){
	        
	        addr_left_tmp = strdup(addr_left);
		 sprintf(addr_left_tmp,"tmp_%s", addr_left);	 
          	while(getIdentifier(addr_left_tmp, symtable, symtable_root)  !=  NULL)
		  sprintf(addr_left_tmp, "tmp_%s", addr_left_tmp);

		sprintf(code_2a,"%s %s = %s;\n", code_2a, addr_left_tmp,  tn->left->content);
		sprintf(code_2a,"%s %s *= %s;\n", code_2a, addr_left_tmp,  tn->right->content);
		
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
		sprintf(code_2a,"%s %s < %s\n",code_2a, tn->left->content, tn->right->content);

		/*sprintf(code_2a,"%s %s = 1;\n",code_2a, addr_left);
		sprintf(code_2a,"%s if(%s >= %s)\n",code_2a, tn->left->content, tn->right->content);
		
		sprintf(code_2a,"%s %s = 0;\n",code_2a, addr_left);*/
		set_tree_node_content(addr_left, tn);
		return addr_left;
	}
	else if(!strcmp(tn->content, ">")){
		sprintf(code_2a,"%s %s > %s\n", code_2a, tn->left->content, tn->right->content);
		
		/* sprintf(code_2a,"%s %s = 1;\n",code_2a, addr_left);
		sprintf(code_2a,"%s if(%s <= %s)\n",code_2a, tn->left->content, tn->right->content);
		
		sprintf(code_2a,"%s %s = 0;\n",code_2a, addr_left); */
		set_tree_node_content(addr_left, tn);
		return addr_left;
	}
	else if(!strcmp(tn->content, "<=")){
		sprintf(code_2a,"%s %s <= %s\n",code_2a, tn->left->content, tn->right->content);
		
		
		/*sprintf(code_2a,"%s %s = 1;\n",code_2a, addr_left);
		sprintf(code_2a,"%s if(%s > %s)\n",code_2a, tn->left->content, tn->right->content);
		
		sprintf(code_2a,"%s %s = 0;\n",code_2a, addr_left);*/
		set_tree_node_content(addr_left, tn);
		return addr_left;
	}
	else if(!strcmp(tn->content, ">=")){
		sprintf(code_2a,"%s %s >= %s\n",code_2a, tn->left->content, tn->right->content);
		
		/*sprintf(code_2a,"%s %s = 1;\n",code_2a, addr_left);
		sprintf(code_2a,"%s if(%s < %s)\n",code_2a, tn->left->content, tn->right->content);
		
		sprintf(code_2a,"%s %s = 0;\n",code_2a, addr_left);*/
		set_tree_node_content(addr_left, tn);
		return addr_left;
	}
	else if(!strcmp(tn->content, "!=")){
		sprintf(code_2a,"%s %s != %s\n",code_2a, tn->left->content, tn->right->content);

		
		set_tree_node_content(addr_left, tn);
		return addr_left;
	}
	else if(!strcmp(tn->content, "==")){
		sprintf(code_2a,"%s %s == %s\n",code_2a, tn->left->content, tn->right->content);
		
		
		/*sprintf(code_2a,"%s %s = 1;\n", code_2a, addr_left);
		sprintf(code_2a,"%s if(%s != %s)\n",code_2a, tn->left->content, tn->right->content);
		
		sprintf(code_2a,"%s %s = 0;\n",code_2a, addr_left);*/
		set_tree_node_content(addr_left, tn);
		return addr_left;
	}
	else if(!strcmp(tn->content, "|")){

	    addr_left_tmp = strdup(addr_left);
		sprintf(addr_left_tmp,"tmp_%s", addr_left);	 
        while(getIdentifier(addr_left_tmp, symtable, symtable_root)  !=  NULL)
		  sprintf(addr_left_tmp, "tmp_%s", addr_left_tmp);
	        
		sprintf(code_2a,"%s %s = %s;\n", code_2a, addr_left_tmp,  tn->left->content);
		sprintf(code_2a,"%s %s *= %s;\n", code_2a, addr_left_tmp,  tn->right->content);

		scalar_product_name_tmp = strdup(scalar_product_name);
        while(getIdentifier(scalar_product_name_tmp, symtable, symtable_root) != NULL)
		  sprintf(scalar_product_name_tmp, "tmp_%s", scalar_product_name_tmp);
		
		addIdentifier(scalar_product_name_tmp, TYPE_FLOAT, 1, 1, 0, symtable); 
		sprintf(code_2a,"%s %s += %s;\n", code_2a, scalar_product_name_tmp,  addr_left_tmp);

		sprintf(addr_left,"%s", scalar_product_name_tmp);
		set_tree_node_content(addr_left, tn);
		return addr_left;
	}
	return tn->content;
}
