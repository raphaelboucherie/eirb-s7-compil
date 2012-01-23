
#include <stdlib.h>
#include <stdio.h>
#include <string.h>

#include "stringList.h"
#include "symbolTable.h"

void sseMultStep(int offset1, int offset3, 
		 struct symbolTableTreeNode* symbolTableCurrentNode);
void sseAddStep(int offset1, int offset3, 
		struct symbolTableTreeNode* symbolTableCurrentNode);
void sseSubStep(int offset1, int offset3, 
		struct symbolTableTreeNode* symbolTableCurrentNode);
