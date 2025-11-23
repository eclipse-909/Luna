extern "C" {

#include <string.h>
#include "types/string.h"

String string_from_cstr(const char *cstr) {
	if (cstr == NULL) {
		return {{NULL, 0, 0}};
	}
	const size_t len = strlen(cstr);
	uint8_t* ptr = (uint8_t*)malloc(len);
	if (ptr == NULL) {
		return {{NULL, 0, 0}};
	}
	memcpy(ptr, cstr, len);
	return {{ptr, len, len}};
}

void string_drop(const String string) {
	dyn_array_drop_uint8_t(string.arr);
}

str string_as_str(const String string) {
	return {string.arr.ptr, string.arr.len};
}

str str_from_cstr(const char* cstr) {
	if (cstr == NULL) {
		return {{NULL, 0}};
	}
	const size_t len = strlen(cstr);
	return {(uint8_t*)cstr, len};
}

dyn_array_impl(str)

}