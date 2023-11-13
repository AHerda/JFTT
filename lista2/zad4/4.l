%{

#include <iostream>
#include <stack>
#include <string>
#include <cmath>

std::stack<int> st;
std::string err;
int x;
int y;

int pop(std::stack<int>& st) {
    int temp = st.top();
    st.pop();
    return temp;
}

%}

%x ERROR

%%

\-?[0-9]+ {
    st.push(atoi(yytext));
    ECHO;
    fprintf(yyout, " ");
}

\+ {
    if(st.size() < 2) {
        err = "Błąd: za mała liczba argumentów";
        BEGIN(ERROR);
    } else
        st.push(pop(st) + pop(st));
    ECHO;
    fprintf(yyout, " ");
}

\- {
    if(st.size() < 2) {
        err = "Błąd: za mała liczba argumentów";
        BEGIN(ERROR);
    } else {
        x = pop(st);
        y = pop(st);
        st.push(y - x);
    }
    ECHO;
    fprintf(yyout, " ");
}

\* {
    if(st.size() < 2) {
        err = "Błąd: za mała liczba argumentów";
        BEGIN(ERROR);
    } else
        st.push(pop(st) * pop(st));
    ECHO;
    fprintf(yyout, " ");
}

\/ {
    if(st.size() < 2) {
        err = "Błąd: za mała liczba argumentów";
        BEGIN(ERROR);
    } else {
        x = pop(st);
        if(x == 0) {
            err = "Błąd: dzielenie przez 0";
            BEGIN(ERROR);
        } else {
            y = pop(st);
            st.push(y / x);
        }
    }
    ECHO;
    fprintf(yyout, " ");
}

\% {
    if(st.size() < 2) {
        err = "Błąd: za mała liczba argumentów";
        BEGIN(ERROR);
    } else {
        x = pop(st);
        if(x == 0) {
            err = "Błąd: dzielenie przez 0";
            BEGIN(ERROR);
        } else {
            y = pop(st);
            st.push(y % x);
        }
    }
    ECHO;
    fprintf(yyout, " ");
}

\^ {
    if(st.size() < 2) {
        err = "Błąd: za mała liczba argumentów";
        BEGIN(ERROR);
    } else {
        x = pop(st);
        y = pop(st);
        st.push(static_cast<int>(pow(y, x)));
    }
    ECHO;
    fprintf(yyout, " ");
}

(\n|(\r\n)) {
    ECHO;
    if(st.size() != 1) {
        fprintf(yyout, "\t%s\n\n", "Błąd: za mała liczba operatorów");
        st = std::stack<int>();
    } else {
        fprintf(yyout, "\t= %d\n\n", pop(st));
    }
}

[^[[:blank:]]]|"." {
    err = "Błąd: zły symbol \"" + (std::string) yytext + "\"";
    BEGIN(ERROR);
}

^[[:blank:]]*     ;
[[:blank:]]*$     ;
[[:blank:]]*      ;

<ERROR>{
    .*      ECHO;
    \n {
        ECHO;
        fprintf(yyout, "\t%s\n\n", err.c_str());
        BEGIN(INITIAL);
        while(st.size() > 0) 
            int d = pop(st);
    }
}

%%

int yywrap() {
    if (!feof(yyin)) {
        return 0;  // There are more files to process
    } else {
        return 1;  // End of file
    }
}

int main(int argc, char** argv) {
    yyin = fopen(argv[1], "r");
    yyout = fopen(argv[2], "w");

    yylex();

    fclose(yyin);
    fclose(yyout);
    return 0;
}