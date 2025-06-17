# Calculadora con Árbol de Sintaxis Abstracta (AST)

Este proyecto es una calculadora interactiva implementada en C++ que utiliza un Árbol de Sintaxis Abstracta (AST) para evaluar expresiones matemáticas . Soporta operaciones como suma, resta, multiplicación, división y exponentes

## Características

- Interfaz por consola interactiva.
- Implementación con nodos de AST para representar operaciones.
- Soporte para:
  - Suma (`+`)
  - Resta (`-`)
  - Multiplicación (`*`)
  - División (`/`) con validación de división por cero
  - Exponente (`e`)
- Validación de entrada: rechaza letras o caracteres inválidos.
- Opción de ejecución por consola o por análisis desde archivo (usando `Bison`/`Flex`).

## Requisitos

- C++
- [Bison](https://www.gnu.org/software/bison/)
- [Flex](https://github.com/westes/flex)
- GNU/Linux o entorno compatible (puedes adaptar a Windows con MSYS2 MINGW64 o Powershell)

## Compilación

bash

-flex -o lex.yy.cpp compiladorflex.l

-bison -d -o compilador.tab.cpp compilador.y

-g++ -o compilador compilador.tab.cpp lex.yy.cpp AST.cpp -std=c++11

## Ejecucion

Si se ejecuta con un txt:

  -/Compilador.exe < nombre_archivo.txt

Si se ejecuta para el uso de la calculadora:

  -./Compilador.exe
 

