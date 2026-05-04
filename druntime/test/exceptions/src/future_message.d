version (Posix)
    import core.sys.posix.unistd : write;
else
{
    import core.atomic : atomicLoad;
    import core.stdc.stdio : fprintf, stderr;
}

// Make sure basic stuff works with future Throwable.message
class NoMessage : Throwable
{
    @nogc @safe pure nothrow this(string msg, Throwable next = null)
    {
        super(msg, next);
    }
}

class WithMessage : Throwable
{
    @nogc @safe pure nothrow this(string msg, Throwable next = null)
    {
        super(msg, next);
    }

    override const(char)[] message() const
    {
        return "I have a custom message.";
    }
}

class WithMessageNoOverride : Throwable
{
    @nogc @safe pure nothrow this(string msg, Throwable next = null)
    {
        super(msg, next);
    }

    const(char)[] message() const
    {
        return "I have a custom message and no override.";
    }
}

class WithMessageNoOverrideAndDifferentSignature : Throwable
{
    @nogc @safe pure nothrow this(string msg, Throwable next = null)
    {
        super(msg, next);
    }

    immutable(char)[] message()
    {
        return "I have a custom message and I'm nothing like Throwable.message.";
    }
}

void test(Throwable t)
{
    try
    {
        throw t;
    }
    catch (Throwable e)
    {
        writeStderr(e.message);
        writeStderr(" ");
    }
}

void main()
{
     test(new NoMessage("exception"));
     test(new WithMessage("exception"));
     test(new WithMessageNoOverride("exception"));
     test(new WithMessageNoOverrideAndDifferentSignature("exception"));
     writeStderr("\n");
}

void writeStderr(const(char)[] message)
{
    version (Posix)
    {
        // Avoid libc's shared stderr FILE* here: Alpine/musl crashes when this
        // low-level exception test reaches it through atomicLoad(stderr).
        while (message.length)
        {
            const written = write(2, message.ptr, message.length);
            if (written <= 0)
                return;
            message = message[written .. $];
        }
    }
    else
        fprintf(atomicLoad(stderr), "%.*s", cast(int) message.length, message.ptr);
}
