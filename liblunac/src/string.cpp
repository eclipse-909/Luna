extern "C" {

#include <string.h>
#include <stdlib.h>
#include "types/string.h"

String from_cstr(const char *cstr) {
	const size_t len = strlen(cstr);
	uint8_t* ptr = (uint8_t*)malloc(len);
	if (ptr == NULL) {
		return {{NULL, 0, 0}};
	}
	memcpy(ptr, cstr, len);
	return {{ptr, len, len}};
}

str as_str(const String string) {
	return {string.arr.ptr, string.arr.len};
}

void string_drop(const String string) {
	dyn_array_drop_uint8_t(string.arr);
}

}