#include "generate2a.h"
char* addr_left;
char* addr_right;
char addr_left_tmp[1024];
char* scalar_product_name = "res_ps";
char* scalar_product_name_tmp = NULL;
char instruction[4096] = "";

char* reverse_operator(char* comp){
	char* operand;
	char reverse[1024];
	char* tmp1;
	char* tmp2;
	if((operand = strstr(comp, "==")) != NULL){
		tmp1 = strtok(comp, " ");
		tmp2 = strstr(operand, " ");
		sprintf(reverse, "%s != %s", tmp1, tmp2);
	}
	else if((operand = strstr(comp, "!=")) != NULL){
		tmp1 = strtok(comp, " ");
		tmp2 = strstr(operand, " ");
		sprintf(reverse, "%s == %s", tmp1, tmp2);
	}
	else if((operand = strstr(comp, "<"))!= NULL){
		tmp1 = strtok(comp, " ");
		tmp2 = strstr(operand, " ");
		sprintf(reverse, "%s >= %s", tmp1, tmp2);
	}
	else if((operand = strstr(comp, ">"))!= NULL){
		tmp1 = strtok(comp, " ");
		tmp2 = strstr(operand, " ");
		sprintf(reverse, "%s <= %s", tmp1, tmp2);
	}
	else if((operand = strstr(comp, "<="))!= NULL){
		tmp1 = strtok(comp, " ");
		tmp2 = strstr(operand, " ");
		sprintf(reverse, "%s > %s", tmp1, tmp2);
	}
	else if((operand = strstr(comp, ">="))!= NULL){
		tmp1 = strtok(comp, " ");
		tmp2 = strstr(operand, " ");
		sprintf(reverse, "%s < %s", tmp1, tmp2);
	}
	return reverse;

}
char* tree_to_2a_code(TreeNode* tn, struct symbolTableTreeNode* symtable, struct symbolTableTreeNode* symtable_root, struct string* list){
	if(tree_length(tn->left) > tree_length(tn->right)){
		if(tn->left != NULL){
			addr_left = tree_to_2a_code(tn->left, symtable, symtable_root,list);
		}

		if(tn->right != NULL){
			addr_right = tree_to_2a_code(tn->right, symtable, symtable_root,list);
		}
	}

	else{
		if(tn->right != NULL){
			addr_right = tree_to_2a_code(tn->right, symtable, symtable_root, list);
		}

		if(tn->left != NULL){
			addr_left = tree_to_2a_code(tn->left, symtable, symtable_root, list);
		}
	}
	if(!strcmp(tn->content, "+")){
		sprintf(addr_left_tmp, "tmp_%s", addr_left);
		while(getIdentifier(addr_left_tmp, symtable, symtable_root)  !=  NULL)
			sprintf(addr_left_tmp, "tmp_%s", addr_left_tmp);
		struct symbolTableIdentifierList* left = getIdentifier(addr_left, symtable, symtable_root);
		addIdentifier(addr_left_tmp, left->type, left->dimension, left->size, left->get_by_addr, symtable);
		
		sprintf(instruction, "%s = %s;\n", addr_left_tmp, tn->left->content);
		list = addStringEnd(list, instruction);
		sprintf(instruction, "%s += %s;\n", addr_left_tmp, tn->right->content);
		list = addStringEnd(list, instruction);
			while(list != NULL){
			list = list->next;
			}

		sprintf(addr_left,"%s",addr_left_tmp);
		set_tree_node_content(addr_left, tn);
		return addr_left;
	}
	else if(!strcmp(tn->content, "-")){

		sprintf(addr_left_tmp,"tmp_%s", addr_left);	 
		while(getIdentifier(addr_left_tmp, symtable, symtable_root)  !=  NULL)
			sprintf(addr_left_tmp, "tmp_%s", addr_left_tmp);
		struct symbolTableIdentifierList* left = getIdentifier(addr_left, symtable, symtable_root);
		addIdentifier(addr_left_tmp, left->type, left->dimension, left->size, left->get_by_addr, symtable);

		sprintf(instruction, "%s = %s;\n", addr_left_tmp, tn->left->content);
		list = addStringEnd(list, instruction);
		sprintf(instruction, "%s -= %s;\n", addr_left_tmp, tn->right->content);
		list = addStringEnd(list, instruction);

		sprintf(addr_left,"%s",addr_left_tmp);
		set_tree_node_content(addr_left, tn);
		return addr_left;
	}
	else if(!strcmp(tn->content, "*")){

		sprintf(addr_left_tmp,"tmp_%s", addr_left);	 
		while(getIdentifier(addr_left_tmp, symtable, symtable_root)  !=  NULL)
			sprintf(addr_left_tmp, "tmp_%s", addr_left_tmp);
		struct symbolTableIdentifierList* left = getIdentifier(addr_left, symtable, symtable_root);
		addIdentifier(addr_left_tmp, left->type, left->dimension, left->size, left->get_by_addr, symtable);
		
		sprintf(instruction, "%s = %s;\n", addr_left_tmp, tn->left->content);
		list = addStringEnd(list, instruction);
		sprintf(instruction, "%s *= %s;\n", addr_left_tmp, tn->right->content);
		list = addStringEnd(list, instruction);

		sprintf(addr_left,"%s",addr_left_tmp);
		set_tree_node_content(addr_left, tn);
		return addr_left;
	}
	else if(!strcmp(tn->content, "=")){
		sprintf(instruction, "%s = %s;\n", addr_left, addr_right);
		list = addStringEnd(list, instruction);


		return addr_left;
	}
	else if(!strcmp(tn->content, "+=")){
		sprintf(instruction, "%s += %s", addr_left, addr_right);
		list = addStringEnd(list, instruction);
		return addr_left;
	}
	else if(!strcmp(tn->content, "*=")){
		sprintf(instruction, "%s *= %s", addr_left, addr_right);
		list = addStringEnd(list, instruction);
		return addr_left;
	}
	else if(!strcmp(tn->content, "-=")){
		sprintf(instruction, "%s -= %s", addr_left, addr_right);
		list = addStringEnd(list, instruction);
		return addr_left;
	}
	else if(!strcmp(tn->content, "<")){
		sprintf(instruction, "%s < %s", tn->left->content, tn->right->content);
		list = addStringEnd(list, instruction);


		set_tree_node_content(addr_left, tn);
		return addr_left;
	}
	else if(!strcmp(tn->content, ">")){
		sprintf(instruction, "%s > %s", tn->left->content, tn->right->content);
		list = addStringEnd(list, instruction);

		set_tree_node_content(addr_left, tn);
		return addr_left;
	}
	else if(!strcmp(tn->content, "<=")){
		sprintf(instruction, "%s <= %s", tn->left->content, tn->right->content);
		list = addStringEnd(list, instruction);


		set_tree_node_content(addr_left, tn);
		return addr_left;
	}
	else if(!strcmp(tn->content, ">=")){
		sprintf(instruction, "%s >= %s", tn->left->content, tn->right->content);
		list = addStringEnd(list, instruction);

		set_tree_node_content(addr_left, tn);
		return addr_left;
	}
	else if(!strcmp(tn->content, "!=")){
		sprintf(instruction, "%s != %s", tn->left->content, tn->right->content);
		list = addStringEnd(list, instruction);


		set_tree_node_content(addr_left, tn);
		return addr_left;
	}
	else if(!strcmp(tn->content, "==")){
		sprintf(instruction, "%s == %s", tn->left->content, tn->right->content);
		list = addStringEnd(list, instruction);


		set_tree_node_content(addr_left, tn);
		return addr_left;
	}
	else if(!strcmp(tn->content, "|")){

		sprintf(addr_left_tmp,"tmp_%s", addr_left);	 
		while(getIdentifier(addr_left_tmp, symtable, symtable_root)  !=  NULL)
			sprintf(addr_left_tmp, "tmp_%s", addr_left_tmp);
		struct symbolTableIdentifierList* left = getIdentifier(addr_left, symtable, symtable_root);
		addIdentifier(addr_left_tmp, left->type, left->dimension, left->size, left->get_by_addr, symtable);

		sprintf(instruction, "%s = %s", addr_left_tmp, tn->left->content);
		list = addStringEnd(list, instruction);
		sprintf(instruction, "%s * %s", addr_left_tmp, tn->right->content);
		list = addStringEnd(list, instruction);

		scalar_product_name_tmp = strdup(scalar_product_name);
		while(getIdentifier(scalar_product_name_tmp, symtable, symtable_root) != NULL)
			sprintf(scalar_product_name_tmp, "tmp_%s", scalar_product_name_tmp);

		addIdentifier(scalar_product_name_tmp, TYPE_FLOAT, 1, 1, 0, symtable); 
		sprintf(instruction, "%s += %s", scalar_product_name_tmp, addr_left_tmp);
		list = addStringEnd(list, instruction);

		sprintf(addr_left,"%s", scalar_product_name_tmp);
		set_tree_node_content(addr_left, tn);
		return addr_left;
	}
	else{
		if(strstr(tn->content, "++") != NULL || strstr(tn->content, "--") != NULL){
			sprintf(instruction,"%s", tn->content);
			list = addStringEnd(list, instruction);
		}
	}
	return tn->content;
}
