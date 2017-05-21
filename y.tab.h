/* A Bison parser, made by GNU Bison 3.0.4.  */

/* Bison interface for Yacc-like parsers in C

   Copyright (C) 1984, 1989-1990, 2000-2015 Free Software Foundation, Inc.

   This program is free software: you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation, either version 3 of the License, or
   (at your option) any later version.

   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with this program.  If not, see <http://www.gnu.org/licenses/>.  */

/* As a special exception, you may create a larger work that contains
   part or all of the Bison parser skeleton and distribute that work
   under terms of your choice, so long as that work isn't itself a
   parser generator using the skeleton or a modified version thereof
   as a parser skeleton.  Alternatively, if you modify or redistribute
   the parser skeleton itself, you may (at your option) remove this
   special exception, which will cause the skeleton and the resulting
   Bison output files to be licensed under the GNU General Public
   License without this special exception.

   This special exception was added by the Free Software Foundation in
   version 2.2 of Bison.  */

#ifndef YY_YY_Y_TAB_H_INCLUDED
# define YY_YY_Y_TAB_H_INCLUDED
/* Debug traces.  */
#ifndef YYDEBUG
# define YYDEBUG 0
#endif
#if YYDEBUG
extern int yydebug;
#endif
/* "%code requires" blocks.  */
#line 39 "aa.y" /* yacc.c:1909  */

	#include <fstream>
	#include <iostream>
	#include <map>
	#include <stack>
	#include <string.h>
	#include <cstring>
	#include <stdio.h>
	#include <unistd.h>

	using namespace std;

#line 57 "y.tab.h" /* yacc.c:1909  */

/* Token type.  */
#ifndef YYTOKENTYPE
# define YYTOKENTYPE
  enum yytokentype
  {
    right_bracket = 258,
    left_bracket = 259,
    right_curly = 260,
    left_curly = 261,
    semicolon = 262,
    equals = 263,
    assign = 264,
    if_word = 265,
    else_word = 266,
    while_word = 267,
    for_word = 268,
    int_word = 269,
    float_word = 270,
    relop = 271,
    mulop = 272,
    addop = 273,
    float_num = 274,
    int_num = 275,
    id_word = 276,
    boolean = 277,
    system_out = 278
  };
#endif
/* Tokens.  */
#define right_bracket 258
#define left_bracket 259
#define right_curly 260
#define left_curly 261
#define semicolon 262
#define equals 263
#define assign 264
#define if_word 265
#define else_word 266
#define while_word 267
#define for_word 268
#define int_word 269
#define float_word 270
#define relop 271
#define mulop 272
#define addop 273
#define float_num 274
#define int_num 275
#define id_word 276
#define boolean 277
#define system_out 278

/* Value type.  */
#if ! defined YYSTYPE && ! defined YYSTYPE_IS_DECLARED

union YYSTYPE
{
#line 54 "aa.y" /* yacc.c:1909  */

	struct {
		int sType;
		string* expval;
		string* b_true;
		string* b_false;
	} expr;
	struct {
		string* next;
	} stmt,if_stmt;
	struct{
		int sType;
		string* idval;
	} factor;
	struct{
		string* begin;
		string* next;
		string* temp;
	} for_loop;
	struct{
		string* begin;
		string* next;
	} while_loop;
	string* idval;
	int sType;
	string* begin;
	string* tempval;
	char addopval;
	char mulopval;
	string* relopval;
	int intval;
	float floatval;
	int bval;

#line 150 "y.tab.h" /* yacc.c:1909  */
};

typedef union YYSTYPE YYSTYPE;
# define YYSTYPE_IS_TRIVIAL 1
# define YYSTYPE_IS_DECLARED 1
#endif


extern YYSTYPE yylval;

int yyparse (void);

#endif /* !YY_YY_Y_TAB_H_INCLUDED  */
