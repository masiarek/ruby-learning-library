# object is the root of every class and carries its own methods; builtins is
# a module every scope sees, not a mixin every object carries; and there is
# nothing below object. Prints the same numbered rows as
# basic_object_and_kernel_rb.rb.

import builtins


def section(n, title):
    print(f"{n}. {title}")


def row(label, value):
    print(f"   {label:<46} {value}")


BUILTIN_FUNCTIONS = ["print", "repr", "input", "open", "format", "int", "isinstance", "len", "exit"]
OBJECT_METHODS = ["__repr__", "__str__", "__eq__", "__hash__", "__class__", "__getattribute__", "__reduce__", "__dir__"]


class Plain:
    pass


section(1, "three things at the top")
row("[c.__name__ for c in Plain.__mro__]", [c.__name__ for c in Plain.__mro__])
row("[c.__name__ for c in int.__mro__]", [c.__name__ for c in int.__mro__])
row("object.__bases__", object.__bases__)
row("type(object).__name__", type(object).__name__)
row("type(builtins).__name__", type(builtins).__name__)
row("len(vars(object)) > 20  (object has its own methods)", len(vars(object)) > 20)

section(2, "object: the root, and not small")
names = sorted(dir(object))
row("len(dir(object))", len(names))
for i in range(0, len(names), 6):
    row("sorted(dir(object))" if i == 0 else "", " ".join(names[i:i + 6]))

section(3, "builtins: a module every scope sees, not methods every object has")
row("functions:", " ".join(BUILTIN_FUNCTIONS))
row("  all in vars(builtins)", all(n in vars(builtins) for n in BUILTIN_FUNCTIONS))
row("methods:", " ".join(OBJECT_METHODS))
row("  all in dir(object)", all(n in dir(object) for n in OBJECT_METHODS))
row("print is builtins.print", print is builtins.print)
row("print.__module__", print.__module__)
row("hasattr(5, 'print')", hasattr(5, "print"))
row("hasattr(object(), 'print')", hasattr(object(), "print"))

section(4, "there is no class below object")


class Bare:
    pass


row("Bare.__bases__[0] is object", Bare.__bases__[0] is object)
row("hasattr(Bare(), '__repr__')", hasattr(Bare(), "__repr__"))
row("repr(Bare()).startswith('<__main__.Bare object at 0x')", repr(Bare()).startswith("<__main__.Bare object at 0x"))
try:
    del object.__repr__
except TypeError as e:
    row("del object.__repr__", type(e).__name__)
try:
    class Rootless(metaclass=type):
        pass
    Rootless.__bases__ = ()
except TypeError as e:
    row("Rootless.__bases__ = ()", type(e).__name__)
bare = Bare()
row("bare == Bare()", bare == Bare())
row("bare is bare", bare is bare)
row("not bare", not bare)
row("isinstance(bare, object)", isinstance(bare, object))

section(5, "a proxy: __getattr__ forwards the misses, but not the dunders")


class Proxy:
    def __init__(self, target):
        self._target = target

    def __getattr__(self, name):
        print(f"   (forwarding {name})")
        return getattr(self._target, name)


pr = Proxy([3, 1, 2])
row("pr.copy()", pr.copy())
row("pr.__len__()  (explicit call: forwarded)", pr.__len__())
try:
    len(pr)
except TypeError as e:
    row("len(pr)  (implicit lookup skips __getattr__)", type(e).__name__)
row("pr.__class__.__name__", pr.__class__.__name__)
row("repr(pr).startswith('<__main__.Proxy object')", repr(pr).startswith("<__main__.Proxy object"))
row("isinstance(pr, list)", isinstance(pr, list))
row("non-dunder names in vars(Proxy)", [n for n in sorted(vars(Proxy)) if not n.startswith("__")])


class Strict:
    """__getattribute__ runs for every lookup, hit or miss."""

    def __init__(self, target):
        object.__setattr__(self, "_target", target)

    def __getattribute__(self, name):
        target = object.__getattribute__(self, "_target")
        print(f"   (intercepting {name})")
        return getattr(target, name)


st = Strict([1])
st.append(2)
row("object.__getattribute__(st, '_target')", object.__getattribute__(st, "_target"))
