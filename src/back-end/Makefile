LEX=lex
YACC=yacc
CFLAGS=-Wall -Wno-unused-variable -g
CC=gcc

all:backend

program:asm
	gcc -m32 test.s

asm:backend exemple.c
	clear && ./backend exemple.c 1>test.s 2>log && gcc -S -O0 exemple.c && cat test.s

frontend:frontend.c scanner_frontend.c
	$(CC) $(CFLAGS) -o $@ $^

backend:backend.c scanner_backend.c utils.c label.c pile.c symbolTable.c stringList.c
	clear && $(CC) $(CFLAGS) -o $@ $^

frontend.c:frontend.y
	$(YACC) -o $@ --defines=frontend.tab.h $^

backend.c:backend.y
	$(YACC) -o $@ --defines=backend.tab.h $^

%.c:%.l
	$(LEX) -o $@ $^

clean:
	rm -f frontend.c backend.c
