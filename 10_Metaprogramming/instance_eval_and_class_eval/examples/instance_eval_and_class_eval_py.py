"""instance_eval_and_class_eval_py.py -- the same rows, asked of exec, eval and explicit self."""

import types


def row(n, label, value):
    head = "   " if n == "" else f"{n:>2}."
    print(f"{head} {label:<46} {value}")


class Safe:
    def __init__(self):
        self._secret = 42


safe = Safe()
row(1, 'vars(safe)["_secret"] -- nothing to switch', vars(safe)["_secret"])


def peek(self):
    return type(self).__name__


row(2, "peek(safe) -- self is the argument", peek(safe))

ns = {}
exec("def x(self): return 'instance x'", ns)           # 3. a function, then attached
setattr(Safe, "x", ns["x"])
row(3, 'exec("def x(self) ...") + setattr: Safe().x()', repr(Safe().x()))
try:
    Safe.x()
except TypeError as e:
    row("", "Safe.x() -- no instance to be self", type(e).__name__)

Safe.y = classmethod(lambda cls: "class y")            # 4. a class method is a classmethod
row(4, "Safe.y = classmethod(...): Safe.y()", repr(Safe.y()))
row("", "Safe().y() -- reachable from instances too", repr(Safe().y()))

safe.only_me = types.MethodType(lambda self: "me", safe)   # 5. bound to one object
row(5, "safe.only_me = MethodType(f, safe)", f"in vars(safe): {[k for k, v in vars(safe).items() if callable(v)]}")
row("", 'hasattr(Safe(), "only_me")', hasattr(Safe(), "only_me"))


def add(self, n):
    return self._secret + n


row(6, "add(safe, 3) -- self and args are parameters", add(safe, 3))
row("", "types.MethodType(add, safe)(3)", types.MethodType(add, safe)(3))
row("", "no strict/lenient split", "a function takes exactly its parameters")

code = compile("def z(self): return 3", "generated.py", "exec")   # 7. a filename for tracebacks
ns = {}
exec(code, ns)
row(7, 'compile(src, "generated.py", "exec")', f'co_filename = {ns["z"].__code__.co_filename}:{ns["z"].__code__.co_firstlineno}')
ns = {}
exec("def w(self): return 4", ns)
row("", "exec(src) -- no filename", f'co_filename = {ns["w"].__code__.co_filename}')


def scope():
    factor = 3
    row(8, 'eval("factor * 2") -- sees the current scope', eval("factor * 2"))
    try:
        eval("factor * 2", {})
    except NameError as e:
        row("", 'eval("factor * 2", {}) -- an empty namespace', type(e).__name__)


scope()

row(9, 'eval("1 + 1") / exec("1 + 1")', f'{eval("1 + 1")} / {exec("1 + 1")}')


class A:
    pass


row(10, "peek(A()) / peek(safe) -- self is passed in", f"{peek(A())} / {peek(safe)}")
row("", "a function has no self to move", "-")

klass = Safe
setattr(klass, "v", lambda self: 5)
row(11, "setattr(klass, 'v', ...): klass().v()", klass().v())


class klass:                                           # a new class named klass, not Safe
    pass


row("", "class klass: pass -> klass is Safe", klass is Safe)

x = 5
row(12, 'x = 5; eval("x + 1") -- the current scope', eval("x + 1"))
row(13, "eval is exec -- two builtins, not aliases", eval is exec)
