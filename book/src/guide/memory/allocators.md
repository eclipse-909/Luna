# Allocators
The responsibility of an allocator is to allocate memory when you need to store data dynamically, then deallocate that memory when you don't need it anymore. Programmers are encouraged to create their own allocators to fit the needs of their programs should they require a custom allocator.
## Allocator Interface
The `Allocator` interface is what you will need to implement to create a 'proper' allocator. You could technically make an allocator and not implement the interface, but then you are making the choice to opt-out of the features it comes with.

The `Allocator` interface looks something like this:
```luna
Allocator :: interface {
	alloc_bytes :: fn<T>(->this, size: usize) => ->T;
	free_bytes :: fn<T>(->this, ptr: ->T, size: usize);

	//more methods/functions not shown...
}
```