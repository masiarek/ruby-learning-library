"""send_and_public_send_py.py -- the same rows, asked of Python's getattr."""

import operator


def row(n, label, value):
    head = "   " if n == "" else f"{n:>2}."
    print(f"{head} {label:<46} {value}")


class Calc:
    def add(self, a, b):
        return a + b


class Report:
    def to_csv(self):
        return "a,b"

    def to_text(self):
        return "a b"


class Vault:
    def __init__(self):
        self._code = 42        # one underscore: private by convention only
        self.__mangled = 7     # two underscores: stored as _Vault__mangled

    def _secret(self):
        return f"the code is {self._code}"


class Mailer:
    def getattr(self, name):   # a method named getattr shadows nothing
        return "shadow"

    def deliver(self):
        return "delivered"


calc = Calc()
row(1, 'getattr(calc, "add")(2, 3)', getattr(calc, "add")(2, 3))
row(2, 'operator.methodcaller("add", 2, 3)(calc)', operator.methodcaller("add", 2, 3)(calc))
fmt = "csv"
row(3, 'getattr(Report(), f"to_{fmt}")(), fmt = "csv"', repr(getattr(Report(), f"to_{fmt}")()))
row(4, "(1).__add__(2) / operator.add(1, 2)", f"{(1).__add__(2)} / {operator.add(1, 2)}")
row(5, "list(map(lambda x: x * 2, [1, 2, 3]))", list(map(lambda x: x * 2, [1, 2, 3])))

vault = Vault()
row(6, 'getattr(vault, "_code") / callable(...)',
    f'{getattr(vault, "_code")} / {callable(getattr(vault, "_code"))}')
row(7, 'getattr(vault, "_secret")() -- convention only', repr(getattr(vault, "_secret")()))
try:
    getattr(vault, "__mangled")
except AttributeError as e:
    row(8, 'getattr(vault, "__mangled")', f"{type(e).__name__}: no attribute {e.name!r}")
row("", 'getattr(vault, "_Vault__mangled")', getattr(vault, "_Vault__mangled"))
row(9, 'hasattr: "_secret" / "__mangled" / "_Vault__mangled"',
    f'{hasattr(vault, "_secret")} / {hasattr(vault, "__mangled")} / {hasattr(vault, "_Vault__mangled")}')
try:
    getattr(vault, "nope")
except AttributeError as e:
    row(10, 'getattr(vault, "nope") -> type, e.name', f"{type(e).__name__}, {e.name!r}")
row("", 'getattr(vault, "nope", None) -- a default', getattr(vault, "nope", None))

mailer = Mailer()
row(11, 'getattr(mailer, "deliver")() -- a builtin, not a method', repr(getattr(mailer, "deliver")()))
row("", 'mailer.getattr("deliver") -- the class\'s own method', repr(mailer.getattr("deliver")))
row("", "no __send__ needed", "getattr cannot be shadowed by the class")
row(12, "getattr.__module__ / type(getattr).__name__",
    f"{getattr.__module__} / {type(getattr).__name__}")
try:
    getattr(calc, "add")(1)
except TypeError as e:
    row(13, 'getattr(calc, "add")(1) -- arity is still checked', type(e).__name__)
