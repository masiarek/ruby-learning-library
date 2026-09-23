# The Python twin: `match` with class, literal and alternative patterns,
# plus guards for everything Ruby's === does that a pattern cannot.
import re


def row(n, label, value):
    print("%2d. %-38s -> %s" % (n, label, value))


def compiles(src):
    try:
        compile(src, "<row>", "exec")
        return "compiles"
    except SyntaxError as e:
        return type(e).__name__


# 1. a class pattern is isinstance; | joins alternatives
def kind(v):
    match v:
        case int() | float():
            return "number"
        case _:
            return "other"


row(1, "3: when Integer, Float", repr(kind(3)))


# 2. no range pattern: a guard
def size(n):
    match n:
        case int(x) if 1 <= x <= 5:
            return "small"
        case int(x) if x >= 6:
            return "big"


row(2, "3: when 1..5", "%r  (guard: case int(x) if 1 <= x <= 5)" % size(3))


# 3. no regex pattern: a guard with a walrus keeps the match object
def digits(s):
    match s:
        case str() if (m := re.search(r"(\d+)", s)):
            return "digits %s" % m.group(1)


row(3, '"id 42": when /(\\d+)/ sets $~', "%r  (guard: if (m := re.search(...)))" % digits("id 42"))


# 4. a lambda test is a guard
def big(n):
    match n:
        case n if n > 100:
            return "big"
        case _:
            return "small"


row(4, "150: when ->(n) { n > 100 }", "%r  (guard: case n if n > 100)" % big(150))


# 5. a bare name would capture, so the list is spelled out with |
def vowel(c):
    match c:
        case "a" | "e" | "i" | "o" | "u":
            return "vowel"
        case _:
            return "consonant"


row(5, '"e": when *VOWELS', '%r  (case "a" | "e" | "i" | "o" | "u")' % vowel("e"))


# 6. the first matching case wins and nothing falls through
def first(v):
    match v:
        case 1:
            return "first"
        case int():
            return "second"


row(6, "1: when 1 ... when Integer", "%r  (no fall-through)" % first(1))

# 7. match needs a subject; the subject-less form is if/elif
n = -4
if n < 0:
    v = "negative"
elif n == 0:
    v = "zero"
else:
    v = "positive"
row(7, "case with no subject, n = -4", "%s for a bare match:; if/elif gives %r" % (compiles("match:\n    case 1: pass"), v))


# 8. no case matched: nothing happens; case _: catches the rest
def one(v):
    result = None
    match v:
        case 1:
            result = "one"
    return result


def one_or_other(v):
    match v:
        case 1:
            return "one"
        case _:
            return "other"


row(8, "99: no when matches", "%r; with case _: -> %r" % (one(99), one_or_other(99)))


# 9. a class pattern calls isinstance, and isinstance has a hook
class EvenMeta(type):
    def __instancecheck__(cls, n):
        return isinstance(n, int) and n % 2 == 0


class Even(metaclass=EvenMeta):
    pass


def parity(n):
    match n:
        case Even():
            return "even"
        case _:
            return "odd"


row(9, "4, 7: when Even (a custom ===)", "%s  (case Even(): via __instancecheck__)" % " / ".join(parity(n) for n in [4, 7]))


# 10. a literal pattern compares with ==
def is_one(v):
    match v:
        case 1:
            return "matched"
        case _:
            return "no match"


row(10, "1.0: when 1", "%s  (1 == 1.0 -> %r)" % (is_one(1.0), 1 == 1.0))


# 11. None, True and False match by identity
def is_none(v):
    match v:
        case None:
            return "matched"
        case _:
            return "no match"


row(11, "nil: when nil", "%s  (case None: uses `is`)" % is_none(None))

# 12. the four tests behind rows 1 to 4, spelled out
row(12, "what when calls",
    "isinstance(3, int) -> %r; 3 in range(1, 6) -> %r; bool(re.search(\"ab\", \"cab\")) -> %r; (lambda n: n > 100)(150) -> %r"
    % (isinstance(3, int), 3 in range(1, 6), bool(re.search("ab", "cab")), (lambda n: n > 100)(150)))
