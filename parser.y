%{

/*-----------------------------------
|        Declaraciones en C          |
------------------------------------*/
#include <stdio.h>
#include <stdlib.h>
#include <QString>
#include <math.h>
#include "scanner.h"
extern int yylex(void);
extern int linea;
void yyerror(char *s);
QString resultado;

%}

/*-----------------------------------
|      Declaraciones de Bison        |
------------------------------------*/
//Atributos
%union{
  double decimal;
  int entero;
  struct{
    char cadena[255];
    double valor;
  } atributos;
}

//Terminales
%token <decimal> numero 
%token suma resta multiplica divide pizq pder potencia

//No terminales
%type <atributos> INICIO EXPRESION EXP_AUX TERMINO TER_AUX FACTOR FAC_AUX NUMERO

%% //<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>

/*-----------------------------------
|        Gramática descendente       |
|------------------------------------|
|             S -> E                 |
|             E -> T E'              |
|            E' -> + T E'            |
|               |  - T E'            |
|               |  e                 |
|             T -> F T'              |
|            T' -> * F T'            |
|               |  / F T'            |
|               |  e                 |
|             F -> N F'              |
|            F' -> ^ N F'            |
|               |  e                 |
|             N -> ( E )             |
|               |  num               |
------------------------------------*/

/*-------------------------
|          S -> E          |
--------------------------*/
INICIO : EXPRESION 
    { 
      $$ = $1; 
      sprintf($$.cadena, "%s = %.f\n", $1.cadena, $1.valor );
      resultado =  QString::fromUtf8($$.cadena);
    };


/*-------------------------
|        E -> T E'         |
--------------------------*/
EXPRESION : TERMINO EXP_AUX { $$ = $2; /*Sintetizando*/};


/*-------------------------
|       E' -> + T E'       |
|          |  - T E'       |
|          |  e            |
--------------------------*/
EXP_AUX
: suma TERMINO 
    { //Sumando
      $<atributos>$.valor = $<atributos>0.valor + $<atributos>2.valor; //Heredando
      sprintf($<atributos>$.cadena, "%s+%s", $<atributos>0.cadena, $<atributos>2.cadena);
    } 
    EXP_AUX { $$ = $4; /*Sintetizando*/ }

| resta TERMINO 
    { //Restando
      $<atributos>$.valor = $<atributos>0.valor - $<atributos>2.valor; //Heredando
      sprintf($<atributos>$.cadena, "%s-%s", $<atributos>0.cadena, $<atributos>2.cadena);
    } 
    EXP_AUX { $$ = $4; /*Sintetizando*/ }

| %empty { $$ = $<atributos>0; /* Sintetizando lo heredado */};


/*-------------------------
|        T -> F T'         |
--------------------------*/
TERMINO : FACTOR TER_AUX { $$ = $2; };


/*-------------------------
|       T' -> * F T'       |
|          |  / F T'       |
|          |  e            |
--------------------------*/
TER_AUX
: multiplica FACTOR 
    { //Multiplicando
      $<atributos>$.valor = $<atributos>0.valor * $<atributos>2.valor; //Heredando
      sprintf($<atributos>$.cadena, "%s*%s", $<atributos>0.cadena, $<atributos>2.cadena);
    } 
    TER_AUX { $$ = $4; /*Sintetizando*/ }

| divide FACTOR 
    { //Dividiendo
      $<atributos>$.valor = $<atributos>0.valor / $<atributos>2.valor; //Heredando
      sprintf($<atributos>$.cadena, "%s/%s", $<atributos>0.cadena, $<atributos>2.cadena);
    } 
    TER_AUX { $$ = $4; /*Sintetizando*/ }

| %empty { $$ = $<atributos>0; /* Sintetizando lo heredado */};


/*-------------------------
|        F -> N F'         |
--------------------------*/
FACTOR : NUMERO FAC_AUX { $$ = $2; };


/*-------------------------
|       F' -> ^ N F'       |
|          |  e            |
--------------------------*/
FAC_AUX
: potencia NUMERO 
    { //Potenciando
      $<atributos>$.valor = pow($<atributos>0.valor, $<atributos>2.valor); //Heredando
      sprintf($<atributos>$.cadena, "%s^%s", $<atributos>0.cadena, $<atributos>2.cadena);
    }
    FAC_AUX { $$ = $4; /*Sintetizando*/ }

| %empty { $$ = $<atributos>0; /* Sintetizando lo heredado */};


/*-------------------------
|        N -> ( E )        |
|          |  num          |
--------------------------*/
NUMERO : pizq EXPRESION pder { $$.valor = $2.valor; sprintf($$.cadena, "(%s)", $2.cadena); }
       | numero { $$.valor = $1; sprintf($$.cadena, "%.f", $1); };


%% //<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>

/*-----------------------------------
|         Código C adicional         |
------------------------------------*/
void yyerror(char *s)
{
  printf("Error sintactico: %s",s);
}