#ifndef GLOBALS_H
#define GLOBALS_H

#include "pile.h"

/* SYMBOL TABLE PART */

static int currentOffset = 0;
static struct symT* symbolTable = NULL;    

static const int type_UNDEFINED = -3;
static const int type_FLOAT = -2;
static const int type_INT = -1;
// everything from 0 to n is a function with n parameter

/***********************/

/* LABEL MANAGEMENT PART */

static int labelNumber = 0; // might change
static struct pile* labelPile = NULL;

/************************/

/* DECLARATOR LIST MANAGEMENT PART */



/**********************************/


#endif //GLOBALS_H
