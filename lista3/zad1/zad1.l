%option noyywrap

%{
    #include <stdio.h>
    #include <stdlib.h>

    #include "zad1.hpp"

    #define GF 1234577

    bool if_file;

    int yylex();
%}

%%
^[ \t]*\#(.|\\\n|\\\r\n)*(\n|\r\n)  {}
\\\n                                {}


\+                                  { if(if_file) ECHO; return ADD; }
\-                                  { if(if_file) ECHO; return SUB; }
\*                                  { if(if_file) ECHO; return MUL; }
\/                                  { if(if_file) ECHO; return DIV; }
\^                                  { if(if_file) ECHO; return POW; }
\%                                  { if(if_file) ECHO; return MOD; }
\(                                  { if(if_file) ECHO; return LPAR; }
\)                                  { if(if_file) ECHO; return RPAR; }

[0-9]+                              { if(if_file) ECHO; yylval = atoi(yytext); return NUM; }

[ \t]+                              {}

(\n|\r\n)                           { ECHO; return RESULT; }

^"exit"$                            { printf("Kończenie działania programu.\n"); return 0; }

.                                   { return ERR; }
%%
