# The Python twin: the same numbered rows as hashes_and_default_values_rb.rb,
# asked of a dict, a Counter and a defaultdict. Exceptions print their type only.

from collections import Counter, defaultdict


def row(n, label, value):
    print(f"{n:2d}. {label:<56} {value}")


def raises(fn):
    try:
        return repr(fn())
    except Exception as e:
        return type(e).__name__


def dig(obj, *keys):
    """No dict.dig: walk the keys and answer None at the first miss."""
    for k in keys:
        try:
            obj = obj[k]
        except (KeyError, IndexError, TypeError):
            return None
    return obj


d = {"b": 1, "a": 2}
d["c"] = 3
row(1,  'd = {"b": 1, "a": 2}; d["c"] = 3; list(d)',            repr(list(d)))
row(2,  "key type of {'a': 1}; {'a': 1} == {\"a\": 1}",          f"{type(list({'a': 1})[0]).__name__}, {({'a': 1} == {'a': 1})}")
row(3,  'd["zz"]  (missing key)',                               raises(lambda: d["zz"]))
row(4,  'd["zz"] is already the raising form; d.get("zz")',     f'{raises(lambda: d["zz"])}, {d.get("zz")}')
row(5,  'd.get("zz", 0); d["zz"] if "zz" in d else "no zz"',    f'{d.get("zz", 0)}, {(d["zz"] if "zz" in d else "no zz")!r}')

counts = Counter("hello")
row(6,  'counts = Counter("hello"); dict(counts)',              repr(dict(counts)))
row(7,  'counts["zz"], len(counts)  (default not stored)',      f'{counts["zz"]}, {len(counts)}')
dd = defaultdict(int)
for ch in "hello":
    dd[ch] += 1
dd["zz"]
row(8,  'defaultdict(int): dd["zz"], len(dd); dd.get("yy")',    f'{dd["zz"]}, {len(dd)} (stored), {dd.get("yy")}')

groups = defaultdict(list)
for w in ["apple", "fig", "kiwi", "plum", "banana"]:
    groups[len(w)].append(w)
row(9,  "defaultdict(list); group words by len",                repr(dict(groups)))
groups[99]
row(10, "groups[99]; len(groups)  (the factory stores)",        f"{groups[99]}, {len(groups)}")

t = dict.fromkeys("ab", [])
t["a"].append(1)
t["b"].append(2)
row(11, 't = dict.fromkeys("ab", []); append via a, via b; t', repr(t))
u = {}
u.setdefault("a", []).append(1)
row(12, 'u = {}; u.setdefault("a", []).append(1)',              repr(u))

n = {"a": {"b": [10, 20]}}
row(13, 'dig(n, "a", "b", 1), dig(n, "a", "zz", 1)  (helper)',  f'{dig(n, "a", "b", 1)}, {dig(n, "a", "zz", 1)}')
row(14, "{str(k): v ...}, {k: v * 10 ...} comprehensions",     repr([{str(k): v for k, v in d.items()}, {k: v * 10 for k, v in d.items()}]))
row(15, 'dict([("a", 1)]), list(d.items()), {v: k ...}',       repr([dict([("a", 1)]), list(d.items()), {v: k for k, v in d.items()}]))

pair = next(iter(d.items()))
k, v = pair
row(16, "for pair in d.items(): a tuple; for k, v in ...",     f"{pair!r} is a {type(pair).__name__}; k = {k!r}, v = {v}")
row(17, '"a" in d, 2 in d.values(), "zz" in d',                 repr(["a" in d, 2 in d.values(), "zz" in d]))

row(18, "a str key is immutable (nothing to copy); a list key", raises(lambda: {[1, 2]: "x"}))
row(19, 'len({1: "int", 1.0: "float"})  (1 == 1.0, same hash)', len({1: "int", 1.0: "float"}))

plain = {}
plain["".join("a")] = 1
plain["".join("a")] = 2
row(20, "two equal str keys: no identity mode, plain dict",     f"-, {len(plain)}")
row(21, '{"a": 1} | {"b": 2}; {"a": 1} | {"a": 2} (right wins)', repr([{"a": 1} | {"b": 2}, {"a": 1} | {"a": 2}]))

m = {"a": 1, "b": 2}
row(22, 'm.pop("a"), m.pop("zz", None), m.pop("zz")',           f'{m.pop("a")}, {m.pop("zz", None)}, {raises(lambda: m.pop("zz"))}')
