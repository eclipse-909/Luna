#ifndef ATTRIBUTE_H
#define ATTRIBUTE_H

#include "string.h"

struct Type;
dyn_array_decl(Type, struct);

typedef struct {
	String identifier;
	DynArray(Type) comptime_params;
	DynArray(Type) runtime_params;
} Attribute;

#endif //ATTRIBUTE_H