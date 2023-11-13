%{
#include <stdio.h>

int lines = 1;
int words = 0;
%}

%%

^[ \t\n]*       ;
[ \t]+$         ;
[ \t]+          fprintf(yyout, " ");
[a-zA-Z0-9]+    { words++; ECHO; }
\n              { lines++; ECHO; }

%%

int yywrap() {
    return 1; 
}

int main(int argc, char** argv) {
    yyin = fopen(argv[1], "r");
    yyout = fopen(argv[2], "w");

    yylex();
    fprintf(yyout, "\nwords: %d lines: %d", words, lines);

    fclose(yyin);
    fclose(yyout);
    return 0;
}