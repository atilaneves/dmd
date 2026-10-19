// REQUIRED_ARGS: -preview=nosharedaccess

import core.atomic : cas;

void byRef(ref shared int);

struct Nested
{
    int value;
}

struct SharedStruct
{
    int value;
    shared int explicitlyShared;
    Nested nested;
    Nested* indirect;

    this(int initial) shared { value = initial; }
    shared(int)* address() return shared { return &value; }
    ref shared(int) reference() return shared { return value; }
    void useRef() shared
    {
        ref shared(int) aliasValue = value;
        byRef(aliasValue);
        byRef(value);
        byRef(nested.value);
        static assert(!__traits(compiles, () { auto p = &indirect.value; }));
        cas(&value, 0, 1);
        address();
        reference();
    }
    void useExplicit()
    {
        byRef(explicitlyShared);
        cas(&explicitlyShared, 0, 1);
    }
}

class SharedClass
{
    int value;
    shared int explicitlyShared;
    Nested nested;
    Nested* indirect;

    this(int initial) shared { value = initial; }
    shared(int)* address() shared { return &value; }
    ref shared(int) reference() shared { return value; }
    void useRef() shared
    {
        ref shared(int) aliasValue = value;
        byRef(aliasValue);
        byRef(value);
        byRef(nested.value);
        static assert(!__traits(compiles, () { auto p = &indirect.value; }));
        cas(&value, 0, 1);
        address();
        reference();
    }
    void useExplicit()
    {
        byRef(explicitlyShared);
        cas(&explicitlyShared, 0, 1);
    }
    synchronized int read() { return value; }
    synchronized void write() { value = 1; }
}
