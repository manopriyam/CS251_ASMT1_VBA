%{ 
/* Definition section */
    #include<stdio.h> 
    #include<stdlib.h>  
    #include<string.h>
    int flag=0; 
    extern FILE *yyin;
    extern int yylineno;
    extern char* yytext;

    #include<ctype.h>
    int count=0;
    int q;
    char type[20];

    struct node { 
        struct node *left; 
        struct node *right; 
        char *token; 
    }; 

    struct node* mknode (struct node *left, struct node *right, char *token); 

    void printtree(struct node*); 
    void printInorder(struct node *); 
    
    struct node *head;
    
    struct dataType {
        char * id_name;
        char * data_type;
        char * type;
        int line_no;
    } symbolTable[40];

    void add(char, char *);
    void insert_type();
    int search(char *);

    int ic_idx = 0;
    int temp_var = 0; 
    int label=0;
    
	int isIf=0;
    char icg[100][100];
%}


%union {
	struct var_name { 
		char* name; 
		struct node* nd;
	} nd_obj; 
	
	struct var_name3 {
        char name[100];
        struct node* nd;
        char if_body[10];
        char else_body[10];  
	} nd_obj3;
}; 

%start program

%token <nd_obj> COMMENT STRING_LITERAL OBJECT OBJECT_BLOCK DATATYPE

%token <nd_obj> T_DO_WHILE T_DO_UNTIL T_END_IF T_ELSE_IF T_IF T_THEN T_ELSE T_SELECT_CASE T_END_SELECT T_CASE_ELSE T_CASE T_EXIT_FOR T_FOR_EACH T_FOR T_TO T_STEP T_NEXT T_EXIT_DO T_DO T_LOOP T_WHILE T_UNTIL T_WEND T_END_WITH T_WITH T_ON_ERROR T_ON T_GOTO T_GO_SUB T_RETURN T_IN

%token <nd_obj> T_AS T_APP_ACTIVATE T_BEEP T_CALL T_CHDIR T_CHDRIVE T_CLOSE T_CONST T_DECLARE T_DELETE_SETTING T_DIM T_ERASE T_ERROR T_EVENT T_FILE_COPY T_FUNCTION T_IMPLEMENTS T_KILL T_LET T_LOAD T_UNLOAD T_LOCK T_UNLOCK T_LSET T_MKDIR T_NAME T_OPEN T_LINE_INPUT T_INPUT T_OPTION_BASE T_OPTION_COMPARE T_OPTION_PRIVATE T_OPTION_PRIVATE_MODULE T_OPTION_EXPLICIT T_PROPERTY_GET T_PROPERTY_LET T_PROPERTY_SET T_PROPERTY T_PRINT T_PRIVATE T_PUBLIC T_PUT T_RAISE_EVENT T_RANDOMIZE T_REDIM T_RESET T_RESUME T_RMDIR T_RSET T_SAVE_SETTING T_SEEK T_SEND_KEYS T_SET T_SET_ATTR T_STATIC T_STOP T_SUB T_TIME T_TYPE T_WIDTH T_WRITE T_ENUM T_END T_EXIT T_BY_VAL T_BY_REF T_NEW T_MSG_BOX 

%token <nd_obj> T_POWER T_MULTIPLY T_DIVIDE T_BACKSLASH T_MOD T_PLUS T_MINUS T_CONCATENATE T_EQUAL T_NOT_EQUAL T_LESS_EQUAL T_GREATER_EQUAL T_LESS_THAN T_GREATER_THAN T_IS T_LIKE T_NOT T_AND T_OR T_XOR T_EQV T_IMP

%token <nd_obj> NUMERIC_LITERAL 
%token <nd_obj> FLOAT_LITERAL 
%token <nd_obj> IDENTIFIER PARENTHESIS SEPARATOR

%type <nd_obj> program statements statement vartype declare declaration redeclaration value assignment printvalues printing conditionalifelse ifblock elseifs elseifblock elseblock

%type <nd_obj3> expression

%left T_IMP T_EQV
%left T_XOR
%left T_OR
%left T_AND
%left T_NOT
%left T_NOT_EQUAL T_LESS_EQUAL T_GREATER_EQUAL T_LESS_THAN T_GREATER_THAN T_IS T_LIKE
%left T_CONCATENATE
%right T_PLUS T_MINUS
%left T_MULTIPLY T_DIVIDE T_BACKSLASH T_MOD
%right T_POWER
%left T_EQUAL

%left '_' ':' ';' '.' '(' ')'

%nonassoc NEXT


/* Rule Section */
%% 


