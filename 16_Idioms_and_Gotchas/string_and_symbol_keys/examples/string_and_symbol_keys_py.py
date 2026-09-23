# Python has one string type and no symbols: "a" and 'a' are the same key, JSON
# keys are always str, and an Enum member is the nearest thing to a symbol.
import enum
import json
import sys


def row(n, label, value):
    print(f"{n:2d}. {label:<46} {value}")


class Key(enum.Enum):
    A = "a"


d = {"a": 1}

row(1, '{"a": 1}["a"] / [\'a\']', f"{d['a']!r} / {d['a']!r}")
row(2, '"a" in d / \'a\' in d', f"{'a' in d} / {'a' in d}")

parsed = json.loads('{"a": 1, "b": [1, 2]}')
row(3, "json.loads('{\"a\": 1, \"b\": [1, 2]}')", f"{parsed!r}  key type {type(next(iter(parsed))).__name__}")
row(4, "json.loads(...) keys are always", type(next(iter(parsed))).__name__ + "  (no symbolize_names to ask for)")
as_enum = {Key(k): v for k, v in d.items()}
row(5, "{Key(k): v for k, v in d.items()}", f"{as_enum!r}  key type {type(next(iter(as_enum))).__name__}")

row(6, '{"a": 1}   (quotes, then a colon: a str key)', f"{d!r}  key type {type(next(iter(d))).__name__}")

both = {"a": 1, "a": 2}
row(7, 'len({"a": 1, "a": 2})', f"{len(both)}  {both!r}  (the same key twice: last wins)")
row(8, '{"a": 1} == {"a": 1} / {Key.A: 1} == {"a": 1}', f"{ {'a': 1} == {'a': 1} } / { {Key.A: 1} == {'a': 1} }")

as_json = json.dumps({1: 2})
back = json.loads(as_json)
row(9, "json.dumps({1: 2}), then json.loads", f"{as_json}  -> {back!r}  key type {type(next(iter(back))).__name__}")

row(10, 'sys.intern("a") is sys.intern("a")', f"{sys.intern('a') is sys.intern('a')}  (interning: the nearest to a symbol)")
try:
    {["a"]: 1}
    listkey = "?"
except TypeError as e:
    listkey = type(e).__name__
row(11, '{("a", "b"): 1} / {["a"]: 1}', f"{ {('a', 'b'): 1}!r} / {listkey}  (any hashable key)")

try:
    d[Key.A]
except KeyError as e:
    row(12, '{"a": 1}[Key.A]', f"{type(e).__name__}: {e}  <- the enum member, not the string")
