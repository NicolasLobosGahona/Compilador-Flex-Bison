%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <string>
#include "compilador.tab.hpp"
void yyerror(const char *);
extern char *yytext;
%}

%option noyywrap

DIGITO [0-9]
LETRA [a-zA-Z_]
ENTERO {DIGITO}+
FLOTANTE {DIGITO}+"."{DIGITO}+


%%

[ \t\r\n]+      ;

"int"      { return INT; }
"float"    { return FLOAT; }
"str"   { return STRING; }
"resolver" { return RESOLVER; }
"imprimir" { return IMPRIMIR; }
"if"       { return IF; }
"else"     { return ELSE; }
"while"    { return WHILE; }


"==" { return IGUAL; }
"!=" { return DISTINTO; }
">=" { return MAYOR_IGUAL; }
">"  { return MAYOR; }
"<=" { return MENOR_IGUAL; }
"<"  { return MENOR; }

"="  { return ASIGNACION; }

{FLOTANTE} {
    yylval.floatval = atof(yytext);
    return FLOAT_NUMERO;
}

{ENTERO} {
    yylval.intval = atoi(yytext);
    return NUMERO;
}

{LETRA}({LETRA}|{DIGITO})* {
    yylval.id = strdup(yytext);
    return ID;
}

\"[^\"]*\" {
    std::string temp(yytext);
    temp = temp.substr(1, temp.size() - 2);
    yylval.strval = strdup(temp.c_str());
    return CADENA;
}

[-+*/();{}] { return *yytext; }

. {
    char mensaje[100];
    sprintf(mensaje, "Carácter no reconocido: '%s'", yytext);
    yyerror(mensaje);
    return -1;
}

%%