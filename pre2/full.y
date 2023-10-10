%{
#include<stdio.h>
#include<stdlib.h>
#include<ctype.h>
#include<string.h>
typedef struct {
    char name[40];
    double value;
} Symbol;

Symbol symbolTable[100]; 
int symbolCount = 0;

int yylex();
extern int yyparse();
FILE* yyin;
void yyerror(const char* s);

double findVariable(const char* name) {
    for (int i = 0; i < symbolCount; i++) {
        if (strcmp(symbolTable[i].name, name) == 0) {
            return symbolTable[i].value;
        }
    }
    yyerror("Undefined variable");
    return 0; 
}

void addVariable(const char* name, double value) {
    if (symbolCount < 100) {
        strcpy(symbolTable[symbolCount].name,name);
        symbolTable[symbolCount].value = value;
        symbolCount++;
    } else {
        yyerror("Symbol table is full");
    }
}

%}

%union {
    double num;           
    char* identifier;   
}

%type <num> expr

%token ADD MINUS MUL DIV LPAREN RPAREN
%token<num> NUMBER
%token<identifier> IDENTIFIER
%left ADD MINUS
%left MUL DIV
%right UMINUS          

%%

lines   :       lines expr ';' { printf("%f\n", $2); }
        |       lines stmt ';' 
        |       lines ';'
        |      
        ;

stmt    :       IDENTIFIER '=' expr { 
                    const char* identifier = $1;
                    addVariable(identifier, $3);
                }
        ;

expr    :       expr ADD expr   { $$ = $1 + $3; }
        |       expr MINUS expr   { $$ = $1 - $3; }
        |       expr MUL expr   { $$ = $1 * $3; }
        |       expr DIV expr   { $$ = $1 / $3; }
        |       MINUS expr %prec UMINUS   { $$ = -$2; }
        |       LPAREN expr RPAREN { $$ = $2; }
        |       NUMBER  { $$ = $1; }
        |       IDENTIFIER { $$ = findVariable($1); }
        ;
%%

int yylex() {
    int t;
    int num = 0;
    char identifier[50];
    int i = 0;
    
    while (1) {
        t = getchar();
        if (t == ' ' || t == '\t' || t == '\n') {
            // do nothing
        } else if (isdigit(t)) {
            num = t - '0';
            while (1) {
                t = getchar();
                if (isdigit(t)) {
                    t = t - '0';
                    num = num * 10 + t;
                } else {
                    ungetc(t, stdin);
                    yylval.num = num;
                    return NUMBER;
                }
            }
        } else if (isalpha(t)) {
            identifier[i++] = t;
            while (1) {
                t = getchar();
                if (isalnum(t) || t == '_') {
                    identifier[i++] = t;
                } else {
                    ungetc(t, stdin);
                    identifier[i] = '\0';
                    yylval.identifier = strdup(identifier); 
                    return IDENTIFIER;
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
        } else if (t == '=') {
            return '=';
        } else {
            return t;
        }
    }
}


int main(void) {
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
