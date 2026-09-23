"""Python has no block syntax: whatever a method would yield to is an ordinary
callable object passed as an argument -- a lambda, an inner def, a partial.
The rows match the Ruby program's rows; where Python differs, the row says so."""

import functools
import operator
from contextlib import contextmanager

W = 46


def row(n, label, value):
    print(f"{n:>2}. {label:<{W}} {value}")


def apply(fn):
    return fn(21)                       # calls the callable, takes its value


def report(callback=None):
    return f"callback given? {callback is not None}"


def bare(fn=None):
    return fn()                         # None is not callable: TypeError


def inner(fn):
    return fn(5)


def outer(fn):
    return inner(fn)                    # the callable is passed on like any value


def show(arg):
    return f"show received {arg!r}"


@contextmanager
def bracket():
    print("    before")
    yield
    print("    after")


def both(f, g):
    return [f(21), g(21)]


row(1, "a callable takes 21 and hands back its value:", apply(lambda x: x * 2))
row(2, "callback given? without one / with one:", f"{report()} / {report(print)}")

try:
    bare()
    row(3, "calling a missing callback:", "no error (unexpected)")
except TypeError as e:
    row(3, "calling a missing callback:", type(e).__name__)

f = lambda a: a                                                      # noqa: E731
row(4, "a lambda on its own, f = lambda a: a:", f"{type(f).__name__} - a lambda is an expression")

row(5, "two callables on one call, both(f, g):", f"{both(lambda x: x * 2, functools.partial(operator.mul, 2))} - any number")

def add_one(x):
    return x + 1

row(6, "nothing to reify, it is an object already:", f"{type(add_one).__name__}, callable? {callable(add_one)}, add_one(1) = {add_one(1)}; not passed: {report.__defaults__[0]}")
row(7, "passing it on as an argument:", outer(lambda v: v * 10))
row(8, "map takes the callable as an argument:", show(list(map(lambda x: x * 2, [1, 2]))))
row(9, "the same with a comprehension:", show([x * 2 for x in [1, 2]]))

print("10. with runs before/after around its suite:")
with bracket():
    print("    inside")
print("    the with statement is a statement: it has no value to return")
