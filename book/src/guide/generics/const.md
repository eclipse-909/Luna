# Associated Constants
A genric argument doesn't have to be a `Type`. It can acutally be any value, as long as it can be determined at compile-time. Arrays use an associated constant for the length because it doesn't make sense to store the length in memory if it's a compile-time constant.
```luna
Array :: struct<T, N: usize> {
	ptr: ->T
}

impl Array<T, N> {
	len :: fn(->self) => usize { N }
}

main :: fn() {
	arr := [0, 1, 2, 3, 4];
	array := Array<N = 5> {ptr: arr.as_ptr()};
	#assert(array.len() == 5);
}
```
Luna doesn't actually have an Array struct because arrays are built-in types, but this is how it would be used.