# The Python twin: `locals()` is a snapshot dict of a scope, `eval`/`exec` take
# explicit namespaces, a frame object is the closest thing to a Binding, and a
# closure keeps its captured variables in cells.

import inspect
import string


def two_locals():
    a = 1
    b = 2
    return locals()


def counter_env():
    count = 0
    return locals()


def set_through_a_snapshot():
    snap = locals()
    snap["c"] = 3
    try:
        return c  # noqa: F821 - never assigned here, so this is a global lookup
    except NameError as e:
        return type(e).__name__


def make_multiplier():
    z = 5
    return lambda q: q * z


def frame_demo():
    a = 1
    b = 2
    frame = inspect.currentframe()
    return [frame.f_code.co_name, sorted(k for k in frame.f_locals if k != "frame")]


def row(n, label, value):
    print(f"{n:2d}. {label:<52} {value!r}")


def raises(fn):
    try:
        return fn()
    except Exception as e:  # noqa: BLE001 - the class is the result
        return type(e).__name__


env = two_locals()
row(1, "env = two_locals(); type(env).__name__, sorted(env)", [type(env).__name__, sorted(env)])
row(2, 'env["a"]', env["a"])
row(3, 'eval("a + b", {}, env)', eval("a + b", {}, env))
env["a"] = 10
row(4, 'after env["a"] = 10: eval("a * b", {}, env)', eval("a * b", {}, env))
env["c"] = 3
row(5, 'env["c"] = 3 adds c to the dict', ["c" in env, sorted(env)])
row(6, "in a function, set through a locals() snapshot", set_through_a_snapshot())
exec("w = 7", {}, env)
row(7, 'exec("w = 7", {}, env); env["w"]', env["w"])
ce = counter_env()
for _ in range(3):
    exec("count += 1", {}, ce)
row(8, 'exec("count += 1", {}, ce) three times; count', ce["count"])
row(9, "a frame: f_code.co_name, its f_locals (a dict knows neither)", frame_demo())
z = 5
row(10, 'globals()["__name__"], eval("z")', [globals()["__name__"], eval("z")])
triple = make_multiplier()
row(11, "a lambda's closure: co_freevars, cell contents", [triple.__code__.co_freevars, [c.cell_contents for c in triple.__closure__]])
row(12, 'string.Template("a is $a, b is $b").substitute(env)', string.Template("a is $a, b is $b").substitute(env))
row(13, 'eval("nope", {}, env) raises', raises(lambda: eval("nope", {}, env)))
