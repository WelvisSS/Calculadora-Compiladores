all: calc

calc: lex.yy.c calc.tab.c
	g++ lex.yy.c calc.tab.c -std=c++17 -o calc

lex.yy.c: calc.l
	flex calc.l

calc.tab.c: calc.y
	bison -d calc.y

clean:
	rm calc lex.yy.c calc.tab.c calc.tab.h