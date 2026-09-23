"""functools.reduce is Python's inject; there is no each_with_object, because a
for loop over an outer variable does that job. Rows are numbered to match
inject_and_each_with_object_rb.rb."""

import builtins
import math
import operator
from collections import Counter
from fractions import Fraction
from functools import reduce
from itertools import chain


def row(n, label, value):
    print(f"{n:2d}. {label:<58} {value!r}")


nums = [1, 2, 3, 4]
words = ["apple", "banana", "cherry"]
tenths = [0.1] * 10

print("functools.reduce")
row(1, "reduce(operator.add, nums)", reduce(operator.add, nums))
row(2, "reduce(lambda acc, x: acc + x, nums, 0)", reduce(lambda acc, x: acc + x, nums, 0))
row(3, "reduce(operator.add, nums, 10)  (initial value last)", reduce(operator.add, nums, 10))
row(4, "reduce(operator.mul, nums)", reduce(operator.mul, nums))
row(5, 'one name; hasattr(builtins, "reduce")', [reduce(operator.add, nums), hasattr(builtins, "reduce")])
try:
    reduce(operator.add, [])
except TypeError as e:
    row(6, "reduce(add, []) raises; reduce(add, [], 0); sum([])", [type(e).__name__, reduce(operator.add, [], 0), sum([])])


def never(a, b):
    raise AssertionError("never")


row(7, "reduce(never, [7])  (one element: no call)", reduce(never, [7]))
row(8, "reduce(lambda best, w: longer of the two, words)", reduce(lambda best, w: w if len(w) > len(best) else best, words))
row(9, "reduce(math.lcm, range(1, 6)), reduce(math.gcd, ...)", [reduce(math.lcm, range(1, 6)), reduce(math.gcd, [12, 18, 24])])

print()
print("sum is not reduce(add): floats are compensated since 3.12")
row(10, "reduce(operator.add, [0.1] * 10)", reduce(operator.add, tenths))
row(11, "sum([0.1] * 10), math.fsum([0.1] * 10)", [sum(tenths), math.fsum(tenths)])
row(12, "reduce(add, [1e100, 1.0, -1e100]), sum(...), fsum(...)", [reduce(operator.add, [1e100, 1.0, -1e100]), sum([1e100, 1.0, -1e100]), math.fsum([1e100, 1.0, -1e100])])
row(13, "reduce(add, [0.1, 0.2, 0.3]), sum(...)", [reduce(operator.add, [0.1, 0.2, 0.3]), sum([0.1, 0.2, 0.3])])
row(14, "sum([1, Fraction(1, 3)]), sum([1, 2], 0.0)", [sum([1, Fraction(1, 3)]), sum([1, 2], 0.0)])

print()
print("No each_with_object: a loop over an outer variable, or a comprehension")
sizes = {}
for w in words:
    sizes[w] = len(w)
row(15, "sizes = {}; for w in words: sizes[w] = len(w)", sizes)
row(16, "reduce(lambda h, w: h | {w: len(w)}, words, {})", reduce(lambda h, w: h | {w: len(w)}, words, {}))


def assign_only(h, x):
    h[x] = x * 10          # returns None, so None becomes the accumulator


try:
    reduce(assign_only, nums, {})
except TypeError as e:
    row(17, "reduce(assign_only, nums, {}) raises", type(e).__name__)
row(18, "reduce(lambda acc, x: acc + [x * 10], nums, [])", reduce(lambda acc, x: acc + [x * 10], nums, []))
row(19, "reduce's function always gets (acc, x)", [None, reduce(lambda a, b: (a, b), [5], "memo")])
acc = []
for w in words:
    acc.append(w)
row(20, "acc = []; for w in words: acc.append(w)", acc)
text = ""
for w in words:
    text += w             # a for loop has no scope of its own: += is kept
row(21, 'text = ""; for w in words: text += w  (kept)', text)
row(22, 'dict(Counter("banana"))', dict(Counter("banana")))

print()
print("Three more folds")
try:
    sum(words, "")
except TypeError as e:
    row(23, 'sum(words, "") raises; reduce(add, words)', [type(e).__name__, reduce(operator.add, words)])
row(24, "sum([[1, 2], [3, 4]], []), list(chain.from_iterable(...))", [sum([[1, 2], [3, 4]], []), list(chain.from_iterable([[1, 2], [3, 4]]))])
row(25, "sum(x * i for i, x in enumerate(nums)), unpacked in the for", sum(x * i for i, x in enumerate(nums)))
