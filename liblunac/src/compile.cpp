extern "C" {

#include "frontend/compile.h"

#include "frontend/lex.h"
#include "frontend/parse.h"
#include "types/ast-node.h"
#include "types/string.h"

void compile(const CompOptions* options) {
	//TODO

	const String dummy_code = string_from_cstr("const main = fn {};\n");

	const DynArray(Token) tokens = lex(string_as_str(dummy_code));
	string_drop(dummy_code);

	//TODO print tokens

	const AstNode ast = parse(dyn_array_as_slice_Token(tokens));
	dyn_array_drop_Token(tokens);

	print_ast(&ast);
}
}