#ifndef __GENERATE_2A_H__
#define __GENERATE_2A_H__

#include <stdlib.h>
#include <stdio.h>
#include "derivationtree.h"
#include "symbolTable.h"
#include "globals.h"
#include "pile.h"

char* tree_to_2a_code(TreeNode* tn, struct symbolTableTreeNode* symtable, struct symbolTableTreeNode* symtable_root, char* code_2a, struct pile* stack_tmp);
int tree_length(TreeNode* tn);
int max(int i , int j);

#endif /* __GENERATE_2A_H__ */
