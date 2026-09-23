# The Python twin: the same numbered rows as ranges_two_dots_and_three_rb.rb,
# asked of range, itertools.count and slices. Exceptions print their type only.

import string
from itertools import count, islice


def row(n, label, value):
    print(f"{n:2d}. {label:<56} {value}")


def raises(fn):
    try:
        return repr(fn())
    except Exception as e:
        return type(e).__name__


row(1,  "list(range(1, 6)), list(range(1, 5))  (half-open only)", repr([list(range(1, 6)), list(range(1, 5))]))
row(2,  "len(range(1, 6)), len(range(1, 5)), type(range(1, 6))",  f"[{len(range(1, 6))}, {len(range(1, 5))}, {type(range(1, 6)).__name__}]")
row(3,  "[chr(c) for c in range(97, 102)], ascii_lowercase[:5]",  repr([[chr(c) for c in range(97, 102)], string.ascii_lowercase[:5]]))
row(4,  "list(islice(count(1), 3)); count(1) has no end",         f"[{list(islice(count(1), 3))}, None]")
row(5,  "3 <= 5, 9 <= 5  (no beginless range: a comparison)",     repr([3 <= 5, 9 <= 5]))
row(6,  "list(count(1))  (not run: it would never return)",       "-")
row(7,  "list(range(1, 11, 3))  (the step is the third argument)", repr(list(range(1, 11, 3))))
row(8,  "range(1.0, 2.0); [1 + i * 0.5 for i in range(3)]",       f"{raises(lambda: range(1.0, 2.0))}, {[1 + i * 0.5 for i in range(3)]}")
letters = [chr(c) for c in range(ord("a"), ord("z") + 1)]
row(9,  '"bb" in letters (a list), "a" <= "bb" <= "z"',            repr(["bb" in letters, "a" <= "bb" <= "z"]))
row(10, "5.5 in range(1, 11), 5.0 in range(1, 11)",                repr([5.5 in range(1, 11), 5.0 in range(1, 11)]))

x = 42
match x:
    case n if n in range(1, 11):
        size = "small"
    case n if n in range(11, 101):
        size = "medium"
    case _:
        size = "large"
row(11, "match 42: case n if n in range(1, 11) / range(11, 101)", repr(size))

a = [10, 20, 30, 40, 50]
row(12, 'a[1:3], a[1:-1], a[:2], a[2:], "hello"[1:4]',             repr([a[1:3], a[1:-1], a[:2], a[2:], "hello"[1:4]]))
n = 10**12
row(13, "sum(range(1, 101)); n * (n + 1) // 2 for n = 10**12",     repr([sum(range(1, 101)), n * (n + 1) // 2]))
row(14, "range(1, 5)[-1], range(1, 5)[-1:], max(range(1, 5))",     f"[{range(1, 5)[-1]}, {range(1, 5)[-1:]}, {max(range(1, 5))}]")
row(15, "list(range(5, 1)), list(range(5, 0, -1))",                repr([list(range(5, 1)), list(range(5, 0, -1))]))
row(16, "range(1, 6) == range(1, 6, 1), range(0) == range(1, 1)",  repr([range(1, 6) == range(1, 6, 1), range(0) == range(1, 1)]))
row(17, "range(1, 6)[1], range(1, 6)[1:3]  (range is a sequence)", f"[{range(1, 6)[1]}, {range(1, 6)[1:3]}]")
row(18, "min(max(7, 1), 5), set(range(2, 4)) <= set(range(1, 6))", repr([min(max(7, 1), 5), set(range(2, 4)) <= set(range(1, 6))]))
