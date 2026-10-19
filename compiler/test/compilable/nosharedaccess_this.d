// REQUIRED_ARGS: -preview=nosharedaccess

// With -preview=nosharedaccess, shared fields may be initialized or
// referred to without reading their values. Cover both struct and class `this`.
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

    // Construction may initialize fields before the shared instance is published.
    this(int initial) shared { value = initial; }
    // Returning an address or reference does not read the shared field value.
    shared(int)* address() return shared { return &value; }
    ref shared(int) reference() return shared { return value; }
    void useRef() shared
    {
        // Ref aliases and arguments refer to storage, including nested value fields.
        ref shared(int) aliasValue = value;
        byRef(aliasValue);
        byRef(value);
        byRef(nested.value);
        // Reaching a pointee field requires reading the shared pointer first.
        static assert(!__traits(compiles, () { auto p = &indirect.value; }));
        // CAS performs the value access atomically after taking the field address.
        cas(&value, 0, 1);
        address();
        reference();
    }
    // Explicitly shared fields also permit ref arguments and atomic access.
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

    // Construction may initialize fields before the shared instance is published.
    this(int initial) shared { value = initial; }
    // Returning an address or reference does not read the shared field value.
    shared(int)* address() shared { return &value; }
    ref shared(int) reference() shared { return value; }
    void useRef() shared
    {
        // Ref aliases and arguments refer to storage, including nested value fields.
        ref shared(int) aliasValue = value;
        byRef(aliasValue);
        byRef(value);
        byRef(nested.value);
        // Reaching a pointee field requires reading the shared pointer first.
        static assert(!__traits(compiles, () { auto p = &indirect.value; }));
        // CAS performs the value access atomically after taking the field address.
        cas(&value, 0, 1);
        address();
        reference();
    }
    // Explicitly shared fields also permit ref arguments and atomic access.
    void useExplicit()
    {
        byRef(explicitlyShared);
        cas(&explicitlyShared, 0, 1);
    }
    // Synchronized methods permit ordinary field reads and writes under the monitor.
    synchronized int read() { return value; }
    synchronized void write() { value = 1; }
}
