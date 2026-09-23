# A dict finds a key by __hash__ first and __eq__ second; defining __eq__
# alone makes a class unhashable. Prints the same numbered rows as
# eql_and_hash_for_hash_keys_rb.rb. TypeError messages are printed as the
# type name only: CPython rewords them between 3.12 and 3.14.

from collections import Counter, namedtuple
from dataclasses import dataclass


def section(n, title):
    print(f"{n}. {title}")


def row(label, value):
    print(f"   {label:<42} {value}")


class Pt:
    def __init__(self, x, y):
        self.x, self.y = x, y

    def __eq__(self, other):
        return isinstance(other, Pt) and (self.x, self.y) == (other.x, other.y)

    def __repr__(self):
        return f"Pt({self.x},{self.y})"


class Pt2(Pt):
    def __hash__(self):
        return hash((self.x, self.y))


@dataclass
class S:
    x: int
    y: int


@dataclass(frozen=True)
class D:
    x: int
    y: int


NT = namedtuple("NT", "x y")

section(1, "__eq__ alone: the class becomes unhashable")
row("Pt(1, 2) == Pt(1, 2)", Pt(1, 2) == Pt(1, 2))
row("Pt.__hash__ is None", Pt.__hash__ is None)
try:
    hash(Pt(1, 2))
except TypeError as e:
    row("hash(Pt(1, 2))", type(e).__name__)
try:
    {Pt(1, 2): "a", Pt(1, 2): "b"}
except TypeError as e:
    row("{Pt(1,2): 'a', Pt(1,2): 'b'}", type(e).__name__)

section(2, "what __eq__ alone still does, and what it does not")
pair = [Pt(1, 2), Pt(1, 2)]
row("Pt(1, 2) in [Pt(1, 2)]  (uses ==)", Pt(1, 2) in pair[:1])
try:
    set(pair)
except TypeError as e:
    row("set([Pt(1,2), Pt(1,2)])", type(e).__name__)
try:
    Counter(pair)
except TypeError as e:
    row("Counter([Pt(1,2), Pt(1,2)])", type(e).__name__)
try:
    dict.fromkeys(pair)
except TypeError as e:
    row("dict.fromkeys([Pt(1,2), Pt(1,2)])", type(e).__name__)

section(3, "__eq__ and __hash__ together fix it")
pair = [Pt2(1, 2), Pt2(1, 2)]
row("Pt2(1, 2) == Pt2(1, 2)", Pt2(1, 2) == Pt2(1, 2))
row("hash(Pt2(1, 2)) == hash(Pt2(1, 2))", hash(Pt2(1, 2)) == hash(Pt2(1, 2)))
d = {Pt2(1, 2): "a", Pt2(1, 2): "b"}
row("len({Pt2(1,2): 'a', Pt2(1,2): 'b'})", len(d))
row("d[Pt2(1, 2)]", repr(d[Pt2(1, 2)]))
row("len(set(pair))", len(set(pair)))
row("len(dict.fromkeys(pair))  (uniq)", len(dict.fromkeys(pair)))
row("Counter(pair)", dict(Counter(pair)))

section(4, "dataclasses: frozen ones are hashable, mutable ones are not")
row("S.__hash__ is None  (eq=True, frozen=False)", S.__hash__ is None)
try:
    {S(1, 2): 1}
except TypeError as e:
    row("{S(1, 2): 1}", type(e).__name__)
row("len({D(1,2): 1, D(1,2): 2})  (frozen=True)", len({D(1, 2): 1, D(1, 2): 2}))
row("len({NT(1,2): 1, NT(1,2): 2})  (namedtuple)", len({NT(1, 2): 1, NT(1, 2): 2}))
row("NT(1, 2) == NT(1, 2.0)", NT(1, 2) == NT(1, 2.0))
row("hash(NT(1, 2)) == hash(NT(1, 2.0))", hash(NT(1, 2)) == hash(NT(1, 2.0)))

section(5, "a tuple key works by value; a list cannot be a key; a mutated key is lost")
row("{(1, 2): 'tuple'}[(1, 2)]", repr({(1, 2): "tuple"}[(1, 2)]))
try:
    {[1, 2]: "list"}
except TypeError as e:
    row("{[1, 2]: 'list'}", type(e).__name__)
key = Pt2(1, 2)
d = {key: "here"}
key.x = 9
row("key = Pt2(1, 2); d = {key: 'here'}; key.x = 9", "(the key changed after insertion)")
row("d.get(Pt2(9, 2))", d.get(Pt2(9, 2)))
row("d.get(key)", d.get(key))
row("list(d)", list(d))
d = {k: v for k, v in d.items()}
row("rebuilt: {k: v for k, v in d.items()}; d.get(Pt2(9, 2))", repr(d.get(Pt2(9, 2))))

section(6, "1 and 1.0 are == and hash alike")
row("1 == 1.0", 1 == 1.0)
row("hash(1) == hash(1.0)", hash(1) == hash(1.0))
row("{1: 'int'}[1.0]", repr({1: "int"}[1.0]))
row("{1: 'int', 1.0: 'float'}", {1: "int", 1.0: "float"})
row("len(dict.fromkeys([1, 1.0]))", len(dict.fromkeys([1, 1.0])))
row("len({1, 1.0})", len({1, 1.0}))
row("len({1, 1.0, True})", len({1, 1.0, True}))

section(7, "a str key is immutable, so it is stored as is")
s = "key"
d = {s: 1}
row("s = 'key'; d = {s: 1}", "(a str is immutable)")
row("list(d)[0] is s", list(d)[0] is s)
row("d['key']", repr(d["key"]))

section(8, "no compare_by_identity: key by id() instead")
by_id = {}
a = "a"
b = "b"
by_id[id(a)] = 1
by_id[id(a)] = 2
row("the same str object twice, keyed by id()", len(by_id))
by_id[id(b)] = 3
row("a second object", len(by_id))

section(9, "the rules")


class BadHash:
    def __hash__(self):
        return "nope"


class OnlyHash:
    def __hash__(self):
        return 1


try:
    {BadHash(): 1}
except TypeError as e:
    row("__hash__ returning a str", type(e).__name__)
row("__hash__ without __eq__: keys kept", len({OnlyHash(): 1, OnlyHash(): 2}))
row("hasattr(object, '__eq__')", hasattr(object, "__eq__"))
row("hasattr(object, '__hash__')", hasattr(object, "__hash__"))
row("vars(Pt)['__hash__']  (set by defining __eq__)", vars(Pt)["__hash__"])
