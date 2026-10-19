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

// Accessing fields through `this` with `core.atomic` in shared constructors and methods
struct T
{
    shared int v;
    shared bool flag;

    this(int i) shared
    {
        if (atomicLoad(v) > 0) {}
        if (atomicLoad(flag)) {}
        auto n = new int(atomicLoad(v) + 1);
    }

    void m() shared
    {
        if (atomicLoad(flag) && atomicLoad(v) == 0) {}
    }
}

struct Pages
{
    size_t numPages, pageSize;

    bool owns(void[] buf) shared
    {
        return buf.ptr < buf.ptr + atomicLoad(numPages) * atomicLoad(pageSize);
    }

    size_t total() shared
    {
        size_t n = atomicLoad(numPages) * atomicLoad(pageSize);
        size_t m = -atomicLoad(numPages) + ~atomicLoad(pageSize);
        return n + m;
    }
}

// Fields of `this` that are always accessed safely, the result of
// arithmetic on them is an rvalue and doesn't read shared memory again.
// The preview used to reject these because the result is `shared`.
class K
{
    shared int v;
    this() shared
    {
        if (v + 1 > 0) {}
        int q = v * v;
        int r = -v;
    }
}

synchronized class Sync
{
    private int k;
    void f()
    {
        if (k > 0) {}
        k = k + 1;
        int q = k * k;
        int r = ~k + (k << 1);
    }
}

// `alias this` to a `shared` method that does the atomic read
struct G
{
    int v;
    int get() shared { return atomicLoad(v); }
    alias get this;
}

shared G g;

void aliasThis()
{
    bool a = g is 0;
    bool b = g !is 0;
    bool c = g == 0;
    bool d = g < 1;
    int e = g + 1;
}

// Branches of the same type may still be used as lvalues
void branches(bool lc)
{
    byRef(lc ? x : y);
    auto a = atomicLoad(lc ? x : y);
    auto b = lc ? atomicLoad(x) : 0;
    long c = lc ? cast() x : 0L;
    auto d = cast() (lc ? x : y);
}

void arrayOps(int[] arr, int[2] st)
{
    arr[] += atomicLoad(x);
    st[] *= cast() x;
}
