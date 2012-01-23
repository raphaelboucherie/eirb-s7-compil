#include "sse.h"

void sseMultStep(int offset1, int offset3, 
		 struct symbolTableTreeNode* symbolTableCurrentNode)
{
  symbolTableCurrentNode->code = 
    addString(symbolTableCurrentNode->code,"\tmovups\t -%d(%s), %s\n", offset1, "%ebp", "%xmm0");
  symbolTableCurrentNode->code = 
    addString(symbolTableCurrentNode->code,"\tmovups\t -%d(%s), %s\n", offset3, "%ebp", "%xmm1");
  symbolTableCurrentNode->code = 
    addString(symbolTableCurrentNode->code,"\tmulps\t %s, %s\n", "%xmm1", "%xmm0" );
  symbolTableCurrentNode->code = 
    addString(symbolTableCurrentNode->code,"\tmovups\t %s, -%d(%s)\n", "%xmm0", offset1, "%ebp");
  symbolTableCurrentNode->code = 
    addString(symbolTableCurrentNode->code,"\tmovups\t %s, -%d(%s)\n", "%xmm1", offset3, "%ebp");
}

void sseAddStep(int offset1, int offset3, 
		struct symbolTableTreeNode* symbolTableCurrentNode)
{
  symbolTableCurrentNode->code = 
    addString(symbolTableCurrentNode->code,"\tmovups\t -%d(%s), %s\n", offset1, "%ebp", "%xmm0");
  symbolTableCurrentNode->code = 
    addString(symbolTableCurrentNode->code,"\tmovups\t -%d(%s), %s\n", offset3, "%ebp", "%xmm1");
  symbolTableCurrentNode->code = 
    addString(symbolTableCurrentNode->code,"\taddps\t %s, %s\n", "%xmm1", "%xmm0" );
  symbolTableCurrentNode->code = 
    addString(symbolTableCurrentNode->code,"\tmovups\t %s, -%d(%s)\n", "%xmm0", offset1, "%ebp");
  symbolTableCurrentNode->code = 
    addString(symbolTableCurrentNode->code,"\tmovups\t %s, -%d(%s)\n", "%xmm1", offset3, "%ebp");
}

void sseSubStep(int offset1, int offset3, 
		struct symbolTableTreeNode* symbolTableCurrentNode)
{
  symbolTableCurrentNode->code = 
    addString(symbolTableCurrentNode->code,"\tmovups\t -%d(%s), %s\n", offset1, "%ebp", "%xmm0");
  symbolTableCurrentNode->code = 
    addString(symbolTableCurrentNode->code,"\tmovups\t -%d(%s), %s\n", offset3, "%ebp", "%xmm1");
  symbolTableCurrentNode->code = 
    addString(symbolTableCurrentNode->code,"\subps\t %s, %s\n", "%xmm1", "%xmm0" );
  symbolTableCurrentNode->code = 
    addString(symbolTableCurrentNode->code,"\tmovups\t %s, -%d(%s)\n", "%xmm0", offset1, "%ebp");
  symbolTableCurrentNode->code = 
    addString(symbolTableCurrentNode->code,"\tmovups\t %s, -%d(%s)\n", "%xmm1", offset3, "%ebp");
}
