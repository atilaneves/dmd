import dshell;

int main()
{
    // Compile both Darwin sections implementations, including on non-Darwin hosts.
    foreach (model; ["32", "64"])
    {
        run([DMD, "-conf=", "-I=../../druntime/src", "-c", "-o-",
            "-os=osx", "-m" ~ model, "-preview=nosharedaccess",
            "../../druntime/src/rt/sections_osx_x86.d",
            "../../druntime/src/rt/sections_osx_64.d"]);
    }
    return 0;
}
