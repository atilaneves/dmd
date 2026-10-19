// REQUIRED_ARGS: -preview=nosharedaccess

interface H
{
    size_t toHash() const shared @safe pure nothrow @nogc;
}

class C : H
{
    override size_t toHash() const shared @safe pure nothrow @nogc
    {
        return 7;
    }
}

void main() @safe
{
    shared(C)[] values = [new shared C, null];
    auto expected = hashOf(size_t(0), hashOf(size_t(7), 0));
    assert(values.hashOf == expected);
    assert(hashOf(values, 17) == hashOf(size_t(0), hashOf(size_t(7), 17)));

    shared(H)[] interfaces = [new shared C, null];
    assert(interfaces.hashOf == expected);
    assert(hashOf(interfaces, 17) == hashOf(values, 17));

    shared(C) c = new shared C;
    assert(c.hashOf == 7);
    assert(hashOf(c, 17) == hashOf(size_t(7), 17));
    shared(C) empty;
    assert(empty.hashOf == 0);
    assert(hashOf(empty, 17) == hashOf(size_t(0), 17));
}
