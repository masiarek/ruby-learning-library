"""functools.partial applies some arguments now and the rest later; there is
no curry and no composition operator, so compose is two lines of your own;
inspect.signature describes a callable's shape. The rows match the Ruby
program's rows."""

import functools
import inspect
import operator

W = 48


def row(n, label, value):
    print(f"{n:>2}. {label:<{W}} {value}")


def add(a, b):
    return a + b


def add3(a, b, c):
    return a + b + c


def vsum(*xs):
    return sum(xs)


def f(x):
    return x + 1


def g(x):
    return x * 10


def compose(first, second):
    return lambda x: second(first(x))   # the whole of Ruby's >>


double = lambda x: x * 2                                     # noqa: E731
sq = lambda x: x * x                                         # noqa: E731
curried = lambda a: lambda b: a + b                          # noqa: E731

row(1, "partial: some arguments now, the rest later:", f"partial(add, 1)(2) = {functools.partial(add, 1)(2)}, by hand: curried(1)(2) = {curried(1)(2)}, partial(add, 1, 2)() = {functools.partial(add, 1, 2)()}")
inc = functools.partial(add, 1)
row(2, "a partial is a value that remembers its pieces:", f"inc = partial(add, 1); inc(41) = {inc(41)}, {type(inc).__name__}, func {inc.func.__name__}, args {inc.args}, keywords {inc.keywords}")
row(3, "three arguments, split any way:", f"partial(partial(add3, 1), 2)(3) = {functools.partial(functools.partial(add3, 1), 2)(3)}, partial(add3, 1, 2)(3) = {functools.partial(add3, 1, 2)(3)}, partial(add3, 1)(2, 3) = {functools.partial(add3, 1)(2, 3)}")
row(4, "a partial by keyword; nothing checks arity early:", f"partial(add, b=2)(1) = {functools.partial(add, b=2)(1)}, keywords {functools.partial(add, b=2).keywords}; signature(inc) {inspect.signature(inc)}")

try:
    functools.partial(add, 1, 2, 3)()
    too_many = "no error (unexpected)"
except TypeError as e:
    too_many = type(e).__name__
row(5, "a variadic takes any split; too many fails at the call:", f"partial(vsum, 1)(2, 3) = {functools.partial(vsum, 1)(2, 3)}, partial(vsum, 1, 2)(3) = {functools.partial(vsum, 1, 2)(3)}; partial(add, 1, 2, 3)(): {too_many}")

try:
    f >> g
    shifted = "no error (unexpected)"
except TypeError as e:
    shifted = type(e).__name__
row(6, "no >> on functions; compose is two lines:", f"f >> g: {shifted}; compose(f, g)(1) = {compose(f, g)(1)}, compose(g, f)(1) = {compose(g, f)(1)}")
fg = compose(f, g)
mul2 = functools.partial(operator.mul, 2)
row(7, "compose returns a function, from any callables:", f"{type(fg).__name__}; compose(compose(double, str), len)(50000) = {compose(compose(double, str), len)(50000)}, map(compose(mul2, f)) {list(map(compose(mul2, f), [1, 2]))}")
pipeline = functools.reduce(compose, [double, sq, f])
row(8, "a pipeline by reduce(compose); order matters:", f"reduce(compose, [double, sq, f])(3) = {pipeline(3)}, compose(double, sq)(3) = {compose(double, sq)(3)}, compose(sq, double)(3) = {compose(sq, double)(3)}")


class Callable:
    def __call__(self, x):
        return x + 100


row(9, "anything with __call__ composes, on either side:", f"compose(double, Callable())(1) = {compose(double, Callable())(1)}, compose(Callable(), double)(1) = {compose(Callable(), double)(1)}")

full = lambda a, b=1, *c, d, e=2, **f: 0                    # noqa: E731
kinds = [p.kind.name for p in inspect.signature(full).parameters.values()]
row(10, "inspect.signature describes the shape:", f"add {inspect.signature(add)} {len(inspect.signature(add).parameters)}, full {inspect.signature(full)}, kinds {kinds}")
