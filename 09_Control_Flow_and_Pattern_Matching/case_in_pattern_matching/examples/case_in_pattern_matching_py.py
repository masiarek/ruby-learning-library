# The Python twin: match/case with sequence, mapping, class and capture
# patterns, asked the same thirteen questions.
from collections import namedtuple
from dataclasses import dataclass


def row(n, label, value):
    print("%2d. %-44s -> %s" % (n, label, value))


def compiles(src):
    try:
        compile(src, "<row>", "exec")
        return "compiles"
    except SyntaxError as e:
        return type(e).__name__


# 1. a sequence pattern: a class check, a capture with `as`, and a star for the rest
match [1, 2, 3]:
    case [int() as a, *rest]:
        row(1, "[1, 2, 3] in [Integer => a, *rest]", "a = %r, rest = %r" % (a, rest))

# 2. a mapping pattern names the keys it needs; extra keys are ignored
person = {"name": "Ada", "age": 36, "city": "London"}
match person:
    case {"name": str() as n, "age": age}:
        row(2, "person in {name: String => n, age:}", "n = %r, age = %r  (city ignored)" % (n, age))


# 3. **rest collects the extra keys; forbidding them takes a guard
def describe(h):
    match h:
        case {"name": name, **rest} if not rest:
            return "exact"
        case {"name": name, **rest}:
            return "extra: %r" % sorted(rest)


row(3, "{name:, **nil} vs {name:, **rest}", "%s / %s  (guard `if not rest`; {**None} is a %s)"
    % (describe(person), describe({"name": "Ada"}), compiles("match h:\n    case {**None}: pass")))

# 4. patterns nest
doc = {"user": {"name": "Ada", "roles": ["dev", "admin"]}}
match doc:
    case {"user": {"name": str() as n, "roles": [str() as first, *_]}}:
        row(4, "nested {user: {roles: [String => first, *]}}", "n = %r, first = %r" % (n, first))

# 5. no find pattern: a sequence pattern allows one star
match ["dev", "admin", "ops"]:
    case [*roles] if "admin" in roles:
        post = roles[roles.index("admin") + 1:]
row(5, 'find pattern [*, "admin", *post]', "%s for two stars; guard `if \"admin\" in roles` -> post = %r"
    % (compiles("match x:\n    case [*_, 'admin', *post]: pass"), post))

# 6. alternatives with |
match [1, 2, 3]:
    case [_, _] | [_, _, _]:
        shape = "pair or triple"
row(6, "alternatives [_, _] | [_, _, _]", repr(shape))

# 7. no one-line form: a match with one case
config = {"host": "localhost", "port": 80, "tls": False}
match config:
    case {"host": host, "port": port}:
        pass
row(7, "rightward config => {host:, port:}", "%s; match with one case -> host = %r, port = %r"
    % (compiles("config => {host:, port:}"), host, port))

# 8. no boolean form: `in` is the membership test
try:
    5 in int
    member = "no error"
except TypeError as e:
    member = type(e).__name__
row(8, "boolean: value in pattern", "5 in int -> %s (membership test); isinstance(5, str) -> %r" % (member, isinstance(5, str)))

# 9. None is a pattern, compared by identity
match None:
    case None:
        matched = "matched None"
row(9, "nil pattern", repr(matched))

# 10. a namedtuple is a tuple, so a sequence pattern fits; a class pattern needs __match_args__
Point = namedtuple("Point", "x y")
match Point(1, 2):
    case [x, y]:
        as_seq = [x, y]
match Point(1, 2):
    case Point(x, y):
        as_cls = [x, y]
row(10, "Struct: in [x, y] / in {x:, y:}", "%r via [x, y] / %r via Point(x, y)" % (as_seq, as_cls))


# 11. a dataclass: keyword and positional class patterns; it is not a sequence
@dataclass(frozen=True)
class Coord:
    lat: float
    lng: float


c = Coord(1.5, 2.5)
match c:
    case Coord(lat=lat, lng=lng):
        k = [lat, lng]
match c:
    case Coord(lat, lng):
        b = [lat, lng]
match c:
    case [lat, lng]:
        s = [lat, lng]
    case _:
        s = "no match"
row(11, "Data: {lat:, lng:} / Coord[a, b] / Coord(k:)", "%r via Coord(lat=, lng=) / %r via Coord(lat, lng) / [lat, lng] -> %r" % (k, b, s))

# 12. match is a block statement: no one-line form at all
row(12, "one line: case 5 in X / case 5; in X", "%s / %s" % (compiles("match 5: case int(): pass"), compiles("match 5:\n    case int(): pass")))

# 13. mapping pattern keys are literals of any type
match {"name": "Ada"}:
    case {"name": n}:
        got = n
row(13, "hash pattern keys are symbols", 'case {"name": n}: matches a str-keyed dict -> n = %r' % got)
