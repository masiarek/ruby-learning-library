# The Python twin: CPython frees an object the instant its reference count hits
# zero, so a weakref dies and __del__ runs at a predictable line; the cycle
# collector in `gc` exists only for reference cycles.

import gc
import sys
import weakref

log = []


class Widget:
    def __del__(self):
        log.append("__del__ ran for a Widget")


class Plain:
    pass


def row(n, label, value):
    print(f"{n:2d}. {label:<52} {value!r}")


n = gc.collect()
row(1, "gc.collect() returns an int (objects it freed) >= 0", [type(n).__name__, n >= 0])

before = len(gc.get_objects())
kept = [[i] for i in range(1000)]
row(2, "len(gc.get_objects()) grew by >= 1000 after 1000 lists", len(gc.get_objects()) - before >= len(kept))

states = [gc.isenabled()]
gc.disable()
states.append(gc.isenabled())
gc.enable()
states.append(gc.isenabled())
row(3, "[isenabled(), after disable(), after enable()]", states)

before_any = any(isinstance(o, Widget) for o in gc.get_objects())
w = Widget()
row(4, "any Widget in gc.get_objects() before / after Widget()", [before_any, any(isinstance(o, Widget) for o in gc.get_objects())])

wd = weakref.WeakValueDictionary()
value = Plain()
wd["key"] = value
row(5, 'weakref.WeakValueDictionary: "key" in wd, wd["key"] is value', ["key" in wd, wd["key"] is value])

r = weakref.ref(w)
row(6, "weakref.ref(w) while w is referenced: alive, r() is w", [r() is not None, r() is w])
del w
row(7, "after del w: r() is None at once; __del__ already ran", [r() is None, log])

keep = Plain()
fin = weakref.finalize(keep, print, "finalize ran for keep (after the last row: at exit)")
row(8, "weakref.finalize(keep, print, ...): alive, atexit", [fin.alive, fin.atexit])

n1 = sys.getrefcount(keep)
alias = keep
n2 = sys.getrefcount(keep)
del alias
row(9, "sys.getrefcount: +1 with an alias, back after del", [n2 == n1 + 1, sys.getrefcount(keep) == n1])
row(10, "gc.get_stats(): generations, keys of one", [len(gc.get_stats()), sorted(gc.get_stats()[0])])
row(11, 'gc.is_tracked(1), gc.is_tracked("a"), gc.is_tracked([])', [gc.is_tracked(1), gc.is_tracked("a"), gc.is_tracked([])])

a = Plain()
b = Plain()
a.other = b
b.other = a
ra = weakref.ref(a)
del a, b
alive_after_del = ra() is not None
freed = gc.collect() >= 2
row(12, "a cycle survives del; gc.collect() frees it", [alive_after_del, freed, ra() is None])
row(13, 'sys.getsizeof("x" * 1000) > 1000', sys.getsizeof("x" * 1000) > 1000)
