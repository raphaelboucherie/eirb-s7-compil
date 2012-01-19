LEX=lex
YACC=yacc
CFLAGS=-Wall -ggdb
CC=gcc

all:frontend backend

frontend:frontend.c scanner_frontend.c symtable.c derivationtree.c pile.c generate2a.c checktype.c
	$(CC) $(CFLAGS) -o $@ $^

backend:backend.c scanner_backend.c
	$(CC) $(CFLAGS) -o $@ $^

frontend.c:frontend.y
	$(YACC) -o $@ --defines=frontend.tab.h $^

backend.c:backend.y
	$(YACC) -o $@ --defines=backend.tab.h $^

%.c:%.l
	$(LEX) -o $@ $^

clean:
	rm -f frontend.c backend.c
