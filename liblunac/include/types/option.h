#ifndef OPTION_H
#define OPTION_H

//this is needed temporarily to get rid of error messages
//get rid of it once other headers are included for real
#include <stdint.h>

typedef enum {
	Some,
	None,
} OptionTag;

#define option_decl(type, ...)  \
	typedef struct {            \
		OptionTag tag;          \
		__VA_ARGS__ type value; \
	} _Option_##type
#define Option(type) _Option_##type

#endif //OPTION_H