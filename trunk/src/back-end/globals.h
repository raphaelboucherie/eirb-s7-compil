#ifndef GLOBALS_H
#define GLOBALS_H

#include "pile.h"
#include "symbolTable.h"

/* SYMBOL TABLE PART */

static struct symT* symbolTable = NULL;    

static const int type_UNDEFINED = -3;
static const int type_FLOAT = -2;
static const int type_INT = -1;
// everything from 0 to n is a function with n parameter


static struct symbolTableTreeNode *symbolTableRoot = NULL;
static struct symbolTableTreeNode *symbolTableCurrentNode = NULL;


/***********************/

/* LABEL MANAGEMENT PART */

static struct pile* labelPile = NULL;

/************************/

/* DECLARATOR LIST MANAGEMENT PART */



/**********************************/


#endif //GLOBALS_H
