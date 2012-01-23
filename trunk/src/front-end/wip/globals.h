#ifndef __GLOBALS_H__
#define __GLOBALS_H__

#include "symbolTable.h"
#include "stringList.h"

#define TYPE_UNDEF 		 0
#define TYPE_VOID 		 1
#define TYPE_INT 		 2
#define TYPE_FLOAT 		 3
#define TYPE_ARRAY 		 4
#define TYPE_FCTN_INT	 5
#define TYPE_FCTN_VOID 	 6
#define TYPE_FCTN_UNDEF	 7
#define TYPE_CONSTANT	 8

/* Macro de Logging */
#define DEBUG 0 
#define LOG(out, format, args...) if(DEBUG) fprintf(out, format, args)

static struct symbolTableTreeNode* symbol_table_root = NULL;
static struct symbolTableTreeNode* symbol_table_current = NULL;

static struct pile* stack_for = NULL;
static struct pile* stack_while = NULL;
static struct string* list_tmp;

/* struct pile* stack_return_value_tmp = NULL; */

#endif /* __GLOBALS_H__ */
