/* REQUIRED_ARGS: -preview=nosharedaccess
 * TEST_OUTPUT:
---
fail_compilation/shared_operands.d(107): Error: direct access to shared `c` is not allowed, see `core.atomic`
fail_compilation/shared_operands.d(108): Error: direct access to shared `c` is not allowed, see `core.atomic`
fail_compilation/shared_operands.d(109): Error: direct access to shared `c` is not allowed, see `core.atomic`
fail_compilation/shared_operands.d(110): Error: direct access to shared `c` is not allowed, see `core.atomic`
fail_compilation/shared_operands.d(111): Error: direct access to shared `c` is not allowed, see `core.atomic`
fail_compilation/shared_operands.d(112): Error: direct access to shared `c` is not allowed, see `core.atomic`
fail_compilation/shared_operands.d(113): Error: direct access to shared `c` is not allowed, see `core.atomic`
fail_compilation/shared_operands.d(114): Error: direct access to shared `c` is not allowed, see `core.atomic`
fail_compilation/shared_operands.d(115): Error: direct access to shared `c` is not allowed, see `core.atomic`
fail_compilation/shared_operands.d(116): Error: direct access to shared `x` is not allowed, see `core.atomic`
fail_compilation/shared_operands.d(121): Error: direct access to shared `x` is not allowed, see `core.atomic`
fail_compilation/shared_operands.d(122): Error: direct access to shared `x` is not allowed, see `core.atomic`
fail_compilation/shared_operands.d(123): Error: direct access to shared `x` is not allowed, see `core.atomic`
fail_compilation/shared_operands.d(124): Error: direct access to shared `x` is not allowed, see `core.atomic`
fail_compilation/shared_operands.d(125): Error: direct access to shared `x` is not allowed, see `core.atomic`
fail_compilation/shared_operands.d(126): Error: direct access to shared `x` is not allowed, see `core.atomic`
fail_compilation/shared_operands.d(127): Error: direct access to shared `x` is not allowed, see `core.atomic`
fail_compilation/shared_operands.d(128): Error: direct access to shared `x` is not allowed, see `core.atomic`
fail_compilation/shared_operands.d(129): Error: direct access to shared `x` is not allowed, see `core.atomic`
fail_compilation/shared_operands.d(130): Error: direct access to shared `x` is not allowed, see `core.atomic`
fail_compilation/shared_operands.d(131): Error: direct access to shared `x` is not allowed, see `core.atomic`
fail_compilation/shared_operands.d(132): Error: direct access to shared `sb` is not allowed, see `core.atomic`
fail_compilation/shared_operands.d(133): Error: direct access to shared `c` is not allowed, see `core.atomic`
fail_compilation/shared_operands.d(134): Error: direct access to shared `x` is not allowed, see `core.atomic`
fail_compilation/shared_operands.d(135): Error: direct access to shared `x` is not allowed, see `core.atomic`
fail_compilation/shared_operands.d(141): Error: direct access to shared `x` is not allowed, see `core.atomic`
fail_compilation/shared_operands.d(142): Error: direct access to shared `x` is not allowed, see `core.atomic`
fail_compilation/shared_operands.d(143): Error: direct access to shared `x` is not allowed, see `core.atomic`
fail_compilation/shared_operands.d(144): Error: direct access to shared `x` is not allowed, see `core.atomic`
fail_compilation/shared_operands.d(149): Error: direct access to shared `x` is not allowed, see `core.atomic`
fail_compilation/shared_operands.d(150): Error: direct access to shared `x` is not allowed, see `core.atomic`
fail_compilation/shared_operands.d(151): Error: direct access to shared `x` is not allowed, see `core.atomic`
fail_compilation/shared_operands.d(152): Error: direct access to shared `lc ? x : x` is not allowed, see `core.atomic`
fail_compilation/shared_operands.d(157): Error: direct access to shared `x` is not allowed, see `core.atomic`
fail_compilation/shared_operands.d(162): Error: direct access to shared `x` is not allowed, see `core.atomic`
fail_compilation/shared_operands.d(163): Error: direct access to shared `x` is not allowed, see `core.atomic`
fail_compilation/shared_operands.d(173): Error: direct access to shared `$r:this\.a( \* this\.a)?` is not allowed, see `core\.atomic`(\nfail_compilation/shared_operands\.d\(173\): Error: direct access to shared `this\.a` is not allowed, see `core\.atomic`)?$
fail_compilation/shared_operands.d(174): Error: direct access to shared `$r:-?this\.a` is not allowed, see `core\.atomic`$
fail_compilation/shared_operands.d(183): Error: direct access to shared `$r:this\.a( \* this\.a)?` is not allowed, see `core\.atomic`(\nfail_compilation/shared_operands\.d\(183\): Error: direct access to shared `this\.a` is not allowed, see `core\.atomic`)?$
fail_compilation/shared_operands.d(192): Error: direct access to shared `$r:this\.n( \* this\.m)?` is not allowed, see `core\.atomic`(\nfail_compilation/shared_operands\.d\(192\): Error: direct access to shared `this\.m` is not allowed, see `core\.atomic`)?$
fail_compilation/shared_operands.d(199): Error: using the result of a comma expression is not allowed
fail_compilation/shared_operands.d(199): Error: direct access to shared `x` is not allowed, see `core.atomic`
---
*/

// Reading a shared lvalue as a condition or as an operand of
// a unary/binary expression is a read and must go through `core.atomic`.
// The expected output for the fields of `this` is a regex since the fields
// themselves are also reported when fix-nosharedaccess-this-fields is merged.

#line 100

shared bool c;
shared int x;
shared byte sb;

void conditions()
{
    if (c) {}
    while (c) {}
    for (; c;) {}
    do {} while (c);
    assert(c);
    auto a = c ? 1 : 2;
    auto b = !c;
    auto d = c && true;
    auto e = false || c;
    if (x) {}
}

void operands()
{
    auto a = x > 0;
    auto b = 0 <= x;
    auto d = x + 1;
    auto e = 1 - x;
    auto f = x * 2;
    auto g = x / 2;
    auto h = x % 2;
    auto i = x ^^ 2;
    auto j = x & 1;
    auto k = x | 1;
    auto l = x ^ 1;
    auto m = sb + 1;
    auto n = c & true;
    auto o = x is 0;
    auto p = x !is 0;
}

void others(int[] arr)
{
    int y;
    y += x;
    y <<= x;
    auto a = arr[x];
    switch (x) { default: }
}

void branches(bool lc)
{
    int a = lc ? x : 0;
    long b = lc ? x : 0L;
    auto c = (lc ? x : 1) + 1;
    auto d = lc ? x : x;
}

int branchReturn(bool b)
{
    return b ? x : 0;
}

void arrayOps(int[] arr, int[2] st)
{
    arr[] += x;
    st[] *= x;
}

// Fields of `this` are only exempt where that is always safe, so
// the shared result of arithmetic on them is still an error
struct S
{
    shared int a;
    void f()
    {
        int k = a * a;
        int l = -a;
    }
}

class C
{
    shared int a;
    int g()
    {
        return a * a;
    }
}

struct P
{
    size_t n, m;
    size_t h() shared
    {
        size_t q = n * m;
        return q;
    }
}

void commaOperand(bool lc)
{
    int a = (lc ? 1 : 2, x) + 1;
}

