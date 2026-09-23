# The Python twin: the same numbered rows as struct_and_data_rb.rb, asked of
# namedtuple and @dataclass (for Struct) and @dataclass(frozen=True) (for Data).
# Exceptions print their type only.

from collections import namedtuple
from dataclasses import asdict, astuple, dataclass, field, replace


def row(n, label, value):
    print(f"{n:2d}. {label:<68} {value}")


def raises(fn):
    try:
        return repr(fn())
    except Exception as e:
        return type(e).__name__


def setattr_(obj, name, value):
    setattr(obj, name, value)
    return obj


Point = namedtuple("Point", "x y")


@dataclass
class P:
    x: int
    y: int


row(1,  "namedtuple Point(1, 2), Point(x=1, y=2); @dataclass P(1, 2)",           f"{[Point(1, 2), Point(x=1, y=2)]}; {P(1, 2)}")
row(2,  "Point(1); Point(1, 2, 3)  (and the same for P)",                        f"{raises(lambda: Point(1))}, {raises(lambda: Point(1, 2, 3))}; {raises(lambda: P(1))}, {raises(lambda: P(1, 2, 3))}")
p = Point(1, 2)
q = P(1, 2)
q.x = 5
row(3,  "p.x = 5 on the namedtuple; q.x = 5 on the dataclass; then q, p[0]",   f"{raises(lambda: setattr_(p, 'x', 5))}; {q}, {p[0]}")
row(4,  "Point == Point, hash ==, dict key; P == P, hash(P), P.__hash__ is None",  f"{[Point(1, 2) == Point(1, 2), hash(Point(1, 2)) == hash(Point(1, 2)), {Point(1, 2): 'key'}[Point(1, 2)]]}; {P(1, 2) == P(1, 2)}, {raises(lambda: hash(P(1, 2)))}, {P.__hash__ is None}")
row(5,  "list(p), Point._fields, p._asdict(); astuple(q), asdict(q)",            f"{[list(p), Point._fields, p._asdict()]}; {[astuple(q), asdict(q)]}")
Other = namedtuple("Other", "x y")


@dataclass
class Q:
    x: int
    y: int


row(6,  "Point(1, 2) == Other(1, 2)  (both tuples); P(1, 2) == Q(1, 2)",        f"{Point(1, 2) == Other(1, 2)}; {P(1, 2) == Q(1, 2)}")
matched = []
match Point(1, 2):
    case Point(x, y):
        matched.append(f"case Point(x, y) -> {x},{y}")
match Point(1, 2):
    case (x, y):
        matched.append(f"case (x, y) -> {x},{y}")
match P(1, 2):
    case P(x, y):
        matched.append(f"case P(x, y) -> {x},{y}")
row(7,  "match: case Point(x, y); case (x, y); case P(x, y)  (__match_args__)", repr(matched))


@dataclass
class Rect:
    w: int
    h: int

    def area(self):
        return self.w * self.h


row(8,  "@dataclass Rect with def area(self): Rect(2, 3).area()",               Rect(2, 3).area())


@dataclass(kw_only=True)
class KW:
    x: int
    y: int


row(9,  "@dataclass(kw_only=True) KW: KW(1, 2)",                                 raises(lambda: KW(1, 2)))


@dataclass(frozen=True)
class Coord:
    lat: float
    lng: float


c = Coord(1, 2)
row(10, "@dataclass(frozen=True) Coord: Coord(1, 2), Coord(lat=1, lng=2)",      repr([c, Coord(lat=1, lng=2)]))
row(11, "Coord(1); Coord(1, 2, 3); Coord(lat=1, lng=2, alt=3)",                  "; ".join([raises(lambda: Coord(1)), raises(lambda: Coord(1, 2, 3)), raises(lambda: Coord(lat=1, lng=2, alt=3))]))
row(12, "c.lat = 5",                                                            raises(lambda: setattr_(c, "lat", 5)))
bypassed = Coord(1, 2)
object.__setattr__(bypassed, "lat", 5)
row(13, 'object.__setattr__(c2, "lat", 5)  (bypasses frozen); then c2',         repr(bypassed))
row(14, "replace(c, lat=9), then c",                                            repr([replace(c, lat=9), c]))
row(15, "c == Coord(1, 2), hash ==; as a dict key",                             repr([c == Coord(1, 2), hash(c) == hash(Coord(1, 2)), {c: "key"}[Coord(1, 2)]]))
row(16, "astuple(c), asdict(c); list(c)  (not iterable)",                       f"{[astuple(c), asdict(c)]}; {raises(lambda: list(c))}")
matched = []
match c:
    case [lat, lng]:
        matched.append("case [lat, lng] matched")
    case _:
        matched.append("case [lat, lng] -> no match")
match c:
    case Coord(lat=lat, lng=lng):
        matched.append(f"case Coord(lat=lat, lng=lng) -> {lat},{lng}")
match c:
    case Coord(lat, lng):
        matched.append(f"case Coord(lat, lng) -> {lat},{lng}")
row(17, "match c: [lat, lng]; Coord(lat=lat, lng=lng); Coord(lat, lng)",         repr(matched))


@dataclass(frozen=True)
class Temp:
    deg: float

    def __post_init__(self):
        object.__setattr__(self, "deg", float(self.deg))


row(18, 'Temp("35").deg, Temp(deg=12).deg  (__post_init__ normalises)',         repr([Temp("35").deg, Temp(deg=12).deg]))


@dataclass(frozen=True)
class Bag:
    items: list = field(default_factory=list)


bag = Bag()
bag.items.append(2)
row(19, "Bag().items.append(2)  (immutability is shallow); hash(Bag())",        f"{bag}; {raises(lambda: hash(Bag()))}")
