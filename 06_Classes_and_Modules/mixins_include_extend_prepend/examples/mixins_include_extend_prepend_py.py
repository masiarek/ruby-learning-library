# The Python twin: a mixin is a base class, the order of bases is the MRO,
# and there is no prepend and no per-object extend.
# Each numbered row is printed by the Ruby program too, in the same order.

import functools
import types
from collections.abc import Sequence


def row(n, label, value):
    print(f"{n:2d}. {label:<58} {value}")


def failing(thunk):
    try:
        return thunk()
    except (AttributeError, TypeError) as e:
        return type(e).__name__          # messages are reworded between Python releases


def names(cls, k):
    return [c.__name__ for c in cls.__mro__[:k]]


TRACE = []


class Greeting:
    def greet(self):
        TRACE.append("Greeting")
        return f"hello from {self.name}"


class Person(Greeting):                  # 1. a mixin is a base class
    def __init__(self, name):
        self.name = name

    def __repr__(self):
        return f"<Person {self.name}>"


ann = Person("ann")
bob = Person("bob")

row(1, "class Person(Greeting) -- Person.__mro__[:3]", f"{names(Person, 3)!r}; ann.greet(): {ann.greet()!r}")
row(2, "issubclass(Person, Greeting) / bases beyond object",
    f"{issubclass(Person, Greeting)} / {[c.__name__ for c in Person.__mro__[1:-1]]!r}")


class Shouting:
    def shout(self):
        return f"{self.name.upper()}!"


bob.shout = types.MethodType(Shouting.shout, bob)   # 3. bind one method onto one object
row(3, "bob.shout = MethodType(...) -- bob.shout() / ann.shout()",
    f"{bob.shout()!r} / {failing(lambda: ann.shout())}")


class Counting:
    @classmethod
    def count(cls):
        return f"{cls.__name__} counts"


class Registry(Counting):                # 4. class methods come from a base with classmethods
    pass


row(4, "a base with @classmethod -- Registry.count()",
    f"{Registry.count()!r}; kind: {type(vars(Counting)['count']).__name__}")


class Loud:
    def greet(self):
        TRACE.append("Loud")
        return super().greet().upper()   # cooperative: the next class in the MRO


class Person(Loud, Greeting):            # 5. no prepend: list the mixin first
    def __init__(self, name):
        self.name = name

    def __repr__(self):
        return f"<Person {self.name}>"

    def greet(self):
        TRACE.append("Person")
        return "person says " + super().greet()


row(5, "class Person(Loud, Greeting) -- __mro__[:4]", repr(names(Person, 4)))

TRACE.clear()
result = Person("ann").greet()
row(6, "Person(\"ann\").greet(): the result / the order", f"{result!r} / {TRACE!r}")


def duplicate_base():
    class Twice(Greeting, Greeting):
        pass


row(7, "class Twice(Greeting, Greeting) -- a base listed twice", failing(duplicate_base))


@functools.total_ordering               # 8. two methods in, six out
class Version:
    def __init__(self, n):
        self.n = n

    def __eq__(self, other):
        return self.n == other.n

    def __lt__(self, other):
        return self.n < other.n

    def __repr__(self):
        return f"v{self.n}"


clamp = min(max(Version(5), Version(1)), Version(3))
row(8, "@total_ordering + __lt__/__eq__ -- v1 < v2 / min(max())",
    f"{Version(1) < Version(2)} / {clamp!r}")


class Deck(Sequence):                    # 9. __getitem__ + __len__ in, __contains__ etc. out
    CARDS = ["b", "a", "c"]

    def __getitem__(self, i):
        return self.CARDS[i]

    def __len__(self):
        return len(self.CARDS)


row(9, "Sequence + __getitem__/__len__ -- sorted / \"a\" in",
    f"{sorted(Deck())!r} / {'a' in Deck()}")

row(10, "a mixin is a class: Greeting() / a subclass of it",
    f"{type(Greeting()).__name__} instance / {type('Sub', (Greeting,), {}).__name__}")
