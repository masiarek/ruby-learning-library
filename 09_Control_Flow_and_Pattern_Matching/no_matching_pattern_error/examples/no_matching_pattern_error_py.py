# The Python twin: a match with no matching case does nothing, silently. The
# idioms for "this must match" are a final `case _: raise` and
# typing.assert_never. The same twelve rows.
from typing import assert_never


def row(n, label, value):
    print("%2d. %-40s -> %s" % (n, label, value))


def compiles(src):
    try:
        compile(src, "<row>", "exec")
        return "compiles"
    except SyntaxError as e:
        return type(e).__name__


def silent(v, pattern):
    """Run a one-case match built from `pattern`; report whether the case ran."""
    ns = {"v": v, "ran": "nothing ran"}
    exec("match v:\n    case %s:\n        ran = 'matched'" % pattern, ns)
    return ns["ran"]


# 1. no case matched: nothing happens
row(1, "case 5; in String (no else)", silent(5, "str()"))

# 2. a missing key is just a case that did not match
row(2, "{a: 1} => {b:}", silent({"a": 1}, '{"b": b}'))

# 3. the same inside a longer match
row(3, "case {a: 1}; in {b:}", silent({"a": 1}, '{"b": b}'))


# 4. the idiom for "must match": a final case _: raise
def must_be_str(v):
    match v:
        case str():
            return "string"
        case _:
            raise ValueError("no pattern matched %r" % (v,))


try:
    must_be_str(5)
except ValueError as e:
    v = "%s: %s" % (type(e).__name__, e)
row(4, "5 => String", "silent; `case _: raise` idiom -> %s" % v)

# 5. plain unpacking is the one destructuring that raises
try:
    (a,) = [1, 2]
except ValueError as e:
    v = type(e).__name__
row(5, "[1, 2] => [a]", "silent as a pattern; `a, = [1, 2]` -> %s" % v)

# 6. the boolean question is isinstance
row(6, "5 in String", repr(isinstance(5, str)))

# 7. if/elif with no else is None too
v = None
if isinstance(5, str):
    v = "string"
row(7, "case 5 when String (no else)", repr(v))


# 8. typing.assert_never is the exhaustiveness idiom
def exhaustive(v):
    match v:
        case str():
            return "string"
        case _:
            assert_never(v)


try:
    exhaustive(5)
except AssertionError as e:
    v = "%s: %s" % (type(e).__name__, e)
row(8, "ancestors", "assert_never(5) -> %s" % v)

# 9. AssertionError and ValueError are Exceptions, so `except Exception` catches them
row(9, "rescue => e (bare) on case/in", "issubclass(AssertionError, Exception) -> %r" % issubclass(AssertionError, Exception))


# 10. case _: is the else
def with_default(v):
    match v:
        case str():
            return "string"
        case _:
            return "else branch"


row(10, "case 5; in String ... else", repr(with_default(5)))

# 11. match is a statement: it has no value to assign
row(11, "x = (5 => Integer)", "%s for x = match v: ..." % compiles("x = match v:\n    case int(): pass"))

# 12. a nested miss is silent too; only indexing raises
try:
    {"a": {"b": 1}}["a"]["c"]
except KeyError as e:
    v = type(e).__name__
row(12, "{a: {b: 1}} => {a: {c:}}", "%s; config[\"a\"][\"c\"] -> %s" % (silent({"a": {"b": 1}}, '{"a": {"c": c}}'), v))
