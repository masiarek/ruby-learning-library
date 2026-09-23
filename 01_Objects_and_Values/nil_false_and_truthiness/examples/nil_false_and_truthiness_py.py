"""Python asks __bool__, then __len__: the twin of nil_false_and_truthiness_rb.rb.

It prints the same numbered rows. Python has no symbol, so row 1's last line
uses a str and says so.
"""


def row(label, shown):
    print(f"   {label:<36} {shown}")


print("1. the truth table: bool(x)")
for label, x in [("None", None), ("False", False), ("0", 0), ("0.0", 0.0), ("''", ""),
                 ("[]", []), ("{}", {}), ("'a' (no symbols: a str)", "a")]:
    row(label, repr(bool(x)))

print("2. None is an object with methods")
row("str(None)", repr(str(None)))
try:
    list(None)
except TypeError as e:
    row("list(None) (no nil.to_a)", type(e).__name__)
try:
    int(None)
except TypeError as e:
    row("int(None) (no nil.to_i)", type(e).__name__)
row("repr(None)", repr(repr(None)))

print("3. or returns the first truthy operand")
x = None
row('x = None;  x or "default"', repr(x or "default"))
x = 0
row('x = 0;     x or "default"', repr(x or "default"))
x = ""
row('x = "";    x or "default"', repr(x or "default"))
x = False
row('x = False; x or "default"', repr(x or "default"))

print("4. None and False are two different objects")
row("None == False", repr(None == False))
x = None
row("x = None;  x is None", repr(x is None))
x = False
row("x = False; x is None", repr(x is None))
row("False == 0", repr(False == 0))

print("5. truthiness is a method a class can define")


class Hollow:
    def __bool__(self):
        return False


h = Hollow()
row("not h   (Hollow defines __bool__)", repr(not h))
row("'truthy' if h else 'falsy'", repr("truthy" if h else "falsy"))
row("not not h", repr(not not h))
row("len([])", repr(len([])))
row("'truthy' if [] else 'falsy'", repr("truthy" if [] else "falsy"))

print("6. if 0 and if '' take the else branch")
n = 0
row("n = 0;  'then' if n else 'else'", repr("then" if n else "else"))
s = ""
row("s = ''; 'then' if s else 'else'", repr("then" if s else "else"))

print("7. dropping None is not dropping falsy")
mixed = [None, 1, False, 2]
row("[v for v in mixed if v is not None]", repr([v for v in mixed if v is not None]))
row("[v for v in mixed if v]", repr([v for v in mixed if v]))
