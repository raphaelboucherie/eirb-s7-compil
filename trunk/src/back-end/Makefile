LEX=lex
YACC=yacc
CFLAGS=-Wall -Wno-unused-variable -g
CC=gcc
FILE=srctest/exemple.c
all:backend

program:asm
	gcc -m32 -g test.s

asm:backend 
	clear && ./backend $(FILE) 1>test.s 2>log && gcc -S -O0 $(FILE) && cat test.s

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
