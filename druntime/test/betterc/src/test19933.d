/*******************************************/
// https://issues.dlang.org/show_bug.cgi?id=19933
// https://issues.dlang.org/show_bug.cgi?id=18816

import core.stdc.stdio : printf;

extern(C) int main()
{
    printf("Hello\n");
    return 0;
}
