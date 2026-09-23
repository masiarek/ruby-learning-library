# The Python twin: a positional class pattern reads __match_args__, a keyword
# class pattern reads attributes, and sequence/mapping patterns are for
# registered Sequence/Mapping types only. LOG records the attributes read.
import re
from collections import namedtuple
from collections.abc import Mapping, Sequence
from dataclasses import dataclass


def row(n, label, value):
    print("%2d. %-40s -> %s" % (n, label, value))


def compiles(src):
    try:
        compile(src, "<row>", "exec")
        return "compiles"
    except SyntaxError as e:
        return type(e).__name__


LOG = []


def read():
    got, LOG[:] = list(LOG), []
    return got


class Point:
    def __init__(self, x, y):
        self.x, self.y = x, y

    def __getattribute__(self, name):
        if not name.startswith("_"):
            LOG.append(name)
        return object.__getattribute__(self, name)


pt = Point(1, 2)


# 1. a sequence pattern needs a registered Sequence, not just __len__/__getitem__
class Pair:
    def __init__(self, a, b):
        self._items = (a, b)

    def __len__(self):
        return 2

    def __getitem__(self, i):
        return self._items[i]


def as_seq(v):
    match v:
        case [a, b]:
            return [a, b]
        case _:
            return "no match"


before = as_seq(Pair(1, 2))
Sequence.register(Pair)
row(1, "in [a, b] on a Point", "%r before Sequence.register(Pair); %r after" % (before, as_seq(Pair(1, 2))))


# 2. a positional class pattern needs __match_args__
def positional(v):
    try:
        match v:
            case Point(a, b):
                return [a, b]
    except TypeError as e:
        return type(e).__name__


before = positional(pt)
Point.__match_args__ = ("x", "y")
read()
row(2, "in Point[a, b]", "%s without __match_args__; %r with ('x', 'y')  (read %r)" % (before, positional(pt), read()))

# 3. a keyword class pattern reads attributes
match pt:
    case Point(x=a, y=b):
        v = [a, b]
row(3, "in {x:, y:}", "%r  via getattr: read %r" % (v, read()))

# 4. only the attributes the pattern names are read
match pt:
    case Point(x=a):
        v = a
row(4, "in Point(x:)", "%r  via getattr: read %r" % (v, read()))

# 5. **rest belongs to mapping patterns only
row(5, "in {x:, **rest}", "%s for case Point(x=a, **rest):" % compiles("match v:\n    case Point(x=a, **rest): pass"))


# 6. namedtuple and dataclass set __match_args__ for you
NT = namedtuple("NT", "x y")


@dataclass
class DC:
    x: int
    y: int


row(6, "Struct / Data: deconstruct, deconstruct_keys", "namedtuple __match_args__ %r; dataclass %r" % (NT.__match_args__, DC.__match_args__))

# 7. list and dict are registered; str is excluded from sequence patterns
row(7, "Array#deconstruct, Hash#deconstruct_keys", "isinstance([], Sequence) -> %r; isinstance({}, Mapping) -> %r; \"ab\" as [_, _] -> %r"
    % (isinstance([], Sequence), isinstance({}, Mapping), as_seq("ab")))

# 8. an int is neither, so it does not match
row(8, "5 in [_] (no deconstruct)", "%r; isinstance(5, Sequence) -> %r" % (as_seq(5), isinstance(5, Sequence)))


# 9. __match_args__ must be a tuple
class Broken:
    __match_args__ = ["x"]

    def __init__(self):
        self.x = 1


def broken(v):
    try:
        match v:
            case Broken(a):
                return a
    except TypeError as e:
        return type(e).__name__


row(9, "deconstruct returning a String", "%s for a list-valued __match_args__" % broken(Broken()))

# 10. re.Match has no __match_args__; groups() and groupdict() are the deconstruction
m = re.match(r"(?P<a>\d+)-(?P<b>\d+)", "10-20")
row(10, "MatchData: deconstruct / deconstruct_keys", "__match_args__ on re.Match -> %r; groups() %r / groupdict() %r"
    % (hasattr(re.Match, "__match_args__"), m.groups(), m.groupdict()))
