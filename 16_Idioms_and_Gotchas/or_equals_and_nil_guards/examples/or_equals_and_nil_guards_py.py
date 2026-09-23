# Python has no ||=. The idiom is `x = x or v`, which replaces EVERY falsy value,
# so the same twelve rows come out differently for 0 and "".
import functools


def row(n, label, value):
    print(f"{n:2d}. {label:<52} {value}")


print("The `x = x or v` idiom, value by value")
x = None;  x = x or 5; row(1, "x = None;  x = x or 5", repr(x))
x = False; x = x or 5; row(2, "x = False; x = x or 5  (False is replaced)", repr(x))
x = 0;     x = x or 5; row(3, "x = 0;     x = x or 5  (0 is falsy: replaced!)", repr(x))
x = "";    x = x or 5; row(4, 'x = "";    x = x or 5  ("" is falsy: replaced!)', repr(x))

print()
print("Memoization with functools.cache")
runs = 0


@functools.cache
def compute():
    global runs
    runs += 1
    return "value"


for _ in range(3):
    compute()
row(5, "@functools.cache compute(), called 3 times: ran", f"{runs} time(s)")

runs = 0


@functools.cache
def compute_false():
    global runs
    runs += 1
    return False


for _ in range(3):
    compute_false()
row(6, "@functools.cache of a False result, 3 calls: ran", f"{runs} time(s)  <- no trap: it caches the value")


class Config:
    def __init__(self):
        self.runs = 0

    @functools.cached_property
    def right(self):
        self.runs += 1
        return False


cfg = Config()
for _ in range(3):
    cfg.right
row(7, "@cached_property of a False result, 3 reads: ran", f"{cfg.runs} time(s)")

print()
print("The cousins")
a = 1;    a = a and a + 1
b = None; b = b and b + 1
row(8, "a = 1; a = a and a + 1 / b = None; b = b and b + 1", f"{a!r} / {b!r}")

h = {}
h.setdefault("k", []).append(1)
h.setdefault("k", []).append(2)
row(9, 'h.setdefault("k", []).append(1), then 2', repr(h))

try:
    list(None)
    as_list = "?"
except TypeError as e:
    as_list = type(e).__name__
row(10, "list(None) / (None or []) / list([1]) / list(range(1, 3))",
    f"{as_list} / {(None or [])!r} / {list([1])!r} / {list(range(1, 3))!r}")

h = {"a": 1}
try:
    h["z"]
    missing = "?"
except KeyError as e:
    missing = type(e).__name__
row(11, 'h["z"] / h.get("z", 0) / h.get("z") or "no z"', f"{missing} / {h.get('z', 0)!r} / {(h.get('z') or 'no z')!r}")

p1 = None or 5
p2 = None or 5
row(12, "p1 = None or 5 / p2 = None or 5", f"{p1!r} / {p2!r}  (or has ordinary precedence)")
