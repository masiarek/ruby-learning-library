# The same rows, asked of Python: the same binary floats, but round() is
# banker's and correctly rounded, overflow raises, and max() with a NaN
# silently depends on the order.
import math
import sys
from decimal import ROUND_HALF_UP, Decimal
from fractions import Fraction


def row(n, expr, value, note=""):
    print(f"{n:2d}. {expr:<34} -> {value:<22} {note}")


def caught(thunk):
    try:
        return repr(thunk())
    except OverflowError as e:
        return type(e).__name__


def half_up(x):
    return Decimal(str(x)).quantize(Decimal("1"), rounding=ROUND_HALF_UP)


nan = math.nan

row(1,  "0.1 + 0.2",                          repr(0.1 + 0.2),                      f"== 0.3 is {0.1 + 0.2 == 0.3}")
row(2,  "round(0.1 + 0.2, 2)",                repr(round(0.1 + 0.2, 2)),            f"== 0.3 is {round(0.1 + 0.2, 2) == 0.3}")
row(3,  "abs(0.1 + 0.2 - 0.3)",               repr(abs(0.1 + 0.2 - 0.3)),           f"< sys.float_info.epsilon is {abs(0.1 + 0.2 - 0.3) < sys.float_info.epsilon}; math.isclose(0.1 + 0.2, 0.3) is {math.isclose(0.1 + 0.2, 0.3)}")
row(4,  "round(2.5), round(3.5), round(-2.5)", f"{round(2.5)}, {round(3.5)}, {round(-2.5)}", f"a half rounds to even; the result is an {type(round(2.5)).__name__}")
row(5,  "Decimal('2.5') quantized HALF_UP",   str(half_up(2.5)),                    f"away from zero on request, via decimal; 3.5 gives {half_up(3.5)}, -2.5 gives {half_up(-2.5)}")
row(6,  "round(2.675, 2)",                    repr(round(2.675, 2)),                f"the float is {2.675:.20f}, and round() rounds that exact value, so down")
row(7,  "round(0.125, 2)",                    repr(round(0.125, 2)),                "0.125 is exact in binary: a true half, rounded to even")
row(8,  "math.floor(2.567 * 100) / 100",      repr(math.floor(2.567 * 100) / 100),  f"no digits argument on floor; round(1234.567, -2) is {round(1234.567, -2)}, a {type(round(1234.567, -2)).__name__}")
row(9,  "sys.float_info.epsilon",             repr(sys.float_info.epsilon),         f"max {sys.float_info.max}, min {sys.float_info.min}, dig {sys.float_info.dig}, mant_dig {sys.float_info.mant_dig}")
row(10, "2.0 ** 1024",                        caught(lambda: 2.0 ** 1024),          f"overflow raises; sys.float_info.max * 10 is {sys.float_info.max * 10}, no error")
row(11, "nan == nan, math.isnan(nan)",        f"{nan == nan}, {math.isnan(nan)}",    f"NaN is unequal to everything, itself included; nan < 1.0 is {nan < 1.0}")
row(12, "nan in [nan], [nan] == [nan]",       f"{nan in [nan]}, {[nan] == [nan]}",   "a container checks identity before ==, so the same NaN object is found")
row(13, "max(1.0, nan), max(nan, 1.0)",       f"{max(1.0, nan)}, {max(nan, 1.0)}",   "no error: the answer depends on the order")
row(14, "Fraction(0.1)",                      str(Fraction(0.1)),                   f"the exact binary value; (0.1).hex() is {(0.1).hex()}")
row(15, "Fraction(0.1).limit_denominator(100)", str(Fraction(0.1).limit_denominator(100)), "the simplest fraction with a denominator up to 100")
row(16, "1e16 + 1",                           repr(1e16 + 1),                       f"== 1e16 is {1e16 + 1 == 1e16}: the doubles are 2 apart here; 1e16 + 2 is {1e16 + 2}")
row(17, "math.nextafter(1.0, 2.0)",           repr(math.nextafter(1.0, 2.0)),       f"math.ulp(1.0) == epsilon is {math.ulp(1.0) == sys.float_info.epsilon}; nextafter(1e16, inf) is {math.nextafter(1e16, math.inf)}")
