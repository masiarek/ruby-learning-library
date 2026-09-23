# The Python twin: the same numbered rows as comparable_and_spaceship_rb.rb,
# asked of rich comparisons, functools.total_ordering and sorted. Exceptions
# print their type only.

import functools
import heapq
import math


def row(n, label, value):
    print(f"{n:2d}. {label:<60} {value}")


def raises(fn):
    try:
        return repr(fn())
    except Exception as e:
        return type(e).__name__


def cmp(a, b):
    """Python has no <=>; this is the idiom: -1, 0 or 1."""
    return (a > b) - (a < b)


@functools.total_ordering
class Version:
    def __init__(self, text):
        self.parts = [int(p) for p in text.split(".")]

    def __eq__(self, other):
        return isinstance(other, Version) and self.parts == other.parts

    def __lt__(self, other):
        if not isinstance(other, Version):
            return NotImplemented
        return self.parts < other.parts

    def __repr__(self):
        return "v" + ".".join(map(str, self.parts))


class OnlyLt:
    def __init__(self, v):
        self.v = v

    def __lt__(self, other):
        return self.v < other.v

    def __repr__(self):
        return f"L{self.v}"


row(1,  "cmp(1, 2), cmp(2, 2), cmp(3, 2)  with cmp = (a > b) - (a < b)", repr([cmp(1, 2), cmp(2, 2), cmp(3, 2)]))
row(2,  '1 < "a"; None < 1; None == None',                               f'{raises(lambda: 1 < "a")}, {raises(lambda: None < 1)}, {None == None}')
row(3,  '(1, 2) < (1, 3), (1, 2) < (1, 2, 0), (1, "a") < (1, 2)',       f'{(1, 2) < (1, 3)}, {(1, 2) < (1, 2, 0)}, {raises(lambda: (1, "a") < (1, 2))}')
a = Version("1.10")
b = Version("1.9")
row(4,  "Version a = v1.10, b = v1.9: a > b, a < b, a == v1.10, a >= b", repr([a > b, a < b, a == Version("1.10"), a >= b]))
row(5,  "b <= a <= v2.0, min(max(a, b), b), min(max(a, v0.1), v1.0)",    repr([b <= a <= Version("2.0"), min(max(a, b), b), min(max(a, Version("0.1")), Version("1.0"))]))
row(6,  "sorted([a, b, v1.2]), min(a, b), max(a, b)",                   repr([sorted([a, b, Version("1.2")]), min(a, b), max(a, b)]))
row(7,  'a < "1.0"; a == "1.0"',                                        f'{raises(lambda: a < "1.0")}; {a == "1.0"}')
row(8,  "comparison methods in vars(Version)  (total_ordering added 3)", repr(sorted(m for m in vars(Version) if m in {"__eq__", "__lt__", "__le__", "__gt__", "__ge__"})))
row(9,  "1 < 2, 'a' < 'b', 1.0 < 2.0, [1] < [2]; None < None",          f"{[1 < 2, 'a' < 'b', 1.0 < 2.0, [1] < [2]]}; {raises(lambda: None < None)}")
row(10, "[1, 2] < [1, 3]",                                              repr([1, 2] < [1, 3]))
row(11, "[3, None].sort(); max([3, None])",                             f"{raises(lambda: [3, None].sort())}; {raises(lambda: max([3, None]))}")
row(12, '[3, "a"].sort()',                                              raises(lambda: [3, "a"].sort()))
row(13, "sorted(xs, key=lambda x: (x is None, x)); without the Nones", repr([sorted([3, None], key=lambda x: (x is None, x)), sorted(x for x in [3, None] if x is not None)]))
l1, l2 = OnlyLt(1), OnlyLt(2)
row(14, "OnlyLt: sorted, min, max; l1 > l2; l1 <= l2; l1 == L1",        f"{sorted([l2, l1])}, {min(l2, l1)}, {max(l2, l1)}; {l1 > l2}; {raises(lambda: l1 <= l2)}; {l1 == OnlyLt(1)}")
nan = math.nan
row(15, "nan < 1.0, nan > 1.0; sorted([nan, 1.0])  (no error)",         f"{[nan < 1.0, nan > 1.0]}; {sorted([nan, 1.0])}")
row(16, '"a" < "B", "abc" > "ab"  (no symbols)',                        repr(["a" < "B", "abc" > "ab"]))
row(17, "1 == 1.0, type(max([1, 1.0])), type(max([1.0, 1]))",           repr([1 == 1.0, type(max([1, 1.0])).__name__, type(max([1.0, 1])).__name__]))
row(18, "sorted(xs, reverse=True), heapq.nlargest(2, xs), (min, max)",  repr([sorted([3, 1, 2], reverse=True), heapq.nlargest(2, [3, 1, 2]), (min([3, 1, 2]), max([3, 1, 2]))]))
row(19, "min(max(2, 3), 1)  (no check that lo <= hi)",                  min(max(2, 3), 1))
