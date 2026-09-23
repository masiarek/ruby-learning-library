"""The Python twin: a default is evaluated once, when `def` runs, and the one
resulting object is stored on the function -- so a `[]` default is shared by
every call (the mutable-default trap), a default cannot see the other
parameters, and a counter in a default counts to one."""
import itertools


def add_item(item, lst=[]):
    lst.append(item)
    return lst


def add_item_sentinel(item, lst=None):
    if lst is None:
        lst = []
    lst.append(item)
    return lst


def defines(source):
    try:
        exec(source, {})
        return "defined"
    except NameError as e:
        return f"{type(e).__name__} at def time"


counter = itertools.count(1)


def tick(n=next(counter)):
    return n


print("1. def add_item(item, lst=[])")
print("   add_item('a'), add_item('b'), add_item('c') ->", add_item("a"), add_item("b"), add_item("c"))
print("2. where the default lives:       add_item.__defaults__ ->", add_item.__defaults__)
print("                                  (one object, stored on the function when def ran)")
print("3. the None-sentinel fix:         add_item_sentinel('a'), ('b') ->", add_item_sentinel("a"), add_item_sentinel("b"), "(the idiom)")
print("4. a default may use an earlier parameter?")
print("   def rect(w, h=w * 2)           ->", defines("def rect(w, h=w * 2): return [w, h]"))
print("   def chain(a, b=a + 1, c=b + 1) ->", defines("def chain(a, b=a + 1, c=b + 1): return [a, b, c]"))
print("5. nor a later one:               def later(a=b, b=1)    ->", defines("def later(a=b, b=1): return [a, b]"))
print("6. a default that counts calls:   tick(), tick(), tick() ->", tick(), tick(), tick())
print("   tick(10), tick()               ->", tick(10), tick(), "(the default was evaluated once, at def)")
print("7. when the default runs:         def side(...) -> ", end="")


def side(a=(print("(default evaluated now) ", end=""), 1)[1]):
    return a


print("at def time")
print("                                  side()   ->", side(), "(nothing evaluated)")
print("                                  side(2)  ->", side(2))
print("                                  side()   ->", side())
