# The same rows, asked of Python: 1 == 1.0, and they also hash alike, so a
# dict, a set and Counter see one key — and the int keeps its spelling.
# Comparison across the line is exact here too.
from collections import Counter
from fractions import Fraction


def row(n, expr, value, note=""):
    print(f"{n:2d}. {expr:<36} -> {value:<22} {note}")


def match_literal(x):
    match x:
        case 1:
            return "case 1 matches"
        case _:
            return "nothing matches"


def match_class(x):
    match x:
        case int():
            return "case int()"
        case float():
            return "case float()"


big = 2 ** 53 + 1
h = {1: "int"}
h[1.0] = "float"
one, one_again, one_f = 1, 1, 1.0

row(1,  "1 == 1.0",                              repr(1 == 1.0),                      "== compares by numeric value across types")
row(2,  "type(1) is type(1.0)",                  repr(type(1) is type(1.0)),          f"no eql?; (1).__eq__(1.0) is {(1).__eq__(1.0)}, so float.__eq__ answers instead")
row(3,  "one is one_f",                          repr(one is one_f),                  f"identity; one is one_again is {one is one_again}: small ints are cached in CPython")
row(4,  "hash(1) == hash(1.0)",                  repr(hash(1) == hash(1.0)),          "equal numbers must hash alike, so these are one key")
row(5,  "{1: 'a'}[1.0]",                         repr({1: "a"}[1.0]),                 f"found; {{1.0: 'a'}}[1] is {({1.0: 'a'}[1])!r} too")
row(6,  "h = {1: 'int'}; h[1.0] = 'float'; h",   repr(h),                             f"one entry, and the int key kept its spelling; len(h) is {len(h)}")
row(7,  "list(dict.fromkeys([1, 1.0]))",         repr(list(dict.fromkeys([1, 1.0]))), f"the uniq idiom keeps one; {{1, 1.0}} is {({1, 1.0})!r}, Counter {dict(Counter([1, 1.0]))!r}")
row(8,  "1.0 in [1], [1].index(1.0)",            f"{1.0 in [1]}, {[1].index(1.0)}",     "in, index and count use ==, so they cross the line")
row(9,  "1 < 1.5, 1 <= 1.0",                     f"{1 < 1.5}, {1 <= 1.0}",              f"ordered as equal, no <=>; match 1.0: {match_literal(1.0)}")
row(10, "isinstance(1.0, int), isinstance(1, float)", f"{isinstance(1.0, int)}, {isinstance(1, float)}", f"a class pattern does not convert: match 1.0 takes {match_class(1.0)}; (1.0).is_integer() is {(1.0).is_integer()}")
row(11, "2 ** 53 + 1 == float(2 ** 53 + 1)",     repr(big == float(big)),             f"exact comparison: the float is {int(float(big))}, so 2 ** 53 + 1 > it is {big > float(big)}")
row(12, "10 ** 20 + 1 == 1e20",                  repr(10 ** 20 + 1 == 1e20),          f"but 10 ** 20 == 1e20 is {10 ** 20 == 1e20}: the int is not rounded to a float first")
row(13, "0.1 == Fraction(1, 10)",                repr(0.1 == Fraction(1, 10)),        f"a Fraction meets a float exactly, and 0.1 is not one tenth; 0.5 == Fraction(1, 2) is {0.5 == Fraction(1, 2)}")
row(14, "0 == -0.0, hash(0.0) == hash(-0.0)",    f"{0 == -0.0}, {hash(0.0) == hash(-0.0)}", f"one value and one key: {{0.0: 'a'}}[-0.0] is {({0.0: 'a'}[-0.0])!r}")
row(15, "1 == Fraction(1), 1 == complex(1, 0)",  f"{1 == Fraction(1)}, {1 == complex(1, 0)}", f"== crosses every numeric type, and so does hash: hash(1) == hash(Fraction(1)) is {hash(1) == hash(Fraction(1))}")
