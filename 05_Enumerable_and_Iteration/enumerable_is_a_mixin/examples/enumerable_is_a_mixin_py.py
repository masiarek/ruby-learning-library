"""Python has no Enumerable to include: an object with __iter__ is iterable, and
the toolbox lives in builtins and itertools rather than on the object. The one
place Python does the same trick is collections.abc.Sequence. Rows are numbered
to match enumerable_is_a_mixin_rb.rb."""

import builtins
import os
from collections import namedtuple
from collections.abc import Iterable, Sequence
from itertools import batched, islice


def row(n, label, value):
    print(f"{n:2d}. {label:<52} {value!r}")


class Bare:                     # knows how to walk its items, and nothing else
    def __iter__(self):
        yield "Emma"
        yield "Dracula"


class Shelf:                    # there is no line to add: __iter__ is all Python asks
    def __init__(self, *titles):
        self._titles = titles

    def __iter__(self):
        yield from self._titles


shelf = Shelf("Emma", "Dracula", "Middlemarch", "Persuasion")   # sizes 4, 7, 11, 10: no ties

print("A class with only __iter__: nothing to include, and no methods arrive")
bare = Bare()
row(1, 'hasattr(bare, "map")  (__iter__, nothing else)', hasattr(bare, "map"))
try:
    bare.map(lambda t: t)
except AttributeError as e:
    row(2, "bare.map(...) raises", type(e).__name__)
row(3, "Shelf.__mro__ names, isinstance(shelf, Iterable)", ([c.__name__ for c in Shelf.__mro__], isinstance(shelf, Iterable)))
row(4, 'hasattr(shelf, "map")', hasattr(shelf, "map"))

print()
print("The same handful, as builtins and itertools taking the iterable")
row(5, "list(map(str.upper, shelf))", list(map(str.upper, shelf)))
row(6, "[t for t in shelf if len(t) > 6]", [t for t in shelf if len(t) > 6])
row(7, "sorted(shelf, key=len)", sorted(shelf, key=len))
row(8, "min(shelf, key=len)", min(shelf, key=len))
row(9, '"Emma" in shelf  (in falls back to __iter__)', "Emma" in shelf)
row(10, "next(iter(shelf)), list(islice(shelf, 2))", [next(iter(shelf)), list(islice(shelf, 2))])
row(11, "list(batched(shelf, 3))  (3.12+)", list(batched(shelf, 3)))
row(12, "list(shelf)", list(shelf))
row(13, "list(enumerate(shelf))", list(enumerate(shelf)))
try:
    sum(shelf, "")
except TypeError as e:
    row(14, 'sum(shelf, "") raises; "".join(shelf)', [type(e).__name__, "".join(shelf)])
row(15, "type(map(str.lower, shelf)).__name__  (lazy already)", type(map(str.lower, shelf)).__name__)
row(16, "list(islice(map(str.lower, shelf), 2))", list(islice(map(str.lower, shelf), 2)))
row(17, "type(iter(shelf)).__name__, next(iter(shelf))", [type(iter(shelf)).__name__, next(iter(shelf))])

print()
print("Builtins that are Iterable, and one that is not")
Point = namedtuple("Point", "x y")
with os.scandir(".") as entries:
    samples = [
        ("[]", []), ("{}", {}), ("range(3)", range(3)), ("Point(1, 2)", Point(1, 2)),
        ('os.scandir(".")', entries), ("set()", set()), ("iter([])", iter([])),
        ('"abc"', "abc"), ("3", 3),
    ]
    for i, (label, value) in enumerate(samples):
        row(18 + i, f"isinstance({label}, Iterable)", isinstance(value, Iterable))

print()
print("The mixin idea, seen from the ABCs' side")
row(27, "sorted(Iterable.__abstractmethods__)", sorted(Iterable.__abstractmethods__))
row(28, 'hasattr(shelf, "sorted"), "sorted" in dir(builtins)', [hasattr(shelf, "sorted"), "sorted" in dir(builtins)])
row(29, 'list.__mro__ names, hasattr(list, "map")', ([c.__name__ for c in list.__mro__], hasattr(list, "map")))
row(30, "sorted(Sequence.__abstractmethods__)  (a real mixin)", sorted(Sequence.__abstractmethods__))


class Deck(Sequence):           # supply the two abstract methods...
    def __init__(self, *cards):
        self._cards = cards

    def __getitem__(self, i):
        return self._cards[i]

    def __len__(self):
        return len(self._cards)


deck = Deck("A", "K", "Q", "K")   # ...and in, index, count, iter and reversed arrive
row(31, 'deck: "K" in, .index("Q"), .count("K"), reversed', ["K" in deck, deck.index("Q"), deck.count("K"), list(reversed(deck))])
