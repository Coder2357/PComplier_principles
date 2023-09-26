%{
#include<stdio.h>
#include<stdlib.h>
#include<ctype.h>
#ifndef YYSTYPE
#define YYSTYPE double
#endif
int yylex();
extern int yyparse();
FILE* yyin;
void yyerror(const char* s);
%}

%token ADD MINUS MUL DIV LPAREN RPAREN
%token NUMBER
%left ADD MINUS
%left MUL DIV
%right UMINUS         

%%

lines   :       lines expr ';' { printf("%f\n", $2); }
        |       lines ';'
        |
        ;

expr    :       expr ADD expr   { $$ = $1 + $3; }
        |       expr MINUS expr   { $$ = $1 - $3; }
        |       expr MUL expr   { $$ = $1 * $3; }
        |       expr DIV expr   { $$ = $1 / $3; }
        |       MINUS expr %prec UMINUS   { $$ = -$2; }
        |       LPAREN expr RPAREN { $$ = $2; }
        |       NUMBER  { $$ = $1; }
        ;

%%

// programs section

int yylex()
{
    int t;
    int num=0; 
    while(1){
        t=getchar();
        if(t==' '||t=='\t'||t=='\n'){
            //do nothing
        }else if(isdigit(t)){
            num=t-'0'; 
            while(1){
                t=getchar();
                if(isdigit(t)){
                    t=t-'0';
                    num=num*10+t;
                }else{
                    ungetc(t,stdin); 
                    yylval=num; 
                    return NUMBER;
                }
            }
        }else if(t=='+'){
            return ADD;
        }else if(t=='-'){
            return MINUS;
        }else if(t=='*'){
            return MUL;
        }else if(t=='/'){
            return DIV;
        }else if(t=='('){
            return LPAREN;
        }else if(t==')'){
            return RPAREN;
        }else{
            return t; 
        }
    }
}

int main(void)
{
    yyin = stdin;
    do {
        yyparse();
    } while (!feof(yyin));
    return 0;
}

void yyerror(const char* s) {
    fprintf(stderr, "Parse error: %s\n", s);
    exit(1);
}
