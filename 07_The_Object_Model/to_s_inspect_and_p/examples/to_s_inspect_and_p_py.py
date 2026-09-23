# __str__ is for people, __repr__ is for programmers; print calls one and
# repr the other. Prints the same numbered rows as to_s_inspect_and_p_rb.rb.
# The defaults contain an object address, so the program prints tests of
# their shape rather than the strings themselves.

import builtins
import contextlib
import enum
import io
import pprint
from collections import namedtuple
from dataclasses import dataclass


def section(n, title):
    print(f"{n}. {title}")


def row(label, value):
    print(f"   {label:<40} {value}")


def writes(fn):
    """What a printing call writes, as a string, so the page can show a newline."""
    buffer = io.StringIO()
    with contextlib.redirect_stdout(buffer):
        fn()
    return repr(buffer.getvalue())


def p(*args):
    """Ruby's p: print the repr of each argument, return the argument(s)."""
    for a in args:
        print(repr(a))
    return args[0] if len(args) == 1 else (list(args) if args else None)


class Plain:
    pass


class Point:
    def __init__(self, x, y):
        self.x, self.y = x, y


class OnlyStr:
    def __str__(self):
        return "only __str__"


class OnlyRepr:
    def __repr__(self):
        return "<OnlyRepr>"


class Both:
    def __init__(self, n):
        self.n = n

    def __str__(self):
        return f"str of {self.n}"

    def __repr__(self):
        return f"<Both {self.n}>"


@dataclass
class S:
    x: int
    y: int


NT = namedtuple("NT", "a")

section(1, "the two defaults")
row('str(Plain()) starts with "<__main__.Plain object at 0x"', str(Plain()).startswith("<__main__.Plain object at 0x"))
row("repr(Plain()) == str(Plain())", repr(Plain()) == str(Plain()))
row("repr(Point(1, 2)) mentions x", "x" in repr(Point(1, 2)))
row("vars(Point(1, 2))", vars(Point(1, 2)))

section(2, "__str__ never defines __repr__; __repr__ does define str")
row("str(OnlyStr())", str(OnlyStr()))
row("repr(OnlyStr()) is still the default", repr(OnlyStr()).startswith("<__main__.OnlyStr object at 0x"))
row("repr(OnlyRepr())", repr(OnlyRepr()))
row("str(OnlyRepr())  (falls back to __repr__)", str(OnlyRepr()))

obj = Both(3)
section(3, "who calls which")
print(f"   {'print(obj)':<40} ", end="")
print(obj)
print(f"   {'p(obj)':<40} ", end="")
p(obj)
row('f"{obj}"', f"{obj}")
row('"%s / %r" % (obj, obj)', "%s / %r" % (obj, obj))
row("str(obj)", str(obj))
row('f"{obj!s}"', f"{obj!s}")
row('f"{obj!r}"', f"{obj!r}")

section(4, "containers repr their elements, even in str")
row("str([obj])", str([obj]))
row("repr([obj])", repr([obj]))
row('str({"k": obj})', str({"k": obj}))
row('f"{[obj]}"', f"{[obj]}")
print(f"   {'print([obj])':<40} ", end="")
print([obj])

section(5, "print returns None; the p helper returns its argument")
print("   p(obj) prints: ", end="")
returned = p(obj)
row("  ...and returns obj itself", returned is obj)
print("   p(1, 2) prints two lines:")
returned = p(1, 2)
row("  ...and returns", repr(returned))
row("p() returns", repr(p()))
print('   print("one") prints: ', end="")
returned = print("one")
row("  ...and returns", repr(returned))

section(6, "None")
row("print(None) writes", writes(lambda: print(None)))
row("p(None) writes", writes(lambda: p(None)))
row("print(None, end='') writes", writes(lambda: print(None, end="")))
row('repr(f"{None}")', repr(f"{None}"))
row("repr(str(None))", repr(str(None)))
row("repr(None)", repr(None))
row("str([None])", str([None]))

section(7, "strings; no symbol, so an Enum member")
row('str("str")', str("str"))
row('repr("str")', repr("str"))
row('repr("tab\\there")', repr("tab\there"))
row('repr("\\N{LATIN SMALL LETTER E WITH ACUTE}")', repr("\N{LATIN SMALL LETTER E WITH ACUTE}"))

class Sym(enum.Enum):
    sym = 1


row("str(Sym.sym)", str(Sym.sym))
row("repr(Sym.sym)", repr(Sym.sym))

section(8, "stdlib classes define both")
row("repr(S(1, 2))", repr(S(1, 2)))
row("str(S(1, 2)) == repr(S(1, 2))", str(S(1, 2)) == repr(S(1, 2)))
row("repr(NT(1))", repr(NT(1)))
row('str(RuntimeError("boom"))', str(RuntimeError("boom")))
row('repr(RuntimeError("boom"))', repr(RuntimeError("boom")))
row("str(1e20)", str(1e20))
row("repr(range(1, 4))", repr(range(1, 4)))

section(9, "pprint wraps a nested structure at a width")
nested = {"name": "widget", "parts": [{"id": i, "tags": ["alpha", "beta", "gamma"]} for i in range(1, 4)]}
pprint.pprint(nested, width=40)
row("pprint.pformat(obj) == repr(obj)", pprint.pformat(obj) == repr(obj))

section(10, "where they live")
row("Plain.__str__ is object.__str__", Plain.__str__ is object.__str__)
row("Plain.__repr__ is object.__repr__", Plain.__repr__ is object.__repr__)
row("hasattr(builtins, 'print')", hasattr(builtins, "print"))
row("hasattr(object, '__repr__')", hasattr(object, "__repr__"))
