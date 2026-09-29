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

# Check the memory-in-use figure (used by -ftime-trace) stays sane after the
# mmap chunk falls back to a smaller malloc chunk, i.e. when the current
# chunk's real capacity is smaller than CHUNK_SIZE.
cat > "${OUTPUT_BASE}.d" <<'EOF'
module rmem_limit;

import dmd.root.rmem : Mem, allocmemoryNoFree, heapTotal, heapMemoryInUse;
import core.stdc.stdio : puts;

void main()
{
    // Before the first chunk is allocated, in-use must be 0.
    assert(heapMemoryInUse() == 0);

    Mem.disableGC();
    enum size_t allocSize = 4096;
    enum size_t numAllocs = 8;
    size_t requested = 0;
    foreach (i; 0 .. numAllocs)
    {
        auto p = cast(ubyte*) allocmemoryNoFree(allocSize, 16);
        p[0 .. allocSize] = 1;
        requested += allocSize;
    }
    auto inUse = heapMemoryInUse();
    assert(inUse <= heapTotal);
    assert(inUse >= requested);
    puts("memory-in-use accounting passed");
}
EOF

$DMD -I../src "${OUTPUT_BASE}.d" ../src/dmd/root/rmem.d \
    -of="${OUTPUT_BASE}${EXE}"
(
    ulimit -v 65536
    "${OUTPUT_BASE}${EXE}"
)

# The huge-page mmap path (dmd.root.rmem's HugePages version) is only
# built on x86-64 Linux; on any other 64-bit Linux architecture (e.g.
# AArch64), allocmemoryNoFree always uses the malloc fallback and makes
# no large mmap call at all, so the count below would be 0, not 1. The
# test runner exposes MODEL (32/64) and OS, but not the CPU
# architecture, so ask uname directly.
if [ "$(uname -m)" = "x86_64" ]; then

# After the first mmap failure, later chunks must go straight to the malloc
# fallback: count the large (>= 64MB) mmap attempts the process makes by
# interposing the libc symbol the huge-page path actually calls. glibc
# aliases the "mmap" the D binding calls to "mmap64" on this platform, so
# that is the symbol to interpose (confirmed by objdump on the compiled call
# site); interposing "mmap" alone would silently count nothing.
cat > "${OUTPUT_BASE}.d" <<'EOF'
module rmem_limit;

import dmd.root.rmem : Mem, allocmemoryNoFree;
import core.stdc.stdio : puts, printf;
import core.sys.linux.dlfcn : dlsym, RTLD_NEXT;

private extern (C) alias MmapFn =
    void* function(void*, size_t, int, int, int, long) nothrow @nogc;

__gshared int largeMmapCount = 0;
__gshared MmapFn realMmap64;

extern (C) void* mmap64(void* addr, size_t length, int prot, int flags,
                        int fd, long offset) nothrow @nogc
{
    if (length >= 64 * 1024 * 1024)
        largeMmapCount++;
    if (realMmap64 is null)
        realMmap64 = cast(MmapFn) dlsym(RTLD_NEXT, "mmap64");
    return realMmap64(addr, length, prot, flags, fd, offset);
}

void main()
{
    Mem.disableGC();
    // Small allocations so each fallback chunk holds many of them, and
    // filling several fallback chunks stays well under the address-space
    // limit set below.
    enum size_t allocSize = 4096;
    enum size_t numAllocs = 2048; // several fallback chunks worth
    foreach (i; 0 .. numAllocs)
    {
        auto p = cast(ubyte*) allocmemoryNoFree(allocSize, 16);
        p[0 .. allocSize] = cast(ubyte) i;
    }
    printf("large mmap attempts: %d\n", largeMmapCount);
    assert(largeMmapCount == 1);
    puts("large mmap attempted exactly once after first failure passed");
}
EOF

$DMD -I../src "${OUTPUT_BASE}.d" ../src/dmd/root/rmem.d \
    -L-ldl -of="${OUTPUT_BASE}${EXE}"
(
    ulimit -v 65536
    "${OUTPUT_BASE}${EXE}"
)

fi
