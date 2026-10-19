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

#line 100
struct SharedStruct
{
    int value;
    shared int explicitlyShared;

    int read() shared { return value; }
    void write() shared { value = 1; }
    int readExplicit() { return explicitlyShared; }
    void writeExplicit() { explicitlyShared = 1; }
}

class SharedClass
{
    int value;
    shared int explicitlyShared;

    int read() shared { return value; }
    void write() shared { value = 1; }
    int readExplicit() { return explicitlyShared; }
    void writeExplicit() { explicitlyShared = 1; }
}
