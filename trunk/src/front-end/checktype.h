#ifndef __CHECK_TYPE_H__
#define __CHECK_TYPE_H__

#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include "globals.h"
#include "derivationtree.h"
#include "symbolTable.h"


int check_type(TreeNode* tn, const struct symbolTableTreeNode* symtable, struct symbolTableTreeNode* symtable_root);

#endif /* __CHECK_TYPE_H__ */
