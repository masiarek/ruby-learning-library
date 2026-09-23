# `return a, b` builds a tuple; unpacking takes it apart, and it raises when
# the counts disagree. Named returns are a namedtuple or a dataclass.
import collections
import dataclasses
import operator


def row(n, label, value):
    print(f"{n:2d}. {label:<44} {value}")


def pair():
    return 1, 2


def triple():
    return [1, 2, 3]


Pair = collections.namedtuple("Pair", "q r")


@dataclasses.dataclass(frozen=True)
class Coord:
    x: int
    y: int


def div_mod(a, b):
    return Pair(*divmod(a, b))


def nothing():
    pass


row(1, "def pair(): return 1, 2 -> pair(), type", f"{pair()!r}, {type(pair()).__name__}")
x, y = pair()
row(2, "x, y = pair()", f"x={x} y={y}")
row(3, "divmod(7, 2)", repr(divmod(7, 2)))
xs = [1, 2, 3, 4]
row(4, "two comprehensions (no partition)", repr(([v for v in xs if v % 2 == 0], [v for v in xs if v % 2])))
row(5, "(min(xs), max(xs))   (no minmax)", repr((min([3, 1, 2]), max([3, 1, 2]))))
first, *rest = triple()
row(6, "first, *rest = triple()", f"first={first} rest={rest!r}")
_, second = pair()
row(7, "_, second = pair()", f"second={second}")
row(8, 'operator.itemgetter("a", "c")(d)', repr(operator.itemgetter("a", "c")({"a": 1, "b": 2, "c": 3})))
row(9, "namedtuple: div_mod(7, 2), .q", f"{div_mod(7, 2)!r}, q={div_mod(7, 2).q}")
c = Coord(x=1, y=2)
x, y = dataclasses.astuple(c)
row(10, "dataclass: c = Coord(1, 2); x, y = astuple(c)", f"{c!r}; x={x} y={y}")
try:
    a, b = 1
    few = "?"
except TypeError as e:
    few = type(e).__name__
try:
    c1, c2 = [1, 2, 3]
    many = "?"
except ValueError as e:
    many = type(e).__name__
row(11, "a, b = 1 / c1, c2 = [1, 2, 3]", f"{few} / {many}  (both raise)")
row(12, "def nothing(): pass -> type(nothing())", type(nothing()).__name__)
