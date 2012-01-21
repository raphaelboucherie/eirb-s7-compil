#ifndef GLOBALS_H
#define GLOBALS_H

#include "pile.h"
#include "symbolTable.h"
#include "stringList.h"




static const int type_UNDEFINED = 0x1;
static const int type_FLOAT = 0x10;
static const int type_INT = 0x100;
static const int type_ARRAY = 0x1000;
static const int type_FUNCTION = 0x10000;

static const int operator_ASSIGN = 0x1;
static const int operator_MUL = 0x10;
static const int operator_ADD = 0x100;
static const int operator_SUB = 0x1000;

struct symbolTableTreeNode *symbolTableRoot = NULL;
struct symbolTableTreeNode *symbolTableCurrentNode = NULL;


static struct pile* labelPile = NULL;

struct string* asmCode;


#endif //GLOBALS_H
