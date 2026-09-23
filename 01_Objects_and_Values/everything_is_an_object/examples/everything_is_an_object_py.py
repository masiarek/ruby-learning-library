"""Everything is an object in Python too: the twin of everything_is_an_object_rb.rb.

It prints the same numbered rows. Where Python has no counterpart to a Ruby row,
the row says so and prints the closest thing.
"""
import sys


def row(label, shown):
    print(f"   {label:<30} {shown}")


print("1. every value has a class")
row("type(1).__name__", type(1).__name__)
row("type(None).__name__", type(None).__name__)
row("type(True).__name__", type(True).__name__)
row("type(int).__name__", type(int).__name__)
row("type(type).__name__", type(type).__name__)

print("2. an operator is a method call")
row("1 + 2", repr(1 + 2))
row("(1).__add__(2)", repr((1).__add__(2)))
row('getattr(1, "__add__")(2)', repr(getattr(1, "__add__")(2)))

print("3. None is an object with methods")
try:
    list(None)
except TypeError as e:
    row("list(None) (no nil.to_a)", type(e).__name__)
row("str(None)", repr(str(None)))
row("repr(None)", repr(repr(None)))

print("4. a literal is a receiver")
try:
    (3).times
except AttributeError as e:
    row("(3).times (no counterpart)", type(e).__name__)
row('"a".upper()', repr("a".upper()))
try:
    compile("1.__class__", "<lesson>", "eval")
except SyntaxError as e:
    row("1.__class__ (compiled)", type(e).__name__)
row("(1).__class__.__name__", repr((1).__class__.__name__))

print("5. the ancestor chain")
row("int.__mro__ names", repr([c.__name__ for c in int.__mro__]))
row("type(None).__mro__ names", repr([c.__name__ for c in type(None).__mro__]))

print("6. everything is an object, classes included")
row("isinstance(1, object)", repr(isinstance(1, object)))
row("isinstance(None, object)", repr(isinstance(None, object)))
row("isinstance(int, object)", repr(isinstance(int, object)))
row("isinstance(int, type)", repr(isinstance(int, type)))

print("7. even the top level is an object")
row("__name__", repr(__name__))
row("type(sys.modules[__name__])", type(sys.modules[__name__]).__name__)

print("8. what a small integer cannot do")
x = 1
try:
    x.tag = "mine"
except AttributeError as e:
    row("x = 1; x.tag = 'mine'", type(e).__name__)
