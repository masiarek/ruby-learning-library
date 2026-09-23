# The Python twin: the same numbered rows as arrays_and_negative_indexes_rb.rb,
# asked of a Python list. Exceptions print their type name only.

import operator
from itertools import chain


def row(n, label, value):
    print(f"{n:2d}. {label:<44} {value}")


def raises(fn):
    try:
        return repr(fn())
    except Exception as e:
        return type(e).__name__


def flatten(xs):
    """Python has no list.flatten: a recursive helper, or chain for one level."""
    out = []
    for x in xs:
        out.extend(flatten(x) if isinstance(x, list) else [x])
    return out


def setitem(xs, i, v):
    xs[i] = v
    return xs


a = [10, 20, 30, 40]
row(1,  "a = [10, 20, 30, 40]; len(a)",              len(a))
row(2,  "a[0], a[-1]  (negative: from the end)",     repr([a[0], a[-1]]))
row(3,  "a[10], a[-10]  (past either end)",           f"{raises(lambda: a[10])}, {raises(lambda: a[-10])}")
row(4,  "a[10] is already the raising form",          raises(lambda: a[10]))
row(5,  "a[10] if len(a) > 10 else 'none'",           repr(a[10] if len(a) > 10 else "none"))
row(6,  "a[1:3]  (stop excluded; no inclusive form)", repr(a[1:3]))
row(7,  "a[1:3]  (the only slice form)",              repr(a[1:3]))
row(8,  "a[1:]  (to the end)",                        repr(a[1:]))
row(9,  "a[1:1 + 2]  (no start, length form)",        repr(a[1:1 + 2]))
row(10, "a[4:], a[5:]  (slice at / past the end)",    repr([a[4:], a[5:]]))

b = a[:]
row(11, "b[5] = 99 on a 4-element copy",              raises(lambda: setitem(b, 5, 99)))
d = a[:]
row(12, "d = a[:]; d[-5] = 1  (before the start)",  raises(lambda: setitem(d, -5, 1)))
row(13, "a[:2], a[-2:], [][0]",                       f"{a[:2]}, {a[-2:]}, {raises(lambda: [][0])}")
row(14, "itemgetter(0, 2)(a); with 10 too",           f"{operator.itemgetter(0, 2)(a)}, {raises(lambda: operator.itemgetter(0, 2, 10)(a))}")

x = [[]] * 3
x[0].append(1)
row(15, "[[]] * 3 then x[0].append(1)  (shared)",     repr(x))
y = [[] for _ in range(3)]
y[0].append(1)
row(16, "[[] for _ in range(3)] then y[0]... (fresh)", repr(y))

nested = [[1], [2, [3, [4]]]]
row(17, "flatten(nested) helper, chain one level",    repr([flatten(nested), list(chain.from_iterable(nested))]))

c = [1, 2]
row(18, "c = [1, 2]; c.append(3), c.extend([4]), c",  repr([c.append(3), c.extend([4]), c]))
row(19, "c.pop(), c.pop(0), then c",                  repr([c.pop(), c.pop(0), c]))
row(20, "c.insert(0, 0), then c",                     repr([c.insert(0, 0), c]))


def f(*args):
    return args


row(21, "[*a, 5], [*range(1, 4)], f(*a) with *args",  repr([[*a, 5], [*range(1, 4)], f(*a)]))
row(22, "a - [20]; sorted(set(a) - {20})",            f"{raises(lambda: a - [20])}, {sorted(set(a) - {20})}")
