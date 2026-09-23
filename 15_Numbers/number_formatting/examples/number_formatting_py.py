# The same rows, asked of Python: format() and f-strings speak the same
# mini-language plus a thousands flag, hex/bin/oct carry a prefix, int(s, base)
# raises on junk, and str(float) switches to exponent form one digit later
# than Ruby's to_s.


def row(n, expr, value, note=""):
    print(f"{n:2d}. {expr:<42} -> {value:<26} {note}")


def caught(thunk):
    try:
        return repr(thunk())
    except (ValueError, TypeError) as e:
        return type(e).__name__  # the message is reworded between releases


row(1,  "format(3.14159, '.2f')",                     repr(format(3.14159, ".2f")),               "fixed decimals; f'{3.14159:.2f}' and '%.2f' % 3.14159 are the other spellings")
row(2,  "f'{3.14159:08.3f}'",                         repr(f"{3.14159:08.3f}"),                   "width 8, zero-filled, 3 decimals")
row(3,  "f'{123456.789:e}'",                          repr(f"{123456.789:e}"),                    f"scientific; f'{{0.000123456:.3e}}' is {f'{0.000123456:.3e}'!r}, g picks a form: {f'{1234567.0:g}'!r}")
row(4,  "f'{255:x} {255:b} {255:o}'",                 repr(f"{255:x} {255:b} {255:o}"),           f"bases without a prefix; #x #b #o give {f'{255:#x} {255:#b} {255:#o}'!r}")
row(5,  "f'{5:+d}|{42:05d}|{42:<5d}|'",                repr(f"{5:+d}|{42:05d}|{42:<5d}|"),         "a sign, zero fill, left alignment")
row(6,  "f'{-5:08b}'",                                repr(f"{-5:08b}"),                          f"a negative keeps its minus sign, no two's complement; f'{{-255:x}}' is {f'{-255:x}'!r}")
row(7,  "format(2.675, '.2f')",                       repr(format(2.675, ".2f")),                 f"the exact binary value is rounded: 2.665 gives {2.665:.2f} and 2.685 gives {2.685:.2f}")
row(8,  "f'{1234567:,}'",                             repr(f"{1234567:,}"),                       f"a thousands flag is built in; f'{{1234567:_}}' is {f'{1234567:_}'!r}, f'{{1234567.891:,.2f}}' is {f'{1234567.891:,.2f}'!r}")
row(9,  "hex(255), bin(255), format(255, 'x')",       f"{hex(255)!r}, {bin(255)!r}, {format(255, 'x')!r}", f"hex/bin/oct carry a prefix; no to_s(36), but int('73', 36) reads it: {int('73', 36)}")
row(10, "int('ff', 16), int('0x1f', 16), int('0x1f', 0)", f"{int('ff', 16)}, {int('0x1f', 16)}, {int('0x1f', 0)}", f"back from a base; base 0 reads the prefix; int('zz', 16) is {caught(lambda: int('zz', 16))}: int() always raises on junk")
row(11, "int('0b101', 0), int('1_000'), int('017', 8)", f"{int('0b101', 0)}, {int('1_000')}, {int('017', 8)}", "a prefix needs base 0 or the matching base; underscores are fine")
row(12, "int('08')",                                  repr(int("08")),                            f"a leading 0 is just a digit in base 10; int('017', 0) is {caught(lambda: int('017', 0))}")
row(13, "str(0.1 + 0.2), str(1e20)",                  f"{str(0.1 + 0.2)!r}, {str(1e20)!r}",         "str is the shortest string that reads back as the same float; no .0 in the exponent form")
row(14, "str(999999999999999.9), str(1e15)",          f"{str(999999999999999.9)!r}, {str(1e15)!r}",  f"positional up to 16 integer digits; exponent form from 17: str(1e16) is {str(1e16)!r}; small: str(1e-5) is {str(1e-5)!r}")
row(15, "round(1234.5678, 2), round(1234.5678, -2)",  f"{round(1234.5678, 2)}, {round(1234.5678, -2)}", f"round(x, -2) on a float stays a float; round(1250, -2) is {round(1250, -2)}, half to even")
row(16, "str(round(3.1, 2)), f'{3.1:.2f}'",            f"{str(round(3.1, 2))!r}, {f'{3.1:.2f}'!r}",     "round drops trailing zeros, format keeps them: money wants format, or Decimal")
