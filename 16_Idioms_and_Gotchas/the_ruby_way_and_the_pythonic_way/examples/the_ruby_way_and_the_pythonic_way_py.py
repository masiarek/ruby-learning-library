# The same nineteen rows, the Pythonic way; then the one-way check (no aliases),
# the Zen as `import this` prints it, and the same word-frequency program.
import collections
import contextlib
import dataclasses
import enum
import functools
import io
import json
import re
import sys
from fractions import Fraction


def row(n, label, value):
    print(f"{n:2d}. {label:<40} {value}")


print("The idiom pairs")
out = ""
for x in [1, 2, 3]:
    out += str(x)
row(1, "for x in [1, 2, 3]: out += str(x)", repr(out))
row(2, "[x * x for x in xs if x % 2 == 0]", repr([x * x for x in [1, 2, 3, 4] if x % 2 == 0]))
row(3, "not [] / not [1]", f"{not []} / {not [1]}")
a = [3, 1]
row(4, "a = [3, 1]; a.sort() returns", f"{a.sort()!r}  (a is now {a!r})")
row(5, 'if not any([]): "empty"', repr("empty" if not any([]) else None))


class Person:
    pass


person = Person()
person.name = "ann"
row(6, 'person.name = "ann"  (no declaration)', repr(person.name))
row(7, "type(None).__name__ / repr(None) / str(None)", f"{type(None).__name__} / {None!r} / {str(None)!r}")

captured = io.StringIO()
with contextlib.redirect_stdout(captured):
    returned = print("hi")
row(8, f'r = print("hi")  (printed {captured.getvalue()!r})', f"r = {returned!r}")
row(9, "import json twice", f"{type(json).__name__} / {'json' in sys.modules}  (loaded once, cached in sys.modules)")
h = {"a": 1}
row(10, '{"a": 1}["a"] / .get("z") / .get("z", 0)', f"{h['a']} / {h.get('z')!r} / {h.get('z', 0)}")


class Key(enum.Enum):
    A = "a"


row(11, 'sys.intern("a") is sys.intern("a") / Key.A', f"{sys.intern('a') is sys.intern('a')} / {Key.A!r}")


class Greeting:
    def hello(self):
        return "hello from the mixin"


class Host(Greeting):
    pass


row(12, "class Host(Greeting): Host().hello()", f"{Host().hello()!r}  mro {[c.__name__ for c in Host.__mro__]!r}")


@functools.total_ordering
class Version:
    def __init__(self, n):
        self.n = n

    def __eq__(self, other):
        return self.n == other.n

    def __lt__(self, other):
        return self.n < other.n


row(13, "@total_ordering, __lt__ and __eq__: V(1) < V(2)", f"{Version(1) < Version(2)}  <= {Version(1) <= Version(3)}")


class Bag:
    def __init__(self, *xs):
        self.xs = xs

    def __iter__(self):
        return iter(self.xs)


row(14, "__iter__ only: sorted(bag) / map", f"{sorted(Bag(2, 1))!r} / {list(map(lambda v: v * 10, Bag(2, 1)))!r}")


class Finder:
    def __getattr__(self, name):
        if name.startswith("find_by_"):
            return lambda value: f"{name[len('find_by_'):]}={value}"
        raise AttributeError(name)


row(15, '__getattr__: Finder().find_by_name("x")', repr(Finder().find_by_name("x")))

Point = collections.namedtuple("Point", "x y")
row(16, 'namedtuple("Point", "x y")(1, 2)', repr(Point(1, 2)))


@dataclasses.dataclass(frozen=True)
class Coord:
    x: int
    y: int


try:
    Coord(1, 2).x = 9
except dataclasses.FrozenInstanceError as e:
    frozen = type(e).__name__
row(17, "frozen dataclass: replace(y=5) / set .x", f"{dataclasses.replace(Coord(1, 2), y=5)!r} / {frozen}")


def shape(v):
    match v:
        case [x, y]:
            return f"pair {x},{y}"
        case {"name": str() as n}:
            return f"named {n}"
        case _:
            return "other"


row(18, 'match: shape([1, 2]) / shape({"name": "ann"})', f"{shape([1, 2])!r} / {shape({'name': 'ann'})!r}")
row(19, "Fraction(1, 3) + Fraction(1, 6)", repr(Fraction(1, 3) + Fraction(1, 6)))

print()
print("One obvious way: the aliases Ruby has do not exist")
print(f"    hasattr([], 'collect') {hasattr([], 'collect')}, hasattr([], 'filter') {hasattr([], 'filter')}, "
      f"hasattr([], 'length') {hasattr([], 'length')}, hasattr([], 'size') {hasattr([], 'size')}, "
      f"hasattr(5, 'then') {hasattr(5, 'then')}")

print()
print("The Zen, as `import this` prints it")
import this  # noqa: E402  (importing it prints the text)

print()
print("Word frequency, the same program in both languages")
text = "the quick brown fox jumps over the lazy dog the fox sleeps and the dog barks and barks"
counts = collections.Counter(re.findall(r"[a-z']+", text.lower()))
for word, count in sorted(counts.items(), key=lambda kv: (-kv[1], kv[0]))[:5]:
    print(f"    {word:<8} {count}")
