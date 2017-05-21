%{
enum type_enum{int_type, float_type, boolean_type, error_type};
struct symbol_table_entry{
	int add;
	type_enum type;
}
map<string, pair<int , type_enum>> symbol_table;
int add_counter = 1;
int temp_var_counter = 1;
stack<string> labels;
	
%}


%code requires {
	#include <vector>
	#include <map>
	using namespace std;
}

%start METHOD_BODY

%union{
	int ival;
	float fval;
	int bval;
	string idval;
	string aopval;
	struct {
		int sType;
		string expval;
		string b_true;
		string b_false;
	} expr;
	struct {
		vector<int> *trueList, *falseList;//no need for next because every if has else
	} bexpr;
	struct {
		string next;
	} stmt, if_stmt;
	struct{
		int sType;
		string idval;
	} factor;
	struct{
		string begin;
		string next;
		string temp;
	} for_loop;
	struct{
		string begin;
		string next;
	} while_loop;
	int sType;
	string begin;
	string tempval;
	char sign;
	char mulopval;
}

%token right_bracket
%token left_bracket
%token right_curly
%token left_curly
%token semicolon
%token equals
%token relop
%token <sign> addop
%token <malopval> mulop
%token assign

%token if_word
%token else_word
%token while_word
%token for_word

%token int_word 	
%token float_word
%token <idval> id_word

%token system_out

%type <sign> SIGN_TYPE
%type <stmt> STATEMENT
%type <expr> EXPRESSION
%type <expr> SIMPLE_EXPRESSION
%type <expr> SIMPLE_EXPRESSION_
%type <while_loop> WHILE
%type <for_loop> FOR
%type <sType> PRIMITIVE_TYPE
%type <stmt> STATEMENT_LIST
%type <stmt> STATEMENT_LIST_
%type <factor> FACTOR
%type <tempval> TERM
%type <tempval> TERM_
%type <if_stmt> IF

%%
METHOD_BODY :
	STATEMENT_LIST
	;

STATEMENT_LIST :
	{
		labels.push(newLabel());
	}
	STATEMENT
	{
		writeCode($2.next);
	}
	STATEMENT_LIST_
	;
	
STATEMENT_LIST_ :
	{
		labels.push(newLabel());
	}
	STATEMENT
	{writeCode($2.next);}
	STATEMENT_LIST_ 
	|
	epson
	;
STATEMENT :
	{
		$<stmt>$.next = labels.top();
		labels.pop();
	}
	DECLARATION
	|
	{
		$<stmt>$.next = labels.top();
		labels.pop();
		labels.push($<stmt>$.next);
	}
	IF
	|
	{
		$<stmt>$.next = labels.top();
		labels.pop();
		labels.push($<stmt>$.next);
	}
	WHILE 
	|
	{
		$<stmt>$.next = labels.top();
		labels.pop();
		labels.push($<stmt>$.next);
	}
	FOR
	|
	{
		$<stmt>$.next = labels.top();
		labels.pop();
	}
	ASSIGNMENT
	|
	{
		$<stmt>$.next = labels.top();
		labels.pop();
	}
	SYSTEM_PRINT
	;	
DECLARATION :
	PRIMITIVE_TYPE 
	id_word
	{
		symbol_table[$2] = make_pair(add_counter++, $1.sType);
	}
	semicolon
	;
PRIMITIVE_TYPE :
	int_word 
	{
		$$.sType = int_type;
	}
	|
	float_word
	{
		$$.sType = float_type;
	}
	;
IF :
	if_word
	left_bracket EXPRESSION right_bracket
	{
		$<if_stmt>$.next = labels.top();
		labels.pop();
		if($3.sType != boolean_type){
			yyerror("expression is not boolean in if");
		}
		writeCode($3.b_true);
		labels.push(newLabel());
	}	
	left_curly STATEMENT right_curly 
	else_word
	{
		writeCode($7.next);
		writeCode("goto " + $<if_stmt>$.next);
		writeCode($3.b_false);
		labels.push(newLabel());
	}
	left_curly STATEMENT right_curly
	{
		writeCode($13.next);
	}
	;
WHILE :
	while_word
	{
		$<while_loop>$.next = labels.top();
		labels.pop();
		$3.b_true = newLabel();
		$3.b_false = $<while_loop>$.next;
		$<while_loop>$.begin = newLabel();
		writeCode($<while_loop>$.begin);
	}
	left_bracket EXPRESSION right_bracket
	{
		if($3.sType != boolean_type){
			yyerror("expression is not boolean in while");
		}
		writeCode($4.b_true);
		labels.push(newLabel());
	}
	left_curly STATEMENT right_curly{
		writeCode($8.next);
		writeCode("goto "+ $<while_loop>$.begin);
	}
	;
ASSIGNMENT : 
	id_word
	assign
	EXPRESSION
	{
		//put in vector of unused
		if(symbol_table[$1].second == symbol_table[$3.temp].second) //same type
			symbol_table[$1].first = symbol_table[$3.temp].first;
		else // not same type
			yyerror("not same type assignment");
	}
	semicolon
	;
