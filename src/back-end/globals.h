#ifndef GLOBALS_H
#define GLOBALS_H

#include "pile.h"
#include "symbolTable.h"
#include "stringList.h"

/* SYMBOL TABLE PART */

//struct symT* symbolTable = NULL;    

static const int type_UNDEFINED = 0x1;
static const int type_FLOAT = 0x10;
static const int type_INT = 0x100;
static const int type_ARRAY = 0x1000;
static const int type_FUNCTION = 0x10000;

// everything from 0 to n is a function with n parameter


struct symbolTableTreeNode *symbolTableRoot = NULL;
struct symbolTableTreeNode *symbolTableCurrentNode = NULL;


/***********************/

/* LABEL MANAGEMENT PART */

static struct pile* labelPile = NULL;

/************************/

/* DECLARATOR LIST MANAGEMENT PART */



/**********************************/


struct string* asmCode;


#endif //GLOBALS_H
