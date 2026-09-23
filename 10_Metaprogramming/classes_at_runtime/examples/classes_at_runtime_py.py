"""classes_at_runtime_py.py -- the same rows, asked of type(), types.new_class and __name__."""

import collections
import dataclasses
import sys
import types


def row(n, label, value):
    head = "   " if n == "" else f"{n:>2}."
    print(f"{head} {label:<46} {value}")


HOOK_LOG = []


class Animal:
    def speak(self):
        return "..."

    def __init_subclass__(cls, **kwargs):              # 9. always sees a name
        HOOK_LOG.append(cls.__name__)
        super().__init_subclass__(**kwargs)


def speak(self):
    return "woof"


k = type("Dog", (Animal,), {"speak": speak})           # 1. name, bases, namespace
row(1, 'k = type("Dog", (Animal,), {"speak": speak})', f"k().speak() = {k().speak()!r}")
row(2, "k.__name__ -- named at birth", repr(k.__name__))
row("", 'type("", (), {}).__name__ -- even an empty name', repr(type("", (), {}).__name__))
Dog = k                                                # 3. assignment changes nothing
row(3, "Dog = k; k.__name__", repr(k.__name__))
k.__name__ = "Renamed"                                 #    __name__ is a writable attribute
row("", 'k.__name__ = "Renamed"; k.__name__', repr(k.__name__))
k.__name__ = "Dog"
Hound = Dog
row(4, "Hound = Dog; Hound.__name__", repr(Hound.__name__))

zoo = types.ModuleType("zoo")                          # 5. a namespace is a module object
cat = type("Cat", (), {})
setattr(zoo, "Cat", cat)
row(5, "setattr(zoo, 'Cat', cat); cat.__qualname__", f"{cat.__qualname__!r} (unchanged), __module__ = {cat.__module__!r}")
row("", 'getattr(zoo, "Cat") is cat', getattr(zoo, "Cat") is cat)

Greeting = type("Greeting", (), {"hi": lambda self: "hi"})   # 6. a mixin is a class
Dog2 = type("Dog2", (Greeting, Animal), {})
row(6, "type('Dog2', (Greeting, Animal), {})().hi()", f"{Dog2().hi()!r}, mixin name = {Greeting.__name__!r}")
row("", "[c.__name__ for c in Dog2.__mro__[:2]]", [c.__name__ for c in Dog2.__mro__[:2]])

Point = collections.namedtuple("Point", "x y")         # 7. the standard-library factories
Coord = dataclasses.make_dataclass("Coord", ["lat", "lng"], frozen=True)
row(7, 'namedtuple("Point", "x y")(1, 2)', Point(1, 2))
row("", 'make_dataclass("Coord", ["lat", "lng"])(1, 2)', Coord(1, 2))

row(8, "type(k) / k.__bases__ / type('A', (), {}).__bases__",
    f"{type(k).__name__} / {tuple(b.__name__ for b in k.__bases__)} / {tuple(b.__name__ for b in type('A', (), {}).__bases__)}")
row("", "isinstance(k, type)", isinstance(k, type))


class Kitten(Animal):
    pass


row(9, "__init_subclass__ saw, in order (k, Dog2, Kitten)", HOOK_LOG)

factor = 3


def triple(self, x):                                   # 10. a function is a closure
    return x * factor


row(10, "type('T', (), {'triple': triple})().triple(3)", type("T", (), {"triple": triple})().triple(3))

Meta = type("Meta", (type,), {})                       # 11. subclassing type IS allowed: a metaclass
row(11, "Meta = type('Meta', (type,), {}) -- allowed", f"mro = {[c.__name__ for c in Meta.__mro__]}")
row("", "a Python module is an instance of ModuleType", f"isinstance(zoo, types.ModuleType) = {isinstance(zoo, types.ModuleType)}")

row(12, "type('bad name', (), {}).__name__ -- any str", repr(type("bad name", (), {}).__name__))

me = sys.modules[__name__]
row(13, 'hasattr(module, "Hound")', hasattr(me, "Hound"))
delattr(me, "Hound")
row("", 'delattr(module, "Hound") -> then hasattr', hasattr(me, "Hound"))


def make_class():                                      # 14. a fresh class per call
    class Made:
        def id(self):
            return "made"
    return Made


row(14, "make_class() is make_class() / __qualname__", f"{make_class() is make_class()} / {make_class().__qualname__!r}")


class Base:
    def __init_subclass__(cls, tag=None, **kwargs):
        super().__init_subclass__(**kwargs)
        cls.tag = tag


T = types.new_class("T", (Base,), {"tag": "x"})        # 15. keyword options reach __init_subclass__
row(15, "types.new_class('T', (Base,), {'tag': 'x'}).tag", repr(T.tag))
row("", "type('T2', (Base,), {}, tag='y').tag", repr(type("T2", (Base,), {}, tag="y").tag))
