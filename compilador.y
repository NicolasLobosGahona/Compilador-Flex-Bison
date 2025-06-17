%code requires {
    #include <vector>
    class AST;
}

%{
#include <stdio.h>
#include <string.h>
#include "ast.hpp"
#include <unistd.h>

int yylex(void);
void yyerror(const char *s);
AST *raiz;

struct simbolo {char *nombre; int valor;};
struct simbolo lista_simbolos[100];
int cant_simbolo = 0;

int buscar_simbolo(char *nombre){
    for(int i = 0; i < cant_simbolo; i++){
        if(strcmp(lista_simbolos[i].nombre, nombre) == 0){
            return lista_simbolos[i].valor;
        }
    }
    yyerror("Variable no definida");
    return 0;
}

void almacenar_simbolo(char *nombre, int valor){
    if(cant_simbolo < 100){
        lista_simbolos[cant_simbolo].nombre = strdup(nombre);
        lista_simbolos[cant_simbolo].valor = valor;
        cant_simbolo++;
    } else {
        yyerror("Lista llena.");
    }
}
%}


%union {
    AST* nodo;
    std::vector<AST*>* lista;
    int intval;
    char* id;
    float floatval;
    char* strval;
}

%token <intval> NUMERO
%token <floatval> FLOAT_NUMERO
%token <strval> CADENA STRING
%token <id> ID
%token INT FLOAT 
%token ASIGNACION
%token RESOLVER IMPRIMIR
%token IGUAL DISTINTO MAYOR MAYOR_IGUAL MENOR MENOR_IGUAL
%token IF ELSE WHILE
%type <nodo> EXPRESION INSTRUCCION CONDICION DECLARACION BUCLE
%type <lista> INSTRUCCIONES

%left '+' '-'
%left '*' '/'
%left IGUAL DISTINTO
%left MENOR MENOR_IGUAL MAYOR MAYOR_IGUAL

%%

INICIO : INSTRUCCIONES{
    raiz = AST::crearInstrucciones(*$1);
    raiz->ejecutar();
} 
;

INSTRUCCIONES
    : INSTRUCCION{
        $$ = new std::vector<AST*>();
        $$->push_back($1);
    }
    | INSTRUCCIONES INSTRUCCION{
        $1->push_back($2);
        $$ = $1;
    }
    | INSTRUCCIONES DECLARACION{
        $1->push_back($2);
        $$ = $1;
    }
    | DECLARACION{
        $$ = new std::vector<AST*>();
        $$->push_back($1);
    }
;

INSTRUCCION
    : ID ASIGNACION EXPRESION ';' { $$ = AST::crearAsignacion($1, $3); }
    | RESOLVER '(' EXPRESION ')' ';' { $$ = AST::crearResolver($3); }
    | IMPRIMIR '(' EXPRESION ')' ';' { $$ = AST::crearImprimir($3); }
    | CONDICION{$$ = $1;}
    | BUCLE{$$ = $1;}
;

EXPRESION
    : '(' EXPRESION ')' { $$ = $2; }
    | EXPRESION '+' EXPRESION { $$ = AST::crearOperaciones('+', $1, $3); }
    | EXPRESION '-' EXPRESION { $$ = AST::crearOperaciones('-', $1, $3); }
    | EXPRESION '*' EXPRESION {$$ = AST::crearOperaciones('*', $1, $3); }
    | EXPRESION '/' EXPRESION { $$ = AST::crearOperaciones('/', $1, $3); }
    | EXPRESION IGUAL EXPRESION {$$ = AST::crearOperaciones('=', $1, $3); }
    | EXPRESION DISTINTO EXPRESION { $$ = AST::crearOperaciones('!', $1, $3); }
    | EXPRESION MENOR EXPRESION {$$ = AST::crearOperaciones('<', $1, $3); }
    | EXPRESION MENOR_IGUAL EXPRESION { $$ = AST::crearOperaciones('x', $1, $3); }
    | EXPRESION MAYOR EXPRESION { $$ = AST::crearOperaciones('>', $1, $3); }
    | EXPRESION MAYOR_IGUAL EXPRESION { $$ = AST::crearOperaciones('y', $1, $3); }
    | NUMERO {  $$ = AST::crearNumero($1); }
    | FLOAT_NUMERO { $$ = AST::crearNumeroFloat($1); }
    | CADENA { $$ = AST::crearCadena($1); }
    | ID { $$ = AST::crearIdentificador($1); }
;

DECLARACION
    : INT ID ASIGNACION EXPRESION ';' {  $$ = AST::crearAsignacion($2, $4); }
    | FLOAT ID ASIGNACION FLOAT_NUMERO ';' { $$ = AST::crearAsignacion($2,AST::crearNumeroFloat($4));}
    | STRING ID ASIGNACION CADENA ';' { $$ = AST::crearAsignacion($2, AST::crearCadena($4)); }
