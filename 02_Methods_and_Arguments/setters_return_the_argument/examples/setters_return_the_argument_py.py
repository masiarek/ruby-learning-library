"""The Python twin: `obj.x = 5` runs a property's setter but is a statement
with no value at all -- `(obj.x = 5)` does not compile -- and the setter's
return value is visible only when the function is called directly."""


class Box:
    def __init__(self):
        self._x = None
        self.h = {}

    @property
    def x(self):
        return self._x

    @x.setter
    def x(self, value):
        self._x = value
        return "ignored"

    def __setitem__(self, key, value):
        self.h[key] = value
        return "ignored_too"

    def __getitem__(self, key):
        return self.h.get(key)

    def set_wrong(self, value):
        x = value
        return x

    def set_right(self, value):
        self.x = value
        return value


class Writer:
    w = property(fset=lambda self, value: setattr(self, "_w", value))


class Logged:
    def __setattr__(self, name, value):
        print(f"(__setattr__ saw {name} = {value!r}) ", end="")
        super().__setattr__(name, value)


def compiles(source):
    try:
        compile(source, "<lesson>", "exec")
        return "compiles"
    except SyntaxError as e:
        return f"SyntaxError: {e.msg}"


def attempt(call):
    try:
        return repr(call())
    except AttributeError as e:
        return type(e).__name__


b = Box()
b.x = 5
print("1. assignment is a statement:     r = (b.x = 5)         ->", compiles("r = (b.x = 5)"), "; after b.x = 5, b.x is", repr(b.x))
print("2. the setter's value directly:   Box.x.fset(b, 6)      ->", repr(Box.x.fset(b, 6)), "; setattr(b, 'x', 7) ->", repr(setattr(b, "x", 7)))
w = Writer()
w.w = 3
print("3. a property with only fset:     w.w = 3 stores", repr(w._w), "; reading w.w ->", attempt(lambda: w.w))
b.x = 1, 2
print("4. two values on the right:       b.x = 1, 2; b.x       ->", b.x, "(a", type(b.x).__name__ + ")")
print("5. inside the class, self is required: b.set_wrong(50)  ->", b.set_wrong(50), ", b.x still", b.x, "; b.set_right(60) ->", b.set_right(60), ", b.x now", b.x)
a = b.x = 9
print("6. chained assignment:            a = b.x = 9           -> a is", a, ", b.x is", b.x, "(allowed as a statement)")
b["k"] = "v"
print("7. __setitem__ too:               b['k'] = 'v'; b['k']  ->", repr(b["k"]), "; b.__setitem__('k2', 'v2') ->", repr(b.__setitem__("k2", "v2")))
b.x += 1
print("8. += goes through the pair:      b.x += 1; b.x         ->", b.x, "(getter, then setter; the statement has no value)")
print("9. a universal hook:              __setattr__ sees every assignment: ", end="")
logged = Logged()
logged.color = "red"
print("; sorted(vars(logged)) ->", sorted(vars(logged)))
