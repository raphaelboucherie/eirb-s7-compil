#ifndef GLOBALS_H
#define GLOBALS_H

#include "pile.h"
#include "symbolTable.h"
#include "stringList.h"




static const int type_UNDEFINED = 0b1;
static const int type_FLOAT = 0b10;
static const int type_INT = 0b100;
static const int type_ARRAY = 0b1000;
static const int type_FUNCTION = 0b10000;

static const int operator_ASSIGN = 0b1;
static const int operator_MUL = 0b10;
static const int operator_ADD = 0b100;
static const int operator_SUB = 0b1000;

struct symbolTableTreeNode *symbolTableRoot = NULL;
struct symbolTableTreeNode *symbolTableCurrentNode = NULL;


static struct pile* labelPile = NULL;

struct string* asmCode;


#endif //GLOBALS_H
