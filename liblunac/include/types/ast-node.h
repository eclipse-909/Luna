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

#endif//AST_NODE_H