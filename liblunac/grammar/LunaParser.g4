// $antlr-format alignTrailingComments true, columnLimit 150, minEmptyLines 1, maxEmptyLinesToKeep 1, reflowComments false, useTab false
// $antlr-format allowShortRulesOnASingleLine false, allowShortBlocksOnASingleLine true, alignSemicolons hanging, alignColons hanging

parser grammar LunaParser;

@header { #include "LunaParserBase.h" }

options
{
    tokenVocab = LunaLexer;
    superClass = LunaParserBase;
}

// === Top level statements ===

// entry point
entryPoint
    : topLevel* EOF
    ;

//configurationPredicate
// : configurationOption | configurationAll | configurationAny | configurationNot ; configurationOption: identifier (
// EQ (STRING_LITERAL | RAW_STRING_LITERAL | RAW_CODE_LITERAL))?; configurationAll: 'all' LPAREN configurationPredicateList? RPAREN;
// configurationAny: 'any' LPAREN configurationPredicateList? RPAREN; configurationNot: 'not' LPAREN configurationPredicate RPAREN;

//configurationPredicateList
// : configurationPredicate (COMMA configurationPredicate)* COMMA? ; cfgAttribute: 'cfg' LPAREN configurationPredicate RPAREN;
// cfgAttrAttribute: 'cfg_attr' LPAREN configurationPredicate COMMA cfgAttrs? RPAREN; cfgAttrs: attr (COMMA attr)* COMMA?;

topLevel
    : attribute* (
        packageLevel
        | statement
    )
    ;
packageLevel
    : attribute* (
        externLevel
        | externBlock
    )
    ;
externLevel
    : attribute* (
        importDeclaration
        | varDecl
        | implementation
        | packageBlock
        | comptimeExpr
    )
    ;
packageBlock
    : KW_PRIVATE? KW_PACKAGE identifier externClause? LCURLYBRACE packageLevel* RCURLYBRACE
    ;
externBlock
    : KW_EXTERN expression? LCURLYBRACE packageLevel* RCURLYBRACE
    ;
comptimeExpr
    : KW_COMPTIME blockExpression
    ;

// Imports
importDeclaration
    : KW_IMPORT importTree SEMI
    ;
importTree
    : (simplePath? PATHSEP)? (STAR | LCURLYBRACE (importTree (COMMA importTree)* COMMA?)? RCURLYBRACE)
    | simplePath (KW_AS (identifier | UNDERSCORE))?
    ;

//TODO variable declaration should be changed to this
// pattern : const? type? = expression; //runtime
// pattern : type? : expression; //compile-time
// Variable declaration - also used to declare structs, functions, etc...
varDecl
    : (KW_CONST | KW_LET) pattern (COLON type_)? (EQ expression)? SEMI
    ;

externClause
    : KW_EXTERN expression? identifier? // extern std::ffi::Abi::C some_function_name
    ;

// Function
fnDecl
    : KW_FN genericParams? (LPAREN fnParameters? RPAREN)? fnCaptureGroup? (FATARROW type_)? whereClause? externClause? blockExpression?
    ;
fnParameters
    : fnThisParam (EQ expression)? COMMA?
    | (fnThisParam COMMA)? fnParam (COMMA fnParam)* (COMMA fnParamWithDefault)* COMMA?
    | (fnThisParam COMMA)? fnParamWithDefault (COMMA fnParamWithDefault)* COMMA?
    ;
fnThisParam
    : THINARROW? KW_CONST? KW_THISVALUE
    | KW_CONST? KW_THISVALUE COLON type_
    ;
fnParam
    : pattern COLON type_
    ;
fnParamWithDefault
    : fnParam EQ expression
    ;
fnCallParams
    : expression (COMMA expression)* COMMA?
    ;
fnCaptureGroup
    : LSQUAREBRACKET (fnCaputureParam (COMMA fnCaputureParam)* COMMA?)? RSQUAREBRACKET
    ;
fnCaputureParam
    : identifier AND?
    ;

// Struct
structDecl
    : KW_STRUCT genericParams? whereClause? externClause? structFieldsBlock?
    ;
structFieldsBlock
    : LCURLYBRACE (structField (COMMA structField)* COMMA?)? RCURLYBRACE
    ;
structField
    : attribute* identifier COLON type_
    ;

// Enum
enumDecl
    : KW_ENUM genericParams? (COLON type_)? whereClause? externClause? enumBlock?
    ;
enumBlock
    : LCURLYBRACE enumItems? RCURLYBRACE
    ;
enumItems
    : enumItem (COMMA enumItem)* COMMA?
    ;
enumItem
    : attribute* identifier structFieldsBlock? (EQ expression)?
    ;

// Union
unionDecl
    : KW_UNION genericParams? whereClause? externClause? structFieldsBlock?
    ;

// Contract
contractDecl
    : KW_CONTRACT genericParams? (COLON typeParamBounds?)? whereClause? LCURLYBRACE contractAssociatedItem* RCURLYBRACE
    ;
contractAssociatedItem
    : attribute* varDecl //TODO this might need to be limited to functions, associated types, and associated constants
    ;

// Impl block
implementation
    : KW_IMPL genericParams? (NOT? typePath KW_FOR)? type_ whereClause? LCURLYBRACE contractAssociatedItem* RCURLYBRACE
    ;

// Generic parameters
//TODO default args
genericParams
    : LT genericParam (COMMA genericParam)* (COMMA genericParamWithDefault)* COMMA? GT
    | LT genericParamWithDefault (COMMA genericParamWithDefault)* COMMA? GT
    ;
genericParam
    : genericLifetimeParam
    | genericConstParam
    | genericTypeParam
    ;
genericParamWithDefault
    : (genericTypeParam | genericConstParam) EQ expression
    ;
genericLifetimeParam
    : LIFETIME_OR_LABEL (COLON lifetimeBounds)?
    ;
genericConstParam
    : pattern COLON type_
    ;
genericTypeParam
    : genericConstParam COLON typeParamBounds
    ;
whereClause
    : KW_WHERE whereClauseItem (COMMA whereClauseItem)* COMMA?
    ;
whereClauseItem
    : lifetimeWhereClauseItem
    | typeBoundWhereClauseItem
    ;
lifetimeWhereClauseItem
    : lifetime COLON lifetimeBounds
    ;
typeBoundWhereClauseItem
    : forLifetimes? type_ COLON typeParamBounds
    ;
forLifetimes
    : KW_FOR genericParams
    ;

// Attributes
attributeDeclExpr
    : KW_ATTRIBUTE (LPAREN attributeParams? RPAREN)? blockExpression
    ;
attributeParams
    : fnParam (COMMA fnParam)* (COMMA fnParamWithDefault)* COMMA?
    | fnParamWithDefault (COMMA fnParamWithDefault)* COMMA?
    ;
attribute
    : LSQUAREBRACKET expression (LPAREN fnCallParams? RPAREN)? RSQUAREBRACKET
    ;

// Macros
macroDeclExpr
    : KW_MACRO (LPAREN attributeParams? RPAREN)? FATARROW KW_CODE blockExpression
    ;

//metaItem
// : simplePath ( EQ literalExpression //w | LPAREN metaSeq RPAREN )? ; metaSeq: metaItemInner (COMMA metaItemInner)* COMMA?;
// metaItemInner: metaItem | literalExpression; // w

//metaWord: identifier; metaNameValueStr: identifier EQ ( STRING_LITERAL | RAW_STRING_LITERAL | RAW_CODE_LITERAL ); metaListPaths:
// identifier LPAREN ( simplePath (COMMA simplePath)* COMMA?)? RPAREN; metaListIdents: identifier LPAREN ( identifier (COMMA
// identifier)* COMMA?)? RPAREN; metaListNameValueStr : identifier LPAREN (metaNameValueStr ( COMMA metaNameValueStr)* COMMA?)? RPAREN
// ;

// Statements
statement
    : SEMI
    | varDecl
    | expressionStatement
    ;
expressionStatement
    : expression SEMI
    | expressionWithBlock SEMI?
    ;

// Expressions
expression
    : attribute+ expression                                          # AttributedExpression // technical, remove left recursive
    | literalExpression                                              # LiteralExpression_
    | pathExpression                                                 # PathExpression_
    | expression DOT pathExprSegment LPAREN fnCallParams? RPAREN     # MethodCallExpression
    | expression DOT identifier                                      # FieldExpression
    | expression LPAREN fnCallParams? RPAREN                         # CallExpression
    | expression LSQUAREBRACKET expression RSQUAREBRACKET            # IndexExpression
    | expression QUESTION                                            # ErrorPropagationExpression
    | expression NOT                                                 # ErrorPanicExpression
    | expression AND                                                 # ReferenceExpression
    | expression STAR                                                # DereferenceExpression
    | (MINUS | NOT) expression                                       # NegationExpression
    | expression KW_AS typeNoBounds                                  # TypeCastExpression
    | expression (STAR | SLASH | PERCENT) expression                 # ArithmeticOrLogicalExpression
    | expression (PLUS | MINUS) expression                           # ArithmeticOrLogicalExpression
    | expression (shl | shr) expression                              # ArithmeticOrLogicalExpression
    | expression AND expression                                      # ArithmeticOrLogicalExpression
    | expression CARET expression                                    # ArithmeticOrLogicalExpression
    | expression OR expression                                       # ArithmeticOrLogicalExpression
    | expression comparisonOperator expression                       # ComparisonExpression
    | expression (comparisonOperator expression)+                    # MultiComparisonExpression
    | expression booleanComparisonOperator expression                # LazyBooleanExpression
    | expression DOTDOT expression?                                  # RangeExpression
    | DOTDOT expression?                                             # RangeExpression
    | DOTDOTEQ expression                                            # RangeExpression
    | expression DOTDOTEQ expression                                 # RangeExpression
    | expression EQ expression                                       # AssignmentExpression
    | expression compoundAssignOperator expression                   # CompoundAssignmentExpression
    | KW_CONTINUE LIFETIME_OR_LABEL? expression?                     # ContinueExpression
    | KW_BREAK LIFETIME_OR_LABEL? expression?                        # BreakExpression
    | KW_RETURN expression?                                          # ReturnExpression
    | LPAREN expression RPAREN                                       # GroupedExpression
    | LSQUAREBRACKET arrayElements? RSQUAREBRACKET                   # ArrayExpression
    | fnDecl                                                         # FunctionDeclExpression
    | structDecl                                                     # StructDeclExpression
    | enumDecl                                                       # EnumDeclExpression
    | unionDecl                                                      # UnionDeclExpression
    | contractDecl                                                   # ContractDeclExpression
    | attributeDeclExpr                                              # AttributeDeclExpression
    | macroDeclExpr                                                  # MacroDeclExpression
    | structExpression                                               # StructExpression_
    | enumerationVariantExpression                                   # EnumerationVariantExpression_
    | expressionWithBlock                                            # ExpressionWithBlock_
    | comptimeExpr                                                   # ComptimeExpression
    ;

booleanComparisonOperator
    : ANDAND
    | CARETCARET
    | OROR
    ;
comparisonOperator
    : EQEQ
    | NE
    | GT
    | LT
    | GE
    | LE
    ;
compoundAssignOperator
    : PLUSEQ
    | MINUSEQ
    | STAREQ
    | SLASHEQ
    | PERCENTEQ
    | ANDEQ
    | OREQ
    | CARETEQ
    | SHLEQ
    | SHREQ
    ;

expressionWithBlock
    : attribute+ expressionWithBlock // technical
    | blockExpression
    | loopExpression
    | ifExpression
    | ifBindExpression
    | matchExpression
    ;
literalExpression
    : CHAR_LITERAL
    | STRING_LITERAL
    | RAW_STRING_LITERAL
    | codeLiteral
    | BYTE_LITERAL
    | BYTE_STRING_LITERAL
    | RAW_BYTE_STRING_LITERAL
    | INTEGER_LITERAL
    | FLOAT_LITERAL
    ;
pathExpression
    : pathInExpression
    | qualifiedPathInExpression
    ;
blockExpression
    : LCURLYBRACE statements? RCURLYBRACE
    ;
statements
    : statement+ expression?
    | expression
    ;

// 8.2.6
arrayElements
    : expression (COMMA expression)*
    | expression SEMI expression
    ;

// Struct expression
structExpression
    : structExprStruct
    | pathInExpression
    ;
structExprStruct
    : pathInExpression LCURLYBRACE (structExprFields | structBase)? RCURLYBRACE
    ;
structExprFields
    : structExprField (COMMA structExprField)* (COMMA structBase)? COMMA?
    ;
structExprField
    : identifier | identifier EQ expression
    ;
structBase
    : DOTDOT expression
    ;

// Enum expression
enumerationVariantExpression
    : structExprStruct
    | pathInExpression
    ;

// Loop expressions
loopExpression
    : loopLabel? (
        infiniteLoopExpression
        | whileLoopExpression
        | whilePatternLoopExpression
        | iterLoopExpression
        | forLoopExpression
    )
    ;
infiniteLoopExpression
    : KW_LOOP blockExpression
    ;
whileLoopExpression
    : KW_LOOP expression /*except structExpression*/ blockExpression
    ;
whilePatternLoopExpression
    : KW_LOOP patternBinding+ blockExpression
    ;
iterLoopExpression
    : KW_LOOP pattern KW_IN expression blockExpression
    ;
forLoopExpression
    : KW_LOOP expression COLON expression blockExpression
    ;
loopLabel
    : LIFETIME_OR_LABEL COLON
    ;

//TODO change if/ifelse/match to this
/*
: KW_IF expression blockExpression ifElseClause? //standard if - else if - else
| KW_IF expression EQEQ matchArmsBlock           //pattern matching
| KW_IF ifelseArmsBlock                          //ifelse
*/

// If expression
ifExpression
    : KW_IF expression blockExpression ifElseClause?
    ;
ifElseClause
    : KW_ELSE (blockExpression | ifExpression | ifBindExpression)
    ;

// ifelse expression
ifelseExpression
    : KW_IF LCURLYBRACE (attribute* expression FATARROW ifElseArmExpression)+ (attribute* expression FATARROW expression COMMA?)? RCURLYBRACE
    ;
ifElseArmExpression
    : expression COMMA
    | expressionWithBlock COMMA?
    ;

// If bind expression
ifBindExpression
    : KW_IF patternBinding+ blockExpression ifBindElseClause?
    ;
singlePatternBinding
    : KW_CONST pattern EQ expression
    ;
multiPatternBinding
    : singlePatternBinding (booleanComparisonOperator singlePatternBinding)*
    ;
groupMultiPatternBinding
    : LPAREN multiPatternBinding RPAREN
    ;
patternBinding
    : multiPatternBinding
    | groupMultiPatternBinding
    ;
ifBindElseClause
    : KW_ELSE (blockExpression | ifExpression | ifBindExpression)
    ;

// Match expression
matchExpression
    : KW_MATCH expression LCURLYBRACE (attribute* matchArm FATARROW matchArmExpression)+ (attribute* matchArm FATARROW expression COMMA?)? RCURLYBRACE
    ;
matchArmExpression
    : expression COMMA
    | expressionWithBlock COMMA?
    ;
matchArm
    : pattern (KW_IF expression)?
    ;

// Patterns
pattern
    : patternNoTopAlt (OR patternNoTopAlt)*
    ;
patternNoTopAlt
    : patternWithoutRange
    | rangePattern
    ;
patternWithoutRange
    : literalPattern
    | identifierPattern
    | UNDERSCORE
    | restPattern
    | pointerPattern
    | structPattern
    | groupedPattern
    | slicePattern
    | pathPattern
    ;
literalPattern
    : CHAR_LITERAL
    | BYTE_LITERAL
    | STRING_LITERAL
    | RAW_STRING_LITERAL
    | codeLiteral
    | BYTE_STRING_LITERAL
    | RAW_BYTE_STRING_LITERAL
    | MINUS? INTEGER_LITERAL
    | MINUS? FLOAT_LITERAL
    ;
identifierPattern
    : THINARROW? KW_CONST? identifier (AT pattern)?
    ;
restPattern
    : DOTDOT
    ;
rangePattern
    : rangePatternBound DOTDOTEQ rangePatternBound # InclusiveRangePattern
    | rangePatternBound DOTDOT                     # HalfOpenRangePattern
    ;
rangePatternBound
    : CHAR_LITERAL
    | BYTE_LITERAL
    | MINUS? INTEGER_LITERAL
    | MINUS? FLOAT_LITERAL
    | pathPattern
    ;
pointerPattern
    : THINARROW KW_CONST? patternWithoutRange
    ;
structPattern
    : pathInExpression LCURLYBRACE structPatternElements? RCURLYBRACE
    ;
structPatternElements
    : structPatternFields (COMMA DOTDOT?)?
    | DOTDOT
    ;
structPatternFields
    : structPatternField (COMMA structPatternField)*
    ;
structPatternField
    : identifier COLON pattern
    | THINARROW? KW_CONST? identifier
    ;
groupedPattern
    : LPAREN pattern RPAREN
    ;
slicePattern
    : LSQUAREBRACKET slicePatternItems? RSQUAREBRACKET
    ;
slicePatternItems
    : pattern (COMMA pattern)* COMMA?
    ;
pathPattern
    : pathInExpression
    | qualifiedPathInExpression
    ;

// Types
type_
    : typeNoBounds
    | implTraitType
    ;
typeNoBounds
    : LPAREN type_ RPAREN
    | typePath
    | rawPointerType
    | UNDERSCORE
    | qualifiedPathInType
    | bareFunctionType
    | fnType
    | structType
    | enumType
    | unionType
    | attributeType
    | macroType
    ;
rawPointerType
    : THINARROW KW_CONST? typeNoBounds
    ;

// Function
fnType
    : KW_FN typeGenericParams? (LPAREN fnTypeParameters? RPAREN)? (LSQUAREBRACKET type_ (COMMA type_)* RSQUAREBRACKET)? (FATARROW type_)? whereClause? externClause?
    ;
fnTypeParameters
    : fnTypeThisParam (EQ expression)? COMMA?
    | (fnTypeThisParam COMMA)? fnTypeParam (COMMA fnTypeParam)* COMMA?
    ;
fnTypeThisParam
    : THINARROW? KW_CONST? KW_THISVALUE
    | (KW_CONST? KW_THISVALUE COLON)? type_
    ;
fnTypeParam
    : (pattern COLON)? type_
    ;
structType
    : KW_STRUCT typeGenericParams? whereClause? externClause? structTypeFieldsBlock?
    ;
structTypeFieldsBlock
    : LCURLYBRACE structTypeFields RCURLYBRACE
    ;
structTypeFields
    : structTypeField (COMMA structTypeField)* COMMA?
    ;
structTypeField
    : (identifier COLON)? type_
    ;
enumType
    : KW_ENUM typeGenericParams? (COLON type_)? whereClause? externClause? enumTypeBlock?
    ;
enumTypeBlock
    : LCURLYBRACE (enumTypeItem (COMMA enumTypeItem)* COMMA?)? RCURLYBRACE
    ;
enumTypeItem
    : identifier structTypeFieldsBlock?
    ;
unionType
    : KW_UNION typeGenericParams? whereClause? externClause? structTypeFieldsBlock?
    ;
typeGenericParams
    : LT typeGenericParam (COMMA typeGenericParam)* COMMA? GT
    ;
typeGenericParam
    : LIFETIME_OR_LABEL (COLON lifetimeBounds)?
    | (pattern COLON)? type_ (COLON typeParamBounds)?
    ;
attributeType
    : KW_ATTRIBUTE typeGenericParams? (LPAREN fnTypeParameters? RPAREN)?
    ;
macroType
    : KW_MACRO (LPAREN fnTypeParameters? RPAREN)?
    ;

bareFunctionType
    : forLifetimes? functionTypeQualifiers KW_FN LPAREN maybeNamedFunctionParameters? RPAREN bareFunctionReturnType?
    ;
functionTypeQualifiers
    : (KW_EXTERN identifier?)?
    ;
bareFunctionReturnType
    : FATARROW typeNoBounds
    ;
maybeNamedFunctionParameters
    : maybeNamedParam (COMMA maybeNamedParam)* COMMA?
    ;
maybeNamedParam
    : attribute* ((identifier | UNDERSCORE) COLON)? type_
    ;
implTraitType
    : KW_IMPL typeParamBounds
    ;

// Params
typeParamBounds
    : typeParamBound (PLUS typeParamBound)* PLUS?
    ;
typeParamBound
    : lifetime
    | traitBound
    ;
traitBound
    : QUESTION? forLifetimes? typePath
    | LPAREN QUESTION? forLifetimes? typePath RPAREN
    ;
lifetimeBounds
    : (lifetime PLUS)* lifetime?
    ;
lifetime
    : LIFETIME_OR_LABEL
    ;

// Type paths
simplePath
    : PATHSEP? simplePathSegment (PATHSEP simplePathSegment)*
    ;
simplePathSegment
    : identifier
    | KW_THISVALUE
    ;
pathInExpression
    : PATHSEP? pathExprSegment (PATHSEP pathExprSegment)*
    ;
pathExprSegment
    : pathIdentSegment (PATHSEP genericArgs)?
    ;
pathIdentSegment
    : identifier
    | KW_THISVALUE
    | KW_THISTYPE
    ;

// Generics
//TODO: let x : T<_>=something;
genericArgs
    : LT GT
    | LT genericArgsLifetimes (COMMA genericArgsTypes)? (COMMA genericArgsBindings)? COMMA? GT
    | LT genericArgsTypes (COMMA genericArgsBindings)? COMMA? GT
    | LT (genericArg COMMA)* genericArg COMMA? GT
    ;
genericArg
    : lifetime
    | type_
    | genericArgsConst
    | genericArgsBinding
    ;
genericArgsConst
    : blockExpression
    | MINUS? literalExpression
    | simplePathSegment
    ;
genericArgsLifetimes
    : lifetime (COMMA lifetime)*
    ;
genericArgsTypes
    : type_ (COMMA type_)*
    ;
genericArgsBindings
    : genericArgsBinding (COMMA genericArgsBinding)*
    ;
genericArgsBinding
    : identifier EQ type_
    ;
qualifiedPathInExpression
    : qualifiedPathType (PATHSEP pathExprSegment)+
    ;
qualifiedPathType
    : LT type_ (KW_AS typePath)? GT
    ;
qualifiedPathInType
    : qualifiedPathType (PATHSEP typePathSegment)+
    ;
typePath
    : PATHSEP? typePathSegment (PATHSEP typePathSegment)*
    ;
typePathSegment
    : pathIdentSegment PATHSEP? (genericArgs | typePathFn)?
    ;
typePathFn
    : LPAREN typePathInputs? RPAREN (THINARROW type_)?
    ;
typePathInputs
    : type_ (COMMA type_)* COMMA?
    ;

// technical
identifier
    : NON_KEYWORD_IDENTIFIER
    ;

keyword
    : KW_AS
    | KW_ASYNC
    | KW_ATTRIBUTE
    | KW_BREAK
    | KW_CODE
    | KW_COMPTIME
    | KW_CONST
    | KW_CONTRACT
    | KW_CONTINUE
    | KW_ELSE
    | KW_ENUM
    | KW_EXTERN
    | KW_FN
    | KW_FOR
    | KW_GOTO
    | KW_IF
    | KW_IMPL
    | KW_IMPORT
    | KW_IN
    | KW_LABEL
    | KW_LET
    | KW_LOOP
    | KW_MACRO
    | KW_MATCH
    | KW_PACKAGE
    | KW_PRIVATE
    | KW_RETURN
    | KW_STRUCT
    | KW_THISTYPE
    | KW_THISVALUE
    | KW_UNION
    | KW_WHERE
    | KW_YIELD
    ;

// LA can be removed, legal rust code still pass but the cost is `let c = a < < b` will pass... i hope antlr5 can add
// some new syntax? dsl? for these stuff so i needn't write it in (at least) 5 language

shl
    : LT {this->next('<')}? LT
    ;

shr
    : GT {this->next('>')}? GT
    ;

codeLiteral
    : KW_CODE CODE_LANG? RAW_STRING_LITERAL
    ;