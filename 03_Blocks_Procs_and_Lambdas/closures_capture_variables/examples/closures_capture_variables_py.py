"""A nested def or lambda closes over the enclosing function's variables --
the variables, not their values -- but assigning one needs `nonlocal`, and a
loop variable is one variable shared by every closure made in the loop.
The rows match the Ruby program's rows; the closures are built inside
functions because a module-level name is a global, not a captured cell."""

W = 52


def row(n, label, value):
    print(f"{n:>2}. {label:<{W}} {value}")


def make_counter():
    count = 0

    def inc():
        nonlocal count
        count += 1

    def get():
        return count
    return inc, get


def later_value():
    n = 1
    f = lambda: n                                            # noqa: E731
    n = 2
    return f(), f.__closure__[0].cell_contents, f.__code__.co_freevars


def assign_outer_without_nonlocal():
    total = 0

    def add(x):
        total += x                                           # makes total local to add
    try:
        add(1)
        return "no error"
    except UnboundLocalError as e:
        return type(e).__name__


def assign_outer_with_nonlocal():
    total = 0

    def add(x):
        nonlocal total
        total += x
    for x in [1, 2, 3]:
        add(x)
    return total


def name_stays_inside():
    def f():
        inner = 1                                            # noqa: F841
    f()
    try:
        return inner                                         # noqa: F821
    except NameError as e:
        return type(e).__name__


def keep(i):
    return lambda: i                                         # one variable per call


def shared_loop_variable():
    comp = [lambda: i for i in range(1, 4)]
    in_for = []
    for i in range(1, 4):
        in_for.append(lambda: i)
    return [g() for g in comp], [g() for g in in_for], i


def shadow(x):
    x += 5
    return x


def local_by_default(x):
    tmp = x                                                  # noqa: F841


def nested_def_is_a_closure():
    n = 2

    def sees_n():
        return n
    return sees_n()


value, cell, freevars = later_value()
row(1, "a closure sees the later value of n:", value)

inc, get = make_counter()
inc()
inc()
_, get_other = make_counter()
row(2, "two closures share one count; a new maker starts over:", f"{get()}, {get_other()}")

row(3, "assigning the outer total, without / with nonlocal:", f"{assign_outer_without_nonlocal()} / {assign_outer_with_nonlocal()}")
row(4, "a name first assigned inside stays inside:", f"reading inner outside = {name_stays_inside()}")

per_call = [keep(i) for i in range(1, 4)]
defaulted = [lambda i=i: i for i in range(1, 4)]
row(5, "a factory call or an i=i default is fresh per call:", f"{[g() for g in per_call]}, {[g() for g in defaulted]}")

comp, in_for, i_after = shared_loop_variable()
row(6, "a comprehension's i; a for loop's i:", f"{comp}, {in_for}, i after the loop = {i_after}")

x = 10
shadow(x)
row(7, "a parameter shadows the outer x:", f"x = {x}")

tmp = "outer"
local_by_default(1)
row(8, "an assignment in a def is local by default:", f"tmp = {tmp!r}")

row(9, "the captured variable, seen from outside:", f"f.__closure__[0].cell_contents = {cell}, co_freevars = {freevars}")
row(10, "a nested def is a closure:", f"sees n = {nested_def_is_a_closure()}")