FOR:
	for_word left_bracket
	{
		$<for_loop>$.next = labels.top();
		labels.pop();
		$<for_loop>$.begin = newLabel();
		$<for_loop>$.temp = newLabel();
		$3.next = $<for_loop>$.begin;
	}
	STATEMENT semicolon
	{	
		writeCode($<for_loop>$.begin);
		$5.b_true = newLabel();
		$5.b_false = $<for_loop>$.next;
	}
	EXPRESSION semicolon
	{
		writeCode($<for_loop>$.temp);
		labels.push(newLabel());
	}
	STATEMENT semicolon 
	{
		writeCode($7.next);
		writeCode("goto "+$<for_loop>$.begin);
	}
	right_bracket left_curly
	{
		writeCode($7.b_true);
	}
	STATEMENT_LIST
	{
			writeCode("goto "$<for_loop>$.temp);
	}
	right_curly
	;
SYSTEM_PRINT :
	system_out left_bracket EXPRESSION right_bracket
	{
		if($3.sType == int_type){
			
			
		}else if($3.sType == float_type){
			
			
		}else{
			yyerror("can't recognize what to print");
		}
	}
	;
 EXPRESSION :
	SIMPLE_EXPRESSION
	EXPRESSION_
	;
 EXPRESSION_ : 
	epson 
	|
	relop
	SIMPLE_EXPRESSION
	;
 SIMPLE_EXPRESSION : 
	TERM 
	{
		$<expr>$.expval = newVariable();
		symbol_table[$<expr>$.expval].second = symbol_table[$1.tempval].second;
		if($1.sType == int_type){
			writeCode("iload "+to_string(symbol_table[$1.tempval].first));
			writeCode("isotre "+to_string(symbol_table[$<expr>$.expval].first));
		}else if($1.sType == float_type){
			writeCode("fload "+to_string(symbol_table[$1.tempval].first));
			writeCode("fsotre "+to_string(symbol_table[$<expr>$.expval].first));
		}
		labels.push($<expr>$.expval);
	}
	SIMPLE_EXPRESSION_ 
	|
	SIGN_TYPE
	TERM
	{
		$<expr>$.expval = newVariable();
		symbol_table[$<expr>$.expval].second = $2.sType;
		if($2.sType == int_type){
			writeCode("iload "+to_string(symbol_table[$2.tempval].first));
			if($1.sign == '-'){
				writeCode("ineg");
			}
			writeCode("isotre "+to_string(symbol_table[$<expr>$.expval].first));
		}else if($2.sType == float_type){
			writeCode("fload "+to_string(symbol_table[$2.tempval].first));
			if($1.sign == '-'){
				writeCode("fneg");
			}
			writeCode("fsotre "+to_string(symbol_table[$<expr>$.expval].first));
		}
		labels.push($<expr>$.expval);
	}
	SIMPLE_EXPRESSION_ 
	;
 SIMPLE_EXPRESSION_ :
	{
		$<expr>$.expval = labels.top();
		labels.pop();
	}
	addop
	TERM
	{
		if(symbol_table[$<expr>$.expval].second == int_type && symbol_table[$3.tempval].second == int_type){
			writeCode("iload "+to_string(symbol_table[$<expr>$.expval].first));
			writeCode("iload "+to_string(symbol_table[$3.tempval].first));
			writeCode(create_addop_inst($2,int_type));
			writeCode("istore "+to_string(symbol_table[$<expr>$.expval].first));
		}else if(symbol_table[$<expr>$.expval].second == int_type && symbol_table[$3.tempval].second == float_type){
			writeCode("iload "+to_string(symbol_table[$<expr>$.expval].first));
			symbol_table[$<expr>$.expval].second = float_type;
			writeCode("i2f");
			writeCode("fload "+to_string(symbol_table[$3.tempval].first));
			writeCode(create_addop_inst($2,float_type));
			writeCode("fstore "+to_string(symbol_table[$<expr>$.expval].first));
		}else if(symbol_table[$<expr>$.expval].second == float_type && symbol_table[$3.tempval].second == int_type){
			writeCode("fload "+to_string(symbol_table[$<expr>$.expval].first));
			writeCode("iload "+to_string(symbol_table[$3.tempval].first));
			writeCode("i2f");
			writeCode(create_addop_inst($2,float_type));
			writeCode("fstore "+to_string(symbol_table[$<expr>$.expval].first));
		}else if(symbol_table[$<expr>$.expval].second == float_type && symbol_table[$3.tempval].second == float_type){
			writeCode("fload "+to_string(symbol_table[$<expr>$.expval].first));
			writeCode("fload "+to_string(symbol_table[$3.tempval].first));
			writeCode(create_addop_inst($2,float_type));
			writeCode("fstore "+to_string(symbol_table[$<expr>$.expval].first));
		}else{
			yyerror("error while casting");
		}
		labels.push($<expr>$.expval);
	}	
	SIMPLE_EXPRESSION_ 
	|
	{
		$<expr>$.expval = labels.top();
		labels.pop();
	}
	epson
	;
 TERM :
	FACTOR
	{
		$<tempval>$.tempval = newVariable();
		symbol_table[$<tempval>$.tempval].second = $1.sType;
		if($1.sType == int_type){
			writeCode("iload "+to_string(symbol_table[$1.idval].first));
			writeCode("isotre "+to_string(symbol_table[$<tempval>$.tempval].first));
		}else if($1.sType == float_type){
			writeCode("fload "+to_string(symbol_table[$1.idval].first));
			writeCode("fsotre "+to_string(symbol_table[$<tempval>$.tempval].first));
		}
		labels.push($<tempval>$.tempval);
	}	
	TERM_
	;
 TERM_ :
	{
		$<tempval>$.tempval = labels.top();
		labels.pop();
	}
	mulop
	FACTOR
	{
		
		if(symbol_table[$<tempval>$.tempval].second == int_type && $3.sType == int_type){
			writeCode("iload "+to_string(symbol_table[$<tempval>$.tempval].first));
			writeCode("iload "+to_string(symbol_table[$3.idval].first));
			writeCode(create_mulop_inst($2,int_type));
			writeCode("istore "+to_string(symbol_table[$<tempval>$.tempval].first));
		}else if(symbol_table[$<tempval>$.tempval].second == int_type && $3.sType == float_type){
			writeCode("iload "+to_string(symbol_table[$<tempval>$.tempval].first));
			symbol_table[$<tempval>$.tempval].second = float_type;
			writeCode("i2f");
			writeCode("fload "+to_string(symbol_table[$3.idval].first));
			writeCode(create_mulop_inst($2,float_type));
			writeCode("fstore "+to_string(symbol_table[$<tempval>$.tempval].first));
		}else if(symbol_table[$<tempval>$.tempval].second == float_type && $3.sType == int_type){
			writeCode("fload "+to_string(symbol_table[$<tempval>$.tempval].first));
			writeCode("iload "+to_string(symbol_table[$3.idval].first));
			writeCode("i2f");
			writeCode(create_mulop_inst($2,float_type));
			writeCode("fstore "+to_string(symbol_table[$<tempval>$.tempval].first));
		}else if(symbol_table[$<tempval>$.tempval].second == float_type && $3.sType == float_type){
			writeCode("fload "+to_string(symbol_table[$<tempval>$.tempval].first));
			writeCode("fload "+to_string(symbol_table[$3.idval].first));
			writeCode(create_mulop_inst($2,float_type));
			writeCode("fstore "+to_string(symbol_table[$<tempval>$.tempval].first));
		}else{
			yyerror("error while casting");
		}
		labels.push($<tempval>$.tempval);
	}
	TERM_ 
	|
	{
		$<tempval>$.tempval = labels.top();
		labels.pop();
	}
	epson
	;
 FACTOR :
	id_word
	{
		$$.idval = $1;
		$$.sType = symbol_table[$1].second;
	}
	|
	int_word
	{
		$$.sType = int_type;
		writeCode("ldc " + std::to_string($1));
		$$.idval = newVariable();
		symbol_table[$$.idval].second = int_type;
		writeCode("istore " + std::to_string(symbol_table[$$.idval].first));
		
	}
	|
	float_word
	{
		$$.sType = float_type;
		writeCode("ldc " + std::to_string($1));
		$$.idval = newVariable();
		symbol_table[$$.idval].second = float_type;
		writeCode("istore " + std::to_string(symbol_table[$$.idval].first));
	}
	|
	left_bracket EXPRESSION right_bracket
	{
		$$.sType = $2.sType;
		$$.idval = $2.expval;
	}
	;
 
 SIGN_TYPE :
	addop
	{
		$$.sign = $1;
	}
	;
 epson:
	;
	

