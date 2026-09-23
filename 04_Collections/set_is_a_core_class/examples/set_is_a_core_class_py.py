# The Python twin: the same numbered rows as set_is_a_core_class_rb.rb, asked of
# set and frozenset. The iteration order of a set of strings changes from one
# process to the next, so the twin sorts those; small ints are printed raw,
# because they show the hash-table order. Exceptions print their type only.

import bisect
import builtins


def row(n, label, value):
    print(f"{n:2d}. {label:<64} {value}")


def raises(fn):
    try:
        return repr(fn())
    except Exception as e:
        return type(e).__name__


class Plain:
    def __init__(self, v):
        self.v = v


class ByValue:
    def __init__(self, v):
        self.v = v

    def __eq__(self, other):
        return isinstance(other, ByValue) and self.v == other.v

    def __hash__(self):
        return hash(self.v)


class EqOnly:
    def __init__(self, v):
        self.v = v

    def __eq__(self, other):
        return isinstance(other, EqOnly) and self.v == other.v


row(1,  '"set" in dir(builtins), type(set()), type({})',            repr(["set" in dir(builtins), type(set()).__name__, type({}).__name__]))
row(2,  'hasattr(set.add, "__code__")  (built in: no Python source)', hasattr(set.add, "__code__"))
row(3,  "{3, 1, 2}, set([3, 1]), frozenset(range(1, 4))",            repr([{3, 1, 2}, set([3, 1]), frozenset(range(1, 4))]))

s = {3, 1, 2}
before = list(s)
s.discard(1)
s.add(1)
row(4,  "list({3, 1, 2}); after discard(1), add(1); list({8, 1})",   repr([before, list(s), list({8, 1})]))

s = {1, 2}
row(5,  "s = {1, 2}; s.add(3) (returns None); 3 in s; s.add(4)",    repr([s.add(3), 3 in s, s.add(4)]))
row(6,  "{1, 2} | {2, 3}, &, -, ^",                                  repr([{1, 2} | {2, 3}, {1, 2} & {2, 3}, {1, 2} - {2, 3}, {1, 2} ^ {2, 3}]))
row(7,  "{1} <= {1, 2}, issubset, <, {1}.isdisjoint({2})",           repr([{1} <= {1, 2}, {1}.issubset({1, 2}), {1} < {1, 2}, {1}.isdisjoint({2})]))
equal = {1, 2} == {2, 1}
nested = raises(lambda: {{1}})
frozen_in = frozenset({1}) in {frozenset({1})}
row(8,  "{1, 2} == {2, 1}; {{1}}; {frozenset({1})}; frozenset({1}) == {1}", f"[{equal}, {nested}, {frozen_in}, {frozenset({1}) == {1}}]")
match 2:
    case x if x in {1, 2}:
        verdict = "in"
    case _:
        verdict = "out"
row(9,  "2 in {1, 2}; match 2: case x if x in {1, 2}",               repr([2 in {1, 2}, verdict]))
row(10, "comprehension, filter, sorted, | : the type each returns",  repr([type({x for x in s}).__name__, type([x for x in s if x]).__name__, type(sorted(s)).__name__, type(s | s).__name__]))
row(11, "s.discard(9) (returns None, no error), s.remove(9)",        f"[{s.discard(9)}, {raises(lambda: s.remove(9))}]")
row(12, "frozenset({1}).add(2)",                                     raises(lambda: frozenset({1}).add(2)))
row(13, "len({x, x'}) for Plain, ByValue (__eq__+__hash__), EqOnly", repr([len({Plain(1), Plain(1)}), len({ByValue(1), ByValue(1)}), raises(lambda: {EqOnly(1), EqOnly(1)})]))
row(14, "{[1, 2]}; (1, 2) in {(1, 2)}; len and repr of {1, 1.0, True}", f"[{raises(lambda: {[1, 2]})}, {(1, 2) in {(1, 2)}}, {len({1, 1.0, True})}, {({1, 1.0, True})!r}]")
row(15, "a list is refused at insertion (row 14): no stale element",  "-")
row(16, "no sorted set: sorted(s), or bisect.bisect([1, 3, 5], 4)",  repr([sorted({3, 1, 2}), bisect.bisect([1, 3, 5], 4)]))
row(17, 'sorted(set("hello")), list(dict.fromkeys("hello"))',        repr([sorted(set("hello")), list(dict.fromkeys("hello"))]))
row(18, "{1, 2} < {1, 2, 3}, {1} < {2}, {1} > {2}  (no <=>)",          repr([{1, 2} < {1, 2, 3}, {1} < {2}, {1} > {2}]))
