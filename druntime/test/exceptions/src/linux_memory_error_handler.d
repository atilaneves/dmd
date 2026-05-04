import etc.linux.memoryerror;
version (Posix)
    import core.sys.posix.unistd : write;
else
{
    import core.atomic : atomicLoad;
    import core.stdc.stdio : fprintf, stderr;
}

void main()
{
    static if (is(registerMemoryErrorHandler))
    {
        int* getNull() {
            return null;
        }

        assert(registerMemoryErrorHandler());

        bool b;

        try
        {
            *getNull() = 42;
        }
        catch (NullPointerError)
        {
            b = true;
        }

        assert(b);

        b = false;

        try
        {
            *getNull() = 42;
        }
        catch (InvalidPointerError)
        {
            b = true;
        }

        assert(b);

        assert(deregisterMemoryErrorHandler());
    }
    version (Posix)
    {
        // Avoid libc's shared stderr FILE* here: Alpine/musl crashes when this
        // low-level exception test reaches it through atomicLoad(stderr).
        enum message = "success.\n";
        write(2, message.ptr, message.length);
    }
    else
        fprintf(atomicLoad(stderr), "success.\n");
}
