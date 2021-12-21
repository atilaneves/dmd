/*
REQUIRED_ARGS: -revert=nosharedaccess
TEST_OUTPUT:
---
---
*/
void oops() {
    shared int i;
    i = 42;
}
