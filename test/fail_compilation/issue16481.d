enum e = is(typeof(fun!()));
void fun()() { auto m = MapResult!()(0); }
alias f = fun!();

struct MapResult()
{
    this(int) {}
    void front() { undefined(); }
}
