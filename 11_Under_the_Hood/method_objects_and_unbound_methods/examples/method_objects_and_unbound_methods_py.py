# The Python twin: a bound method is `obj.f`; the class attribute `Cls.f` is a
# plain function (Python 3 has no unbound method type); `types.MethodType`
# binds a function to any object, checking nothing.

import inspect
import types


class Greeter:
    def __init__(self, name):
        self.name = name

    def greet(self, greeting, punct="!"):
        return f"{greeting}, {self.name}{punct}"

    hello = greet

    def __repr__(self):
        return f"<Greeter {self.name}>"


class Loud(Greeter):
    def greet(self, greeting, punct="!"):
        return super().greet(greeting, punct).upper()


def row(n, label, value):
    print(f"{n:2d}. {label:<52} {value!r}")


def raises(fn):
    try:
        return fn()
    except Exception as e:  # noqa: BLE001 - the class is the result
        return type(e).__name__


ada = Greeter("Ada")
m = ada.greet

row(1, "type(ada.greet).__name__", type(m).__name__)
row(2, 'call it: m("Hi") -- one spelling', [m("Hi")])
row(3, "m.__name__, m.__qualname__", [m.__name__, m.__qualname__])
row(4, "m.__self__, m.__self__ is ada", [m.__self__, m.__self__ is ada])
sig = inspect.signature(m)
row(5, "signature(m), parameter kinds", [str(sig), [p.kind.name for p in sig.parameters.values()]])

u = Greeter.greet
row(6, "type(Greeter.greet).__name__, m.__func__ is Greeter.greet", [type(u).__name__, m.__func__ is u])
bob = Greeter("Bob")
row(7, 'Greeter.greet(bob, "Yo"), MethodType(u, bob)("Yo")', [u(bob, "Yo"), types.MethodType(u, bob)("Yo")])
row(8, 'Greeter.greet("a string", "Yo") raises', raises(lambda: u("a string", "Yo")))
eve = Loud("Eve")
row(9, "Greeter's greet called on a Loud (a subclass) instance", u(eve, "Hi"))

row(10, "eve.greet.__func__.__qualname__, super's", [eve.greet.__func__.__qualname__, super(Loud, eve).greet.__func__.__qualname__])
row(11, 'super(Loud, eve).greet("Hi")', super(Loud, eve).greet("Hi"))
row(12, "super(Greeter, eve).greet (nothing above) raises", raises(lambda: super(Greeter, eve).greet))

row(13, "callable(m), ismethod(m), isfunction(m)", [callable(m), inspect.ismethod(m), inspect.isfunction(m)])
row(14, 'list(map(ada.greet, ["Hi", "Yo"]))', list(map(ada.greet, ["Hi", "Yo"])))
row(15, "Greeter.hello.__name__, Greeter.hello is Greeter.greet", [Greeter.hello.__name__, Greeter.hello is Greeter.greet])
row(16, "m == ada.greet, m is ada.greet", [m == ada.greet, m is ada.greet])
row(17, "type(print).__name__, print.__module__", [type(print).__name__, print.__module__])
row(18, "type((1).__add__).__name__, (1).__add__(2)", [type((1).__add__).__name__, (1).__add__(2)])
row(19, "list(map((1).__add__, [1, 2, 3]))", list(map((1).__add__, [1, 2, 3])))
