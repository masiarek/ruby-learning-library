"""An `__iter__` written as a generator function makes a class iterable;
there is no mixin to include, because the builtins and itertools accept any
iterable. A generator function is Ruby's Enumerator.new, and everything is
lazy by default. The rows match the Ruby program's rows."""

import collections.abc
import functools
import inspect
import itertools
import operator

W = 50


def row(n, label, value):
    print(f"{n:>2}. {label:<{W}} {value}")


class Countdown:
    def __init__(self, start):
        self.start = start

    def __iter__(self):                 # a generator function: yield makes it one
        n = self.start
        while n > 0:
            yield n
            n -= 1


def pair_sums(xs):
    for a, b in itertools.pairwise(xs):
        yield a + b


def three():
    yield 1
    yield 2
    yield 3


def fib():
    a, b = 0, 1
    while True:                         # never ends; the consumer stops it
        yield a
        a, b = b, a + b


c = Countdown(3)
it = iter(c)
row(1, "iter(c) calls __iter__ and gets a generator:", f"type {type(it).__name__}, next(it) = {next(it)}")
row(2, "the class defines __iter__, the builtins do the rest:", f"own methods {[m for m in vars(Countdown) if not m.startswith('__')] or 'none'}; map {[x * 10 for x in c]}, filter {[x for x in c if x % 2]}, sorted {sorted(c)}, 2 in c {2 in c}, min {min(c)}, sum {sum(c)}, islice(2) {list(itertools.islice(c, 2))}")
row(3, "itertools for the rest:", f"batched(2) {list(itertools.batched(c, 2))}, pairwise {list(itertools.pairwise(c))}, enumerate {list(enumerate(c))}, reduce {functools.reduce(operator.add, c)}, list {list(c)}")
try:
    len(c)
    size = "has len (unexpected)"
except TypeError as ex:
    size = type(ex).__name__
row(4, "c is iterable, iter(c) is the iterator:", f"Iterable {isinstance(c, collections.abc.Iterable)}, Iterator {isinstance(c, collections.abc.Iterator)} / {isinstance(it, collections.abc.Iterator)}, len(c) {size}, enumerate(c, 1) {list(enumerate(c, 1))}")
row(5, "a generator function in a plain def:", f"pair_sums([1, 2, 3]) is {type(pair_sums([1, 2, 3])).__name__}, list {list(pair_sums([1, 2, 3]))}")

gen = three()
pulled = [next(gen), next(gen), next(gen)]
try:
    next(gen)
    after = "no StopIteration (unexpected)"
except StopIteration as ex:
    after = type(ex).__name__
row(6, "def three(): yield 1; yield 2; yield 3:", f"list {list(three())}, next x3 {pulled}, then {after}, size: no len on a generator")
row(7, "an infinite generator, consumed a piece at a time:", f"islice(8) {list(itertools.islice(fib(), 8))}, islice(5) {list(itertools.islice(fib(), 5))}, batched(3) first 2 {list(itertools.islice(itertools.batched(fib(), 3), 2))}")
evens = filter(lambda x: x % 2 == 0, fib())
row(8, "lazy by default: filter and map are iterators:", f"islice(filter(even, fib()), 4) {list(itertools.islice(evens, 4))}, class {type(evens).__name__}, islice(map(sq, count(1)), 3) {list(itertools.islice(map(lambda x: x * x, itertools.count(1)), 3))}")
row(9, "accumulate as a generator from a seed:", f"accumulate(repeat(2), mul, initial=1) {list(itertools.islice(itertools.accumulate(itertools.repeat(2), operator.mul, initial=1), 5))}")
row(10, "Iterable is a protocol, checked by an ABC:", f"isinstance(c, Iterable) {isinstance(c, collections.abc.Iterable)}, isgeneratorfunction(Countdown.__iter__) {inspect.isgeneratorfunction(Countdown.__iter__)}")
