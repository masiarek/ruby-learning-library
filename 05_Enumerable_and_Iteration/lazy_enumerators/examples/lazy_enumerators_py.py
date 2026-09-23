"""Python's generators, and its map and filter builtins, are lazy from birth:
there is no .lazy to call, and the eager spelling is the list comprehension.
Rows are numbered to match lazy_enumerators_rb.rb."""

import operator
from collections.abc import Iterator
from itertools import batched, chain, count, dropwhile, islice, takewhile


def row(n, label, value):
    print(f"{n:2d}. {label:<56} {value!r}")


trace = []


def times_ten(x):
    trace.append(f"map({x})")
    return x * 10


def big(x):
    trace.append(f"select({x})")
    return x > 10


print("Eager: a list comprehension runs to its end before the next one starts")
mapped = [times_ten(x) for x in range(1, 5)]
r = [x for x in mapped if big(x)]
print("    " + " ".join(trace))
row(1, "[times_ten(x) for ...], then [x for ... if big(x)]", r)

trace.clear()
print("Lazy: generator expressions interleave, and islice stops at the second hit")
mapped = (times_ten(x) for x in range(1, 5))
kept = (x for x in mapped if big(x))
r = list(islice(kept, 2))
print("    " + " ".join(trace))
row(2, "list(islice((x for x in (...) if big(x)), 2))", r)

print()
print("An endless source: itertools.count, which only a lazy chain can map over")
row(3, "islice((x for x in (x * 2 for x in count(1)) if % 3), 3)", list(islice((x for x in (x * 2 for x in count(1)) if x % 3 == 0), 3)))
calls = 0


def double(x):
    global calls
    calls += 1
    return x * 2


r = list(islice(filter(lambda x: x % 3 == 0, map(double, count(1))), 3))
row(4, "filter(..., map(double, count(1))); map calls it took", [r, calls])
row(5, "list(takewhile(lambda x: x < 4, count(1)))", list(takewhile(lambda x: x < 4, count(1))))
row(6, "list(islice(batched(count(1), 2), 2))", list(islice(batched(count(1), 2), 2)))
row(7, "islice((x * 2 for x in count(1) if x % 2 == 0), 3)", list(islice((x * 2 for x in count(1) if x % 2 == 0), 3)))
row(8, "islice((x * i for i, x in enumerate(count(1))), 3)", list(islice((x * i for i, x in enumerate(count(1))), 3)))
row(9, 'list(islice(zip(count(1), "abc"), 2))', list(islice(zip(count(1), "abc"), 2)))


def unique(items):            # no lazy uniq in the stdlib: a generator with a seen-set
    seen = set()
    for x in items:
        if x not in seen:
            seen.add(x)
            yield x


row(10, "islice(unique(x % 3 for x in count(1)), 3)", list(islice(unique(x % 3 for x in count(1)), 3)))
row(11, "islice(chain.from_iterable([x, -x] for x in count), 4)", list(islice(chain.from_iterable([x, -x] for x in count(1)), 4)))
row(12, "islice(dropwhile(lambda x: x < 5, count(1)), 2)", list(islice(dropwhile(lambda x: x < 5, count(1)), 2)))

print()
print("Which objects are lazy, and which calls run the chain")
gen = (x for x in range(1, 5))
row(13, "type(genexp), type(map(...)), type(filter(...))", [type(gen).__name__, type(map(str, gen)).__name__, type(filter(None, gen)).__name__])
row(14, "type(islice(count(1), 2)), type(list(islice(...)))", [type(islice(count(1), 2)).__name__, type(list(islice(count(1), 2))).__name__])
row(15, "list(islice((x * x for x in count(1)), 3))  (list = force)", list(islice((x * x for x in count(1)), 3)))
row(16, "type([x for x in range(4)]), type(list(map(...)))", [type([x for x in range(4)]).__name__, type(list(map(str, range(4)))).__name__])
row(17, "5 in count(1), sum(x * 2 for x in range(1, 4))", [5 in count(1), sum(x * 2 for x in range(1, 4))])
try:
    len(count(1))
except TypeError as e:
    row(18, "len(count(1)) raises; length_hint(iter([1,2,3])), (map)", [type(e).__name__, operator.length_hint(iter([1, 2, 3])), operator.length_hint(map(str, [1, 2, 3]))])
e = (x * 2 for x in count(1))
row(19, "e = (x * 2 for x in count(1)); next(e), next(e)", [next(e), next(e)])
row(20, "type(e).__mro__ names, isinstance(e, Iterator)", [[c.__name__ for c in type(e).__mro__], isinstance(e, Iterator)])