;

CONDICION
    : IF '(' EXPRESION ')' '{' INSTRUCCIONES '}' {$$ = AST::crearIf($3, AST::crearInstrucciones(*$6));}
    | IF '(' EXPRESION ')' '{' INSTRUCCIONES '}' ELSE '{' INSTRUCCIONES '}' {$$ = AST::crearIfElse($3, AST::crearInstrucciones(*$6), AST::crearInstrucciones(*$10));}

;

BUCLE
    :WHILE '(' EXPRESION ')' '{' INSTRUCCIONES '}' {$$ = AST::crearWhile($3, AST::crearInstrucciones(*$6));}
;


%%

float leerNumeroTeclado(const std::string &mensaje);

int main() {
    if (isatty(fileno(stdin))){

        while(true){
            std::string opcion;
            std::cout<<std::endl;
            std::cout << "--- Calculadora ---"<<std::endl;
            std::cout << "Operaciones disponibles:"<<std::endl;
            std::cout << "-suma\n-resta\n-multiplicacion\n-division\n-exponente"<<std::endl;

            std::cout << "Ingrese la operacion ('salir' para terminar): ";
            std::cin >> opcion;


            if(opcion == "salir"){break; return 0;}

            if(opcion == "suma"){
                float num1 = leerNumeroTeclado("Ingrese el primer numero: ");
                float num2 = leerNumeroTeclado("Ingrese el segundo numero: ");
                AST* nodo1 = AST::crearNumeroFloat(num1);
                AST* nodo2 = AST::crearNumeroFloat(num2);
                AST* nodoSuma = AST::crearOperaciones('+', nodo1, nodo2);
                float resultado = nodoSuma->evaluar();
                std::cout << "Resultado de la suma: " << resultado << "\n";

            }else if(opcion == "resta"){
                float num1 = leerNumeroTeclado("Ingrese el primer numero: ");
                float num2 = leerNumeroTeclado("Ingrese el segundo numero: ");
                AST* nodo1 = AST::crearNumeroFloat(num1);
                AST* nodo2 = AST::crearNumeroFloat(num2);
                AST* nodoSuma = AST::crearOperaciones('-', nodo1, nodo2);
                float resultado = nodoSuma->evaluar();
                std::cout << "Resultado de la resta: " << resultado << "\n";

            }else if(opcion == "multiplicacion"){
                float num1 = leerNumeroTeclado("Ingrese el primer numero: ");
                float num2 = leerNumeroTeclado("Ingrese el segundo numero: ");
                AST* nodo1 = AST::crearNumeroFloat(num1);
                AST* nodo2 = AST::crearNumeroFloat(num2);
                AST* nodoSuma = AST::crearOperaciones('*', nodo1, nodo2);
                float resultado = nodoSuma->evaluar();
                std::cout << "Resultado de la multiplicacion: " << resultado << "\n";

            }else if(opcion == "division"){
                float num1 = leerNumeroTeclado("Ingrese el primer numero: ");
                float num2 = leerNumeroTeclado("Ingrese el segundo numero: ");
                AST* nodo1 = AST::crearNumeroFloat(num1);
                AST* nodo2 = AST::crearNumeroFloat(num2);
                AST* nodoSuma = AST::crearOperaciones('/', nodo1, nodo2);
                float resultado = nodoSuma->evaluar();
                std::cout << "Resultado de la division: " << resultado << "\n";

            }else if(opcion == "exponente"){
                float num1 = leerNumeroTeclado("Ingrese el primer numero: ");
                float num2 = leerNumeroTeclado("Ingrese el segundo numero: ");
                AST* nodo1 = AST::crearNumeroFloat(num1);
                AST* nodo2 = AST::crearNumeroFloat(num2);
                AST* nodoSuma = AST::crearOperaciones('e', nodo1, nodo2);
                float resultado = nodoSuma->evaluar();
                std::cout << "Resultado de la potencia: " << resultado << "\n";

            }
        }

    }else{
        return yyparse();
    }

}

void yyerror(const char *s) {
    printf("Error: %s\n", s);
    exit(1);
}

float leerNumeroTeclado(const std::string &mensaje) {
    float numero;
    while(true){
        std::cout << mensaje;
        std::cin >> numero;
        if(!std::cin.fail()){
            return numero;
        }

        std::cin.clear();
        std::cin.ignore(11111, '\n');
        std::cout<<"Error, caracter no valido. Intente de nuevo"<<std::endl;
    }
}