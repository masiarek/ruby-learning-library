# The same twenty-three rows, answered by Python: what the Python programmer
# was expecting, measured, beside what Ruby actually did.
import ast
import collections
import contextlib
import io
import json
import sys


def row(n, label, value):
    print(f"{n:2d}. {label:<42} {value}")


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


row(1, 'bool(0) / bool("")', f"{bool(0)} / {bool('')}")
row(2, "[1, 2, 3][10]", raises(lambda: [1, 2, 3][10]))
row(3, "7 / 2 / 7 // 2 / 7 / 2.0", f"{7 / 2} / {7 // 2} / {7 / 2.0}")
s = "abc"
before = s
s += "d"


def assign_item():
    t = "abc"
    t[0] = "x"


row(4, 's = "abc"; s += "d" / s[0] = "x"', f"{s!r}, same object? {s is before} / {raises(assign_item)}")
row(5, '"a" == "a"  (no symbol type)', str("a" == "a"))
x1 = False or True
row(6, "x1 = False or True", f"x1={x1}  (or has ordinary precedence)")
captured = io.StringIO()
with contextlib.redirect_stdout(captured):
    returned = print("hi")
row(7, f'print("hi") returns  (printed {captured.getvalue()!r})', repr(returned))
try:
    if False:
        y = 5
    print(y)
except NameError as e:
    undefined = type(e).__name__
row(8, "if False: y = 5; y / x = 5 if False", f"{undefined} / {compiles('x = 5 if False')}")
row(9, "elif / elsif", f"{compiles('if 1:\n  pass\nelif 2:\n  pass')} / {compiles('if 1:\n  pass\nelsif 2:\n  pass')}")
tree = ast.parse("if True:\n    a = 1\nb = 2\n")
row(10, "no end: a dedent closes the block", f"module has {len(tree.body)} statements, the if holds {len(tree.body[0].body)}")
row(11, "round(2.5) / round(-2.5) / round(3.5)", f"{round(2.5)} / {round(-2.5)} / {round(3.5)}")
a = [1, 2]
b = [2, 1]
row(12, "[1, 2].sort() / [2, 1].sort()  (always None)", f"{a.sort()!r} / {b.sort()!r}")
dd = collections.defaultdict(list)
dd["a"].append(1)
row(13, 'defaultdict(list): dd["a"].append(1); dd["b"]', f"{dd['b']!r} / len {len(dd)}  (a fresh list per key, stored on access)")
row(14, '{"a": 1}: type of the key', type(next(iter({"a": 1}))).__name__)
row(15, "list(map(lambda v: v * 2, [1]))  (no blocks)", repr(list(map(lambda v: v * 2, [1]))))
row(16, '"a" / type("a").__name__ / ord("a")', f"{'a'!r} / {type('a').__name__} / {ord('a')}  (no character type)")
row(17, 'int("08") / int("010") / the literal 08', f"{int('08')} / {int('010')} / {compiles('08')}")
row(18, '"a b c".split()', repr("a b c".split()))
for i in range(1, 4):
    pass
[j for j in [1, 2, 3]]
row(19, "for i in range(1, 4): i after / [j for j in ...]: 'j' in dir()", f"{i} / {'j' in dir()}")
m = 256
n = 256
row(20, "m = 256; n = 256; m is n / [] is [] / [] == []", f"{m is n} / {[] is []} / {[] == []}")


class Safe:
    def reveal(self):
        return self._secret()

    def _secret(self):
        return "s3cret"

    def __hidden(self):
        return "mangled"


row(21, "obj._secret() / obj.reveal() / obj._Safe__hidden()", f"{Safe()._secret()!r} / {Safe().reveal()!r} / {Safe()._Safe__hidden()!r}  (nothing enforced)")


class Person:
    def __init__(self):
        self.name = "ann"


row(22, "self.name = ...: attributes are public", f"vars(Person()) = {vars(Person())!r}")
try:
    require("json")
except NameError as e:
    required = type(e).__name__
row(23, 'import json / require("json")', f"{type(json).__name__} / {required}")
