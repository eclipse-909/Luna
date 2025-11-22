#ifndef PARSE_H
#define PARSE_H

#include "types/token.h"
#include "types/ast-node.h"

AstNode parse(const Slice(Token) tokens);

#endif//PARSE_H