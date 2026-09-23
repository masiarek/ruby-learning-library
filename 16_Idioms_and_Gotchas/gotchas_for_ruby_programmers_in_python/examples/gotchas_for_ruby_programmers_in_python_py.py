# Twenty-three things Python does that a Ruby programmer does not expect,
# one measured line each, numbered as in the page's table. This twin is the
# primary program of the page; the Ruby program prints Ruby's answer per row.
import contextlib
import io


def row(n, label, value):
    print(f"{n:2d}. {label:<44} {value}")


def compiles(source):
    try:
        compile(source, "<gotcha>", "exec")
        return "compiles"
    except SyntaxError as e:
        return type(e).__name__


def raises(fn):
    try:
        return repr(fn())
    except Exception as e:
        return type(e).__name__


def f(a=[]):
    a.append(1)
    return a


row(1, "def f(a=[]): a.append(1); f() / f()", f"{f()!r} / {f()!r}  (one list, shared)")
late = [fn() for fn in [lambda: i for i in range(3)]]
fixed = [fn() for fn in [lambda i=i: i for i in range(3)]]
row(2, "[lambda: i for i in range(3)] / lambda i=i: i", f"{late!r} / {fixed!r}")
m = 256
n = 256
row(3, "m = 256; n = 256; m is n / [] is [] / [] == []", f"{m is n} / {[] is []} / {[] == []}")
row(4, "7 / 2 / 7 // 2 / -7 // 2", f"{7 / 2} / {7 // 2} / {-7 // 2}")
row(5, "round(2.5) / round(3.5) / round(-2.5)", f"{round(2.5)} / {round(3.5)} / {round(-2.5)}")


class NoSelf:
    def m():
        return 1


row(6, "class NoSelf: def m(): ...; NoSelf().m()", f"{raises(lambda: NoSelf().m())}  (self is a real parameter)")
row(7, "compile('if True:\\nprint(1)')", compiles("if True:\nprint(1)"))
captured = io.StringIO()
with contextlib.redirect_stdout(captured):
    print("a", "b", sep="-")
row(8, "print 'x' / print('a', 'b', sep='-')", f"{compiles(chr(112) + 'rint ' + chr(39) + 'x' + chr(39))} / printed {captured.getvalue()!r}")
row(9, "elif / elsif", f"{compiles('if 1:\n  pass\nelif 2:\n  pass')} / {compiles('if 1:\n  pass\nelsif 2:\n  pass')}")
ran = []
for v in [1, 2]:
    if v == 9:
        break
else:
    ran.append("else ran (no break)")
for v in [1, 2]:
    if v == 1:
        break
else:
    ran.append("else ran after break")
row(10, "for ... else, without and with a break", repr(ran))
a = [3, 1]
row(11, "a = [3, 1]; a.sort() / sorted([3, 1])", f"{a.sort()!r} / {sorted([3, 1])!r}")


def assign_item():
    s = "abc"
    s[0] = "x"


row(12, 's = "abc"; s[0] = "x"', raises(assign_item))
row(13, "def empty?(): ... / def save!(): ...", f"{compiles('def empty?(): pass')} / {compiles('def save!(): pass')}")
row(14, "list(range(1, 4)) / list(range(1, 3))", f"{list(range(1, 4))!r} / {list(range(1, 3))!r}  (half-open)")
d = {}
row(15, 'd = {}; d["k"] / d.get("k")', f"{raises(lambda: d['k'])} / {d.get('k')!r}")
try:
    if False:
        y = 5
    print(y)
except NameError as e:
    undefined = type(e).__name__
row(16, "if False: y = 5; y / x = 5 if False", f"{undefined} / {compiles('x = 5 if False')}")


class Account:
    def initialize(self):
        self.balance = 0


row(17, "def initialize(self) is never called: Account().balance", raises(lambda: Account().balance))


def counter_without_nonlocal():
    count = 0

    def bump():
        count += 1

    bump()
    return count


def counter_with_nonlocal():
    count = 0

    def bump():
        nonlocal count
        count += 1

    bump()
    return count


row(18, "count += 1 in an inner def / with nonlocal", f"{raises(counter_without_nonlocal)} / {counter_with_nonlocal()}")
row(19, "lambda: x = 1 / lambda v: v * 2", f"{compiles('lambda: x = 1')} / {(lambda v: v * 2)(2)}")
row(20, "bool([]) / bool(0) / bool(0.0)", f"{bool([])} / {bool(0)} / {bool(0.0)}")
row(21, 'len("abc") / "abc".len', f"{len('abc')} / {raises(lambda: 'abc'.len)}")
row(22, "type((1,)) / type((1)) / type([1])", f"{type((1,)).__name__} / {type((1)).__name__} / {type([1]).__name__}")
row(23, "1 < 2 < 3 / 1 < 3 < 2", f"{1 < 2 < 3} / {1 < 3 < 2}  (chained comparison)")
