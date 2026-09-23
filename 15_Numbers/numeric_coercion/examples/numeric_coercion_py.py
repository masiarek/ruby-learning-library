# The same rows, asked of Python: int.__add__ returns NotImplemented for a
# type it does not know, and Python then tries the other operand's reflected
# method (__radd__, __rmul__, __rsub__). A class of ours joins in by defining
# those; str has none, so TypeError. __index__ and __str__ are the other,
# implicit protocols.
import numbers
from fractions import Fraction


def row(n, expr, value, note=""):
    print(f"{n:2d}. {expr:<28} -> {value:<28} {note}")


def caught(thunk):
    try:
        return repr(thunk())
    except TypeError as e:
        return type(e).__name__  # the message is reworded between releases


class Meters:
    def __init__(self, n):
        self.n = n

    def __add__(self, other):
        return Meters(self.n + Meters.value_of(other))

    def __sub__(self, other):
        return Meters(self.n - Meters.value_of(other))

    def __mul__(self, other):
        return Meters(self.n * Meters.value_of(other))

    def __rmul__(self, other):
        print(f"    Meters.__rmul__({other!r}) called on {self!r}")
        return self * other

    def __rsub__(self, other):
        print(f"    Meters.__rsub__({other!r}) called on {self!r}")
        return Meters(Meters.value_of(other) - self.n)

    @staticmethod
    def value_of(x):
        return x.n if isinstance(x, Meters) else x

    def __repr__(self):
        return f"Meters({self.n})"


class Name:
    def __str__(self):
        return "Bob"


class Index:
    def __index__(self):
        return 1


m = Meters(3)

row(1,  "1 + Fraction(1, 2)",        repr(1 + Fraction(1, 2)),          f"the int is promoted to the wider type: {type(1 + Fraction(1, 2)).__name__}")
row(2,  "1 + 1.5",                   repr(1 + 1.5),                     type(1 + 1.5).__name__)
row(3,  "Fraction(1, 2) + 0.5",      repr(Fraction(1, 2) + 0.5),        "Fraction meets float: float wins, and exactness is gone")
row(4,  "1 + 2j",                    repr(1 + 2j),                      f"{type(1 + 2j).__name__}; every pairing has a wider type to go to")
row(5,  "(1).__add__(2.5)",          repr((1).__add__(2.5)),            "int declines a float: NotImplemented, not an error")
row(6,  "(2.5).__radd__(1)",         repr((2.5).__radd__(1)),           "so Python asks the float's reflected method, and that answers")
row(7,  "m * 2",                     repr(m * 2),                       "our own __mul__, with a number")
row(8,  "2 * m",                     repr(2 * m),                       "int.__mul__(2, m) returned NotImplemented, so Meters.__rmul__(2) ran")
row(9,  "2 - m",                     repr(2 - m),                       "__rsub__ gets the left operand as its argument and keeps the order itself")
row(10, '1 + "1"',                   caught(lambda: 1 + "1"),           "str has no __radd__ for an int")
row(11, '"1" + 1',                   caught(lambda: "1" + 1),           "and str.__add__ wants a str")
row(12, 'int("1") + 1',              repr(int("1") + 1),                f'convert explicitly; "1" + str(1) is {"1" + str(1)!r}')
row(13, '"a" + Name()',              caught(lambda: "a" + Name()),      f'no implicit conversion to str; f"a{{Name()}}" is {f"a{Name()}"!r}, via __str__')
row(14, "[10, 20, 30][Index()]",     repr([10, 20, 30][Index()]),       "__index__ is the implicit conversion to an int")
row(15, "1 + Index()",               caught(lambda: 1 + Index()),       "arithmetic asks for __add__ and __radd__, never for __index__")
row(16, "[c.__name__ for c in int.__mro__]", repr([c.__name__ for c in int.__mro__]), f"no Numeric class; the numbers ABCs instead: isinstance(1, numbers.Number) is {isinstance(1, numbers.Number)}")
