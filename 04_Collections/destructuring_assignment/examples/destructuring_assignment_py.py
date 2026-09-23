# The Python twin: the same numbered rows as destructuring_assignment_rb.rb,
# asked of tuple unpacking and for loops. Exceptions print their type only.

from itertools import starmap


def row(n, label, value):
    print(f"{n:2d}. {label:<56} {value}")


def raises(fn):
    try:
        return repr(fn())
    except Exception as e:
        return type(e).__name__


def unpack1(src):
    (x,) = src
    return x


def unpack2(src):
    a, b = src
    return [a, b]


a, b = 1, 2
row(1,  "a, b = 1, 2",                                          repr([a, b]))
a, b = b, a
row(2,  "a, b = b, a  (swap)",                                  repr([a, b]))
a, *b = [1, 2, 3]
*c, d = [1, 2, 3]
row(3,  "a, *b = [1, 2, 3]; *c, d = [1, 2, 3]  (rest: a list)", repr([[a, b], [c, d]]))
a, *b, c = 1, 2, 3, 4
row(4,  "a, *b, c = 1, 2, 3, 4",                                repr([a, b, c]))
(a, b), c = [1, 2], 3
row(5,  "(a, b), c = [1, 2], 3  (nested)",                      repr([a, b, c]))
row(6,  "first, = [1, 2]; first, = [1]; first, *_ = [1, 2]",    f"{raises(lambda: unpack1([1, 2]))}, {unpack1([1])}, {[1, 2][0]}")
row(7,  "a, b = [1]  (too few)",                                raises(lambda: unpack2([1])))
row(8,  "a, b = 1, 2, 3  (too many)",                           raises(lambda: unpack2((1, 2, 3))))
a = 1, 2
row(9,  "a = 1, 2  (one target: a tuple)",                      repr(a))
row(10, 'a, b = "xy"  (any iterable unpacks)',                  repr(unpack2("xy")))
row(11, "a, b = {'x': 1, 'y': 2}  (a dict unpacks its keys)",   repr(unpack2({"x": 1, "y": 2})))
row(12, "a, b = None",                                          raises(lambda: unpack2(None)))
row(13, 'compile("v = (a, b = 1, 2)")  (a statement: no value)', raises(lambda: compile("v = (a, b = 1, 2)", "<s>", "exec")))

pairs = [[1, 2], [3, 4]]
row(14, "[x + y for x, y in pairs]  (for unpacks)",             repr([x + y for x, y in pairs]))
row(15, "for i, (x, y) in enumerate(pairs)",                    repr([f"{i}:{x + y}" for i, (x, y) in enumerate(pairs)]))
row(16, "[f'{k}{v}' for k, v in d.items()]",                    repr([f"{k}{v}" for k, v in {"a": 1, "b": 2}.items()]))
strict = raises(lambda: (lambda x, y: x + y)([1, 2]))
tuple_param = raises(lambda: compile("lambda (x, y): x", "<s>", "eval"))
row(17, "lambda x, y with [1, 2]; lambda (x, y); starmap",      f"[{strict}, {tuple_param}, {list(starmap(lambda x, y: x + y, pairs))}]")


class Pair:
    def __init__(self, a, b):
        self.a, self.b = a, b

    def __iter__(self):
        return iter((self.a, self.b))


class Point:
    def __init__(self, x, y):
        self.x, self.y = x, y


a, b = Pair(7, 8)
row(18, "a, b = obj with __iter__; c, d = obj without",         f"[[{a}, {b}], {raises(lambda: unpack2(Point(1, 2)))}]")


def two():
    return 1, 2


a, b = two()
row(19, "def two(): return 1, 2; two(), then a, b = two()",     repr([two(), [a, b]]))
