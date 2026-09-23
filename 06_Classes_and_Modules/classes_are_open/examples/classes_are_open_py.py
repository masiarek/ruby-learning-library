# The Python twin: built-in types are closed, user classes are open, and a
# second `class` statement makes a new class rather than reopening the old one.
# Each numbered row is printed by the Ruby program too, in the same order.


def row(n, label, value):
    print(f"{n:2d}. {label:<50} {value}")


def failing(thunk):
    try:
        return thunk()
    except (AttributeError, TypeError) as e:
        return type(e).__name__          # messages are reworded between Python releases


row(1, "\"hello\".shout() before anyone defines it", failing(lambda: "hello".shout()))


def shout(self):
    return self.upper() + "!"


def set_str_shout():
    str.shout = shout


row(2, "str.shout = shout (a built-in type)", failing(set_str_shout))


def double(self):
    return self * 2


row(3, "setattr(int, \"double\", double)", failing(lambda: setattr(int, "double", double)))


class Widget:
    def a(self):
        return "a"


early = Widget()                     # built before the class gains b
Widget.b = lambda self: "b"          # a user class is open: assign a function
row(4, "Widget.b = f: methods / early.b()",
    f"{sorted(k for k in vars(Widget) if not k.startswith('_'))!r} / {early.b()!r}")

Widget.a = lambda self: "a, again"   # 5. silently replaces the old a
row(5, "reassigning Widget.a: early.a() / warning", f"{early.a()!r} / none")

before = Widget


class Widget:                        # 6. a new class object under the old name
    pass


row(6, "a second class Widget statement -- same class?", f"{Widget is before} (early.b() still {early.b()!r})")


class Widget(str):                   # 7. any base you like: it is a third class
    pass


row(7, "class Widget(str) (another base)", f"no error; Widget.__mro__[1] is {Widget.__mro__[1].__name__}")


def set_object_yell():
    object.yell = lambda self: f"{self}!"


row(8, "object.yell = f", failing(set_object_yell))

del before.b                         # 9. removable from a user class, not from str
row(9, "del Widget.b / delattr(str, \"upper\")",
    f"{failing(lambda: early.b())} / {failing(lambda: delattr(str, 'upper'))}")


class LoudStr(str):                  # 10. the alternative: a subclass (or a plain function)
    def shout(self):
        return self.upper() + "!!"


row(10, "class LoudStr(str) -- LoudStr(\"hello\").shout()", repr(LoudStr("hello").shout()))
