%{ 
/* analisador léxico */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "calc.tab.h"

#define M 10000

int inicializado = 0;
// Struct da tabela hash 
typedef struct{
    int codigo;
    char *identificador;
    float valor;
}Simbolos;

// Tabela hash do tipo Simbolos
Simbolos tabelaHash[M];

// Inicializa a tabela com todas posições iguais a -1
extern void inicializarTabela(){
    int i;
    for(i = 0; i < M; i++)
        tabelaHash[i].codigo = -1;
}
// Inicializa a tabela apenas uma vez, impossibilitando perca de dados
extern void init(){
    if (inicializado == 0){ 
        inicializarTabela();
        inicializado = 1;
    }
}

// Função de espalhamento (resto da divisão da chave por M)
extern int gerarCodigoHash(int chave){
    return chave % M;
}
// Converte a variável em um valor
extern int stringToNumber(char *var){
    int tam = strlen(var);
    int codigo = 0;
    for (int i=0; i<tam; i++)
      codigo = codigo + var[i]%M;
    return codigo;
}
// Converte o yytext antes que ele mude o valor
char * strcpy(char *var){

    char * String = (char *) malloc (sizeof(char)*(strlen(var)+1));

    for (int i = 0; i < strlen(var); i++) String[i] = var[i];

    return yylval.var = String;
}

// Verifica se a variável armazenada é igual a variável pesquisada
extern int iguais(char *a, char *b){
    int lenA = strlen(a);
    int lenB = strlen(b);
    int iguais = 1;
    if (lenA == lenB){
        for (int i = 0; i < lenA; i++){
            if (a[i] != b[i]){
                iguais = 0;
                break;
            }
        }
        return iguais;
    }else{
        return 0;
    }
} 

// inserir uma item na tabela
extern void inserir(char *n, int m){
    Simbolos p;
    p.codigo = stringToNumber(n);
    p.identificador = n;
    p.valor = m;
    int indice = gerarCodigoHash(p.codigo);
    while(tabelaHash[indice].codigo != -1){
        if (iguais(tabelaHash[indice].identificador, n) == 1){
            break;
        }
        indice = gerarCodigoHash(indice + 1);
    }
    tabelaHash[indice] = p;
}

// Buscar um item na tabela
extern Simbolos* buscar(char *n){
    
    int chave = stringToNumber(n);
    int indice = gerarCodigoHash(chave);
    while(tabelaHash[indice].codigo != -1){
        if(tabelaHash[indice].codigo == chave && iguais(tabelaHash[indice].identificador, n) == 1){
            return &tabelaHash[indice];
        }
        else{
            indice = gerarCodigoHash(indice + 1);
        }
    }
    return NULL;
}

%}

%option yylineno

%option noyywrap
/* DEFINIÇÕES  */

/* Espaço em banco */
white [ \t]+ 
/* Digito */
digit [0-9]
/* Inteiro */
integer {digit}+
/* Exponenciação */
exponent [eE][+-]?{integer}
/* Número Real */
real {integer}("."{integer})?{exponent}?
/* Variável */
caracteres [a-zA-Z]

varnum {caracteres}*{digit}*

variavel {caracteres}+{varnum}*

/* REGRAS */
%%

{white} { }
{real}  { 
    
    yylval.digit = atof(yytext); 
    return NUM; 
}

{variavel} { 
    init();
    strcpy(yytext);
    return VAR;
}

"+"  return PLUS; 
"-" return MINUS; 
"*" return TIMES; 
"/" return DIVIDE; 

"?" return LOG; 
"$" return RAIZ;

"^" return POW; 

"&&"  return AND; 
"||"  return OR; 
"#"  return XOR; 
"!"  return NEG;

">"  return MAIOR; 
"<"  return MENOR; 
">=" return MAIORIGUAL; 
"<=" return MENORIGUAL; 
"!=" return DIFERENTE; 

"==" return IGUAL; 

"=" return ATRIBUICAO; 

"(" return LEFT; 
")" return RIGHT; 

"\n" return END; 
%%
