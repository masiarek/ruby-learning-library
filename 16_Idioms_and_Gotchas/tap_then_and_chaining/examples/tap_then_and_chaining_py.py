# Python has neither `tap` nor `then`. A call is `then`; `tap` is a two-line
# helper or the `(print(x), x)[1]` trick; a pipeline is `functools.reduce`.
import functools
import operator
import itertools


def row(n, label, value):
    print(f"{n:2d}. {label:<46} {value}")


def tap(value, fn):
    fn(value)
    return value


row(1, "tap(5, lambda v: v * 100)   (helper)", repr(tap(5, lambda v: v * 100)))
row(2, "(lambda v: v * 100)(5)      (a call is `then`)", repr((lambda v: v * 100)(5)))

print("    -- tap inside a chain, printing without breaking it --")
show_before = lambda a: print(f"       before sort: {a!r}")
show_after = lambda a: print(f"       after sort:  {a!r}")
result = [v * 10 for v in tap(sorted(tap([3, 1, 2], show_before)), show_after)]
row(3, "[v * 10 for v in tap(sorted(tap(xs, ..)), ..)]", repr(result))

row(4, 'int("5")', f"{int('5')!r} ({type(int('5')).__name__})")
row(5, "(lambda it: it + 1)(5)", repr((lambda it: it + 1)(5)))

total = sum(
    v
    for v in (x * 2 for x in [1, 2, 3])
    if v > 2
)
row(6, "generator pipeline over four lines, summed", repr(total))

groups = {k: list(g) for k, g in itertools.groupby(sorted([1, 2, 2]))}
row(7, "groupby(sorted(xs)); operator.identity exists?", f"{groups!r}  {hasattr(operator, 'identity')}")

strip = str.strip
lower = str.lower
snake = lambda s: s.replace(" ", "_")
pipe = lambda value, *fns: functools.reduce(lambda acc, fn: fn(acc), fns, value)
row(8, 'pipe("  Hello World ", strip, lower, snake)', repr(pipe("  Hello World ", strip, lower, snake)))


def compose(*fns):
    return lambda v: functools.reduce(lambda acc, fn: fn(acc), fns, v)


row(9, "compose(strip, lower, snake)(same string)", repr(compose(strip, lower, snake)("  Hello World ")))

row(10, "hasattr(5, 'then') / hasattr(5, 'tap')", f"{hasattr(5, 'then')} / {hasattr(5, 'tap')}")
row(11, '"  Hello World ".strip().lower().replace(" ", "_")', repr("  Hello World ".strip().lower().replace(" ", "_")))

seen = []
appended = seen.append(1)
row(12, "seen = []; seen.append(1) returns", f"{appended!r}; seen is {seen!r}  (no receiver comes back)")
