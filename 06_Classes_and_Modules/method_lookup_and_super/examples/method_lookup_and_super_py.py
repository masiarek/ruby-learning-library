# The Python twin: the walk is `__mro__` (C3), `super()` takes explicit
# arguments, and the chain ends in `__getattr__`, not in a Kernel.
# Each numbered row is printed by the Ruby program too, in the same order.

import builtins


def row(n, label, value):
    print(f"{n:2d}. {label:<58} {value}")


def failing(thunk):
    try:
        return thunk()
    except AttributeError as e:
        return type(e).__name__          # messages are reworded between Python releases


def names(cls, k=None):
    return [c.__name__ for c in cls.__mro__[:k]]


class Animal:
    def speak(self, times=1):
        return f"animal x{times}"

    def shout(self, times=1):
        return f"ANIMAL x{times}"

    def move(self):
        return "animal moves"


class Walkable:
    def move(self):
        return "walk, then " + super().move()   # cooperative: the next class in the MRO


class Dog(Walkable, Animal):             # no prepend: Dog is first in its own MRO
    def speak(self, times=1):
        return "dog:" + super().speak(times)    # arguments are always explicit

    def shout(self, times=1):
        times += 1
        return super().shout(times)             # explicit, so of course the new value

    def __getattr__(self, name):                # runs only after normal lookup fails
        if name.startswith("fl"):
            return f"__getattr__ caught {name}"
        raise AttributeError(name)

    def __repr__(self):
        return "<Dog>"


class Cat(Animal):
    def speak(self, times=1):
        return "cat:" + super().speak()         # pass nothing: Animal's default applies

    def purr(self):
        return super().purr()                   # no base has purr


dog = Dog()

row(1, "Dog.__mro__", repr(names(Dog)))


class A: pass
class B(A): pass
class C(A): pass
class D(B, C): pass                      # 2. the diamond, with classes


row(2, "the diamond (B and C extend A) -- D.__mro__[:4]", repr(names(D, 4)))

row(3, "super().speak(times) -- Dog().speak(3)", repr(dog.speak(3)))
row(4, "super().speak() -- Cat().speak(3)", repr(Cat().speak(3)))
row(5, "super().shout(times) after times += 1 -- Dog().shout(3)", repr(dog.shout(3)))
row(6, "super() inside a mixin method -- dog.move()", repr(dog.move()))

class Base:
    def __init__(self):
        self.base = True


class Forgetful(Base):
    def __init__(self):
        self.sub = True                       # never calls super().__init__(): Base's is skipped


class Careful(Base):
    def __init__(self):
        super().__init__()
        self.sub = True


row(7, "__init__ without super() / with super() -- vars()",
    f"{list(vars(Forgetful()))!r} / {list(vars(Careful()))!r}")

owners = [c.__name__ for c in Dog.__mro__ if "speak" in vars(c)]
row(8, "classes in Dog.__mro__ that define speak", repr(owners))

row(9, "super().purr() with no base method -- Cat().purr()", failing(lambda: Cat().purr()))
row(10, "ends in __getattr__ -- dog.fly / hasattr(dog, \"fly\")",
    f"{dog.fly!r} / {hasattr(dog, 'fly')}")
row(11, "Dog.__bases__ / object.__bases__ / where print lives",
    f"{[b.__name__ for b in Dog.__bases__]!r} / {object.__bases__!r} / {'builtins' if builtins.print is print else '?'}")
