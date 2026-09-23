"""Python has no freeze: the twin of freeze_and_frozen_error_rb.rb.

Immutability comes from the type -- tuple, frozenset, str, MappingProxyType,
dataclass(frozen=True) -- and it is shallow in exactly the same way. The rows
follow the Ruby program's numbering.
"""
import copy
import dataclasses
import types
from collections.abc import Hashable
from dataclasses import dataclass


def row(label, shown):
    print(f"   {label:<50} {shown}")


def attempt(label, thunk):
    try:
        thunk()
        row(label, "worked")
    except (TypeError, AttributeError) as e:
        row(label, type(e).__name__)


print("1. no freeze: immutability comes from the type")
t = (1, 2)
row('t = (1, 2); hasattr(t, "freeze")', repr(hasattr(t, "freeze")))
row("type(t).__name__", type(t).__name__)
row("copy.copy(t) is t  (an immutable is not copied)", repr(copy.copy(t) is t))
row("list(t)  (the mutable counterpart)", repr(list(t)))
row("tuple(list(t)) == t", repr(tuple(list(t)) == t))

print("2. the errors are TypeError or AttributeError")


def set_tuple_item():
    t[0] = 9


def set_proxy_item():
    types.MappingProxyType({"a": 1})["b"] = 2


attempt("t[0] = 9", set_tuple_item)
attempt("frozenset({1}).add(2)", lambda: frozenset({1}).add(2))
attempt('MappingProxyType({"a": 1})["b"] = 2', set_proxy_item)
row("[c.__name__ for c in TypeError.__mro__[:3]]", repr([c.__name__ for c in TypeError.__mro__[:3]]))

print("3. a tuple is shallow too")
nested = ([1],)
nested[0].append(2)
row("nested = ([1],); nested[0].append(2)", repr(nested))
row("type(nested[0]).__name__  (still mutable)", type(nested[0]).__name__)


def set_nested_item():
    nested[0] = [9]


attempt("nested[0] = [9]", set_nested_item)

print("4. no deep freeze; MappingProxyType is a read-only view")
d = {"k": [1]}
mp = types.MappingProxyType(d)
mp["k"].append(2)
row('mp = MappingProxyType(d); mp["k"].append(2)', repr(mp["k"]))
d["z"] = 0
row('d["z"] = 0; dict(mp)  (a view, not a copy)', repr(dict(mp)))
row("isinstance(([1],), Hashable)", repr(isinstance(([1],), Hashable)))
attempt("hash(([1],))  (shallow, like freeze)", lambda: hash(([1],)))

print("5. born immutable: numbers, str, None, range; a list is not")
row("isinstance(1, Hashable)", repr(isinstance(1, Hashable)))
row('isinstance("a", Hashable)', repr(isinstance("a", Hashable)))
row("isinstance(None, Hashable)", repr(isinstance(None, Hashable)))
row("isinstance(True, Hashable)", repr(isinstance(True, Hashable)))
row("isinstance(1.5, Hashable)", repr(isinstance(1.5, Hashable)))
row("isinstance(range(1, 3), Hashable)", repr(isinstance(range(1, 3), Hashable)))


def set_str_item():
    s = "lit"
    s[0] = "L"


attempt('s = "lit"; s[0] = "L"  (every str literal)', set_str_item)
row("isinstance([], Hashable)", repr(isinstance([], Hashable)))

print("6. no magic comment: a str literal is immutable already")
s = "lit"
s += "!"
row('s = "lit"; s += "!"; s  (rebinds s)', repr(s))
ba = bytearray(b"lit")
ba += b"!"
row('ba = bytearray(b"lit"); ba += b"!"; ba', repr(ba))

print("7. dataclass(frozen=True) has a back door")


@dataclass(frozen=True)
class Config:
    host: str = "h"


c = Config()


def set_host():
    c.host = "x"


attempt('c = Config(); c.host = "x"', set_host)
object.__setattr__(c, "host", "x")
row('object.__setattr__(c, "host", "x"); c.host', repr(c.host))
row("issubclass(FrozenInstanceError, AttributeError)", repr(issubclass(dataclasses.FrozenInstanceError, AttributeError)))
