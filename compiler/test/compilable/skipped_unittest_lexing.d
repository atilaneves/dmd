/* Without -unittest the parser skips unittest bodies by counting braces.
 * Braces hidden inside literals and comments must not be counted, and
 * line numbers must still be tracked through the skipped body.
 */

unittest
{
    auto a = "}";
    auto b = '}';
    auto c = `}`;
    auto d = r"}";
    auto d2 = r"\" ~ "}";
    auto e = x"7D";
    auto f = q{ { } };
    auto g = q"(})";
    auto g2 = q"(")" ~ "}";
    auto h = i"$(x)}";
    auto i = i`}`;
    auto j = iq{ { } };
    /* } */
    // }
    /+ } /+ } +/ +/
    auto ünïcödé = [1, 2].length ? a[0 .. $] : .5 + 0x7D;
    auto k = "multi
line }";
}

static assert(__LINE__ == 28);

unittest
{
#line 100 "foo.d"
}

static assert(__LINE__ == 102);
static assert(__FILE__ == "foo.d");
