#ifndef AST_NODE_H
#define AST_NODE_H

#include "string.h"

typedef enum {
	VarDecl,
} AstTag;

typedef struct {
	String identifier;
} AstVarDecl;

typedef struct {
	AstTag tag;
	union {
		AstVarDecl var_decl;
	};
} AstNode;

void print_ast(const AstNode* ast);

#endif //AST_NODE_H