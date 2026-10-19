/* REQUIRED_ARGS: -preview=nosharedaccess
 */

// Forms that must stay accepted now that conditions and operands
// of unary/binary expressions are checked for shared access.
// See fail_compilation/shared_operands.d

import core.atomic;

shared bool c;
shared int x;
shared int y;

void byRef(ref shared int) {}

struct S
{
    bool opCast(T : bool)() shared { return true; }
}

void test(shared(int)* p, shared(int)[] arr)
{
    // atomics
    if (atomicLoad(c)) {}
    while (!atomicLoad(c)) {}
    auto a = atomicLoad(x) + 1;
    auto b = atomicLoad(x) > 0 ? 1 : 2;

    // explicit casts
    if (cast() c) {}
    auto d = cast(int) x > 0;
    auto e = cast() x + 1;
    switch (cast() x) { default: }
    int[] ints;
    auto f = ints[cast() x];

    // taking the address / pointer arithmetic on unshared pointers
    if (&x) {}
    if (&x == &y) {}
    if (&x is &y) {}
    if (p) {}
    if (p is null) {}
    if (p == &x) {}
    auto g = p + 1;
    auto h = &x + 1;
    if (arr.ptr) {}
    if (arr.length > 0) {}

    // passing by ref
    byRef(x);

    // opCast on a shared struct
    shared S s;
    if (s) {}

    // no runtime read
    auto i = x.sizeof + 1;
    static assert(is(typeof(x + 1) == int));
    auto j = typeof(x).max > 0;
}

// Accessing fields through `this` in shared constructors and methods
struct T
{
    shared int v;
    shared bool flag;

    this(int i) shared
    {
        if (v > 0) {}
        if (flag) {}
        auto n = new int(v + 1);
    }

    void m() shared
    {
        if (flag && v == 0) {}
    }
}

// The result of arithmetic on such fields is an rvalue, so using it as an
// operand or initializer doesn't read shared memory (see
// std.experimental.allocator.building_blocks.ascending_page_allocator)
struct Pages
{
    size_t numPages, pageSize;

    bool owns(void[] buf) shared
    {
        return buf.ptr < buf.ptr + numPages * pageSize;
    }

    size_t total() shared
    {
        size_t n = numPages * pageSize;
        if (numPages * pageSize > 0) {}
        size_t m = -numPages + ~pageSize;
        return n + m;
    }
}

class K
{
    shared int v;
    this() shared
    {
        if (v + 1 > 0) {}
    }
}

synchronized class Sync
{
    private int k;
    void f()
    {
        if (k > 0) {}
        k = k + 1;
    }
}
