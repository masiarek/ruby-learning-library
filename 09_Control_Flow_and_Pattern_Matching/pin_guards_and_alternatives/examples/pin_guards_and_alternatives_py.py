# The Python twin: a bare name always captures, a dotted name is a value
# pattern, there is no pin, guards take `if`, and | alternatives must bind
# the same names. The same ten rows.


def row(n, label, value):
    print("%2d. %-40s -> %s" % (n, label, value))


def compiles(src):
    try:
        compile(src, "<row>", "exec")
        return "compiles"
    except SyntaxError as e:
        return type(e).__name__


# 1. no pin: comparing with a variable is a guard
def equals_expected(v):
    match v:
        case x if x == expected:
            return "matched"
        case _:
            return "no"


expected = 5
row(1, "5 in ^expected (expected = 5)", "%s for case ^expected:; guard `case x if x == expected` -> %s / %s"
    % (compiles("match v:\n    case ^expected: pass"), equals_expected(5), equals_expected(6)))

# 2. a bare name captures -- and rebinds the module-level name
match 7:
    case expected:
        pass
row(2, "case 7; in expected", "matches anything; expected is now %r; a case after it is a %s"
    % (expected, compiles("match v:\n    case expected: pass\n    case 6: pass")))


# 3. a name may appear once per pattern; equality is a guard
def same_pair(v):
    match v:
        case [a, b] if a == b:
            return "True"
        case _:
            return "False"


row(3, "[3, 3] / [3, 4] in [a, ^a]", "%s for case [a, a]:; guard `[a, b] if a == b` -> %s / %s"
    % (compiles("match v:\n    case [a, a]: pass"), same_pair([3, 3]), same_pair([3, 4])))


# 4. nested repeats are refused the same way
def nested(v):
    match v:
        case [[_, x], y] if x == y:
            return "True"
        case _:
            return "False"


row(4, "[[1, 2], 2] / [[1, 2], 3] in [[_, x], ^x]", "%s for [[_, x], x]; guard -> %s / %s"
    % (compiles("match v:\n    case [[_, x], x]: pass"), nested([[1, 2], 2]), nested([[1, 2], 3])))


# 5. a dotted name is a value pattern, so self.limit compares; an expression needs a guard
class Gate:
    def __init__(self, limit):
        self.limit = limit

    def check(self, n):
        match n:
            case self.limit:
                return "at the limit"
            case int(v) if v < self.limit:
                return "under"
            case _:
                return "over"


gate = Gate(10)
MAX = 9


def is_six(v):
    match v:
        case x if x == 2 * 3:
            return "True"
        case _:
            return "False"


def is_max(v):
    match v:
        case x if x == MAX:
            return "True"
        case _:
            return "False"


row(5, "^(2 * 3), ^@limit, ^$max", "6 via guard `if x == 2 * 3` -> %s; Gate(10) via `case self.limit:`: %s; 9 via guard `if x == MAX` -> %s"
    % (is_six(6), " / ".join(gate.check(n) for n in [10, 3, 12]), is_max(9)))


# 6. a bare CONSTANT captures; only a dotted name is a value pattern
class K:
    LIMIT = 5


def at_limit(v):
    match v:
        case K.LIMIT:
            return "True"
        case _:
            return "False"


row(6, "5 / 6 in LIMIT (a constant)", "case LIMIT: captures (a case after it is a %s); case K.LIMIT: -> %s / %s"
    % (compiles("match v:\n    case LIMIT: pass\n    case 6: pass"), at_limit(5), at_limit(6)))


# 7. guards take if; there is no unless
def order(pair):
    match pair:
        case [x, y] if x > y:
            return "descending"
        case [x, y] if not x > y:
            return "not descending"


row(7, "in [x, y] if x > y / unless x > y", "%s / %s; `unless` guard -> %s"
    % (order([5, 3]), order([1, 9]), compiles("match v:\n    case [x, y] unless x > y: pass")))


# 8. alternatives with |, then `as` for one binding
def kind(v):
    match v:
        case int() | float() as num:
            return "number %r" % num
        case str() as s:
            return "string %r" % s


row(8, "2.5 in Integer | Float => num", repr(kind(2.5)))


# 9. alternatives may bind names, as long as every alternative binds the same ones
def alt(v):
    match v:
        case [x, y] | [x, y, _]:
            return "matched, x = %r" % x


row(9, "[x, y] | [x, y, _] / [_x, _y] | [_x, _y, _]", "%s (same names); [x, y] | [x, z] -> %s; %s"
    % (compiles("match v:\n    case [x, y] | [x, y, _]: pass"), compiles("match v:\n    case [x, y] | [x, z]: pass"), alt([1, 2])))


# 10. a bare name captures even when a function of that name exists
def limit():
    return 5


match 8:
    case limit:
        pass
row(10, "def limit = 5; case 8; in limit", "rebinds the name: limit = %r; `case limit():` -> %s"
    % (limit, compiles("match v:\n    case limit(): pass")))
