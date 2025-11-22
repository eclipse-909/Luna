# Generic Types
Generic arguments can be used to say that the type will be provided by the caller.
```luna
Vec3 :: struct<T> {
	x: T,
	y: T,
	z: T
}

global_alloc :: fn<T>(val: T) => ->T {
	ptr := std::alloc::global.alloc();
	ptr = val;
	ptr
}
```
It's implied that generic arguments have type `Type` if not specified.
```luna
//This is the same as above
Vec3 :: struct<T: Type> {
	x: T,
	y: T,
	z: T
}
```
You can have as many generic arguments as you want and name them whatever you want.
```luna
//This is the same as above
Vec3 :: struct<A, B, C> {
	x: A,
	y: B,
	z: C
}
```
## Complex Generic impl Blocks
Here is a complex example to demonstrate the syntax. It's deliberately confusing to try to show the worst case.
```luna
Foo :: interface<A, B, C: usize> {
	bar :: fn(->this, a: A) => B;
}

Baz :: struct<T, A, B> {
	t: T,
	a: A,
	b: B
}

impl Foo<A, U, C: usize> for Baz<T, A, B> {
	bar :: fn(->this, a: A) => U {
		#todo()
	}
}
```
It doesn't matter what you name the generic arguments. The names in the impl block can be different than the name in the type delcaration. You must keep them in the same order as they were defined. In the impl block, the `A` in Foo and the `A` in Baz means that they must be the same type.
## Specialized Generics
You can implement unique logic for specific types.
```luna
import std::collections::List

//List is already a thing, so this will specialize it
List :: struct<bool> {
	ptr: ?->u8, //instead of doing a point to booleans, we will do a pointer to u8s
	len: usize,
	cap: usize
}

//Index returns a pointer to something, but we don't want a pointer to a bool because we have to make the bool and move it out of the function
impl IndexCopy<usize> for List<bool> {
	index_copy :: fn(->this, index: usize) => bool {
		#if PROFILE == "dev" {
			if index >= this.len { #panic() }
		}
		std::ptr::add(this.ptr!, index / 8) & (0b1000_0000 >> index % 8) == 1
	}
}
```
## The `Type` Type
`Type` is a special type that represents the type of an object. It can be useful in macros and comptime blocks, but it can also be used at runtime.
```luna
type_i32: Type = type_of(40);
#println("{}", type_i32);
```
`Type` is not to be confused with dynamic objects. `Type` is just an identifier for a type and doesn't provide a vtable. In fact, vtables contain an entry for `Type` so you can use `type_of` on dynamic objects.
```luna
dyn_incrememnt :: fn(num: dyn Add) {
	#print("{}", type_of(num));
	#print("{}", num.vtable().type);

	num += 1;
}

main :: fn() {
	num := 10;
	//Using the dyn keyword before a variable will borrow it as a dynamic object.
	//dyn num becomes (&num, &i32::vtable)
	dyn_increment(dyn num);
	#assert(num == 11);

	//prints:
	//	DynObj
	//	i32
}
```
`Type` is good at runtime for things like reflection, but it's also good with the preprocessor and at compile-time. See those chapters for more information.