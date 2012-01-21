#include "utils.h"

char* regOffset(char* string, int a)
{
  char* str = malloc( sizeof ( char ) * 256 );
  sprintf(str,"-%d(%s)", a, string);
  return str;
}

char* constToASMConst(char* string)
{
  char* str = malloc( sizeof ( char ) * 256 );
  sprintf(str,"$%s",string);
  return str;
}

char* postfixExpressionToRegister(char* postfixExpression, 
				  struct symbolTableTreeNode* currentNode,
				  struct symbolTableTreeNode* root)
{
  fprintf(stderr,"Inspecting expression\n");
  fprintf(stderr,"expression = %s\n", postfixExpression);
  assert(postfixExpression != NULL);
  if (postfixExpression[0] == '$')
    {
      fprintf(stderr,"expression type = CONSTANT\n");
      // Expresssion is CONSTANT 
      return postfixExpression;
    }
  else if (postfixExpression[0] == '%' || postfixExpression[0] == '-')
    {
      fprintf(stderr,"expression type = register\n");
      // Expression is already in a register form
      return postfixExpression;
    }
  else
    {
      fprintf(stderr,"expression type = IDENTIFIER\n");
      // Expression is an identifier name, we need to transform it to a data offset
      int offset = searchOffset(postfixExpression,
				currentNode, root);
      return regOffset("%ebp",offset);
    }
}

int isIdentifier(char* expression)
{
  return expression[0] != '%' && expression[0] != '-' && expression[0] != '$';
}

char* ASM_INIT()
{
  //  return "BITS 32\nSECTION .data\nSECTION .text\n\tGLOBAL _start\n\n_start:\n";
  return "\t.text\n";//.globl main\n\t.type	main, @function\nmain:\n\tpushl\t %ebp\n\tmovl\t %esp, %ebp\n\tsubl\t $16, %esp\n";
}
char* ASM_CLOSE()
{
  return "";//mov eax, 1\nint 0x80\n";
}