program : statements { $$.nd = $1.nd; head = $$.nd; }

statements : statement        { $$.nd = $1.nd; }
    | statements statement    { $$.nd = mknode($1.nd, $2.nd, "statements"); }
    | statements '_'          { $$.nd = $1.nd; }
    | statements ':'          { $$.nd = $1.nd; }
    | statements ';'          { $$.nd = $1.nd; }

statement : declaration               { printf("\nStatement : Declaration"); $$.nd = $1.nd; }	
    | redeclaration                   { printf("\nStatement : Re-Declaration"); $$.nd = $1.nd; }
    | assignment                      { printf("\nStatement : Assignment"); $$.nd = $1.nd; }	
    | printing                        { printf("\nStatement : Printing"); $$.nd = $1.nd; }
    /* | subblock                        { printf("\nBlock : Sub Procedure"); } */
    /* | functionblock                   { printf("\nBlock : Function Procedure"); } */
    /* | propertygetblock                { printf("\nBlock : Property Get Procedure"); } */
    /* | propertysetblock                { printf("\nBlock : Property Set Procedure"); } */
    /* | propertyletblock                { printf("\nBlock : Property Let Procedure"); } */
    /* | typeblock                       { printf("\nBlock : Type Procedure"); } */
    /* | withblock                       { printf("\nBlock : With Procedure"); } */
    | conditionalifelse               { printf("\nBlock : Conditional If-ElseIf-Then"); $$.nd = $1.nd; }
    /* | conditionalselectcase           { printf("\nBlock : Conditional Select-Case"); } */
    /* | forloop                         { printf("\nBlock : For Loop"); } */
    /* | foreachloop                     { printf("\nBlock : For Each Loop"); } */
    /* | whileloop                       { printf("\nBlock : While Loop"); } */
    /* | doWhileloop                     { printf("\nBlock : Do While Loop"); } */
    /* | doUntilloop                     { printf("\nBlock : Do Until Loop"); } */
    /* | exit_statement                  { printf("\nStatement : Exit Statement"); } */
    /* | pvtpubdeclaration               { printf("\nStatement : Private/Public Declaration"); } */
    /* | pvtpubsubblock                  { printf("\nBlock : Private/Public Sub Procedure"); } */
    /* | pvtpubfunctionblock             { printf("\nBlock : Private/Public Function Procedure"); } */
    /* | pvtpubpropgetblock              { printf("\nBlock : Private/Public Property Get Procedure"); } */
    /* | pvtpubpropsetblock              { printf("\nBlock : Private/Public Property Set Procedure"); } */
    /* | pvtpubpropletblock              { printf("\nBlock : Private/Public Property Let Procedure"); } */
    | COMMENT                         { printf("\nStatement : Comment"); $$.nd = mknode(NULL, NULL, "COMMENT"); }

vartype : T_AS  DATATYPE { 
        insert_type(); 
        $1.nd = mknode(NULL, NULL, $1.name); 
        $2.nd = mknode(NULL, NULL, $2.name); 
        $$.nd = mknode($1.nd, $2.nd, "vartype"); 
    }
	/* | T_AS IDENTIFIER			 */
    | /* empty */

declare : IDENTIFIER vartype { 
        $1.nd = mknode(NULL, NULL, $1.name); 
        $$.nd = mknode($1.nd, $2.nd, "declareSingle"); 
        //sprintf(icg[ic_idx++], "%s =", $1.name);
    }		
    | declare ',' IDENTIFIER vartype { 
        $3.nd = mknode(NULL, NULL, $3.name);
        $$.nd = mknode($1.nd, mknode($3.nd, $4.nd, "declareSingle"), "declareMultiple"); 
        //sprintf(icg[ic_idx++], "%s =", $3.name);
    }
    /* | IDENTIFIER '(' NUMERIC_LITERAL T_TO NUMERIC_LITERAL ')' vartype   */

declaration : T_DIM declare { 
        $1.nd = mknode(NULL, NULL, $1.name); 
        $$.nd = mknode($1.nd, $2.nd, "declaration"); 
    }

redeclaration : T_REDIM declare { 
        $1.nd = mknode(NULL, NULL, $1.name); 
        $$.nd = mknode($1.nd, $2.nd, "redeclaration"); 
    }

value : IDENTIFIER         { add('V', ""); $$.nd = mknode(NULL, NULL, $1.name); }
    | STRING_LITERAL       { add('C', "String"); $$.nd = mknode(NULL, NULL, $1.name); }
    | NUMERIC_LITERAL      { add('C', "Integer"); $$.nd = mknode(NULL, NULL, $1.name); }
    | FLOAT_LITERAL        { add('C', "Double"); $$.nd = mknode(NULL, NULL, $1.name); }
