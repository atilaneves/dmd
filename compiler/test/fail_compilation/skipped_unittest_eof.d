/*
TEST_OUTPUT:
---
fail_compilation/skipped_unittest_eof.d(10): Error: closing `}` of unittest not found before end of file
---
*/

// `__EOF__` ends the file even inside a skipped unittest body.

unittest
{
    __EOF__
}
