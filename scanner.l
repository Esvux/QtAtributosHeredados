/*-----------------------------------
|        Definiciones de Flex        |
------------------------------------*/
%option noyywrap
%{
/*-----------------------------------
|         Definiciones en C          |
------------------------------------*/
#include <stdio.h>
#include <stdlib.h>
#include "parser.h"
int linea = 0;
%}

/*-----------------------------------
|       Expresiones regulares        |
------------------------------------*/
DIGITO [0-9]
NUMERO {DIGITO}+("."{DIGITO}+)?

%% //<><><><><><><><><><><><> Reglas léxicas <><><><><><><><><><><><><><><>

{NUMERO} 	{ yylval.decimal = atof(yytext); return(numero);  };
"+"			{ return(suma); };
"-"			{ return(resta); };
"*"			{ return(multiplica); };
"^"			{ return(potencia); };
"/"			{ return(divide); };
"("			{ return(pizq); };
")"			{ return(pder); };
"\n"		{ linea++; };
[\t\r\f] 	{  };
" "			{  };
.			{ printf("Error lexico '%s' en la línea %d", yytext, linea); };

%% //<><><><><><><><><><><><> Reglas léxicas <><><><><><><><><><><><><><><>
/*-----------------------------------
|             Código de C            |
------------------------------------*/

