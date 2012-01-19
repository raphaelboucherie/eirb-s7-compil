#ifndef __GENERATE_2A_H__
#define __GENERATE_2A_H__

#include <stdlib.h>
#include <stdio.h>
#include "derivationtree.h"
#include "symtable.h"

char* tree_to_2a_code(TreeNode* tn, Node* symtable);
int tree_length(TreeNode* tn);
int max(int i , int j);

#endif /* __GENERATE_2A_H__ */
