"""Python's iterator protocol from the outside: iter(), next(), StopIteration,
no peek and no rewind, and one cursor shared with for. Rows are numbered to
match external_enumerators_rb.rb."""

import operator
from itertools import count, islice


def row(n, label, value):
    print(f"{n:2d}. {label:<62} {value!r}")


print("next, and the end")
it = iter([1, 2])
row(1, "it = iter([1, 2]); type(it).__name__", type(it).__name__)
row(2, "next(it)", next(it))
row(3, 'hasattr(it, "peek")  (no peek: see the prose)', hasattr(it, "peek"))
row(4, "next(it)", next(it))
try:
    next(it)
except StopIteration as ex:
    row(5, "next(it) at the end raises: class, ex.value", [type(ex).__name__, ex.value])
try:
    next(it)
except StopIteration as ex:
    row(6, 'next(it) again: still exhausted; next(it, "default")', [type(ex).__name__, next(it, "default")])
row(7, 'hasattr(it, "rewind"), iter(it) is it, next(iter([1, 2]))', [hasattr(it, "rewind"), iter(it) is it, next(iter([1, 2]))])
try:
    len(iter([1, 2]))
except TypeError as ex:
    row(8, "length_hint(iter([1, 2])), length_hint(count()), len raises", [operator.length_hint(iter([1, 2])), operator.length_hint(count()), type(ex).__name__])

print()
print("for catches StopIteration silently, and a statement has no value")
arr = [10, 20, 30]
it2 = iter(arr)
seen = []
for x in it2:
    seen.append(x)
row(9, "seen; (a for loop has no value to compare)", [seen, None])

print()
print("There is one cursor: list() and for continue from where next left it")
it3 = iter([10, 20, 30])
first = next(it3)
row(10, 'next(it3); list(it3); next(it3, "exhausted")', [first, list(it3), next(it3, "exhausted")])
row(11, "list(enumerate(iter([1, 2]), 1))", list(enumerate(iter([1, 2]), 1)))

print()
print("Generators built by hand, and what they leave in StopIteration.value")


def two_then_done():
    yield 1
    yield 2
    return "done"


g = two_then_done()
two = [next(g), next(g)]
try:
    next(g)
except StopIteration as ex:
    row(12, "yield 1; yield 2; return 'done': next x2, ex.value", [two, ex.value])


def numbers():
    yield 1
    yield 2
    return "the_return"


def outer():
    r = yield from numbers()      # yield from hands the return value to r
    yield r


row(13, "for/list drop the return value; yield from captures it", [list(numbers()), list(outer())])


def boom():
    yield "a"
    raise RuntimeError("boom")


b = boom()
first = next(b)
try:
    next(b)
except RuntimeError as ex:
    row(14, "a raise inside the generator comes out of next", [first, f"{type(ex).__name__}: {ex}"])


def produce(x, step):
    while True:
        yield x
        x = step(x)


row(15, "list(islice(produce(1, lambda x: x * 2), 5))", list(islice(produce(1, lambda x: x * 2), 5)))
row(16, 'next(iter(x)) for range(3), "abc", {"a": 1}.items()', [next(iter(range(3))), next(iter("abc")), next(iter({"a": 1}.items()))])
row(17, "StopIteration.__mro__ names  (except Exception catches it)", [c.__name__ for c in StopIteration.__mro__][:3])
row(18, 'next(it2, "exhausted") on the it2 that for drained', next(it2, "exhausted"))
