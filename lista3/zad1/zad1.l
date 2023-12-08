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


\+                                  { ECHO; return ADD; }
\-                                  { ECHO; return SUB; }
\*                                  { ECHO; return MUL; }
\/                                  { ECHO; return DIV; }
\^                                  { ECHO; return POW; }
\%                                  { ECHO; return MOD; }
\(                                  { ECHO; return LPAR; }
\)                                  { ECHO; return RPAR; }

[0-9]+                              { ECHO; yylval = atoi(yytext); return NUM; }

[ \t]+                              {}

\n                                  { ECHO; return RESULT; }

^"exit"$                            { printf("Kończenie działania programu.\n"); return 0; }

.                                   { return ERR; }
%%
