#ifndef DYN_ARRAY_H
#define DYN_ARRAY_H

#include <stdint.h>
#include <stdlib.h>

#define DynArray(type) _DynArray_##type
#define Slice(type) _Slice_##type

#define dyn_array_decl(type, ...)                                         \
	typedef struct {                                                      \
		__VA_ARGS__ type* ptr;                                            \
		uintptr_t len;                                                    \
		uintptr_t cap;                                                    \
	} _DynArray_##type;                                                   \
                                                                          \
	typedef struct {                                                      \
		__VA_ARGS__ type* ptr;                                            \
		uintptr_t len;                                                    \
	} _Slice_##type;                                                      \
                                                                          \
	Slice(type) dyn_array_as_slice_##type(const DynArray(type) dyn_arr) { \
		return (Slice(type)){dyn_arr.ptr, dyn_arr.len};                   \
	}                                                                     \
	                                                                      \
	void dyn_array_drop_##type(const DynArray(type) dyn_arr) {            \
		if (dyn_arr.ptr == NULL) {                                        \
			return;                                                       \
		}                                                                 \
		free(dyn_arr.ptr);                                                \
	}

#endif//DYN_ARRAY_H