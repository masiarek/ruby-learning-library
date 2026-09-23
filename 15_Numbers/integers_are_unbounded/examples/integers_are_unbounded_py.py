# The same rows, asked of Python: int is unbounded too, with bit_length,
# pow(a, b, m), math.isqrt, math.gcd and math.lcm — and one limit Ruby does
# not have, the 4300-digit cap on str(int).
import math
import sys


def row(n, expr, value, note=""):
    print(f"{n:2d}. {expr:<27} -> {value:<22} {note}")


def caught(thunk):
    try:
        return repr(thunk())
    except (NameError, ValueError, SyntaxError) as e:
        return type(e).__name__  # messages are reworded between releases


row(1,  "2 ** 200",                   str(2 ** 200),                  f"({len(str(2 ** 200))} digits, and no overflow)")
row(2,  "type(2 ** 200).__name__",    type(2 ** 200).__name__,        "one class for every size; type(1).__name__ is int too")
row(3,  "long",                       caught(lambda: long),           "Python 2's second integer class is gone too")
row(4,  "(255).bit_length()",         repr((255).bit_length()),       f"(256).bit_length() is {(256).bit_length()}")
row(5,  "(-1).bit_length()",          repr((-1).bit_length()),        f"bits of the magnitude: (-256).bit_length() is {(-256).bit_length()}")
row(6,  "digits of 1234",             repr([int(d) for d in str(1234)][::-1]), "no digits(); go through str and reverse")
row(7,  "bin(255)",                   repr(bin(255)),                 f"prefixed; format(255, 'b') is {format(255, 'b')!r}, hex(255) is {hex(255)!r}, bin(-255) is {bin(-255)!r}")
row(8,  "math.isqrt(10 ** 40)",       str(math.isqrt(10 ** 40)),      f"exact; math.sqrt(10 ** 40) is {math.sqrt(10 ** 40)}, a float")
row(9,  "pow(3, 200, 1000)",          repr(pow(3, 200, 1000)),        f"modular pow, never building the {len(str(3 ** 200))}-digit power")
row(10, "math.gcd(12, 18), lcm",      f"{math.gcd(12, 18)}, {math.lcm(12, 18)}", "two functions; math.lcm arrived in 3.9")
row(11, "2 ** -1",                    repr(2 ** -1),                  "a negative exponent gives a float, not a Fraction")
row(12, "int(float(2 ** 53 + 1))",    str(int(float(2 ** 53 + 1))),   "the +1 is lost: a float holds 53 bits of integer")
row(13, "len(str(10 ** 5000))",       caught(lambda: len(str(10 ** 5000))), f"the {sys.get_int_max_str_digits()}-digit limit on str(int)")
sys.set_int_max_str_digits(0)
row(14, "len(f'{10 ** 5000:x}')",     repr(len(f"{10 ** 5000:x}")),   f"hex never had the limit; after set_int_max_str_digits(0), len(str(10 ** 5000)) is {len(str(10 ** 5000))}")
row(15, "0b1010, 0o17, 0x1f, 1_000",  f"{0b1010}, {0o17}, {0x1f}, {1_000}", f"literal forms; a leading 0 alone is a {caught(lambda: compile('017', '', 'eval'))}")
