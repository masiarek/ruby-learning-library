# The same rows, asked of Python: `/` always makes a float, `//` floors,
# `%` follows the divisor, math.fmod follows the dividend, and zero raises.
import math
from fractions import Fraction


def row(n, expr, value, note=""):
    print(f"{n:2d}. {expr:<18} -> {value:<32} {note}")


def caught(thunk):
    try:
        return repr(thunk())
    except (ZeroDivisionError, OverflowError, ValueError) as e:
        return type(e).__name__  # the message is reworded between 3.12 and 3.14


row(1,  "7 / 2",            repr(7 / 2),            "/ always makes a float, even 4 / 2 -> " + repr(4 / 2) + "; 7 // 2 is " + repr(7 // 2))
row(2,  "-7 // 2",          repr(-7 // 2),          "// floors, like Ruby's /")
row(3,  "7 / 2",            repr(7 / 2),            "the float answer needs no fdiv; Fraction(7, 2) is " + repr(Fraction(7, 2)))
row(4,  "7 // 2.0",         repr(7 // 2.0),         "// on a float floors but stays a float; 7 / 2.0 is " + repr(7 / 2.0))
row(5,  "divmod(7, 2)",     repr(divmod(7, 2)),     "quotient and modulo as a tuple")
row(6,  "divmod(-7, 2)",    repr(divmod(-7, 2)),    "the pair floors too: -4 * 2 + 1 == -7")
row(7,  "-7 % 2",           repr(-7 % 2),           "% takes the sign of the divisor")
row(8,  "7 % -2",           repr(7 % -2),           "so a negative divisor gives a negative result")
row(9,  "math.fmod(-7, 2)", repr(math.fmod(-7, 2)), "fmod takes the sign of the dividend, and answers in float")
row(10, "7.0 // 2",         repr(7.0 // 2),         "floors but stays a float; math.floor(7.0 / 2) is " + repr(math.floor(7.0 / 2)))
row(11, "-(-7 // 2)",       repr(-(-7 // 2)),       "the ceiling-division idiom; math.ceil(7 / 2) is " + repr(math.ceil(7 / 2)))
row(12, "7.0 / 0",          caught(lambda: 7.0 / 0), "float division by zero raises too; math.inf is " + repr(math.inf))
row(13, "0.0 / 0",          caught(lambda: 0.0 / 0), "no NaN from division; math.nan == math.nan is " + repr(math.nan == math.nan))
row(14, "7 // 0",           caught(lambda: 7 // 0),  "integer division by zero raises")
row(15, "7.0 % 0",          caught(lambda: 7.0 % 0), "so does modulo")
row(16, "int(math.inf)",    caught(lambda: int(math.inf)), "infinity has no int value; int(math.nan) is " + caught(lambda: int(math.nan)))
