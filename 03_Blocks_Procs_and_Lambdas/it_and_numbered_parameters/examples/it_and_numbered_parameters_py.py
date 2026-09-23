"""Python has no implicit parameter: a lambda and a comprehension both name
theirs, and `it` and `_1` are ordinary identifiers. The rows match the Ruby
program's rows; where Ruby prints a SyntaxError, Python prints what the same
spelling means there."""

import inspect

W = 56


def row(n, label, value):
    print(f"{n:>2}. {label:<{W}} {value}")


xs = [1, 2]
pairs = [[1, 2], [3, 4]]
row(1, "a lambda names its parameter:", f"map(lambda x: x * 2, xs) = {list(map(lambda x: x * 2, xs))}")
row(2, "a comprehension names it too:", f"[x * 2 for x in xs] = {[x * 2 for x in xs]}")
row(3, "two values are unpacked by name:", f"[a + b for a, b in pairs] = {[a + b for a, b in pairs]}, enumerate: {[i * x for i, x in enumerate(xs)]}")
row(4, "one parameter takes the whole pair, unpacking is spelled out:", f"len(p) {[len(p) for p in [[1, 2]]]}, p[0] + p[1] {[p[0] + p[1] for p in [[1, 2]]]}, a + b {[a + b for a, b in [[1, 2]]]}")
row(5, "signature and argcount:", f"lambda x: x {inspect.signature(lambda x: x)} {(lambda x: x).__code__.co_argcount}, lambda a, b: a {inspect.signature(lambda a, b: a)} {(lambda a, b: a).__code__.co_argcount}")
row(6, "nested comprehensions name their own variable:", f"{[[y * 10 for y in r] for r in [[1, 2], [3]]]}, no clash possible")

_1 = 5
it = 6
row(7, "it and _1 are plain names, nothing to mix:", f"_1 = 5; it = 6 -> {_1} {it} ({type(_1).__name__})")
row(8, "it beside an ordinary parameter is a parameter:", f"lambda x, it: it -> {inspect.signature(lambda x, it: it)}, called (1, 2) = {(lambda x, it: it)(1, 2)}")

f = eval(compile("lambda: it * 2", "<string>", "eval"))
del it
try:
    f()
    unbound = "no error (unexpected)"
except NameError as e:
    unbound = type(e).__name__
row(9, "a lambda mentioning it compiles; it is a free name:", f"co_names {f.__code__.co_names}, called after del it: {unbound}")

_ = 7
row(10, "_ is an ordinary name in a script:", f"_ = 7 -> {_}; the REPL's last value and match's wildcard are separate conventions")
