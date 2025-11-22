// $antlr-format alignTrailingComments true, columnLimit 150, maxEmptyLinesToKeep 1, reflowComments false, useTab false
// $antlr-format allowShortRulesOnASingleLine true, allowShortBlocksOnASingleLine true, minEmptyLines 0, alignSemicolons ownLine
// $antlr-format alignColons trailing, singleLineOverrulesHangingColon true, alignLexerCommands true, alignLabels true, alignTrailers true

lexer grammar LunaLexer;

@header { #include "LunaLexerBase.h" }

options
{
    superClass = LunaLexerBase;
}

// Luna keywords
KW_AS         : 'as';
KW_ASYNC      : 'async';
KW_ATTRIBUTE  : 'attribute';
KW_BREAK      : 'break';
KW_CODE       : 'code';
KW_COMPTIME   : 'comptime';
KW_CONST      : 'const';
KW_CONTRACT   : 'contract';
KW_CONTINUE   : 'continue';
KW_ELSE       : 'else';
KW_ENUM       : 'enum';
KW_EXTERN     : 'extern';
KW_FN         : 'fn';
KW_FOR        : 'for';
KW_GOTO       : 'goto';
KW_IF         : 'if';
KW_IMPL       : 'impl';
KW_IMPORT     : 'import';
KW_IN         : 'in';
KW_LABEL      : 'label';
KW_LET        : 'let';
KW_LOOP       : 'loop';
KW_MACRO      : 'macro';
KW_MATCH      : 'match';
KW_NULL       : 'null';
KW_PACKAGE    : 'package';
KW_PRIVATE    : 'private';
KW_RETURN     : 'return';
KW_STRUCT     : 'struct';
KW_THISTYPE   : 'This';
KW_THISVALUE  : 'this';
KW_UNION      : 'union';
KW_WHERE      : 'where';
KW_YIELD      : 'yield';

// rule itself allow any identifier, but keyword has been matched before
NON_KEYWORD_IDENTIFIER: XID_Start XID_Continue* | '_' XID_Continue+;

// [\p{L}\p{Nl}\p{Other_ID_Start}-\p{Pattern_Syntax}-\p{Pattern_White_Space}]
fragment XID_Start: [\p{L}\p{Nl}] | UNICODE_OIDS;

// [\p{ID_Start}\p{Mn}\p{Mc}\p{Nd}\p{Pc}\p{Other_ID_Continue}-\p{Pattern_Syntax}-\p{Pattern_White_Space}]
fragment XID_Continue: XID_Start | [\p{Mn}\p{Mc}\p{Nd}\p{Pc}] | UNICODE_OIDC;

fragment UNICODE_OIDS: '\u1885' ..'\u1886' | '\u2118' | '\u212e' | '\u309b' ..'\u309c';
fragment UNICODE_OIDC: '\u00b7' | '\u0387' | '\u1369' ..'\u1371' | '\u19da';

// comments https://doc.rust-lang.org/reference/comments.html
LINE_COMMENT: ('//' (~[/] | '//') ~[\r\n]* | '//') -> channel (HIDDEN);
BLOCK_COMMENT:
    (
        '/*' (~[*] | '**' | BLOCK_COMMENT_OR_DOC) (BLOCK_COMMENT_OR_DOC | ~[*])*? '*/'
        | '/**/'
        | '/***/'
    ) -> channel (HIDDEN)
;
LINE_DOC: '///' (~[/] ~[\n\r]*)? -> channel (HIDDEN); // isolated cr
BLOCK_DOC:
    '/**' (~[*] | BLOCK_COMMENT_OR_DOC) (BLOCK_COMMENT_OR_DOC | ~[*])*? '*/' -> channel (HIDDEN)
;
BLOCK_COMMENT_OR_DOC: ( BLOCK_COMMENT | BLOCK_DOC) -> channel (HIDDEN);

SHEBANG: {this->SOF()}? '\ufeff'? '#!' ~[\r\n]* -> channel(HIDDEN);

//ISOLATED_CR
// : '\r' {_input->LA(1)!='\n'}// not followed with \n ;

// whitespace https://doc.rust-lang.org/reference/whitespace.html
WHITESPACE : [\p{Zs}]          -> channel(HIDDEN);
NEWLINE    : ('\r\n' | [\r\n]) -> channel(HIDDEN);

// tokens char and string
CHAR_LITERAL: '\'' ( ~['\\\n\r\t] | QUOTE_ESCAPE | ASCII_ESCAPE | UNICODE_ESCAPE) '\'';
STRING_LITERAL: '"' ( ~["] | QUOTE_ESCAPE | ASCII_ESCAPE | UNICODE_ESCAPE | ESC_NEWLINE)* '"';
RAW_STRING_LITERAL: 'r' RAW_STRING_CONTENT;
fragment RAW_STRING_CONTENT: '#' RAW_STRING_CONTENT '#' | '"' .*? '"';
BYTE_LITERAL: 'b\'' (. | QUOTE_ESCAPE | BYTE_ESCAPE) '\'';
BYTE_STRING_LITERAL: 'b"' (~["] | QUOTE_ESCAPE | BYTE_ESCAPE)* '"';
RAW_BYTE_STRING_LITERAL: 'br' RAW_STRING_CONTENT;
fragment ASCII_ESCAPE: '\\x' OCT_DIGIT HEX_DIGIT | COMMON_ESCAPE;
fragment BYTE_ESCAPE: '\\x' HEX_DIGIT HEX_DIGIT | COMMON_ESCAPE;
fragment COMMON_ESCAPE: '\\' [nrt\\0];
fragment UNICODE_ESCAPE:
    '\\u{' HEX_DIGIT HEX_DIGIT? HEX_DIGIT? HEX_DIGIT? HEX_DIGIT? HEX_DIGIT? '}'
;
fragment QUOTE_ESCAPE: '\\' ['"];
fragment ESC_NEWLINE: '\\' '\n';

CODE_LANG
    : 'luna'
    | 'c'
    | 'lir'
    | 'llvmir'
    | 'asm'
    ;

// number

INTEGER_LITERAL: ( DEC_LITERAL | BIN_LITERAL | OCT_LITERAL | HEX_LITERAL) INTEGER_SUFFIX?;
DEC_LITERAL: DEC_DIGIT (DEC_DIGIT | '_')*;
HEX_LITERAL: '0x' '_'* HEX_DIGIT (HEX_DIGIT | '_')*;
OCT_LITERAL: '0o' '_'* OCT_DIGIT (OCT_DIGIT | '_')*;
BIN_LITERAL: '0b' '_'* [01] [01_]*;
FLOAT_LITERAL:
                        {this->floatLiteralPossible()}? (
        DEC_LITERAL '.' {this->floatDotPossible()}?
        | DEC_LITERAL ( '.' DEC_LITERAL)? FLOAT_EXPONENT? FLOAT_SUFFIX?
    )
;
fragment INTEGER_SUFFIX:
    'u8'
    | 'u16'
    | 'u32'
    | 'u64'
    | 'u128'
    | 'usize'
    | 'i8'
    | 'i16'
    | 'i32'
    | 'i64'
    | 'i128'
    | 'isize'
;
fragment FLOAT_SUFFIX: 'f32' | 'f64';
fragment FLOAT_EXPONENT: [eE] [+-]? '_'* DEC_LITERAL;
fragment OCT_DIGIT: [0-7];
fragment DEC_DIGIT: [0-9];
fragment HEX_DIGIT: [0-9a-fA-F];

// LIFETIME_TOKEN: '\'' IDENTIFIER_OR_KEYWORD | '\'_';

LIFETIME_OR_LABEL: '\'' NON_KEYWORD_IDENTIFIER;

PLUS       : '+';
MINUS      : '-';
STAR       : '*';
SLASH      : '/';
PERCENT    : '%';
CARET      : '^';
CARETCARET : '^^';
NOT        : '!';
AND        : '&';
OR         : '|';
ANDAND     : '&&';
OROR       : '||';
//SHL: '<<'; SHR: '>>'; removed to avoid confusion in type parameter
PLUSEQ     : '+=';
MINUSEQ    : '-=';
STAREQ     : '*=';
SLASHEQ    : '/=';
PERCENTEQ  : '%=';
CARETEQ    : '^=';
ANDEQ      : '&=';
OREQ       : '|=';
SHLEQ      : '<<=';
SHREQ      : '>>=';
EQ         : '=';
EQEQ       : '==';
NE         : '!=';
GT         : '>';
LT         : '<';
GE         : '>=';
LE         : '<=';
AT         : '@';
UNDERSCORE : '_';
DOT        : '.';
DOTDOT     : '..';
// DOTDOTDOT  : '...';
DOTDOTEQ   : '..=';
COMMA      : ',';
SEMI       : ';';
COLON      : ':';
PATHSEP    : '::';
THINARROW  : '->';
FATARROW   : '=>';
POUND      : '#';
DOLLAR     : '$';
QUESTION   : '?';

LCURLYBRACE    : '{';
RCURLYBRACE    : '}';
LSQUAREBRACKET : '[';
RSQUAREBRACKET : ']';
LPAREN         : '(';
RPAREN         : ')';