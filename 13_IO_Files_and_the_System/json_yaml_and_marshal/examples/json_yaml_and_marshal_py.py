# The Python twin: json (text, for everyone), no YAML in the standard library,
# pickle (bytes, Python only, and never safe) and tomllib (read-only TOML).
import contextlib
import dataclasses
import io
import json
import pickle
import sys
import tomllib
from datetime import datetime, timezone


def row(n, text, value=""):
    print(f"{n:2d}. {text:<58} {value}")


def indented(text):
    for line in text.splitlines():
        print(f"      {line}")


h = {"a": 1, "b": [1, 2.5, None, True], "c": "sym"}
row(1, "json.dumps puts spaces after , and :; keys are already str", json.dumps(h))
row(2, "dumps of a dict, list, str, None, tuple, float", " ".join([json.dumps({"a": 1}), json.dumps([1, "two"]), json.dumps("str"), json.dumps(None), json.dumps((1, 2)), json.dumps(1.5)]))
row(3, "json.dumps({'a': 1, 'b': [1, 2]}, indent=2):")
indented(json.dumps({"a": 1, "b": [1, 2]}, indent=2))
row(4, "json.loads gives str keys (there is no other kind)", json.loads('{"a": 1, "b": [1, 2.5, null, true]}'))
row(5, "  no symbolize_names: a key is always a str", "n/a")
row(6, "a tuple comes back as a list", json.loads(json.dumps((1, 2))))
row(7, "non-str keys are stringified: {1: 2, None: 3}", json.dumps({1: 2, None: 3}))
row(8, 'a scalar document: loads of 3, "s", null', [json.loads("3"), json.loads('"s"'), json.loads("null")])
row(9, "duplicate keys: the last one wins", json.loads('{"a": 1, "a": 2}'))
try:
    json.loads("nope")
except json.JSONDecodeError as e:
    row(10, "bad input raises; its ancestors", " < ".join(c.__name__ for c in type(e).__mro__[:3]))
try:
    json.dumps(float("nan"), allow_nan=False)
except ValueError as e:
    row(11, "NaN is written as NaN by default; allow_nan=False raises", f"{json.dumps(float('nan'))}; {type(e).__name__}")
row(12, "non-ASCII is escaped by default; ensure_ascii=False keeps it", f"{json.dumps('caf\N{LATIN SMALL LETTER E WITH ACUTE}')} {json.dumps('caf\N{LATIN SMALL LETTER E WITH ACUTE}', ensure_ascii=False)}")


@dataclasses.dataclass
class P:
    x: int


errors = []
for value in (P(1), datetime(2024, 1, 1, tzinfo=timezone.utc)):
    try:
        json.dumps(value)
    except TypeError as e:
        errors.append(type(e).__name__)
row(13, "a dataclass or a datetime raises; default=vars is the fix", f"{' '.join(errors)}; {json.dumps(P(1), default=vars)}")

row(14, "no YAML: 'yaml' in sys.stdlib_module_names; json, pickle, tomllib", [name in sys.stdlib_module_names for name in ("yaml", "json", "pickle", "tomllib")])
row(15, "  (PyYAML is a third-party package)", "n/a")


class Evil:
    def __reduce__(self):
        return (print, ("pickle ran code",))


buf = io.StringIO()
with contextlib.redirect_stdout(buf):
    pickle.loads(pickle.dumps(Evil()))
row(16, "pickle.loads runs __reduce__: what loading an Evil printed", repr(buf.getvalue()))
row(17, "  there is no safe load: every pickle.loads is unsafe_load", "n/a")
row(18, "  no permitted_classes", "n/a")
row(19, "  no aliases option; shared references just round-trip", "n/a")
row(20, "pickle round trip keeps tuples, sets and nesting", pickle.loads(pickle.dumps({"a": [1, {"b": "c"}], "t": (1, 2), "s": {3}})))

dumped = pickle.dumps([1, "a"])
row(21, "pickle.dumps gives bytes; dumps(1, protocol=4) in hex; highest", f"{type(dumped).__name__}; {pickle.dumps(1, protocol=4).hex()}; {pickle.HIGHEST_PROTOCOL}")
row(22, "the round trip keeps Python types: range, datetime", pickle.loads(pickle.dumps({"a": [1, 2], "c": range(1, 4), "d": datetime(2024, 1, 1, tzinfo=timezone.utc)})))
deep = {"a": [1, [2]]}
copy = pickle.loads(pickle.dumps(deep))
copy["a"][1].append(3)
row(23, "loads(dumps(x)) is a deep copy: original, copy", f"{deep}, {copy}")
errors = []
for value in (lambda: 1, sys.stdout):
    try:
        pickle.dumps(value)
    except Exception as e:
        errors.append(f"{type(e).__name__} < {type(e).__mro__[1].__name__}")
row(24, "pickle refuses a lambda and a file object", "; ".join(errors))
try:
    pickle.loads(b"garbage")
except pickle.UnpicklingError as e:
    row(25, "pickle.loads of garbage raises", type(e).__name__)
row(26, "TOML: tomllib.loads (3.11+, read-only)", tomllib.loads('a = 1\n[s]\nb = [1, 2]\n'))
