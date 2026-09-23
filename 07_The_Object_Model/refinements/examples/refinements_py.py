# Python has no refinements. A subclass is the static route; unittest.mock.patch
# is the scoped one, and its scope is dynamic: every caller sees the patch
# while it is active, whatever file the caller lives in. Prints the same
# numbered rows as refinements_rb.rb.

import types
from unittest import mock


def section(n, title):
    print(f"{n}. {title}")


def row(label, value):
    print(f"   {label:<46} {value}")


class Greeter:
    def greet(self):
        return "hello"


def loud(self):
    return "HELLO"


# Written above the `with` block; it will see the patch while the patch is on.
def before_patch():
    return Greeter().greet()


section(1, "the two routes: a subclass, or a patch")
try:
    str.shout = lambda self: self.upper() + "!"
except TypeError as e:
    row("str.shout = ...  (built-in types are closed)", type(e).__name__)


class ShoutStr(str):
    def shout(self):
        return self.upper() + "!"


row("ShoutStr('hi').shout()", ShoutStr("hi").shout())
row("type(ShoutStr('hi') + '!').__name__", type(ShoutStr("hi") + "!").__name__)
row("type(mock.patch.object(Greeter, 'greet', loud)).__name__", type(mock.patch.object(Greeter, "greet", loud)).__name__)

section(2, "before the patch: Greeter is untouched")
row("Greeter().greet()", Greeter().greet())
row("Greeter.greet is loud", Greeter.greet is loud)
row("hasattr(Greeter, 'shout')", hasattr(Greeter, "shout"))

section(3, "inside the with block: replaced")
with mock.patch.object(Greeter, "greet", loud):
    row("Greeter().greet()", Greeter().greet())
    row("[Greeter(), Greeter()] greeted", [g.greet() for g in [Greeter(), Greeter()]])

    def inside_patch():
        return Greeter().greet()

    row("inside_patch()  (a function written in the block)", inside_patch())
row("Greeter().greet()  after the block", Greeter().greet())

section(4, "the scope is dynamic: whoever calls while it is active")
other = types.ModuleType("other")
exec("def call(g): return g.greet()", vars(other))
with mock.patch.object(Greeter, "greet", loud):
    row("before_patch()  (written above the block)", before_patch())
    row("other.call(Greeter())  (another module)", other.call(Greeter()))
    row("eval('Greeter().greet()')", eval("Greeter().greet()"))
    row("inside_patch()  (called from inside again)", inside_patch())
row("inside_patch()  (called after the block)", inside_patch())


@mock.patch.object(Greeter, "greet", loud)
def decorated():
    return before_patch()


row("decorated()  (the decorator form)", decorated())
row("before_patch()  after decorated() returned", before_patch())

section(5, "what reflection sees inside the patch")
with mock.patch.object(Greeter, "greet", loud):
    row("hasattr(Greeter(), 'greet')", hasattr(Greeter(), "greet"))
    row("Greeter.greet is loud", Greeter.greet is loud)
    row("vars(Greeter)['greet'] is loud  (the class changed)", vars(Greeter)["greet"] is loud)
    row("getattr(Greeter(), 'greet')()", getattr(Greeter(), "greet")())
    row("Greeter().greet.__func__.__name__", Greeter().greet.__func__.__name__)
row("Greeter().greet.__func__.__name__  after", Greeter().greet.__func__.__name__)

section(6, "the original is kept; a wrapper calls it; built-ins cannot be patched")
original = Greeter.greet
with mock.patch.object(Greeter, "greet", lambda self: "politely " + original(self).upper()):
    row("patched greet calling the saved original", Greeter().greet())
row("Greeter.greet is original  after", Greeter.greet is original)
try:
    with mock.patch.object(str, "upper", lambda s: "x"):
        pass
except TypeError as e:
    row("mock.patch.object(str, 'upper', ...)", type(e).__name__)
