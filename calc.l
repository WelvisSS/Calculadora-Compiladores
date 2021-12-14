%{ 
/* analisador léxico */
#include <stdio.h>
#include <stdlib.h>
#include "calc.tab.h"
#define M 100
extern int insertTablePosition(int var, char *var2);

int inicializado = 1;
typedef struct{
    int codigo;
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

// Função de espalhamento (resto da divisão da chave por M)
extern int gerarCodigoHash(int chave){
    return chave % M;
}

// Função para ler e retornar um item armazenado
extern Simbolos lerSimb(int var, float valor){
    Simbolos p;
    p.codigo = var;
    p.valor = valor;
    return p;
}

// inserir uma item na tabela
extern void inserir(int var, float valor){
    Simbolos simb = lerSimb(var, valor);
    int indice = gerarCodigoHash(simb.codigo);
    tabelaHash[indice] = simb;
}

// Buscar um item na tabela
extern Simbolos* buscar(int chave){
    int indice = gerarCodigoHash(chave);
    while(tabelaHash[indice].codigo != -1){
        if(tabelaHash[indice].codigo == chave)
            return &tabelaHash[indice];
        else
            indice = gerarCodigoHash(indice + 1);
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
variaveis {caracteres}+

/* REGRAS */
%%

{white} { }
{real}  { 

    yylval.digit = atof(yytext); 
    return NUM; 
}

{variaveis} { 

    insertTablePosition(0, yytext);
    return VAR;
}

"+"  return PLUS; 
"-" return MINUS; 
"*" return TIMES; 
"/" return DIVIDE; 

"log" return LOG; 
"sqrt" return RAIZ;

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

int insertTablePosition(int var, char *var2){
    Simbolos *p;
    /* Impedindo que a tabela seja iniciada mais de uma vez */
    if (inicializado == 1) {
        inicializarTabela();
        inicializado = 0;
    };

    int cont = 0;
    float codigoVar = 1;
    int variacao = 0;

    while(1){
        if (var2[cont] >= 65 && var2[cont] <= 90){ //Verifica se está no intervalo das maiúsculas
            if (variacao == 0){ // Se for 0 multiplica o valor ascii do símbolo atual
                codigoVar = codigoVar * var2[cont];
                cont = cont + 1;
                
            }else{// Não sendo 0 divide o valor ascii do símbolo atual
                codigoVar = codigoVar / var2[cont];
                cont = cont + 1;
            }
            // Faz a troca entre multiplicação e divisão
            variacao = !variacao;

        }else if (var2[cont] >= 97 && var2[cont] <= 122){ //Verifica se está no intervalo das minúsculas
            if (variacao == 0){ // Se for 0 multiplica o valor ascii do símbolo atual
                codigoVar = codigoVar * var2[cont];
                cont = cont + 1;
                
            }else{// Não sendo 0 divide o valor ascii do símbolo atual
                codigoVar = codigoVar / var2[cont];
                cont = cont + 1;
            }
            // Faz a troca entre multiplicação e divisão
            variacao = !variacao;
            
        }else{ // Encerra o laço no fim da leitura da cadeia
            break;
        }
         
    };

    yylval.var = codigoVar;
    return yylval.var;
    
};

