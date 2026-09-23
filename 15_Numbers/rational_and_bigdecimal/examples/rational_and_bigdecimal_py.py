# The same rows, asked of Python: Fraction is Rational, Decimal is
# BigDecimal with a context, complex is Complex — and Python refuses to mix
# a Decimal with a float where Ruby converts.
import cmath
import math
import numbers
from decimal import ROUND_HALF_UP, Decimal, localcontext
from fractions import Fraction


def row(n, expr, value, note=""):
    print(f"{n:2d}. {expr:<38} -> {value:<22} {note}")


def caught(thunk):
    try:
        return repr(thunk())
    except Exception as e:
        return type(e).__name__  # messages are reworded between releases


third = Fraction(1, 3)
tenth = Decimal("0.1")
price = Decimal("1234.5678")

row(1,  "Fraction(1, 3)",                         repr(third),                            f"no literal; str() is {third}")
row(2,  "Fraction('1/3'), Fraction(3), Fraction('0.1')", f"{Fraction('1/3')}, {Fraction(3)}, {Fraction('0.1')}", "the string forms are exact; Fraction('0.1') is one tenth")
row(3,  "Fraction(0.1)",                          str(Fraction(0.1)),                     "from a float you get the float's exact value, not one tenth")
row(4,  "Fraction(1, 3) + Fraction(1, 6)",        str(third + Fraction(1, 6)),            f"exact arithmetic; Fraction(1, 3) * 3 == 1 is {third * 3 == 1}")
row(5,  "float(Fraction(1, 3))",                  repr(float(third)),                     f"a float on request; Fraction(1, 3) + 0.5 is {third + 0.5!r}, a {type(third + 0.5).__name__}")
row(6,  "round(Fraction(5, 2))",                  repr(round(Fraction(5, 2))),            f"half to even, like float; round(Fraction(1, 3), 2) is {round(third, 2)}, a {type(round(third, 2)).__name__}")
row(7,  "Decimal('0.1') + Decimal('0.2') == Decimal('0.3')", repr(tenth + Decimal("0.2") == Decimal("0.3")), "decimal digits, so there is no binary fraction to miss by")
row(8,  "str(Decimal('0.1') + Decimal('0.2'))",   repr(str(tenth + Decimal("0.2"))),      f"str is positional; format(..., 'e') is {format(tenth + Decimal('0.2'), 'e')!r}")
row(9,  "f\"{Decimal('1234.5678'):,}\"",          repr(f"{price:,}"),                     f"grouped by 3; float {float(price)}, int {int(price)}, as_integer_ratio {price.as_integer_ratio()}")
row(10, "Decimal('2.675').quantize(Decimal('0.01'))", str(Decimal("2.675").quantize(Decimal("0.01"))), f"ROUND_HALF_EVEN on decimal digits by default; ROUND_HALF_UP gives {Decimal('2.675').quantize(Decimal('0.01'), rounding=ROUND_HALF_UP)}, and 2.665 gives {Decimal('2.665').quantize(Decimal('0.01'))}")
with localcontext() as ctx:
    ctx.prec = 10
    row(11, "Decimal(1) / 3, with prec 10",       str(Decimal(1) / 3),                    f"division uses the context's precision (28 by default); Decimal(1) / 3 * 3 == 1 is {Decimal(1) / 3 * 3 == 1}, while Fraction(1, 3) * 3 == 1 is {third * 3 == 1}")
row(12, "Decimal('0.1') == 0.1",                  repr(tenth == 0.1),                     f"a float is compared exactly: Decimal(0.1) is {Decimal(0.1)}")
row(13, "Decimal('0.1') + 0.1",                   caught(lambda: tenth + 0.1),            f"no implicit mixing with float; Decimal('0.1') + Fraction(1, 10) is {caught(lambda: tenth + Fraction(1, 10))} too")
row(14, "complex(1, 2) * complex(1, 2)",          repr(complex(1, 2) * complex(1, 2)),    f"2j is a literal; abs(complex(3, 4)) is {abs(complex(3, 4))}; (real, imag) {(complex(1, 2).real, complex(1, 2).imag)}")
row(15, "math.sqrt(-1)",                          caught(lambda: math.sqrt(-1)),          f"no complex unless asked: cmath.sqrt(-1) is {cmath.sqrt(-1)}; 1j ** 2 is {1j ** 2}")
row(16, "isinstance(Fraction(1, 3), numbers.Rational)", repr(isinstance(third, numbers.Rational)), f"the numbers ABCs; isinstance(Decimal('1'), numbers.Real) is {isinstance(Decimal('1'), numbers.Real)}, numbers.Number {isinstance(Decimal('1'), numbers.Number)}")
