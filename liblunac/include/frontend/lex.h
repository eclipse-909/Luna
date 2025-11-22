#ifndef LEX_H
#define LEX_H

#include "types/token.h"

DynArray(Token) lex(const str source);

#endif//LEX_H