%{

#include <stdio.h>
#include <stdbool.h>
#include <string.h>

bool docs = false;

%}

%%

    /* Single line quotes and pointy brackets <> */
\"[^(\"|\\\n)]*?\"                              ECHO;
\<[^(\>|\\\n)]*?\>                              ECHO;

    /* signle line docs comments */
\/\/\/.*\n                                      { if(docs) ECHO; }
\/\/!.*\n                                       { if(docs) ECHO; }

    /* multiline docs comments */
\/\*\*([^*]|[\r\n]|(\*+([^*/]|[\r\n])))*\*+\/   { if(docs) ECHO; }
\/\*\!([^*]|[\r\n]|(\*+([^*/]|[\r\n])))*\*+\/   { if(docs) ECHO; }

    /* signle and mulitiline normal comments */
"//".*\n                                        ;
\/\*([^*]|[\r\n]|(\*+([^*/]|[\r\n])))*\*+\/     ;

.|\n                                            ECHO;

%%

int yywrap() {
    return 1;
}

int main(int argc, char** argv) {
    bool in = false;
    bool out = false;
    if(argc != 5 && argc != 6) {
        printf("Wrong arguments");
        return -1;
    } else {
        for(int i = 1; i < argc; i++) {
            if(strcmp(argv[i], "-i") == 0 || strcmp(argv[i], "--in") == 0) {
                in = true;
                yyin = fopen(argv[i + 1], "r");
                i++;
            }
            else if(strcmp(argv[i], "-o") == 0 || strcmp(argv[i], "--out") == 0) {
                out = true;
                yyout = fopen(argv[i + 1], "w");
                i++;
            }
            else if(strcmp(argv[i], "-d") == 0 || strcmp(argv[i], "--docs") == 0) {
                docs = true;
                i++;
            }
        }
    }

    yylex();
    printf("DUPA2");

    if(in) fclose(yyin);
    if(out) fclose(yyout);
    return 0;
}