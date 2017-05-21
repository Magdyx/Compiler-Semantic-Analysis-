%{
	#include <string>
	#include <stdio.h>
	#include <stdlib.h>
	#include "y.tab.h"
%}

letter  [a-zA-Z]
digit [0-9]
digits {digit}+

%%

{letter}({letter}|{digit})*			{yylval.idval = strdup(yytext);	return id_word;}
"-"?{digits}					{yylval.intval = atoi(yytext); return int_num;}
"-"?{digits}.{digits}("E"{digits}+)?		{yylval.floatval = atof(yytext); return float_num;}
"+"|"-"						{yylval.addopval = strdup(yytext)[0]; return addop;}
"*"|"/"						{yylval.mulopval = strdup(yytext)[0]; return mulop;}
"=="|"!="|">"|">="|"<"|"<=" 			{yylval.relopval = strdup(yytext); return relop;}
 /* "&&"|"||" 					{yylval.boolopval = strdup(yytext); return BOOL_OP;} */
"true"						{yylval.bval = 1; return boolean;}
"false" 					{yylval.bval = 0; return boolean;}
"if"						{return if_word;}
"else"						{return else_word;}
"while"						{return while_word;}
"for"						{return for_word;}
"int"						{return int_word;}
"float"						{return float_word;}
 /* "boolean" 					{return BOOLEAN_WORD;}*/
"=" 						{return equals;}
";" 						{return semicolon;}
"(" 						{return left_bracket;}
")" 						{return right_bracket;}
"{" 						{return left_curly;}
"}" 						{return right_curly;}
"System.out.println"				{return system_out;}
\n

%%


int yywrap() {
   // open next reference or source file and start scanning
   return -1;
}

/*
main()
{
	yylex();
}
*/
