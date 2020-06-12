%{

#include <stdio.h>
#include <stdlib.h>
#include <string.h>


extern int yylex();
extern int yyparse();
extern FILE* yyin;

void yyerror(const char* s);
%}

%code requires {
  	struct s{
		char * val;
		int size;
	};
}

%union {
	int ival;
	float fval;
	struct s sval;
}

%token<ival> T_INT
%token<fval> T_FLOAT
%token<sval> T_STRING
%token T_PLUS T_MINUS T_MULTIPLY T_DIVIDE T_LEFT T_RIGHT
%token T_NEWLINE T_QUIT
%left T_PLUS T_MINUS
%left T_MULTIPLY T_DIVIDE

%type<ival> expression
%type<fval> mixed_expression
%type<sval> string

%start calculation

%%

calculation:
	| calculation line
;

line: T_NEWLINE
    | string T_NEWLINE { printf("\tResult: %s\n", $1.val);}
    | mixed_expression T_NEWLINE { printf("\tResult: %f\n", $1);}
    | expression T_NEWLINE { printf("\tResult: %i\n", $1); }
    | T_QUIT T_NEWLINE { printf("bye!\n"); exit(0); }
;

mixed_expression: T_FLOAT                 		 { $$ = $1; }
	| mixed_expression T_PLUS mixed_expression	 { $$ = $1 + $3; }
	| mixed_expression T_MINUS mixed_expression	 { $$ = $1 - $3; }
	| mixed_expression T_MULTIPLY mixed_expression { $$ = $1 * $3; }
	| mixed_expression T_DIVIDE mixed_expression	 { $$ = $1 / $3; }
	| T_LEFT mixed_expression T_RIGHT		 { $$ = $2; }
	| expression T_PLUS mixed_expression	 	 { $$ = $1 + $3; }
	| expression T_MINUS mixed_expression	 	 { $$ = $1 - $3; }
	| expression T_MULTIPLY mixed_expression 	 { $$ = $1 * $3; }
	| expression T_DIVIDE mixed_expression	 { $$ = $1 / $3; }
	| mixed_expression T_PLUS expression	 	 { $$ = $1 + $3; }
	| mixed_expression T_MINUS expression	 	 { $$ = $1 - $3; }
	| mixed_expression T_MULTIPLY expression 	 { $$ = $1 * $3; }
	| mixed_expression T_DIVIDE expression	 { $$ = $1 / $3; }
	| expression T_DIVIDE expression		 { $$ = $1 / (float)$3; }
;

expression: T_INT				{ $$ = $1; }
	| expression T_PLUS expression	{ $$ = $1 + $3; }
	| expression T_MINUS expression	{ $$ = $1 - $3; }
	| expression T_MULTIPLY expression	{ $$ = $1 * $3; }
	| T_LEFT expression T_RIGHT		{ $$ = $2; }
;

string: T_STRING { $$=$1;}
	| string T_PLUS string	{
							int Tsize = $1.size + $3.size + 1;
                            char *string = (char*) malloc (Tsize);
                            for(int i =0; i < $1.size; i++) string[i] = $1.val[i]; 
                            for(int i =0; i < $3.size; i++) string[i+ $1.size] = $3.val[i]; 
                            struct s answer;
                            answer.val = string;
                            answer.size = Tsize;
                            $$ = answer;}
	| string T_MULTIPLY expression{
		  					int Tsize = $1.size * $3 + 1;
							char *string = (char*) malloc (Tsize);
							for(int i =0; i < $3; i++){ 
								for(int j=0; j<$1.size; j++){
									string[i*$1.size + j] = $1.val[j];
								}
							}
							struct s answer;
							answer.val = string;
							answer.size = Tsize;
							$$ = answer;}
	| T_LEFT string T_RIGHT		 { $$ = $2; }


;

%%

int main() {
	yyin = stdin;

	do {
		yyparse();
	} while(!feof(yyin));

	return 0;
}

void yyerror(const char* s) {
	fprintf(stderr, "Parse error: %s\n", s);
	exit(1);
}
