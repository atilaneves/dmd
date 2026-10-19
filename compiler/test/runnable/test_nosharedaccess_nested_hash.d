// REQUIRED_ARGS: -preview=nosharedaccess

void main()
{
    shared(string[])[] arrays = [cast(shared(string[])) ["one", "two"]];
    string[][] expectedArrays = [["one", "two"]];
    assert(arrays.hashOf == expectedArrays.hashOf);
    assert(hashOf(arrays, 17) == hashOf(expectedArrays, 17));

    shared(string[][])[] nested = [cast(shared(string[][])) [["one"], ["two"]]];
    string[][][] expectedNested = [[["one"], ["two"]]];
    assert(nested.hashOf == expectedNested.hashOf);
    assert(hashOf(nested, 17) == hashOf(expectedNested, 17));
}