/*
numbers : IDENTIFIER       { add('C'); $$.nd = mknode(NULL, NULL, $1.name); }
    | NUMERIC_LITERAL      { add('C'); $$.nd = mknode(NULL, NULL, "NUMBER"); }
    | FLOAT_LITERAL        { add('C'); $$.nd = mknode(NULL, NULL, "FLOATING_NUMBER"); }
*/
expression : expression T_PLUS expression { 
        $$.nd = mknode($1.nd, $3.nd, $2.name); 
        sprintf($$.name, "t%d", temp_var);
        temp_var++;
        sprintf(icg[ic_idx++], "%s = %s %s %s\n",  $$.name, $1.name, $2.name, $3.name);
    } 
    | expression T_MINUS expression { 
        $$.nd = mknode($1.nd, $3.nd, $2.name); 
        sprintf($$.name, "t%d", temp_var);
        temp_var++;
        sprintf(icg[ic_idx++], "%s = %s %s %s\n",  $$.name, $1.name, $2.name, $3.name);
    } 
    | expression T_MULTIPLY expression  { 
        $$.nd = mknode($1.nd, $3.nd, $2.name); 
        sprintf($$.name, "t%d", temp_var);
        temp_var++;
        sprintf(icg[ic_idx++], "%s = %s %s %s\n",  $$.name, $1.name, $2.name, $3.name);
    } 
    | expression T_DIVIDE expression { 
        $$.nd = mknode($1.nd, $3.nd, $2.name); 
        sprintf($$.name, "t%d", temp_var);
        temp_var++;
        sprintf(icg[ic_idx++], "%s = %s %s %s\n",  $$.name, $1.name, $2.name, $3.name);
    } 
    | expression T_BACKSLASH expression { 
        $$.nd = mknode($1.nd, $3.nd, $2.name); 
        sprintf($$.name, "t%d", temp_var);
        temp_var++;
        sprintf(icg[ic_idx++], "%s = %s %s %s\n",  $$.name, $1.name, $2.name, $3.name);
    } 
    | expression T_MOD expression { 
        $$.nd = mknode($1.nd, $3.nd, $2.name); 
        sprintf($$.name, "t%d", temp_var);
        temp_var++;
        sprintf(icg[ic_idx++], "%s = %s %s %s\n",  $$.name, $1.name, $2.name, $3.name);
    } 
    | expression T_POWER expression { 
        $$.nd = mknode($1.nd, $3.nd, $2.name); 
        sprintf($$.name, "t%d", temp_var);
        temp_var++;
        sprintf(icg[ic_idx++], "%s = %s %s %s\n",  $$.name, $1.name, $2.name, $3.name);
    } 
    | expression T_CONCATENATE expression { 
        $$.nd = mknode($1.nd, $3.nd, $2.name); 
        sprintf($$.name, "t%d", temp_var);
        temp_var++;
        sprintf(icg[ic_idx++], "%s = %s %s %s\n",  $$.name, $1.name, $2.name, $3.name);
    } 
    | expression T_EQUAL expression {  
        $$.nd = mknode($1.nd, $3.nd, $2.name); 
        
        if(isIf==0){
			sprintf(icg[ic_idx++], "\tif %s %s %s goto label%d\n", $1.name, $2.name, $3.name, label);
			sprintf(icg[ic_idx++], "\tt%d = 0\n", temp_var);
			
			sprintf($$.name, "t%d", temp_var);
			
			sprintf(icg[ic_idx++], "\tgoto label%d\n", label+1);
			
			sprintf(icg[ic_idx++], "label%d:\n\tt%d = 1\n",label, temp_var++);
			
			sprintf(icg[ic_idx++], "label%d: \n", label+1);
			label+=2;
    }
    else{
			sprintf($$.name, "%s %s %s", $1.name, $2.name, $3.name);
			sprintf($$.if_body, "%d", label++);
			sprintf($$.else_body, "%d", label++);
		}
    }
    | expression T_NOT_EQUAL expression {  
        $$.nd = mknode($1.nd, $3.nd, $2.name); 
        
        if(isIf==0){
			sprintf(icg[ic_idx++], "\tif %s %s %s goto label%d\n", $1.name, $2.name, $3.name, label);
			sprintf(icg[ic_idx++], "\tt%d = 0\n", temp_var);
			
			sprintf($$.name, "t%d", temp_var);
			
			sprintf(icg[ic_idx++], "\tgoto label%d\n", label+1);
			
			sprintf(icg[ic_idx++], "label%d:\n\tt%d = 1\n",label, temp_var++);
			
			sprintf(icg[ic_idx++], "label%d: \n", label+1);
			label+=2;
    }
    else{
			sprintf($$.name, "%s %s %s", $1.name, $2.name, $3.name);
			sprintf($$.if_body, "%d", label++);
			sprintf($$.else_body, "%d", label++);
		}
    }
    | expression T_LESS_EQUAL expression {  
        $$.nd = mknode($1.nd, $3.nd, $2.name); 
        
        if(isIf==0){
			sprintf(icg[ic_idx++], "\tif %s %s %s goto label%d\n", $1.name, $2.name, $3.name, label);
			sprintf(icg[ic_idx++], "\tt%d = 0\n", temp_var);
			
			sprintf($$.name, "t%d", temp_var);
			
			sprintf(icg[ic_idx++], "\tgoto label%d\n", label+1);
			
			sprintf(icg[ic_idx++], "label%d:\n\tt%d = 1\n",label, temp_var++);
			
			sprintf(icg[ic_idx++], "label%d: \n", label+1);
			label+=2;
    }
    else{
			sprintf($$.name, "%s %s %s", $1.name, $2.name, $3.name);
			sprintf($$.if_body, "%d", label++);
			sprintf($$.else_body, "%d", label++);
		}
    }
    | expression T_GREATER_EQUAL expression {  
        $$.nd = mknode($1.nd, $3.nd, $2.name); 
        
        if(isIf==0){
			sprintf(icg[ic_idx++], "\tif %s %s %s goto label%d\n", $1.name, $2.name, $3.name, label);
			sprintf(icg[ic_idx++], "\tt%d = 0\n", temp_var);
			
			sprintf($$.name, "t%d", temp_var);
			
			sprintf(icg[ic_idx++], "\tgoto label%d\n", label+1);
			
			sprintf(icg[ic_idx++], "label%d:\n\tt%d = 1\n",label, temp_var++);
			
			sprintf(icg[ic_idx++], "label%d: \n", label+1);
			label+=2;
    }
    else{
			sprintf($$.name, "%s %s %s", $1.name, $2.name, $3.name);
			sprintf($$.if_body, "%d", label++);
			sprintf($$.else_body, "%d", label++);
		}
    }
    | expression T_LESS_THAN expression {  
        $$.nd = mknode($1.nd, $3.nd, $2.name); 
        
        if(isIf==0){
			sprintf(icg[ic_idx++], "\tif %s %s %s goto label%d\n", $1.name, $2.name, $3.name, label);
			sprintf(icg[ic_idx++], "\tt%d = 0\n", temp_var);
			
			sprintf($$.name, "t%d", temp_var);
			
			sprintf(icg[ic_idx++], "\tgoto label%d\n", label+1);
			
			sprintf(icg[ic_idx++], "label%d:\n\tt%d = 1\n",label, temp_var++);
			
			sprintf(icg[ic_idx++], "label%d: \n", label+1);
			label+=2;
    }
    else{
			sprintf($$.name, "%s %s %s", $1.name, $2.name, $3.name);
			sprintf($$.if_body, "%d", label++);
			sprintf($$.else_body, "%d", label++);
		}
    }
    | expression T_GREATER_THAN expression {  
        $$.nd = mknode($1.nd, $3.nd, $2.name); 
        
        if(isIf==0){
			sprintf(icg[ic_idx++], "\tif %s %s %s goto label%d\n", $1.name, $2.name, $3.name, label);
			sprintf(icg[ic_idx++], "\tt%d = 0\n", temp_var);
			
			sprintf($$.name, "t%d", temp_var);
			
			sprintf(icg[ic_idx++], "\tgoto label%d\n", label+1);
			
			sprintf(icg[ic_idx++], "label%d:\n\tt%d = 1\n",label, temp_var++);
			
			sprintf(icg[ic_idx++], "label%d: \n", label+1);
			label+=2;
    }
    else{
			sprintf($$.name, "%s %s %s", $1.name, $2.name, $3.name);
			sprintf($$.if_body, "%d", label++);
			sprintf($$.else_body, "%d", label++);
		}
    }
    | expression T_IS expression {  
        $$.nd = mknode($1.nd, $3.nd, $2.name); 
        
        if(isIf==0){
			sprintf(icg[ic_idx++], "\tif %s %s %s goto label%d\n", $1.name, $2.name, $3.name, label);
			sprintf(icg[ic_idx++], "\tt%d = 0\n", temp_var);
			
			sprintf($$.name, "t%d", temp_var);
			
			sprintf(icg[ic_idx++], "\tgoto label%d\n", label+1);
			
			sprintf(icg[ic_idx++], "label%d:\n\tt%d = 1\n",label, temp_var++);
			
			sprintf(icg[ic_idx++], "label%d: \n", label+1);
			label+=2;
    }
    else{
			sprintf($$.name, "%s %s %s", $1.name, $2.name, $3.name);
			sprintf($$.if_body, "%d", label++);
			sprintf($$.else_body, "%d", label++);
		}
    }
    | expression T_LIKE expression {  
        $$.nd = mknode($1.nd, $3.nd, $2.name); 
        
        if(isIf==0){
			sprintf(icg[ic_idx++], "\tif %s %s %s goto label%d\n", $1.name, $2.name, $3.name, label);
			sprintf(icg[ic_idx++], "\tt%d = 0\n", temp_var);
			
			sprintf($$.name, "t%d", temp_var);
			
			sprintf(icg[ic_idx++], "\tgoto label%d\n", label+1);
			
			sprintf(icg[ic_idx++], "label%d:\n\tt%d = 1\n",label, temp_var++);
			
			sprintf(icg[ic_idx++], "label%d: \n", label+1);
			label+=2;
    }
    else{
			sprintf($$.name, "%s %s %s", $1.name, $2.name, $3.name);
			sprintf($$.if_body, "%d", label++);
			sprintf($$.else_body, "%d", label++);
		}
    }
    | expression T_NOT expression   {  
        $$.nd = mknode($1.nd, $3.nd, $2.name); 
        
        if(isIf==0){
			sprintf(icg[ic_idx++], "\tif %s %s %s goto label%d\n", $1.name, $2.name, $3.name, label);
			sprintf(icg[ic_idx++], "\tt%d = 0\n", temp_var);
			
			sprintf($$.name, "t%d", temp_var);
			
			sprintf(icg[ic_idx++], "\tgoto label%d\n", label+1);
			
			sprintf(icg[ic_idx++], "label%d:\n\tt%d = 1\n",label, temp_var++);
			
			sprintf(icg[ic_idx++], "label%d: \n", label+1);
			label+=2;
    }
    else{
			sprintf($$.name, "%s %s %s", $1.name, $2.name, $3.name);
			sprintf($$.if_body, "%d", label++);
			sprintf($$.else_body, "%d", label++);
		}
    }
    | expression T_AND expression {  
        $$.nd = mknode($1.nd, $3.nd, $2.name); 
        
        if(isIf==0){
			sprintf(icg[ic_idx++], "\tif %s %s %s goto label%d\n", $1.name, $2.name, $3.name, label);
			sprintf(icg[ic_idx++], "\tt%d = 0\n", temp_var);
			
			sprintf($$.name, "t%d", temp_var);
			
			sprintf(icg[ic_idx++], "\tgoto label%d\n", label+1);
			
			sprintf(icg[ic_idx++], "label%d:\n\tt%d = 1\n",label, temp_var++);
			
			sprintf(icg[ic_idx++], "label%d: \n", label+1);
			label+=2;
    }
    else{
			sprintf($$.name, "%s %s %s", $1.name, $2.name, $3.name);
			sprintf($$.if_body, "%d", label++);
			sprintf($$.else_body, "%d", label++);
		}
    }
    | expression T_OR expression {  
        $$.nd = mknode($1.nd, $3.nd, $2.name); 
        
        if(isIf==0){
			sprintf(icg[ic_idx++], "\tif %s %s %s goto label%d\n", $1.name, $2.name, $3.name, label);
			sprintf(icg[ic_idx++], "\tt%d = 0\n", temp_var);
			
			sprintf($$.name, "t%d", temp_var);
			
			sprintf(icg[ic_idx++], "\tgoto label%d\n", label+1);
			
			sprintf(icg[ic_idx++], "label%d:\n\tt%d = 1\n",label, temp_var++);
			
			sprintf(icg[ic_idx++], "label%d: \n", label+1);
			label+=2;
    }
    else{
			sprintf($$.name, "%s %s %s", $1.name, $2.name, $3.name);
			sprintf($$.if_body, "%d", label++);
			sprintf($$.else_body, "%d", label++);
		}
    }
    | expression T_XOR expression  {  
        $$.nd = mknode($1.nd, $3.nd, $2.name); 
        
        if(isIf==0){
			sprintf(icg[ic_idx++], "\tif %s %s %s goto label%d\n", $1.name, $2.name, $3.name, label);
			sprintf(icg[ic_idx++], "\tt%d = 0\n", temp_var);
			
			sprintf($$.name, "t%d", temp_var);
			
			sprintf(icg[ic_idx++], "\tgoto label%d\n", label+1);
			
			sprintf(icg[ic_idx++], "label%d:\n\tt%d = 1\n",label, temp_var++);
			
			sprintf(icg[ic_idx++], "label%d: \n", label+1);
			label+=2;
    }
    else{
			sprintf($$.name, "%s %s %s", $1.name, $2.name, $3.name);
			sprintf($$.if_body, "%d", label++);
			sprintf($$.else_body, "%d", label++);
		}
    }
    | expression T_EQV expression   {  
        $$.nd = mknode($1.nd, $3.nd, $2.name); 
        
        if(isIf==0){
			sprintf(icg[ic_idx++], "\tif %s %s %s goto label%d\n", $1.name, $2.name, $3.name, label);
			sprintf(icg[ic_idx++], "\tt%d = 0\n", temp_var);
			
			sprintf($$.name, "t%d", temp_var);
			
			sprintf(icg[ic_idx++], "\tgoto label%d\n", label+1);
			
			sprintf(icg[ic_idx++], "label%d:\n\tt%d = 1\n",label, temp_var++);
			
			sprintf(icg[ic_idx++], "label%d: \n", label+1);
			label+=2;
    }
    else{
			sprintf($$.name, "%s %s %s", $1.name, $2.name, $3.name);
			sprintf($$.if_body, "%d", label++);
			sprintf($$.else_body, "%d", label++);
		}
    }
    | expression T_IMP expression  {  
        $$.nd = mknode($1.nd, $3.nd, $2.name); 
        
        if(isIf==0){
			sprintf(icg[ic_idx++], "\tif %s %s %s goto label%d\n", $1.name, $2.name, $3.name, label);
			sprintf(icg[ic_idx++], "\tt%d = 0\n", temp_var);
			
			sprintf($$.name, "t%d", temp_var);
			
			sprintf(icg[ic_idx++], "\tgoto label%d\n", label+1);
			
			sprintf(icg[ic_idx++], "label%d:\n\tt%d = 1\n",label, temp_var++);
			
			sprintf(icg[ic_idx++], "label%d: \n", label+1);
			label+=2;
    }
    else{
			sprintf($$.name, "%s %s %s", $1.name, $2.name, $3.name);
			sprintf($$.if_body, "%d", label++);
			sprintf($$.else_body, "%d", label++);
		}
    }
    | '(' expression ')'                                { $$.nd = $2.nd; strcpy($$.name, $2.name);}
    | value                                             { $$.nd = $1.nd; strcpy($$.name, $1.name);}
    /* | objectblock */

