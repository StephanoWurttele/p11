CC = gcc
LEX = lex
YACC = yacc

a.out: lex.yy.c y.tab.h y.tab.c
		$(CC) lex.yy.c y.tab.h y.tab.c

y.tab.h y.tab.c: *.y
		$(YACC) -d *.y

lex.yy.c: *.l
		$(LEX) *.l

clean:
	   -rm -f o*.txt a.out lex.yy.c y.tab.h y.tab.c	
