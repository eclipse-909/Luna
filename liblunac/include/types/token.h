#ifndef TOKEN_H
#define TOKEN_H

#include "string.h"

typedef enum {
	KW_AS,
} TokenTag;

typedef struct {
	TokenTag tag;
	String value;
} Token;

dyn_array_decl(Token)

#endif//TOKEN_H