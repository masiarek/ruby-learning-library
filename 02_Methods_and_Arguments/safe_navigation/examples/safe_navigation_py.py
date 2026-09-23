"""The Python twin: there is no `?.` operator (PEP 505 was deferred), so the
tools are a conditional expression, getattr with a default, dict.get chains,
and a small dig helper. Python's defaults are the reverse of Ruby's: `d[k]`
raises and `d.get(k)` is lenient."""


def noisy():
    print("(argument evaluated) ", end="")
    return "!"


def attempt(call):
    try:
        return repr(call())
    except (AttributeError, KeyError, TypeError) as e:
        return f"{type(e).__name__}: {e}"


def dig(obj, *keys):
    for key in keys:
        try:
            obj = obj[key]
        except (KeyError, IndexError, TypeError):
            return None
    return obj


class Address:
    def __init__(self, city):
        self.city = city


class User:
    def __init__(self, address):
        self.address = address


u1 = User(Address("Oslo"))
u2 = User(None)
h = {"a": {"b": {"c": 1}}}

name = None
print("1. a method on None:              name.upper()         ->", attempt(lambda: name.upper()))
print("2. the conditional expression:    name.upper() if name is not None else None ->", attempt(lambda: name.upper() if name is not None else None), "; 'abc' -> 'ABC'")
print("3. the arguments are skipped:     x.replace('a', noisy()) if x is not None else None ->", attempt(lambda: name.replace("a", noisy()) if name is not None else None))
print("   ...but not by getattr:         getattr(x, 'replace', lambda *a: None)('a', noisy()) ->", end=" ")
print(attempt(lambda: getattr(name, "replace", lambda *a: None)("a", noisy())))
print("4. only None is skipped:          '' if '' is None else 'kept'  -> 'kept'; but '' and ''.upper() ->", repr("" and "".upper()), "(the `and` idiom drops every falsy value)")
print("5. a chain of objects:            getattr(u1.address, 'city', None) ->", attempt(lambda: getattr(u1.address, "city", None)), ", getattr(u2.address, 'city', None) ->", attempt(lambda: getattr(u2.address, "city", None)))
print("                                  u2.address.city      ->", attempt(lambda: u2.address.city))
print("6. get chains through dicts:      h.get('a', {}).get('b', {}).get('c') ->", attempt(lambda: h.get("a", {}).get("b", {}).get("c")), ", with 'x' ->", attempt(lambda: h.get("a", {}).get("x", {}).get("c")))
print("                                  h['a']['x']['c']     ->", attempt(lambda: h["a"]["x"]["c"]))
print("7. [] is strict, get is lenient:  h['zz']              ->", attempt(lambda: h["zz"]), ", h.get('zz') ->", attempt(lambda: h.get("zz")))
print("                                  h.get('zz', 'default') ->", attempt(lambda: h.get("zz", "default")))
print("8. no dig: a five-line helper:    dig([[1, [2]]], 0, 1, 0) ->", attempt(lambda: dig([[1, [2]]], 0, 1, 0)), ", dig([], 0, 1) ->", attempt(lambda: dig([], 0, 1)))
print("                                  dig(h, 'a', 'b', 'c', 'd') ->", attempt(lambda: dig(h, "a", "b", "c", "d")), "(the helper swallows the dead end)")
print("9. no operator to chain:          PEP 505's None-aware `?.` was deferred; each step needs its own guard")
