all: zad1.y zad1.l
	bison -d -o zad1.cpp zad1.y
	flex -o zad1.c zad1.l
	g++ -o zad1 zad1.cpp zad1.c

clean:
	rm zad1.cpp zad1.hpp zad1.c zad1
