#ifndef FUNCTION_H
#define FUNCTION_H

#include "attribute.h"

typedef struct {
	DynArray(Type) comp_params;
	DynArray(Type) run_params;
	DynArray(Type) capture_params;
	struct Type* return_type;
} Function;

#endif//FUNCTION_H