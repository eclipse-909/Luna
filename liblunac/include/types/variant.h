#ifndef VARIANT_H
#define VARIANT_H

#include <stdint.h>

#define variant_decl(type, ...) \
	typedef struct {            \
		__VA_ARGS__ type tag;   \
		Option(Type) inner;     \
	} _Variant_##type

#define Variant(type) _Variant_##type

#endif //VARIANT_H