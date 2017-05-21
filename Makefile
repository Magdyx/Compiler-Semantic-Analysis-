all: 
	flex lex.l
	g++ -std=c++14 lex.yy.c y.tab.c
run:
	all
	./a.out tests/test1
	java -jar ./jasmin-2.4/jasmin.jar output.j
	java test
