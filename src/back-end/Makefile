LEX=lex
YACC=yacc
CFLAGS=-Wall
CC=gcc

all:backend

program:asm
	as test.asm

asm:backend exemple.c
	clear && ./backend exemple.c 1>test.asm 2>log && gcc -S -O0 exemple.c && cat test.asm

frontend:frontend.c scanner_frontend.c
	$(CC) $(CFLAGS) -o $@ $^

backend:backend.c scanner_backend.c utils.c symT.c label.c pile.c symbolTable.c
	$(CC) $(CFLAGS) -o $@ $^

frontend.c:frontend.y
	$(YACC) -o $@ --defines=frontend.tab.h $^

backend.c:backend.y
	$(YACC) -o $@ --defines=backend.tab.h $^

%.c:%.l
	$(LEX) -o $@ $^

clean:
	rm -f frontend.c backend.c
