#!/usr/bin/env bash

if [ "$OS" != linux ] || [ "$MODEL" != 64 ]; then
    exit 0
fi

set -e

cat > "${OUTPUT_BASE}.d" <<'EOF'
module rmem_limit;

import dmd.root.rmem : Mem, allocmemoryNoFree;
import core.stdc.stdio : puts;

void main()
{
    Mem.disableGC();
    auto p = cast(ubyte*) allocmemoryNoFree(16, 16);
    p[0 .. 16] = 42;
    assert(p[15] == 42);
    puts("16-byte allocation succeeded");
}
EOF

$DMD -I../src "${OUTPUT_BASE}.d" ../src/dmd/root/rmem.d \
    -of="${OUTPUT_BASE}${EXE}"
(
    ulimit -v 65536
    "${OUTPUT_BASE}${EXE}"
)

# Check retained contents when requests exceed the small fallback capacity.
cat > "${OUTPUT_BASE}.d" <<'EOF'
module rmem_limit;

import dmd.root.rmem : Mem, allocmemoryNoFree;
import core.stdc.stdio : puts;

void main()
{
    Mem.disableGC();
    enum size = 1024 * 1024 + 17;
    ubyte*[16] pointers;
    foreach (i, ref p; pointers)
    {
        p = cast(ubyte*) allocmemoryNoFree(size, 16);
        assert(cast(size_t)p % 16 == 0);
        p[0 .. size] = cast(ubyte)i;
    }
    foreach (i, p; pointers)
        foreach (value; p[0 .. size]) assert(value == cast(ubyte)i);
    puts("allocation, alignment, and retained contents passed");
}
EOF

$DMD -I../src "${OUTPUT_BASE}.d" ../src/dmd/root/rmem.d \
    -of="${OUTPUT_BASE}${EXE}"
(
    ulimit -v 65536
    "${OUTPUT_BASE}${EXE}"
)