assignment : IDENTIFIER T_EQUAL expression { 
        $1.nd = mknode(NULL, NULL, $1.name); 
        $$.nd = mknode($1.nd, $3.nd, $2.name); 
        sprintf(icg[ic_idx++], "%s = %s\n",  $$.name, $3.name);
    }
	/* | objectblock T_EQUAL expression    */
    | T_SET assignment                     { $1.nd = mknode(NULL, NULL, $1.name); $$.nd = mknode($1.nd, $2.nd, $1.name); }
    | T_LET assignment                     { $1.nd = mknode(NULL, NULL, $1.name); $$.nd = mknode($1.nd, $2.nd, $1.name); }
/*
objectblock : object 

object : object '.' obj 
    | obj
    | object '.' IDENTIFIER
    | IDENTIFIER '.' object 

obj : IDENTIFIER '(' valuecomma ')' 
    | OBJECT_BLOCK '(' valuecomma ')'
    | OBJECT_BLOCK
    | OBJECT '(' valuecomma ')'
    | OBJECT

valuecomma : value
    | valuecomma ',' value
*/
printvalues : T_CONCATENATE value printvalues {
        $$.nd = mknode($2.nd, $3.nd, $1.name);
    }
    | T_CONCATENATE value {
        $$.nd = mknode($2.nd, NULL, $1.name);
    }

