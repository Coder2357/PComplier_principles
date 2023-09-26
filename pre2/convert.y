%{
/*********************************************
将所有的词法分析功能均放在 yylex 函数内实现，为 +、-、*、\、(、 ) 每个运算符及整数分别定义一个单词类别，在 yylex 内实现代码，能
识别这些单词，并将单词类别返回给词法分析程序。
实现功能更强的词法分析程序，可识别并忽略空格、制表符、回车等
空白符，能识别多位十进制整数。
YACC file
**********************************************/
#include<stdio.h>
#include<stdlib.h>
#include<ctype.h>
#include<string.h> // Added for string manipulation
#ifndef YYSTYPE
#define YYSTYPE double
#endif
int yylex();
extern int yyparse();
FILE* yyin;
void yyerror(const char* s);
%}

//TODO:给每个符号定义一个单词类别
%token ADD MINUS MUL DIV LPAREN RPAREN
%token NUMBER
%left ADD MINUS
%left MUL DIV
%right UMINUS         


%%

lines   :       lines expr ';' //{ printf("%f\n", $2); }
        |       lines ';'
        |
        ;

expr    :       expr ADD expr   { $$ = $1 + $3;printf("+"); }
        |       expr MINUS expr   { $$ = $1 - $3;printf("-"); }
        |       expr MUL expr   { $$ = $1 * $3;printf("*"); }
        |       expr DIV expr   { $$ = $1 / $3;printf("/"); }
        |       MINUS expr %prec UMINUS   { $$ = -$2;printf("-"); }
        |       LPAREN expr RPAREN {$$ = $2; }
        |       NUMBER  { $$ = $1;printf("%f", $1); }
        ;

%%

// programs section

int yylex()
{
    int t;
    int num = 0; 
    
    while (1) {
        t = getchar();
        
        if (t == ' ' || t == '\t' || t == '\n') {
            // do nothing
        } else if (isdigit(t)) {
            num = t - '0'; 
            while (1) {
                t = getchar();
                if (isdigit(t)) {
                    num = num * 10 + (t - '0');
                } else {
                    ungetc(t, stdin); 
                    yylval = num; 
                    return NUMBER;
                }
            }
        } else if (t == '+') {
            return ADD;
        } else if (t == '-') {
            return MINUS;
        } else if (t == '*') {
            return MUL;
        } else if (t == '/') {
            return DIV;
        } else if (t == '(') {
            return LPAREN;
        } else if (t == ')') {
            return RPAREN;
        } else {
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
