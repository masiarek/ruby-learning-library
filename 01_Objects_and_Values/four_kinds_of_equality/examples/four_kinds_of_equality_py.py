"""Python has is, == and isinstance: the twin of four_kinds_of_equality_rb.rb.

There is no eql? -- == and hash() already agree across int and float -- and no
===: match/case uses isinstance for class patterns and guards for the rest.
"""
import re


def row(label, shown):
    print(f"   {label:<44} {shown}")


print("1. is asks: the same object?")
a = [1]
b = [1]
row("a = [1]; b = [1]; a is b", repr(a is b))
row("a is a", repr(a is a))
x = 1
y = 1
row("x = 1; y = 1; x is y  (cached small int)", repr(x is y))
s = "s"
t = "s"
row('s = "s"; t = "s"; s is t  (interned literal)', repr(s is t))
u = "".join(["x", "y"])
v = "".join(["x", "y"])
row('u = "".join(["x", "y"]); v = the same; u is v', repr(u is v))

print("2. == asks: the same value?")
row("a == b", repr(a == b))
row('"x" == "x"', repr("x" == "x"))
row("1 == 1.0", repr(1 == 1.0))
row('"a" == "a"  (no symbol to differ from)', repr("a" == "a"))
row("None == False", repr(None == False))

print("3. no eql?: == and hash() agree across int and float")
row("type(1) is type(1.0) and 1 == 1.0", repr(type(1) is type(1.0) and 1 == 1.0))
row("hash(1) == hash(1.0)", repr(hash(1) == hash(1.0)))
row('{1: "int"}[1.0]', repr({1: "int"}[1.0]))
row('{1: "int"}[True]', repr({1: "int"}[True]))
row("len({1, 1.0})", repr(len({1, 1.0})))

print("4. no ===: isinstance, re.search, in, a call")
row("isinstance(1, int)", repr(isinstance(1, int)))
row("isinstance(1.0, int)", repr(isinstance(1.0, int)))
row('re.search("a", "cat") is not None', repr(re.search("a", "cat") is not None))
row("2 in range(1, 4)", repr(2 in range(1, 4)))
row("(lambda x: x > 1)(2)", repr((lambda x: x > 1)(2)))
row('"cat" == "cat"', repr("cat" == "cat"))

print("5. match/case: isinstance for class patterns, guards for the rest")
match 2:
    case int():
        r = "int"
    case _:
        r = "other"
row("match 2: case int():", repr(r))
match "cat":
    case str() as text if re.search("a", text):
        r = "match"
    case _:
        r = "no"
row('match "cat": case str() as t if re.search:', repr(r))
match 2:
    case n if 1 <= n <= 3:
        r = "in_range"
    case _:
        r = "out"
row("match 2: case n if 1 <= n <= 3:", repr(r))
match 7:
    case n if n > 5:
        r = "big"
    case _:
        r = "small"
row("match 7: case n if n > 5:", repr(r))

print("6. your own class: identity until you define __eq__")


class Point:
    def __init__(self, x, y):
        self.x = x
        self.y = y


row("Point(1, 2) == Point(1, 2)", repr(Point(1, 2) == Point(1, 2)))


class Point:  # noqa: F811 -- redefined on purpose, now with __eq__
    def __init__(self, x, y):
        self.x = x
        self.y = y

    def __eq__(self, other):
        return isinstance(other, Point) and (self.x, self.y) == (other.x, other.y)


row("after def __eq__:  the same comparison", repr(Point(1, 2) == Point(1, 2)))
row("Point.__hash__ is None  (unhashable now)", repr(Point.__hash__ is None))
row("isinstance(Point(1, 2), Point)", repr(isinstance(Point(1, 2), Point)))
try:
    {Point(1, 2): "a", Point(1, 2): "b"}
except TypeError as e:
    row("{p1: 'a', p2: 'b'}  (equal points)", type(e).__name__)
