# The Python twin: there are no constants, a class body is not a scope that
# methods can see, and `typing.Final` changes nothing at run time.
# Each numbered row is printed by the Ruby program too, in the same order.

from typing import Final


def row(n, label, value):
    print(f"{n:2d}. {label:<58} {value}")


def failing(thunk):
    try:
        return thunk()
    except (NameError, AttributeError) as e:
        return type(e).__name__          # messages are reworded between Python releases


TOP = "top-level"


class Outer:
    LIMIT = 10

    class Inner:                         # 1. nesting is spelling only: Outer.Inner
        @staticmethod
        def qualname():
            return Outer.Inner.__qualname__

        @staticmethod
        def limit():
            return Outer.LIMIT           # the only way: name the class


class Compact:                           # 2. a method cannot see a class body's names
    LIMIT = 10

    @staticmethod
    def limit():
        return LIMIT                     # looks for a global LIMIT: NameError


row(1, "nested class: __qualname__ / Outer.LIMIT", f"{Outer.Inner.qualname()!r} / {Outer.Inner.limit()}")
row(2, "a bare LIMIT inside a method of the class that defines it", failing(Compact.limit))


class Parent:
    LIMIT = 20


class Child(Parent):
    @classmethod
    def limit(cls):
        return cls.LIMIT                 # 3. found through the MRO

    @staticmethod
    def top():
        return TOP                       # 4. found as a module global (LEGB)


row(3, "Child(Parent): cls.LIMIT found through the MRO", str(Child.limit()))
row(4, "TOP from inside Child: a module global", f"{Child.top()} / 'TOP' in globals(): {'TOP' in globals()}")

X: Final = 1
X = 2                                    # 5. Final is for type checkers; nothing warns
row(5, "X: Final = 1; X = 2 -- prints / warns", f"{X!r} / none")


class Shop:
    TAX = 0.2

    @staticmethod
    def tax():
        return "method tax"


row(6, "Shop.TAX / Shop.tax() -- one dot for both",
    f"{Shop.TAX} / {Shop.tax()} / (no :: form)")

upper = sorted(k for k in vars(Shop) if k.isupper())
row(7, "getattr(Shop, \"TAX\") / uppercase in vars(Shop) / hasattr",
    f"{getattr(Shop, 'TAX')} / {upper!r} / {hasattr(Shop, 'NOPE')}")


class Missing(type):
    def __getattr__(cls, name):          # 8. the hook, on the metaclass
        return f"__getattr__ saw {name}"


class Shop(Shop, metaclass=Missing):
    pass


row(8, "Shop.NOPE with a metaclass __getattr__", repr(Shop.NOPE))

LIST = [1]
LIST.append(2)                           # 9. the name is a convention; the object is a list
row(9, "LIST = [1]; LIST.append(2) -- LIST / is it frozen?", f"{LIST!r} / no such thing")

NAME = "module global"


class Greeter:
    NAME = "greeter"

    def who(self):
        return NAME                      # 10. LEGB skips the class body: the module global

    def whose(self):
        return type(self).NAME           #     the receiver's class's NAME


class Robot(Greeter):
    NAME = "robot"


row(10, "mixin method: bare NAME / type(self).NAME, on a Robot",
    f"{Robot().who()!r} / {Robot().whose()!r}")
