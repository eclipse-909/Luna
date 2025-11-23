#ifndef STRING_H
#define STRING_H

#include "dyn-array.h"

typedef struct {
	DynArray(uint8_t) arr;
} String;

String string_from_cstr(const char* cstr);
void string_drop(const String string);

typedef struct {
	Slice(uint8_t) slice;
} str;

str string_as_str(const String string);
str str_from_cstr(const char* cstr);

dyn_array_decl(str);

#endif //STRING_H