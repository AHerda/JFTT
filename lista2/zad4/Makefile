c: lex.yy.cpp
	g++ lex.yy.cpp -o main
flex:
	flex -o lex.yy.cpp 4.l
all: flex c
clean:
	rm lex.yy.cpp main