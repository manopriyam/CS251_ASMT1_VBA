# CS251_ASMT1_VBA

CS251 Introduction to Language Processing <br>
2023-24-W Semester <br>

<br>

Group Members : <br>
- Manopriya Mondal <br>
- Shivangi Gaur <br>

<br>

Github Link : [https://github.com/manopriyam/CS251_ASMT1_VBA](https://github.com/manopriyam/CS251_ASMT1_VBA) <br>
You may clone the repository using -
```
git clone https://github.com/manopriyam/CS251_ASMT1_VBA
```

<br>

Used : <br>
- LEX (Lexical Analyzer) <br>

<br>

Note : <br>
1. Lexical Analysis <br>
- Install lex (lexical analyzer) -
```
sudo apt-get install flex
```
- Run lexical analyzer on an input_file -
```
lex lexicalAnalyzer.l
gcc lex.yy.c
./a.out input_file
```
- The repository contains a few dummy VBA files which can be executed as follows - 
```
lex lexicalAnalyzer.l
gcc lex.yy.c
./a.out VBAtrial.bas
```
- Individual dummy file execution - 
```
./a.out VBAtrial1.bas
./a.out VBAtrial2.bas
./a.out VBAtrial3.bas
./a.out VBAtrial4.bas
./a.out VBAtrial5.bas
```
- We have tokenized the input character stream into following tokens:
1. Comment: COMMENT	
2. String Literal: STRING_LITERAL
3. Objects: OBJECT_TYPE
4. Data Types: DATA_TYPE
5. Control Flow Statements: T_word for each of the following accordingly <br>
    End If, Else If, If, Then, Else, Select Case, End Select, Case Else, Case, Exit For, For Each, For, To, Step, Next, Exit Do, Do, Loop, While, Until, Wend, End With, With, On Error, On, GoTo
6. Keywords: KEYWORD
7. Operators: OPERATOR
8. Numeric Literal: NUMERIC_LITERAL
9. Float Literal: FLOAT_LITERAL
10. Identifier: IDENTIFIER
11. Brackets: PARENTHESIS
12. Separators: SEPARATOR

<br>
<br>

References Used : <br>
1. Tutorialspoint VBA Tutorial: [https://www.tutorialspoint.com/vba/index.htm](https://www.tutorialspoint.com/vba/index.htm) 
2. Microsoft VBA Language Reference : [https://learn.microsoft.com/en-us/office/vba/language/reference/user-interface-help/visual-basic-language-reference](https://learn.microsoft.com/en-us/office/vba/language/reference/user-interface-help/visual-basic-language-reference)