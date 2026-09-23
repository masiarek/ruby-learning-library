"""define_method_py.py -- the same rows, asked of setattr and the closures behind it."""

import functools


def row(n, label, value):
    head = "   " if n == "" else f"{n:>2}."
    print(f"{head} {label:<46} {value}")


class Light:
    def __init__(self, colour):
        self.colour = colour

    def greet(self):
        return "hi"

    def is_colour(self, colour):
        return self.colour == colour


for c in ("red", "green", "blue"):                        # 1. late binding: every lambda reads c
    setattr(Light, f"for_{c}", lambda self: self.colour == c)

for c in ("red", "green", "blue"):                        # 2. a default argument freezes c now
    setattr(Light, f"is_{c}", lambda self, c=c: self.colour == c)

returned = setattr(Light, "noop", lambda self: None)     # 3. what setattr returns

Light.hello = Light.greet                                 # 4. from an existing function ...
Light.double = lambda self, x: x * 2                      #    ... or from a lambda


def make_triple(factor):                                  # 6. a closure over a local
    def triple(self, x):
        return x * factor
    return triple


Light.triple = make_triple(3)


def each_twice(self, fn):                                 # 7. a callback is a parameter
    return [fn(1), fn(2)]


Light.each_twice = each_twice

setattr(Light, "__secret", lambda self: "s")              # 8. no mangling after compile time

ns = {}
for c in ("red", "green", "blue"):                        # 10. the string route
    exec(f"def str_{c}(self): return self.colour == {c!r}", ns)
    setattr(Light, f"str_{c}", ns[f"str_{c}"])

Light.is_red2 = functools.partialmethod(Light.is_colour, "red")   # 12. one method, specialised


def my_attr(cls, *names):                                 # 9. attr_accessor, reimplemented
    for n in names:
        setattr(cls, n, property(lambda self, n=n: getattr(self, "_" + n),
                                 lambda self, v, n=n: setattr(self, "_" + n, v)))


class Person:
    pass


my_attr(Person, "name", "age")

light = Light("red")
row(1, "for c in ...: for_red for_green for_blue", [light.for_red(), light.for_green(), light.for_blue()])
row(2, "lambda self, c=c: is_red is_green is_blue", [light.is_red(), light.is_green(), light.is_blue()])
row(3, "setattr(Light, 'noop', ...) returned", returned)
row("", "setattr is always called from outside", "-")
row(4, "hello (Light.hello = Light.greet)", repr(light.hello()))
row("", "double (from a lambda): double(4)", light.double(4))
try:
    light.double()
except TypeError as e:
    row(5, "double with no argument", type(e).__name__)
row(6, "triple(3) -- the closure sees factor", light.triple(3))
row("", "a def is a closure too", "no NameError to show")
row(7, "no yield to fail: a callback is a parameter", "-")
row("", "each_twice(lambda x: x * 10)", light.each_twice(lambda x: x * 10))
row(8, 'setattr(Light, "__secret", ...) then getattr', repr(getattr(light, "__secret")()))
row("", 'hasattr(light, "_Light__secret")', hasattr(light, "_Light__secret"))
person = Person()
person.name = "Ada"
person.age = 36
row(9, 'my_attr(Person, "name", "age") -> name, age', f"{person.name!r}, {person.age}")
row("", "sorted(vars(Person)) minus dunders", sorted(k for k in vars(Person) if not k.startswith("__")))
row(10, "exec(f'def str_{c}(self): ...') per colour", [light.str_red(), light.str_green(), light.str_blue()])
row(11, "sorted(k for k in vars(Light) if 'red' in k)", sorted(k for k in vars(Light) if "red" in k))
row(12, "is_red2 -- partialmethod(is_colour, 'red')", light.is_red2())
