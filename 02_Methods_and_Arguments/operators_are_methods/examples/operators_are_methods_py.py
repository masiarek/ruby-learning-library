"""The Python twin: `__add__`, `__neg__`, `__getitem__`, `__setitem__`,
`__eq__`, `__lt__`, `__lshift__`, `__bool__` and `__rmul__` are the hooks,
`1 + 2` is `(1).__add__(2)`, and `and`, `or`, `not`, `=` and the
conditional expression have no hook at all."""
from functools import total_ordering


@total_ordering
class Vec:
    def __init__(self, x, y):
        self.x, self.y = x, y
        self.bool_calls = 0

    def __add__(self, other):
        return Vec(self.x + other.x, self.y + other.y)

    def __neg__(self):
        return Vec(-self.x, -self.y)

    def __getitem__(self, i):
        return [self.x, self.y][i]

    def __setitem__(self, i, value):
        if i == 0:
            self.x = value
        else:
            self.y = value
        return "ignored"

    def __eq__(self, other):
        return (self.x, self.y) == (other.x, other.y)

    def __lt__(self, other):
        return (self.x, self.y) < (other.x, other.y)

    def __lshift__(self, n):
        return Vec(self.x + n, self.y + n)

    def __mul__(self, n):
        return Vec(self.x * n, self.y * n)

    def __rmul__(self, n):
        return Vec(self.x * n, self.y * n)

    def __bool__(self):
        self.bool_calls += 1
        return False

    def __repr__(self):
        return f"Vec({self.x}, {self.y})"


class NoLt:
    pass


class Bits:
    def __and__(self, other):
        return "bitwise & called"


v = Vec(1, 2)
w = Vec(3, 4)

print("1. an operator is a call:         1 + 2 ->", 1 + 2, ", (1).__add__(2) ->", (1).__add__(2), ", int.__add__(1, 2) ->", int.__add__(1, 2), ", type((1).__add__).__name__ ->", type((1).__add__).__name__)
print("2. def __add__:                   v + w ->", v + w, ", v.__add__(w) ->", v.__add__(w))
print("3. def __neg__:                   -v ->", -v)
v[1] = 9
print("4. __getitem__ and __setitem__:   v[0] ->", v[0], "; v[1] = 9 is a statement with no value (the 'ignored' return is discarded); v is", v)
v[1] = 2
print("5. __eq__ and __lt__ (+ total_ordering): v < w", v < w, ", v == Vec(1, 2)", v == Vec(1, 2), ", v != w", v != w, ", min([w, v]) ->", min([w, v]), ", v > w", v > w)
try:
    NoLt() < NoLt()
except TypeError as e:
    print("   without __lt__:               NoLt() < NoLt() ->", type(e).__name__)
print("6. def __lshift__:                v << 10 ->", v << 10)
result = not v
print("7. not calls __bool__:            not v ->", result, "(__bool__ ran", v.bool_calls, "time and could only return a bool)")
print("8. __mul__ and __rmul__:          v * 2 ->", v * 2, "; 2 * v ->", 2 * v, "(the reflected hook answers)")
b = Bits()
print("9. and is not a hook:             b & b ->", b & b, "; b and 'second' ->", repr(b and "second"), "(__and__ not called)")
import keyword
print("   keywords, not methods:         and", keyword.iskeyword("and"), ", or", keyword.iskeyword("or"), ", not", keyword.iskeyword("not"))
dunder = {"+": "__add__", "-": "__sub__", "*": "__mul__", "/": "__truediv__", "%": "__mod__", "**": "__pow__",
          "==": "__eq__", "!=": "__ne__", "<": "__lt__", "<=": "__le__", ">": "__gt__", ">=": "__ge__",
          "<=>": None, "<<": "__lshift__", ">>": "__rshift__", "&": "__and__", "|": "__or__", "^": "__xor__",
          "~": "__invert__", "!": None, "-@": "__neg__", "+@": "__pos__", "[]": "__getitem__", "===": None,
          "&&": None, "||": None, "..": None, "and": None, "or": None, "not": None, "=": None}
hooked = [op for op, name in dunder.items() if name and hasattr(int, name)]
unhooked = [op for op, name in dunder.items() if not (name and hasattr(int, name))]
print("10. int has a hook for:           " + " ".join(hooked))
print("    no hook (syntax, or not Python):", " ".join(unhooked))
