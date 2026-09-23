"""Python passes callables, and an unbound method such as str.upper already
takes its receiver as the first argument -- which is what Symbol#to_proc
manufactures. operator.methodcaller, attrgetter, bound methods, functions
and any object with __call__ fill the same slot. The rows match the Ruby
program's rows."""

import functools
import inspect
import operator

W = 44


def row(n, label, value):
    print(f"{n:>2}. {label:<{W}} {value}")


def double(x):
    return x * 2


class Doubler:
    def __call__(self, x):
        return x * 2


class Quiet:
    def _secret(self):
        return 42


xs = ["a", "b"]
row(1, "map(str.upper, xs):", list(map(str.upper, xs)))

mc = operator.methodcaller("upper")
row(2, "an unbound method takes the receiver first:", f"str.upper('a') -> {str.upper('a')!r}, operator.add(1, 2) -> {operator.add(1, 2)}")
row(3, "so reduce works; no symbol shortcut:", f"reduce(add, xs) {functools.reduce(operator.add, [1, 2, 3])}, sum {sum([1, 2, 3])}, reduce(add, xs, 10) {functools.reduce(operator.add, [1, 2, 3], 10)}")
row(4, "methodcaller('upper') and str.upper's shape:", f"{type(mc).__name__} -> {mc('a')!r}, signature(str.upper) {inspect.signature(str.upper)}")
row(5, "map(double, xs), a plain function:", f"{list(map(double, [1, 2]))}, type {type(double).__name__}")
row(6, "map('xaby'.index, xs), a bound method:", list(map("xaby".index, xs)))
row(7, "any object with __call__:", f"map(Doubler(), xs) {list(map(Doubler(), [1, 2]))}")
row(8, "a dict's .get, keys in, values out:", f"map(d.get, ['a', 'b']) {list(map({'a': 1, 'b': 2}.get, xs))}")

try:
    list(map("upper", [1]))
    refused = "no error (unexpected)"
except TypeError as e:
    refused = type(e).__name__
try:
    list(map(None, [1, 2]))
    with_none = "no error (unexpected)"
except TypeError as e:
    with_none = type(e).__name__
row(9, "map('upper', xs) is refused; so is map(None, xs):", f"{refused}; {with_none}")

try:
    str.upper()
    row(10, "an unbound method needs a receiver:", "no error (unexpected)")
except TypeError as e:
    row(10, "an unbound method needs a receiver:", type(e).__name__)

row(11, "no private methods: _secret is callable:", f"map(Quiet._secret, [Quiet()]) {list(map(Quiet._secret, [Quiet()]))}")
