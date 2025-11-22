#ifndef FIELD_H
#define FIELD_H

#include "string.h"

struct Type;
struct Attribute;
dyn_array_decl(Attribute, struct)

typedef struct {
	String identifier;
	struct Type* type;
	DynArray(Attribute) attributes;
} Field;

#endif//FIELD_H