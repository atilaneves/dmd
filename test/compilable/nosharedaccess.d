/*
TEST_OUTPUT:
---
compilable/nosharedaccess.d(9): Deprecation: direct access to shared `i` is not allowed, see `core.atomic`
---
*/
void oops() {
    shared int i;
    i = 42;
}
