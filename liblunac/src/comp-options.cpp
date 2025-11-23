extern "C" {

#include "types/comp-options.h"

#include "types/string.h"

dyn_array_impl(CompOutput);

CompOptions CompOptions_default_bin() {
	//TODO

	str src_dirs[] = { str_from_cstr("src") };
	uintptr_t src_dirs_len = sizeof(src_dirs) / sizeof(src_dirs[0]);
	return {
		slice_from_array_str(src_dirs, src_dirs_len), // luna_src_dirs;
		slice_from_array_str({}, 0), // c_header_dirs;
		slice_from_array_str({}, 0), // lib_dirs;
		slice_from_array_str({}, 0), // libs;
		slice_from_array_CompOutput({}, 0), // outputs;
	};
}

CompOptions CompOptions_default_lib() {
	//TODO

	str src_dirs[] = { str_from_cstr("src") };
	uintptr_t src_dirs_len = sizeof(src_dirs) / sizeof(src_dirs[0]);
	return {
		slice_from_array_str(src_dirs, src_dirs_len), // luna_src_dirs;
		slice_from_array_str({}, 0), // c_header_dirs;
		slice_from_array_str({}, 0), // lib_dirs;
		slice_from_array_str({}, 0), // libs;
		slice_from_array_CompOutput({}, 0), // outputs;
	};
}
}