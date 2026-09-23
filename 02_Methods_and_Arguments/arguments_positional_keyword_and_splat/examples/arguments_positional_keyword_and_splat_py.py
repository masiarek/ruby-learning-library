"""The Python twin: `*args`, `**kwargs`, keyword-only after `*`,
positional-only before `/`, no block slot and no anonymous forwarding.
An argument error is a TypeError; only its type is printed, because CPython
rewords the messages between releases."""
import inspect


def f(a, b=2, *rest, z):
    return [a, b, rest, z]


def g(a, *, k, d=4, **opts):
    return [a, k, d, opts]


def h(blk):
    return blk(3)


def target(*args, **opts):
    return [args, opts]


def fwd(*args, **kwargs):
    return target(*args, **kwargs)


def kw(*, k, d=4):
    return [k, d]


def two(a, b):
    return [a, b]


def pos(a):
    return a


def pos_only(a, /):
    return a


def attempt(call):
    try:
        return repr(call())
    except TypeError as e:
        return type(e).__name__


print("1. required, default, *rest, then a name:     def f(a, b=2, *rest, z)  -- z is keyword-only")
print("   f(1, 9)                    ->", attempt(lambda: f(1, 9)), "(z was not given)")
print("   f(1, 2, 3, 4, z=5)         ->", f(1, 2, 3, 4, z=5))
print("2. introspected:              inspect.signature(f)  ->", inspect.signature(f))
print("3. keyword-only after *:      def g(a, *, k, d=4, **opts)")
print("   g(1, k=2)                  ->", g(1, k=2))
print("   g(1, k=2, d=5, x=6)        ->", g(1, k=2, d=5, x=6))
print("4. a callable parameter:      h(lambda x: x * 2)    ->", h(lambda x: x * 2))
print("5. *args, **kwargs forward:   fwd(1, 2, k=3)        ->", fwd(1, 2, k=3), "(no block slot)")
print("6. anonymous *, ** and &:     no counterpart: *args and **kwargs must be named to be forwarded")
print("   fwd's parameters           ->", inspect.signature(fwd))
print("7. too few positionals:       f(1)                  ->", attempt(lambda: f(1)))
print("8. a missing keyword:         kw()                  ->", attempt(lambda: kw()))
print("9. an unknown keyword:        kw(k=1, z=2)          ->", attempt(lambda: kw(k=1, z=2)))
print("10. a dict is not keywords:   kw({'k': 1})          ->", attempt(lambda: kw({"k": 1})))
print("    but ** splats it:         kw(**{'k': 1})        ->", attempt(lambda: kw(**{"k": 1})))
print("11. positionals have names:   two(b=2, a=1)         ->", attempt(lambda: two(b=2, a=1)))
print("    unless marked with /:     pos_only(a=1)         ->", attempt(lambda: pos_only(a=1)) + "; pos(a=1) ->", attempt(lambda: pos(a=1)))
print("12. no arity; parameter counts:", ", ".join(f"{fn.__name__} {len(inspect.signature(fn).parameters)}" for fn in (f, g, kw, two, fwd)))
