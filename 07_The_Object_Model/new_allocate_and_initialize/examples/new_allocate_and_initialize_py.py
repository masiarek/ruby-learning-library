# Point(1, 2) is two steps too: type.__call__ runs __new__ (allocate) and then
# __init__ (initialize). Prints the same numbered rows as
# new_allocate_and_initialize_rb.rb.

import copy


def section(n, title):
    print(f"{n}. {title}")


def row(label, value):
    print(f"   {label:<44} {value}")


class Point:
    def __init__(self, x, y):
        print(f"   (__init__({x}, {y}) runs; self is a {type(self).__name__})")
        self.x, self.y = x, y

    def __copy__(self):
        print(f"   (__copy__ runs, copying {self!r})")
        twin = object.__new__(type(self))
        twin.__dict__.update(self.__dict__)
        return twin

    def __repr__(self):
        return f"Point({getattr(self, 'x', None)!r}, {getattr(self, 'y', None)!r})"


class Point3(Point):
    def __init__(self, x, y, z):
        super().__init__(x, y)
        self.z = z

    def __repr__(self):
        return f"Point3({self.x}, {self.y}, {self.z})"


class BadInit:
    def __init__(self):
        return 5


class Color:
    _cache = {}

    def __new__(cls, name):
        if name not in cls._cache:
            cls._cache[name] = super().__new__(cls)
        return cls._cache[name]

    def __init__(self, name):
        print(f"   (Color.__init__({name!r}) runs)")
        self.name = name

    def __repr__(self):
        return f"Color({self.name!r})"


class Shape:
    def __new__(cls, *args):
        if cls is Shape:
            kind, *rest = args
            return super().__new__({"circle": Circle, "square": Square}[kind])
        return super().__new__(cls)

    def __init__(self, *args):
        self.size = args[-1]

    def __repr__(self):
        return f"<{type(self).__name__} size={self.size}>"


class Circle(Shape):
    pass


class Square(Shape):
    pass


section(1, "calling the class is __new__, then __init__")
row("Point(1, 2)", repr(Point(1, 2)))
row("type(Point).__call__ is type.__call__", type(Point).__call__ is type.__call__)
row("Point.__new__ is object.__new__", Point.__new__ is object.__new__)

section(2, "__init__ is public")
row("'__init__' in vars(Point)", "__init__" in vars(Point))
pt = Point(1, 2)
pt.__init__(3, 4)
row("pt.__init__(3, 4); pt", repr(pt))
row("private methods", "none; a leading _ is a convention")

section(3, "object.__new__(Point) skips __init__")
blank = object.__new__(Point)
row("object.__new__(Point)", repr(blank))
row("vars(blank)", vars(blank))
row("getattr(blank, 'x', None)", getattr(blank, "x", None))
blank.__init__(5, 6)
row("blank.__init__(5, 6); blank", repr(blank))

section(4, "__init__ must return None")
try:
    BadInit()
except TypeError as e:
    row("BadInit()  (its __init__ returns 5)", type(e).__name__)

section(5, "arguments go straight to __init__")
try:
    Point(1)
except TypeError as e:
    row("Point(1)", type(e).__name__)

section(6, "overriding __new__: a cache (and a trap)")
red1 = Color("red")
red2 = Color("red")
blue = Color("blue")
row("Color('red') is Color('red')", red1 is red2)
row("red is blue", red1 is blue)

section(7, "overriding __new__: a factory")
row("Shape('circle', 3)", repr(Shape("circle", 3)))
row("Shape('square', 4)", repr(Shape("square", 4)))
row("Circle(5)", repr(Circle(5)))

section(8, "__copy__ runs on copy.copy; __init__ does not")
original = Point(7, 8)
row("copy.copy(original)", repr(copy.copy(original)))
row("copy.deepcopy(original)", repr(copy.deepcopy(original)))

section(9, "classes that refuse arguments or new instances")
try:
    object(1)
except TypeError as e:
    row("object(1)", type(e).__name__)
try:
    int.__new__(str)
except TypeError as e:
    row("int.__new__(str)", type(e).__name__)
row("type(None)() is None", type(None)() is None)

section(10, "a subclass calls super().__init__")
row("Point3(1, 2, 3)", repr(Point3(1, 2, 3)))
row("Point3.__init__.__code__.co_argcount - 1", Point3.__init__.__code__.co_argcount - 1)