printing : T_MSG_BOX STRING_LITERAL {
        $2.nd = mknode(NULL, NULL, $2.name);
        $$.nd = mknode($2.nd, NULL, "printing");
    }
    | T_MSG_BOX STRING_LITERAL printvalues {
        $2.nd = mknode(NULL, NULL, $2.name);
        $$.nd = mknode($2.nd, $3.nd, "printing");
    }
/*
paramdeclare : declare 
    | // empty 

subblock : T_SUB IDENTIFIER '(' paramdeclare ')' statements T_END T_SUB
    
functionblock : T_FUNCTION IDENTIFIER '(' paramdeclare ')' vartype statements T_END T_FUNCTION 

propertygetblock : T_PROPERTY_GET IDENTIFIER '(' paramdeclare ')' vartype statements T_END T_PROPERTY 

propertysetblock : T_PROPERTY_SET IDENTIFIER '(' paramdeclare ')' vartype statements T_END T_PROPERTY 

propertyletblock : T_PROPERTY_LET IDENTIFIER '(' paramdeclare ')' vartype statements T_END T_PROPERTY 

typeblock : T_TYPE IDENTIFIER type_declaration T_END T_TYPE 
    | T_TYPE IDENTIFIER COMMENT type_declaration T_END T_TYPE 

type_declaration : type_block 
    | type_declaration type_block

type_block : type_dec_value T_AS data_type 
    | type_dec_value T_AS data_type COMMENT 

data_type  : DATATYPE 
    | DATATYPE T_MULTIPLY expression

type_dec_value : IDENTIFIER 
    | IDENTIFIER '(' NUMERIC_LITERAL T_TO NUMERIC_LITERAL ')'

withblock : T_WITH IDENTIFIER statements T_END_WITH 
    | T_WITH objectblock statements T_END_WITH 
*/


