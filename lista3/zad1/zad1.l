%option noyywrap

%{
    #include <stdio.h>
    #include <stdlib.h>

    #include "zad1.hpp"

    #define GF 1234577

    int yylex();
%}

%%
^[ \t]*\#(.|\\\n|\\\r\n)*(\n|\r\n)  {}
\\\n                                {}


\+                                  { return ADD; }
\-                                  { return SUB; }
\*                                  { return MUL; }
\/                                  { return DIV; }
\^                                  { return POW; }
\%                                  { return MOD; }
\(                                  { return LPAR; }
\)                                  { return RPAR; }

[0-9]+                              { yylval = atoi(yytext); return NUM; }

[ \t]+                              {}

\n                                  { return RESULT; }

^"exit"$                            { printf("Kończenie działania programu.\n"); return 0; }

.                                   { return ERR; }
%%