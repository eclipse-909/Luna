#ifndef TYPE_H
#define TYPE_H

#include "function.h"
#include <stdint.h>

struct Field;
dyn_array_decl(Field, struct)
dyn_array_decl(Attribute)
struct Variant;
dyn_array_decl(Variant, struct)

typedef struct {
	String identifier;
	DynArray(Attribute) attributes;
	uintptr_t size;
	uintptr_t align;
	bool constant;
	bool comptime;
	enum {Fn, Struct, Enum, Union, Contract, Attr, Macro} typeType;
	union {
		Function function;
		DynArray(Field) fields;
		DynArray(Variant) variants;
		DynArray(Type) contractProperties;
		Attribute attribute;
		DynArray(Type) macroParams;
	} data;
	DynArray(Type) contracts;
} Type;

#endif//TYPE_H