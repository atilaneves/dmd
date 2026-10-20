/*
TEST_OUTPUT:
---
fail_compilation/skipped_unittest_lexer_errors.d(15): Error: non-hex character 'G' in hex string
fail_compilation/skipped_unittest_lexer_errors.d(20): Error: character 0x20ac is not allowed as a continue character in an identifier
fail_compilation/skipped_unittest_lexer_errors.d(25): Error: unterminated string constant starting at fail_compilation/skipped_unittest_lexer_errors.d(25)
fail_compilation/skipped_unittest_lexer_errors.d(23): Error: closing `}` of unittest not found before end of file
---
*/

// Lexical errors are reported even inside a skipped unittest body.

unittest
{
    auto a = x"7G";
}

unittest
{
    auto b€c = 1;
}

unittest
{
    auto d = "unterminated }
