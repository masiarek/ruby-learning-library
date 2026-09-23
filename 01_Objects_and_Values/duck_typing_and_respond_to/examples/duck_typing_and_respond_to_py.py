"""Duck typing in Python: the twin of duck_typing_and_respond_to_rb.rb.

hasattr and isinstance do the asking, a runtime_checkable Protocol makes a
duck test into a type, and the dunder protocols (__iter__, __call__,
__index__, __fspath__) are the implicit conversions. Same rows, same order.
"""
import numbers
import os
from collections.abc import Hashable, Iterable
from typing import Protocol, runtime_checkable


def row(label, shown):
    print(f"   {label:<52} {shown}")


print("1. ask what it does, not what it is")
row('hasattr([], "__iter__")', repr(hasattr([], "__iter__")))
row('hasattr({}, "__iter__")', repr(hasattr({}, "__iter__")))
row('hasattr(range(2), "__iter__")', repr(hasattr(range(2), "__iter__")))
row('hasattr("", "__iter__")  (a str is iterable)', repr(hasattr("", "__iter__")))
row('hasattr(1, "__iter__")', repr(hasattr(1, "__iter__")))

print("2. the three what-is-it tests")
row("isinstance(1, numbers.Number)", repr(isinstance(1, numbers.Number)))
row("isinstance(True, int)  (a subclass counts)", repr(isinstance(True, int)))
row("type(True) is int", repr(type(True) is int))
row("type(1) is int", repr(type(1) is int))
row("isinstance(1, Hashable)  (an ABC counts)", repr(isinstance(1, Hashable)))

print("3. anything that quacks")


@runtime_checkable
class Quacker(Protocol):
    def quack(self) -> str: ...


class Duck:
    def quack(self):
        return "Quack"


class Robot:
    def quack(self):
        return "Beep"


class Rock:
    pass


flock = [Duck(), Robot()]
row('[d.quack() for d in flock if hasattr(d, "quack")]', repr([d.quack() for d in flock if hasattr(d, "quack")]))
row('hasattr(Rock(), "quack")', repr(hasattr(Rock(), "quack")))
try:
    Rock().quack()
except AttributeError as e:
    row("Rock().quack()", type(e).__name__)
row("[isinstance(d, Quacker) for d in flock]  (Protocol)", repr([isinstance(d, Quacker) for d in flock]))

print("4. __iter__ makes a collection")


class Countdown:
    def __init__(self, start):
        self.start = start

    def __iter__(self):
        yield from range(self.start, 0, -1)


c = Countdown(3)
row('c = Countdown(3); hasattr(c, "__iter__")', repr(hasattr(c, "__iter__")))
row("[i * 10 for i in c]", repr([i * 10 for i in c]))
row("2 in c", repr(2 in c))
row("sorted(c)", repr(sorted(c)))
row("isinstance(c, Iterable)", repr(isinstance(c, Iterable)))
row("isinstance(c, list)", repr(isinstance(c, list)))

print("5. the implicit protocols the core calls for you")


class Name:
    def __init__(self, n):
        self.n = n

    def __str__(self):
        return self.n


class Pair:
    def __iter__(self):
        return iter((1, 2))


class Doubler:
    def __call__(self, x):
        return x * 2


class Idx:
    def __index__(self):
        return 1


class Loc:
    def __fspath__(self):
        return "some/path.txt"


class Plain:
    def __str__(self):
        return "plain"


row('"Hello, " + str(Name("Ada"))  (no to_str)', repr("Hello, " + str(Name("Ada"))))
a, b = Pair()
row("a, b = Pair()  (__iter__)", repr([a, b]))
row("list(map(Doubler(), [1, 2]))  (__call__)", repr(list(map(Doubler(), [1, 2]))))
row("[10, 20, 30][Idx()]  (__index__)", repr([10, 20, 30][Idx()]))
row("os.path.basename(Loc())  (__fspath__)", repr(os.path.basename(Loc())))
try:
    "x" + Plain()
except TypeError as e:
    row('"x" + Plain()  (__str__ is not implicit)', type(e).__name__)

print("6. list() and int() convert on request")
try:
    list(None)
except TypeError as e:
    row("list(None)", type(e).__name__)
row("list([1])", repr(list([1])))
try:
    list(1)
except TypeError as e:
    row("list(1)", type(e).__name__)
row('list({"a": 1})  (the keys)', repr(list({"a": 1})))
row('int("42")', repr(int("42")))
try:
    int("4x")
except ValueError as e:
    row('int("4x")', type(e).__name__)
try:
    int(None)
except TypeError as e:
    row("int(None)", type(e).__name__)
row('"4x".isdigit()  (no lenient to_i)', repr("4x".isdigit()))
