/*
TEST_OUTPUT:
---
fail_compilation/issue16481.d(17): Error: undefined identifier `undefined`
fail_compilation/issue16481.d(11): Error: template instance `issue16481.MapResult!()` error instantiating
fail_compilation/issue16481.d(10):        instantiated from here: `fun!()`
---
*/

enum e = is(typeof(fun!()));
void fun()() { auto m = MapResult!()(0); }
alias f = fun!();

struct MapResult()
{
    this(int) {}
    void front() { undefined(); }
}
