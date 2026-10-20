/* REQUIRED_ARGS: -preview=nosharedaccess
TEST_OUTPUT:
---
fail_compilation/nosharedaccess_this.d(105): Error: direct access to shared `this.value` is not allowed, see `core.atomic`
fail_compilation/nosharedaccess_this.d(106): Error: direct access to shared `this.value` is not allowed, see `core.atomic`
fail_compilation/nosharedaccess_this.d(107): Error: direct access to shared `this.explicitlyShared` is not allowed, see `core.atomic`
fail_compilation/nosharedaccess_this.d(108): Error: direct access to shared `this.explicitlyShared` is not allowed, see `core.atomic`
fail_compilation/nosharedaccess_this.d(116): Error: direct access to shared `this.value` is not allowed, see `core.atomic`
fail_compilation/nosharedaccess_this.d(117): Error: direct access to shared `this.value` is not allowed, see `core.atomic`
fail_compilation/nosharedaccess_this.d(118): Error: direct access to shared `this.explicitlyShared` is not allowed, see `core.atomic`
fail_compilation/nosharedaccess_this.d(119): Error: direct access to shared `this.explicitlyShared` is not allowed, see `core.atomic`
---
*/

// With -preview=nosharedaccess, both reading and writing a shared field
// directly must fail. Repeat the cases for struct and class receivers:
// - read/write access value through an implicitly shared this in shared methods.
// - readExplicit/writeExplicit access an explicitly shared field in ordinary
//   methods, where this itself is not shared.
// Keep the diagnostic line numbers stable as these explanations change.
#line 100
struct SharedStruct
{
    int value;
    shared int explicitlyShared;
    // The shared receiver makes value shared for both the read and the write.
    int read() shared { return value; }
    void write() shared { value = 1; }
    int readExplicit() { return explicitlyShared; }
    void writeExplicit() { explicitlyShared = 1; }
}

class SharedClass
{
    int value;
    shared int explicitlyShared;
    // The shared receiver makes value shared for both the read and the write.
    int read() shared { return value; }
    void write() shared { value = 1; }
    int readExplicit() { return explicitlyShared; }
    void writeExplicit() { explicitlyShared = 1; }
}
