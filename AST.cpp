#include "ast.hpp"
#include <cmath>
extern float buscarSimbolo(const std::string& cadena);
std::vector<std::pair<std::string, float>> tablaSimbolos;

float AST::obtenerFloat() const {
    if (tipo == NODO_NUMERO) {
        return tipoDato == DATO_FLOAT ? valorFloat : valorEntero;

    }else if (tipo == NODO_IDENTIFICADOR) {
        return buscarSimbolo(cadena);

    }else {
        return evaluar(); 
    }
}
float buscarSimbolo(const std::string& cadena) {
    for (const auto& par : tablaSimbolos) {
        if (par.first == cadena) return par.second;
    }
    std::cerr << "Variable no definida: " << cadena << std::endl;
    return 0;
}

void almacenarSimbolo(const std::string& cadena, float valor) {
    for (auto& par : tablaSimbolos) {
        if (par.first == cadena) {
            par.second = valor;
            return;
        }
    }
    tablaSimbolos.emplace_back(cadena, valor);
}

AST* AST::crearNumero(int val) {
    AST* nodo = new AST();
    nodo->tipo = NODO_NUMERO;
    nodo->tipoDato = DATO_INT;
    nodo->valorEntero = val;
    return nodo;
}

AST* AST::crearNumeroFloat(float val) {
    AST* nodo = new AST();
    nodo->tipo = NODO_NUMERO;
    nodo->tipoDato = DATO_FLOAT;
    nodo->valorFloat = val;
    return nodo;
}

AST* AST::crearCadena(const std::string& texto) {
    AST* nodo = new AST();
    nodo->tipo = NODO_CADENA;;
    nodo->tipoDato = DATO_CADENA;
    nodo->cadena = texto;
    return nodo;
}

AST* AST::crearIdentificador(const std::string& cadena) {
    AST* nodo = new AST();
    nodo->tipo = NODO_IDENTIFICADOR;
    nodo->cadena = cadena;
    return nodo;
}

AST* AST::crearOperaciones(char op, AST* izq, AST* der) {
    AST* nodo = new AST();
    nodo->tipo = NODO_BINOP;
    nodo->op = op;
    nodo->izq = izq;
    nodo->der = der;
    return nodo;
}

AST* AST::crearAsignacion(const std::string& cadena, AST* valor) {
    AST* nodo = new AST();
    nodo->tipo = NODO_ASIGNACION;
    nodo->cadena = cadena;
    nodo->unico = valor;
    return nodo;
}

AST* AST::crearResolver(AST* valor) {
    AST* nodo = new AST();
    nodo->tipo = NODO_RESOLVER;
    nodo->unico = valor;
    return nodo;
}

AST* AST::crearImprimir(AST* valor) {
    AST* nodo = new AST();
    nodo->tipo = NODO_IMPRIMIR;
    nodo->unico = valor;
    return nodo;
}

AST* AST::crearIf(AST* cond, AST* cuerpo) {
    AST* nodo = new AST();
    nodo->tipo = NODO_IF;
    nodo->cond = cond;
    nodo->cuerpo = cuerpo;
    return nodo;
}

AST* AST::crearIfElse(AST* cond, AST* cuerpo, AST* sino) {
    AST* nodo = new AST();
    nodo->tipo = NODO_IF_ELSE;
    nodo->cond = cond;
    nodo->cuerpo = cuerpo;
    nodo->sino = sino;
    return nodo;
}

AST* AST::crearWhile(AST* cond, AST* cuerpo) {
    AST* nodo = new AST();
    nodo->tipo = NODO_WHILE;
    nodo->cond = cond;
    nodo->cuerpo = cuerpo;
    return nodo;
}

AST* AST::crearInstrucciones(const std::vector<AST*>& lista) {
    AST* nodo = new AST();
    nodo->tipo = NODO_INSTRUCCIONES;
    nodo->instrucciones = lista;
    return nodo;
}

int AST::evaluar() const {
    switch (tipo) {
        case NODO_NUMERO:
            if(tipoDato == DATO_INT) {
                return valorEntero;
            } else{
                return valorFloat;
            }

        case NODO_IDENTIFICADOR: return buscarSimbolo(cadena);

        case NODO_BINOP: {
            float hIzq = izq->obtenerFloat();
            float hDer = der->obtenerFloat();
            switch (op) {
                case '+': return hIzq + hDer;
                case '-': return hIzq - hDer;
                case '*': return hIzq * hDer;
                case 'e': return pow(hIzq,hDer);
                case '/':
                    if(hDer!=0){
                        return hIzq / hDer;
                    } else {
                        std::cerr << "Error: División por cero" << std::endl;
                        return 0;
                    }
                case '=': return hIzq == hDer;
                case '!': return hIzq != hDer;
                case '<': return hIzq < hDer;
                case '>': return hIzq > hDer;
                case 'x': return hIzq <= hDer;
                case 'y': return hIzq >= hDer;
            }
        }

        case NODO_IMPRIMIR:
        if (tipoDato == DATO_CADENA) {
            std::cout << cadena << std::endl;
            return 0;
        }else if (unico) {
            std::cout << unico->evaluar() << std::endl;
        }
        default: 
            return 0;
    }
}

void AST::ejecutar() const {
    switch (tipo) {
        case NODO_INSTRUCCIONES:
            for (auto& inst : instrucciones) inst->ejecutar();
            break;

        case NODO_ASIGNACION:
            almacenarSimbolo(cadena, unico->evaluar());
            break;

        case NODO_RESOLVER:
            std::cout << "Resultado = " << unico->evaluar() << std::endl;
            break;

        case NODO_IMPRIMIR:
            if (unico) {
                unico->ejecutar();
                if (unico->tipo == NODO_CADENA)
                    std::cout << unico->cadena << std::endl;
                else
                    std::cout << unico->evaluar() << std::endl;
            }
            break;

        case NODO_IF:
            if (cond->evaluar()) cuerpo->ejecutar();
            break;

        case NODO_IF_ELSE:
            if (cond->evaluar()) cuerpo->ejecutar();
            else if (sino) sino->ejecutar();
            break;

        case NODO_WHILE:
            if(cond== nullptr && cuerpo == nullptr) {
                std::cerr << "Error: WHILE con nodos nulos\n";
            }
            while(cond->evaluar()) {
                cuerpo->ejecutar();
            }
            break;
        default:
            break;
    }
}