conditionalifelse : {isIf=1;} ifblock elseifs elseblock T_END_IF {

        /* Actions for handling the IF-ELSE statement */
        if ($3.nd == NULL && $4.nd == NULL) {
            	$$.nd = $2.nd;
		//sprintf(icg[ic_idx++], "\nLABEL %s:\n", $4.if_body);
        } else if ($3.nd != NULL && $4.nd == NULL) {
            /* IF-ELSEIF blocks only */
            $$.nd = mknode($2.nd, $3.nd, "if-elseif");
           
        } else if ($3.nd != NULL && $4.nd != NULL) {
            /* IF-ELSEIF-ELSE blocks */
            $$.nd = mknode(mknode($2.nd, $3.nd, "if-elseif2"), $4.nd, "if-elseif-else");
        }
        else if ($3.nd == NULL && $4.nd != NULL) {
            /* IF-ELSE blocks */
            $$.nd = mknode($2.nd, $4.nd, "if-else");
        }
        
        isIf=0;
    }

ifblock : T_IF expression
	{
	sprintf(icg[ic_idx++], "\tif %s goto label%s\n\tgoto label%s\n", $2.name, $2.if_body, $2.else_body);
	sprintf(icg[ic_idx++],"label%s:\n", $2.if_body);
	}
	
	T_THEN statements {
	sprintf(icg[ic_idx++],"label%s:\n", $2.else_body);
	}
	
		{
        $$.nd = mknode($2.nd, $5.nd, "if-block");
    }

