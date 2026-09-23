# Python has no singleton class. A function stored on one object is not a
# method; a per-object subclass and types.MethodType are the closest things.
# Prints the same numbered rows as singleton_classes_rb.rb.

import copy
import types


def section(n, title):
    print(f"{n}. {title}")


def row(label, value):
    print(f"   {label:<46} {value}")


class Foo:
    def __init__(self, name):
        self.name = name

    def __repr__(self):
        return f"<{type(self).__name__} {self.name}>"

    @classmethod
    def make(cls):
        return cls("made")

    @staticmethod
    def build():
        return "built by Foo"


class Meta(type):
    def forge(cls):
        return f"forged by {cls.__name__}"


class Bar(metaclass=Meta):
    pass


class BarSub(Bar):
    pass


class Loud:
    def shout(self):
        return f"LOUD from {self.name}"


def greet(self):
    return f"hi from {self.name}"


obj = Foo("obj")
other = Foo("other")

section(1, "a function stored on one object")
obj.greet = greet
try:
    obj.greet()
except TypeError as e:
    row("obj.greet = greet; obj.greet()", f"{type(e).__name__} (self is not passed)")
obj.greet = types.MethodType(greet, obj)
row("obj.greet = MethodType(greet, obj); obj.greet()", obj.greet())
try:
    other.greet()
except AttributeError as e:
    row("other.greet()", type(e).__name__)

section(2, "where that function lives")
row("sorted(vars(obj))", sorted(vars(obj)))
row("'greet' in vars(Foo)", "greet" in vars(Foo))
row("type(obj) is Foo", type(obj) is Foo)
row("type(obj).__name__", type(obj).__name__)
row("isinstance(obj, Foo)", isinstance(obj, Foo))

section(3, "the closest to class << obj: a per-object subclass")
obj.__class__ = type("FooOnly", (Foo,), {"name_length": lambda self: len(self.name)})
row("obj.name_length()", obj.name_length())
row("type(obj).__name__ / type(other).__name__", f"{type(obj).__name__} / {type(other).__name__}")

section(4, "class methods live on the class or its metaclass")
row("Foo.make()", repr(Foo.make()))
row("Foo.build()", Foo.build())
row("Foo('x').make()  (a classmethod is reachable)", repr(Foo("x").make()))
row("Bar.forge()  (a metaclass method)", Bar.forge())
try:
    Bar().forge()
except AttributeError as e:
    row("Bar().forge()", type(e).__name__)

section(5, "the class of a class is its metaclass")
row("type(Foo).__name__", type(Foo).__name__)
row("[c.__name__ for c in type(Foo).__mro__]", [c.__name__ for c in type(Foo).__mro__])
row("type(type) is type", type(type) is type)
row("type(Bar).__name__", type(Bar).__name__)
row("type(type).__name__", type(type).__name__)
row("type(BarSub).__name__  (inherited metaclass)", type(BarSub).__name__)
row("BarSub.forge()", BarSub.forge())

section(6, "setattr with a bound MethodType")
setattr(obj, "wave", types.MethodType(lambda self: f"wave from {self.name}", obj))
row("obj.wave()", obj.wave())

section(7, "extend: a per-object subclass with the mixin first")
obj.__class__ = type("FooLoud", (Loud, type(obj)), {})
row("isinstance(obj, Loud)", isinstance(obj, Loud))
row("[c.__name__ for c in type(obj).__mro__]", [c.__name__ for c in type(obj).__mro__])
row("obj.shout()", obj.shout())
row("hasattr(other, 'shout')", hasattr(other, "shout"))

section(8, "copy.copy keeps the class and the bound methods")
dup = copy.copy(obj)
row("type(copy.copy(obj)).__name__", type(dup).__name__)
row("sorted(vars(dup))", sorted(vars(dup)))
dup.name = "copy"
row("dup.wave() after renaming the copy", f"{dup.wave()}  (still bound to obj)")
row("dup.wave.__self__ is obj", dup.wave.__self__ is obj)

section(9, "built-in instances take no attributes")
try:
    (1).greet = greet
except AttributeError as e:
    row("(1).greet = greet", type(e).__name__)
try:
    "sym".greet = greet
except AttributeError as e:
    row('"sym".greet = greet', type(e).__name__)
row("type(None).__name__", type(None).__name__)