%%
main (int argv, char * argc[])
{
	FILE *myfile;
	if(argv == 1) 
	{
		myfile = fopen("input.txt", "r");
	}
	else 
	{
		myfile = fopen(argc[1], "r");
		outfileName = string(argc[1]);
	}
	outfileName = fopen("input.txt", "w");;
	if (!myfile) {
		printf("I can't open input code file!\n");
		return -1;
	}
	yyin = myfile;
	yyparse();
}


string newVariable(){
//set new variable and add its counter
	string temp = "V_"+ to_string(add_counter);
	symbol_table[temp] = make_pair(add_counter,error_type);
	add_counter++;
}

void yyerror(string s){
		printf(s);
}
string newLabel(){
	return "L_"+std::to_string(add_counter++);
}
void writeCode(string s){
	fout<<s<<endl;
}

string create_mulop_inst(char mulop, type_enum t){
	if(mulop == '*'){
		if(t == int_type){
			return "imul";
		}else{
			return "fmul";
		}
	}else if (mulop == '/'){
		if(t == int_type){
			return "idiv";
		}else{
			return "fdiv";
		}
	}else{
		yyerror("not mulop in multiply operation");
	}
}
string create_addop_inst(char addop, type_enum t){
	if(addop == '+'){
		if(t == int_type){
			return "iadd";
		}else{
			return "fadd";
		}
	}else if (addop == '-'){
		if(t == int_type){
			return "isub";
		}else{
			return "fsub";
		}
	}else{
		yyerror("not addop in add operation");
	}
}