elseifs : elseifs elseifblock {
        if ($1.nd != NULL) {
            $$.nd = mknode($1.nd, $2.nd, "else-if-blocks");
        }
        else if ($1.nd == NULL) {  
            $$.nd = mknode(NULL, $2.nd, "else-if-blocks2");
        }
    }
    | /* empty */ { $$.nd = NULL; }

elseifblock : T_ELSE_IF expression {
	sprintf(icg[ic_idx++], "\tif %s goto label%s\n\tgoto label%s\n", $2.name, $2.if_body, $2.else_body);
	sprintf(icg[ic_idx++],"label%s:\n", $2.if_body);}
	T_THEN statements {
	sprintf(icg[ic_idx++],"label%s:\n", $2.else_body);
	}

elseblock : T_ELSE statements {
        $$.nd = mknode($2.nd, NULL, "else-block");
    }
    | /* empty */ { $$.nd = NULL; }
 
/*
conditionalselectcase : T_SELECT_CASE IDENTIFIER cases elsecase T_END_SELECT 

cases : cases caseblock 
    | // empty 

caseblock : T_CASE caseexprs statements

elsecase : T_CASE_ELSE statements
    | // empty 

caseexprs : caseexprs ',' caseexpr
    | caseexpr
    
caseexpr : expression 
    | expression T_TO expression
    | T_IS compop expression

compop : T_EQUAL 
    | T_NOT_EQUAL
    | T_LESS_EQUAL
    | T_GREATER_EQUAL
    | T_LESS_THAN
    | T_GREATER_THAN

forloop : T_FOR assignment T_TO numbers stepping statements T_NEXT IDENTIFIER 

foreachloop : T_FOR_EACH IDENTIFIER T_IN IDENTIFIER statements T_NEXT IDENTIFIER 

stepping : T_STEP numbers 
    | // empty

whileloop : T_WHILE expression statements T_WEND 
	
doWhileloop : T_DO_WHILE expression statements T_LOOP 
    | T_DO statements T_LOOP T_WHILE expression 

doUntilloop : T_DO_UNTIL expression statements T_LOOP 
    | T_DO statements T_LOOP T_UNTIL expression 

exit_statement : T_EXIT_FOR
    | T_EXIT_DO 
    | T_EXIT T_SUB
    | T_EXIT T_FUNCTION
    | T_EXIT T_PROPERTY

pvtpub : T_PRIVATE 
    | T_PUBLIC

pvtpubdeclaration : pvtpub declare

pvtpubsubblock : pvtpub subblock 

pvtpubfunctionblock : pvtpub functionblock

pvtpubpropgetblock : pvtpub propertygetblock

pvtpubpropletblock : pvtpub propertyletblock

pvtpubpropsetblock : pvtpub propertysetblock
*/

