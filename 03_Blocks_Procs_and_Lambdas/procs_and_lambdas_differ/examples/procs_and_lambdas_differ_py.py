"""Python has one kind of function object: a lambda and a def are both a
`function`, both check their argument count, and `return` only ever leaves
the function it is written in. The rows match the Ruby program's rows."""

import inspect
import operator

W = 44


def row(n, label, value):
    print(f"{n:>2}. {label:<{W}} {value}")


def from_inner():
    inner = lambda: 10                                       # noqa: E731
    v = inner()
    return f"inner returned {v}, outer continues"


def from_inner_def():
    def inner():
        return 10
    inner()
    return "still reached: return leaves inner only"


def make_orphan():
    def inner():
        return 1
    return inner                                             # outer is gone when it is called


def call_all(fn, arg_lists):
    out = []
    for args in arg_lists:
        try:
            out.append(str(fn(*args)))
        except TypeError as e:
            out.append(f"{type(e).__name__} (given {len(args)})")
    return ", ".join(out)


def two_def(a, b):
    return (a, b)


row(1, "lambda and def are both function:", f"{type(lambda: 0).__name__} {type(two_def).__name__}, no proc/lambda split")
two_lambda = lambda a, b: (a, b)                             # noqa: E731
row(2, "a lambda given 1, 3, or one tuple:", call_all(two_lambda, [[1], [1, 2, 3], [(1, 2)]]))
row(3, "a def given 1, 3, or one tuple: the same:", call_all(two_def, [[1], [1, 2, 3], [(1, 2)]]))
row(4, "the message is not printed:", "CPython rewords TypeError messages between releases")
row(5, "return in a lambda:", from_inner())
row(6, "return in a nested def:", from_inner_def())
row(7, "return in a def whose outer is gone:", f"returns {make_orphan()()} - no error, a function never returns from another")

sigs = [lambda a, b: 0, lambda a, b=1: 0, lambda *a: 0, lambda: 0]     # noqa: E731
row(8, "inspect.signature, lambda then def:", " ".join(str(inspect.signature(f)) for f in sigs) + f" {inspect.signature(two_def)}")

sq = lambda x: x * x                                         # noqa: E731
row(9, "three ways to call, no case-equality:", f"sq(3) {sq(3)}, sq.__call__(3) {sq.__call__(3)}, operator.call(sq, 3) {operator.call(sq, 3)}")

try:
    compile("lambda: x = 1", "<string>", "eval")
    row(10, "a statement inside a lambda:", "compiled (unexpected)")
except SyntaxError as e:
    row(10, "a statement inside a lambda:", f"{type(e).__name__} - a lambda is one expression, def takes the rest")

row(11, "str.upper and 'a'.upper are callables too:", f"{callable(str.upper)} {callable('a'.upper)} ({type(str.upper).__name__}, {type('a'.upper).__name__})")
