%{

#include <stdio.h>
#include <stdbool.h>

bool xml_started = false;
int licznik = 0;

%}

quote \".*\"

%x NOT_A_COMMENT

%%

\<\?xml.*\?\>                       { ECHO; xml_started = true; }

\<!--[^(\-\-)]*?--[^(\-\-)]*?--\>   ECHO;
\<!--[^(\-\-)]*?---\>               ECHO;

\<!--[^(\-\-)]*?--\>                { if(!xml_started) ECHO; }
\<                                  { ECHO; BEGIN(NOT_A_COMMENT); }

<NOT_A_COMMENT>{
    {quote}                         ECHO;
    \>                              { ECHO; BEGIN(INITIAL); }
    .|\n                            ECHO;
}

%%

int yywrap() {};

int main(int argc, char** argv) {
    yyin = fopen(argv[1], "r");
    yyout = fopen(argv[2], "w");

    yylex();

    fclose(yyin);
    fclose(yyout);
    return 0;
}