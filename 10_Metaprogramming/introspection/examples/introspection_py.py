"""introspection_py.py -- the same rows, asked of dir, vars, inspect and the frame."""

import builtins
import inspect
import os
import sys
import types


def row(n, label, value):
    head = "   " if n == "" else f"{n:>2}."
    print(f"{head} {label:<46} {value}")


class Geometry:                                        # a class used as a namespace
    ORIGIN = (0, 0)

    class Point:
        def __init__(self, x, y):
            self.x = x
            self.y = y

        @classmethod
        def origin(cls):
            return cls(0, 0)

        def area(self):
            return 0

        def move(self, dx, dy):
            self.x += dx
            self.y += dy
            return self

        def configure(self, a, b=1, *r, k, d=2, **o):
            return None

        def __lt__(self, other):
            return (self.x, self.y) < (other.x, other.y)

        def _secret(self):
            return 1


class Probe:                                           # rows 9-11: inside a method
    def __init__(self):
        self.x = 1

    def locals_(self):
        a = 1
        b = 2
        return sorted(locals())                        # read it; never write through it

    def whoami(self):
        return sys._getframe().f_code.co_name

    def defined_table(self, a):
        scope = {"a": a, "self": self}

        def exists(expr):                              # eval with the method's own names
            try:
                eval(expr, globals(), scope)
                return "defined"
            except NameError:
                return None
        return ["a" in locals(), hasattr(builtins, "str"), exists("Nope"), callable(print), exists("nope"),
                hasattr(self, "x"), "assignment is a statement", exists("3"), exists("self"), hasattr(sys, "stdout")]


point = Geometry.Point(1, 2)
klass = Geometry.Point


def own(cls, pred=lambda v: True):
    return sorted(k for k, v in vars(cls).items() if not k.startswith("__") and pred(v))


row(1, "[n for n in dir(point) if not n.startswith('_')]", [n for n in dir(point) if not n.startswith("_")])
row("", "inspect.getmembers(point, inspect.ismethod) names", [n for n, _ in inspect.getmembers(point, inspect.ismethod)])
row(2, "own functions of Point (vars, minus dunders)", own(klass, inspect.isfunction))
row("", "_secret is listed like any other", "one underscore is a naming convention")
row(3, "vars(point)", vars(point))
row("", "getattr(point, name) for each", {k: getattr(point, k) for k in vars(point)})
sig = inspect.signature(klass.configure)
row(4, "inspect.signature(Point.configure)", str(sig))
row("", "parameter kinds", " ".join(f"{p.name}:{p.kind.name}" for p in sig.parameters.values()))
row(5, "inspect.getsourcefile / getsourcelines(area)[1]",
    f"{os.path.basename(inspect.getsourcefile(klass.area))}:{inspect.getsourcelines(klass.area)[1]}")
row("", "inspect.getsource(area).splitlines()[0]", inspect.getsource(klass.area).splitlines()[0].strip())
row(6, "[c.__name__ for c in Point.__mro__]", [c.__name__ for c in klass.__mro__])
row(7, "own names of Geometry", own(Geometry))
row("", "inspect.getsourcelines(Geometry)[1]", inspect.getsourcelines(Geometry)[1])
row(8, "classmethods of Point", own(klass, lambda v: isinstance(v, classmethod)))
point.label = types.MethodType(lambda self: "P", point)
row("", "callables in vars(point) after MethodType", [k for k, v in vars(point).items() if callable(v)])
probe = Probe()
row(9, "sorted(locals()) inside a method (a = 1; b = 2)", probe.locals_())
table = probe.defined_table(0)
row(10, "'a' in locals() / str / Nope / print / nope", table[0:5])
row("", "hasattr(self, 'x') / assignment / 3 / self / stdout", table[5:10])
row("", "no yield/super probes", "a callback is a parameter; super() is explicit")
row(11, "sys._getframe().f_code.co_name inside whoami", repr(probe.whoami()))
row(12, "Point.area.__qualname__ / inspect.ismethod(point.area)", f"{klass.area.__qualname__} / {inspect.ismethod(point.area)}")
row("", "hasattr(Point, 'area') / ('_secret') / in vars(Point)",
    f"{hasattr(klass, 'area')} / {hasattr(klass, '_secret')} / {'_secret' in vars(klass)}")
row("", "'x' in vars(point) / 'z' in vars(point)", f"{'x' in vars(point)} / {'z' in vars(point)}")
row(13, "type(point) / type(Point) / type(Geometry)", f"{type(point).__name__} / {type(klass).__name__} / {type(Geometry).__name__}")
row("", "Point.__qualname__ / Point.__module__", f"{klass.__qualname__!r} / {klass.__module__!r}")
