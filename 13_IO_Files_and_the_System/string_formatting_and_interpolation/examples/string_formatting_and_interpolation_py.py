# The Python twin: f-strings (str() unless !r), the format mini-language,
# the old % operator, and ljust/rjust/center.
class Foo:
    def __str__(self):
        return "Foo!"

    def __repr__(self):
        return "<Foo>"


def row(n, text, value=""):
    print(f"{n:2d}. {text:<52} {value}")


x = 5
row(1, "f\"x is {x}\" interpolates; \"x is {x}\" does not", f"{f'x is {x}'!r} {'x is {x}'!r}")
row(2, 'f"{obj}" calls str; None, a list, a str, a dict', f"{f'{Foo()}'!r} {f'{None}|{[1, 2]}|{"sym"}|{1.0}|{ {"a": 1} }'!r}")
row(3, "any expression, even a nested f-string", f"{f'{1 + 2}'!r} {f'{f"in {x}"}'!r}")
row(4, 'f"{pi:05.2f}"; ":.3e"; ":x :o :b :08b :X"', f"{3.14159:05.2f}; {123456.789:.3e}; {255:x} {8:o} {5:b} {5:08b} {255:X}")
row(5, '":+d" and ": d" signs; ":5d|" and ":<5d|" width', f"{5:+d} {5: d}; {42:5d}|{42:<5d}|")
row(6, '"%s and %s" % (a, b); "%s" % one; "%d%%" % 50', f"{'%s and %s' % ('a', 'b')}; {'%s' % 'one'}; {'%d%%' % 50}")
row(7, "!r is repr: f\"{'str'!r} {'str'}\"; !r and str of None", f"{f'{"str"!r} {"str"}'}; {f'{None!r}|{None}|'!r}")
row(8, '"{name} is {age:d}".format(**h); f"{x=}" (3.8+)', f"{'{name} is {age:d}'.format(name='Ada', age=36)}; {x=}")
row(9, 'ljust(6, "."), rjust(6), center(6, "*"); ":<10|"; ":>10|"', f"{'ab'.ljust(6, '.')}| {'ab'.rjust(6)}| {'ab'.center(6, '*')}| {'left':<10}| {'right':>10}|")
row(10, 'bin(255), hex(255); int("ff", 16); ":#x :#o :#b"', f"{bin(255)} {hex(255)}; {int('ff', 16)}; {255:#x} {8:#o} {5:#b}")
row(11, 'f"{2.675:.2f}" and round(2.675, 2); ":.0f" of 2.5, 3.5', f"{2.675:.2f} {round(2.675, 2)}; {2.5:.0f} {3.5:.0f}")
row(12, 'f"{1/3:.10g}"; str(1e20); str(100.0); str(1e-5)', f"{1 / 3:.10g}; {1e20}; {100.0}; {1e-5}")
row(13, '"{2} {0} {1}".format(...); a nested width f"{n:{w}d}"', f"{'{2} {0} {1}'.format('a', 'b', 'c')}; {42:{5}d}|")
row(14, "a precision on a str truncates: f\"{s:.2}\"", f"{'abcdef':.2}")
row(15, 'thousands built in: f"{n:,}" and f"{n:_}"', f"{1234567:,}; {1234567:_}")
row(16, "padding counts characters: f\"{s:<6}|\"; ljust", f"{'caf\N{LATIN SMALL LETTER E WITH ACUTE}':<6}| {'caf\N{LATIN SMALL LETTER E WITH ACUTE}'.ljust(6, '.')}|")
import textwrap

row(17, "textwrap.dedent strips the common indentation", repr(textwrap.dedent("  indented\n    more\n  back\n")))
row(18, '"%c" of an int and of a one-character str', f"{'%c' % 65} {'%c' % 'h'}")
row(19, 'str(3.0); "%d" % 3.99 truncates; "%f" % 3', f"{3.0}; {'%d' % 3.99}; {'%f' % 3}")
s = "x"
row(20, "an f-string of one str may be the same object: is; ==", f"{f'{s}' is s}; {f'{s}' == s}")
