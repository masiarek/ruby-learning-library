"""Python has no symbol type: the twin of symbols_are_names_rb.rb.

A str does double duty as text and as a name; sys.intern and enum.Enum each do
part of a symbol's job. The rows follow the Ruby program's numbering.
"""
import enum
import functools
import operator
import sys


def row(label, shown):
    print(f"   {label:<44} {shown}")


class Color(enum.Enum):
    RED = enum.auto()
    GREEN = enum.auto()


print("1. one object per name (interning)")
row('sys.intern("a") is sys.intern("a")', repr(sys.intern("a") is sys.intern("a")))
a = "abc"
b = "abc"
row('a = "abc"; b = "abc"; a is b', repr(a is b))
c = "".join(["ab", "c"])
row('c = "".join(["ab", "c"]); a is c', repr(a is c))
row("sys.intern(c) is a", repr(sys.intern(c) is a))

print("2. a str is the only string; Enum is the nearest name type")
row('"a" == "a"  (no symbol to differ from)', repr("a" == "a"))
row('type("a").__name__', type("a").__name__)
row("Color.RED.name", repr(Color.RED.name))
row('Color["RED"] is Color.RED', repr(Color["RED"] is Color.RED))
row('Color.RED == "RED"', repr(Color.RED == "RED"))

print("3. every str is immutable; an Enum member is fixed")
s = "a"
try:
    s[0] = "b"
except TypeError as e:
    row('s = "a"; s[0] = "b"', type(e).__name__)
row('hash("a") == hash("a")  (usable as a key)', repr(hash("a") == hash("a")))
row("Color.RED is Color.RED", repr(Color.RED is Color.RED))
try:
    Color.RED = 1
except AttributeError as e:
    row("Color.RED = 1", type(e).__name__)

print("4. literal forms and dict keys")
row('["a", "b"]  (no %i)', repr(["a", "b"]))
row('"hello world"  (just a str)', repr("hello world"))
row('dict(a=1)  (the {a: 1} spelling)', repr(dict(a=1)))
row('type(next(iter(dict(a=1))))', type(next(iter(dict(a=1)))).__name__)
row('type(next(iter({"a": 1})))', type(next(iter({"a": 1}))).__name__)
row('{"a": 1}["a"]', repr({"a": 1}["a"]))
d = {}
d["k"] = 1
d["k"] = 2
row('d["k"] = 1; d["k"] = 2; d', repr(d))
row("len(d)", repr(len(d)))

print("5. method names are strings")
row('getattr("x", "upper")()', repr(getattr("x", "upper")()))


def greet():
    pass


row("def greet(): ...  (a statement)", "greet.__name__ == " + repr(greet.__name__))
row("str.upper.__name__", repr(str.upper.__name__))
row('"upper" in dir("x")', repr("upper" in dir("x")))

print("6. methodcaller and map do the job of &:sym")
row('operator.methodcaller("upper")("x")', repr(operator.methodcaller("upper")("x")))
row('list(map(str.upper, ["a", "b"]))', repr(list(map(str.upper, ["a", "b"]))))
row("functools.reduce(operator.add, [1, 2])", repr(functools.reduce(operator.add, [1, 2])))
