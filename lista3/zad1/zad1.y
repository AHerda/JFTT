%{
	#include <string>
	#include <iostream>
	#define GF 1234577


	int yylex();
	void yyerror (std::string s);
	std::string rpn;
	std::string error_message;
	bool is_error = false;
	extern FILE *yyin;
	extern bool if_file;

	int mod(int a, int mod) {
		return (a % mod + mod) % mod;
	}

	void rpn_add(std::string token) {
		rpn += token + " ";
	}

	void reset() {
		error_message = "";
		rpn = "";
		is_error = false;
	}

	int add(int a, int b) {
		return mod(a + b, GF);
	}

	int add_pow(int a, int b) {
		return mod(a + b, GF - 1);
	}

	int subtract(int a, int b) {
		return mod(a - b, GF);
	}

	int subtract_pow(int a, int b) {
		return mod(a - b, GF - 1);
	}

	int multiply(int a, int b) {
		return mod(a * b, GF);
	}

	int multiply_pow(int a, int b) {
		return mod(a * b, GF - 1);
	}

	int extended_gcd(int a, int b, int *x, int *y) {
		if (a == 0) {
			*x = 0;
			*y = 1;
			return b;
		}

		int x1, y1;
		int gcd = extended_gcd(b % a, a, &x1, &y1);

		*x = y1 - (b / a) * x1;
		*y = x1;

		return gcd;
	}

	int mod_invert(int a, int m) {
		int x, y;
		int gcd = extended_gcd(a, m, &x, &y);

		if (gcd != 1)
			return -1;
		else {
			int inverse = mod(x, m);
			return inverse;
		}
	}

	int invert(int num, int m) {
		return mod_invert(num, m);
	}


	int divide(int a, int b) {
		int inv = invert(b, GF);
		if (inv == -1)
			return -1;

		inv = inv % GF;
		return mod(a * inv, GF);
	}

	int divide_pow(int a, int b) {
		int inv = invert(b, (GF - 1));
		if (inv == -1)
			return -1;

		inv = mod(inv, GF - 1);
		return mod(a * inv, GF - 1);
	}

	int power(long int a, int b) {
		int result = 1;

		for(int i = 0; i < b; i++)
			result = multiply(result, b);
		return result;
	}

	int modulo(int a, int b) {
		return mod(a % b, GF);
	}

	int modulo_pow(int a, int b) {
		return mod(a % b, (GF - 1));
	}

%}

%token NUM
%token ADD
%token SUB
%token MUL
%token DIV
%token POW
%token MOD
%token LPAR
%token RPAR
%token RESULT
%token ERR

%left ADD SUB
%left MUL DIV MOD
%precedence NEG
%nonassoc POW

%%
input:
	%empty
|	line RESULT input 						{ reset(); }
;

line:
	exp {
		if (!is_error) {
			std::cout << rpn << std::endl;
			std::cout << "\t= " << $1 << "\n\n";
		}
		reset();
	}
|	exp ERR									{ is_error = true; }
|	ERR										{ is_error = true; }
|	exp error								{ is_error = true; }
|	error									{ is_error = true; }
;

exp:
	NUM										{ $$ = mod($1, GF); rpn_add(std::to_string($$)); }
|	SUB exp %prec NEG						{ rpn_add("~"); $$ = mod(-$2, GF); }
|	exp ADD exp								{ rpn_add("+"); $$ = add($1, $3); }
|	exp SUB exp								{ rpn_add("-"); $$ = subtract($1, $3); }
|	exp MUL exp								{ rpn_add("*"); $$ = multiply($1, $3); }
|	exp DIV exp {
		rpn_add("/");

		if($3 == 0) {
			is_error = true;
			yyerror("Dzielenie przez 0");
		}
		else {
			int result = divide($1, $3);
			if (result == -1) {
				is_error = true;
				error_message = std::to_string($3) + " nie jest odwracalne modulo " + std::to_string(GF) + "\n";
				yyerror(error_message);
			}
			else {
				$$ = result;
			}
		}
	}
|	exp POW exponent						{ $$ = power($1, $3); if(!is_error) { rpn_add("^"); } }
|	exp MOD exp								{ rpn_add("%"); if($3 == 0) { is_error = true; yyerror("Modulo 0"); } else { $$ = modulo($1, $3); } }
|	LPAR exp RPAR							{ $$ = $2; }
;

exponent:
	NUM										{ $$ = mod($1, GF - 1); rpn_add(std::to_string($$)); }
|	SUB exponent %prec NEG					{ rpn_add("~"); $$ = mod(-$2, GF - 1); }
|	exponent ADD exponent					{ rpn_add("+"); $$ = add_pow($1, $3); }
|	exponent SUB exponent					{ rpn_add("-"); $$ = subtract_pow($1, $3); }
|	exponent MUL exponent					{ rpn_add("*"); $$ = multiply_pow($1, $3); }
|	exponent DIV exponent {
		rpn_add("/");

		if($3 == 0) {
			is_error = true;
			yyerror("Dzielenie przez 0");
		}
		else {
			int result = divide_pow($1, $3);
			if (result == -1) {
				is_error = true;
				error_message = std::to_string($3) + " nie jest odwracalne modulo " + std::to_string(GF - 1);
				yyerror(error_message);
			}
			else {
				$$ = result;
			}
		}
	}
|	exponent POW exponent					{ is_error = true; yyerror("Składanie potęg"); }
|	exponent MOD exponent					{ rpn_add("%"); if($3 == 0) { is_error = true; yyerror("Modulo 0"); } else { $$ = modulo_pow($1, $3); } }
|	LPAR exponent RPAR						{ $$ = $2; }
;

%%

void yyerror(std::string s)
{
    if (error_message == "") {
        std::cout << "Błąd: Zła składnia!\n\n";
    } else {
        std::cout << "Błąd: " << s << "\n\n";
    }
}

int main(int argc, char** argv)
{
	if_file = false;
	if (argc == 2) {
        yyin = fopen(argv[1], "r");
		if_file = true;
    }
	else if(argc > 2) {
		std::cout << "Za dużo parametrów\n";
		return -1;
	}


    yyparse();
    return 0;
}
