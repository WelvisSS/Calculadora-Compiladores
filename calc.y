%{
/* analisador sintático */
#include <math.h>
#include <stdio.h>

void yyerror(const char *s);
extern int yylex (void);

typedef struct{
    int codigo;
    char *indentficador;
    float valor;
}Simbolos;

extern void inserir(char *n, int m);
extern Simbolos* buscar(char *n);

%}

%union {
	double digit;
	char *var;
}

%token <var> VAR
%token <digit> NUM

%type <digit> Expression

%token PLUS MINUS
%token TIMES DIVIDE POW LOG RAIZ
%token AND OR XOR NEG
%token MAIOR MENOR
%token MAIORIGUAL MENORIGUAL DIFERENTE IGUAL ATRIBUICAO
%token LEFT RIGHT END

%left PLUS MINUS
%left DIVIDE TIMES LOG RAIZ
%left MAIOR MENOR
%left MAIORIGUAL MENORIGUAL DIFERENTE IGUAL
%left AND OR XOR NEG
%right POW
%nonassoc UMINUS

%%

Calc: Calc Atribuicao END
	| Atribuicao END
	;

Atribuicao: VAR ATRIBUICAO Expression 			{ inserir($1, $3); } 	
	| Expression					{ printf("Resultado: %f\n", $1); } 
/* OPERAÇÕES BÁSICAS */
Expression: Expression PLUS Expression	{ $$ = $1 + $3;};
	| Expression MINUS Expression	{ $$ = $1 - $3; printf("%.1f - %.1f\n", $1, $3);}
	| Expression TIMES Expression	{ $$ = $1 * $3; printf("%.1f * %.1f\n", $1, $3);}
	| Expression DIVIDE Expression	{ $$ = $1 / $3; printf("%.1f / %.1f\n", $1, $3);}
	| Expression POW Expression	{ $$ = pow($1, $3); printf("%.1f ^ %.1f\n", $1, $3);}
	| LOG Expression{ $$ = log10($2); printf("log10(%f)\n", $2); };
	| RAIZ Expression{ $$ = sqrt($2); printf("sqrt(%f)\n", $2); };
/* OPERAÇÕES LÓGICAS */
	| Expression AND Expression { $$ = $1 && $3; printf("%f && %f\n", $1, $3); }
	| Expression OR Expression { $$ = $1 || $3; printf("%f || %f\n", $1, $3); }
	| Expression XOR Expression { $$ = !$1 && $3 || $1 && !$3; printf("%f # %f\n", $1, $3); }
	| NEG Expression { $$ = !$2; printf("!%f\n", $2); }
	| MINUS Expression %prec UMINUS { $$ = - $2; }
/* INEQUAÇÕES */
	| Expression MAIOR Expression	{ $$ = $1 > $3; printf("%.1f > %.1f\n", $1, $3);}
	| Expression MENOR Expression	{ $$ = $1 < $3; printf("%.1f < %.1f\n", $1, $3);}
	| Expression MAIORIGUAL Expression	{ $$ = $1 <= $3; printf("%.1f <= %.1f\n", $1, $3);}
	| Expression MENORIGUAL Expression	{ $$ = $1 >= $3; printf("%.1f >= %.1f\n", $1, $3);}
	| Expression DIFERENTE Expression	{ $$ = $1 != $3; printf("%.1f != %.1f\n", $1, $3);}
/* EQUACAO */
	| Expression IGUAL Expression	{ $$ = $1 == $3; printf("%.1f == %.1f\n", $1, $3);}
/* ABRE E FECHA PARÊNTESES */
	| LEFT Expression RIGHT			{ $$ = $2; }
	
/* VARIÁVEIS DE [a-zA-Z] */
	| VAR		{
		Simbolos *p;
		p = buscar($1);

        if(p)
            $$ = p->valor;
        else
            printf("\nVariavel inexistente na tabela!\n");
	}
/* NÚMERO */
	| NUM	    { $$ = $1; };

%%

int main()
{

	int ret = yyparse();
    if (ret){
		fprintf(stderr, "%d error found.\n",ret);
    }
    return 0;
}

void yyerror(const char * s)
{
	printf("%s\n", s);
}
