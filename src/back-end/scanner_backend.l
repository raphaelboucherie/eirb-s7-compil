D[0-9]
L[a-zA-Z_]

%{
#include <stdio.h>
#include <string.h>
#include "backend.tab.h"
void count();
int comment ();
int check_type ();
char inputline[1000];
%}

%option yylineno

%%

"/*"		    { comment(); }
"//".*      { count(); }
"float "	  { count(); return(FLOAT); }
"goto "	    { count(); return(GOTO); }
"if "		    { count(); return(IF); }
"int "		  { count(); return(INT); }
"return "	  { count(); return(RETURN); }
"void "	    { count(); return(VOID); }

{L}({L}|{D})*	{ count(); yylval.str = strdup (yytext); return(IDENTIFIER); }
{D}+    	{ count(); yylval.str=strdup(yytext); return(CONSTANT); }

"+="	{ count(); return(ADD_ASSIGN); }
"-="	{ count(); return(SUB_ASSIGN); }
"*="	{ count(); return(MUL_ASSIGN); }
"++"	{ count(); return(INC_OP); }
"--"	{ count(); return(DEC_OP); }
"<="	{ count(); return(LE_OP); }
">="	{ count(); return(GE_OP); }
"=="	{ count(); return(EQ_OP); }
"!="	{ count(); return(NE_OP); }
";"	  { count(); return(';'); }
"{"	  { count(); return('{'); }
"}"	  { count(); return('}'); }
","	  { count(); return(','); }
":"   { count(); return(':'); }
"="	  { count(); return('='); }
"("	  { count(); return('('); }
")"	  { count(); return(')'); }
"["	  { count(); return('['); }
"]"	  { count(); return(']'); }
"."	  { count(); return('.'); }
"-"	  { count(); return('-'); }
"+"	  { count(); return('+'); }
"*"	  { count(); return('*'); }
"<"	  { count(); return('<'); }
">"	  { count(); return('>'); }
"^"	  { count(); return('^'); }
"|"	  { count(); return('|'); }

[ \t\v\n\f]	{ count(); }
.	{ /* ignore bad characters */ }

%%

int yywrap() {
  return 1;
}


int comment() {
	char c, c1;

loop:
	while ((c = input()) != '*' && c != 0);
	if ((c1 = input()) != '/' && c != 0) {
		unput(c1);
		goto loop;
	}
	return 0;
}


int column = 0;
int line = 0;

void count() {
	int i;

	for (i = 0; yytext[i] != '\0'; i++) {
		if (yytext[i] == '\n') {
			column = 0;
			line++;
		}
		else if (yytext[i] == '\t')
			column += 8 - (column % 8);
		else
			column++;
	}
	// ECHO;
}


