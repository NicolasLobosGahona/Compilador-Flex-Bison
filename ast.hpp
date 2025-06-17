#include <iostream>
#include <vector>
#include <string>

enum TipoDato {
    DATO_NUMERO,
    DATO_INT,
    DATO_FLOAT,
    DATO_CADENA,
    DATO_BOOLEANO
};

enum TipoNodo {
    NODO_NUMERO,
    NODO_IDENTIFICADOR,
    NODO_BINOP,
    NODO_ASIGNACION,
    NODO_DECLARACION, 
    NODO_IMPRIMIR,
    NODO_RESOLVER, 
    NODO_IF,
    NODO_IF_ELSE,
    NODO_WHILE, 
    NODO_INSTRUCCIONES,
    NODO_CADENA
};

class AST {
    public:
        TipoNodo tipo;
        TipoDato tipoDato;
        int valorEntero;
        float valorFloat;
        std::string cadena;
        AST* izq = nullptr;
        AST* der = nullptr;
        AST* cond = nullptr;
        AST* cuerpo = nullptr;
        AST* sino = nullptr;
        AST* unico = nullptr;
        char op; 
        std::vector<AST*> instrucciones;

        static AST* crearNumero(int val);
        static AST* crearNumeroFloat(float val);
        float obtenerFloat() const;
        static AST* crearCadena(const std::string& texto);
        static AST* crearIdentificador(const std::string& nombre);
        static AST* crearOperaciones(char op, AST* izq, AST* der);
        static AST* crearAsignacion(const std::string& nombre, AST* valor);
        static AST* crearResolver(AST* valor);
        static AST* crearImprimir(AST* valor);
        static AST* crearIf(AST* cond, AST* cuerpo);
        static AST* crearIfElse(AST* cond, AST* cuerpo, AST* sino);
        static AST* crearInstrucciones(const std::vector<AST*>& lista);
        static AST* crearWhile(AST* cond, AST* cuerpo);
        int evaluar() const;
        void ejecutar() const;
};