%%


//driver code 
void main (int argc, char** argv) {
    FILE *file; 	
    file = fopen(argv[1], "r"); // open the file given as argument

    if (argc<2) {   // in case of no file given as argument throw error
        printf("ERROR : Insufficient Arguments. Missing file name.\n");
        return;
    }

    if (!file) {    // error for invalid file 
        printf("ERROR : Could NOT Open the file.\n");
        return;
    }
    
    int ch = fgetc(file); // check if empty file
    if (ch == EOF) { // error for invalid file 
        printf("ERROR : Empty file.\n");
        return;
    }
    fclose(file);
    
    printf("\n\nSYNTAX ANALYSIS :\n\n");
    file = fopen(argv[1], "r"); // open the file given as argument
    yyin=file;  // Make file content input for lexical analysis, i.e, sets input file as file
    yyparse(); // function to call parser

    if (flag==0) printf("\n\nValid Source Code\n\n"); 
    else printf("\n\nInvalid Source Code\n\n");

    printf("\n\nSYMBOL TABLE :\n\n");
	printf("\n%20s\t %10s\t %10s\t %15s\t\n", "SYMBOL", "DATATYPE", "TYPE", "LINE_NUMBER");
	printf("_____________________________\n\n");
	for (int i=0; i<count; i++) {
		printf("%20s\t %10s\t %10s\t %15d\t\n", 
            symbolTable[i].id_name, 
            symbolTable[i].data_type, 
            symbolTable[i].type, 
            symbolTable[i].line_no);
	}
	for (int i=0; i<count; i++) {
		free(symbolTable[i].id_name);
		free(symbolTable[i].type);
	}
    printf("\n\n");

	printf("\n\nSYNTAX TREE :\n\n");
	printtree(head); 
	printf("\n\n");
	
	printf("\n\nINTERMEDIATE CODE GENERATION :\n\n");
	for(int i=0; i<ic_idx; i++){
		printf("%s", icg[i]);
	}
	printf("\n\n");

    return;
}

struct node* mknode (struct node *left, struct node *right, char *token) {	
	struct node *newnode = (struct node*)malloc(sizeof(struct node));
	char *newstr = (char*)malloc(strlen(token)+1);
	strcpy(newstr, token);
	newnode->left = left; 
	newnode->right = right;
	newnode->token = newstr;
	return(newnode);
}

void printtree (struct node* tree) {
	printf("Inorder Traversal of the Syntax Tree or Parse Tree: \n\n");
	printInorder(tree);
	printf("\n\n");
}

void printInorder (struct node *tree) {
	if (tree->left) {
		printInorder(tree->left);
	}
	printf("%s, ", tree->token);
	if (tree->right) {
		printInorder(tree->right);
	}
}

void add (char c, char *t) {
    q = search(yytext);
    if (q==-1 && c=='V') {
        symbolTable[count].id_name=strdup(yytext);
        symbolTable[count].data_type=strdup(type);
        symbolTable[count].line_no=yylineno;
        symbolTable[count].type=strdup("Variable");
        count++;
    }
    else if (c=='C') {
        symbolTable[count].id_name=strdup(yytext);
        symbolTable[count].data_type=strdup(t);
        symbolTable[count].line_no=yylineno;
        symbolTable[count].type=strdup("Constant");
        count++;
    }
}

void insert_type() {
	strcpy(type, yytext);
}

int search (char *type) {
	for (int i=count-1; i>=0; i--) {
		if (strcmp(symbolTable[i].id_name, type)==0) {
			return i;
		}
	}
	return -1;
}

void yyerror (char *s) { 
    printf("\n\nSyntax Error : Line %d >> %s\n\n", yylineno, yytext); 
    flag=1; 
}
