# exceptions_have_a_cause_py.py -- the same nine rows put to Python: __context__ is set
# implicitly, `raise X from Y` sets __cause__, `from None` suppresses, a chain of three,
# the two traceback sentences, no loop check, a raise inside finally, __cause__ writable.

import traceback


class Low(Exception):
    pass


class Mid(Exception):
    pass


class High(Exception):
    pass


def chain_of(e):
    names = []
    while e is not None:
        names.append(type(e).__name__)
        e = e.__cause__ or (None if e.__suppress_context__ else e.__context__)
    return names


def sentences(e):
    text = "".join(traceback.format_exception(e))
    return [line.rstrip() for line in text.splitlines()
            if line and not line.startswith(" ") and not line.startswith("Traceback")]


print("1. a raise inside except sets __context__ automatically")
try:
    try:
        raise Low("disk full")
    except Low:
        raise High("save failed")
except High as e:
    print(f"   {type(e).__name__}: {str(e)!r}; __context__: {type(e.__context__).__name__}: {str(e.__context__)!r}; __cause__: {e.__cause__!r}")

print("2. raise X from Y sets __cause__ explicitly")
kept = Low("kept aside")
try:
    raise High("wrapped") from kept
except High as e:
    print(f"   e.__cause__ {type(e.__cause__).__name__}; the same object: {e.__cause__ is kept}; __suppress_context__ {e.__suppress_context__}")

print("3. from None hides the exception being handled (it is still in __context__)")
try:
    try:
        raise Low("noise")
    except Low:
        raise High("clean") from None
except High as e:
    print(f"   e.__cause__ {e.__cause__!r}; e.__context__ {type(e.__context__).__name__}; __suppress_context__ {e.__suppress_context__}")

print("4. a chain of three, walked with __cause__ / __context__")
try:
    try:
        try:
            raise Low("l")
        except Low:
            raise Mid("m")
    except Mid:
        raise High("h")
except High as e:
    print(f"   {chain_of(e)!r}")
    print("5. what the traceback prints about the chain (sentence lines only)")
    for line in sentences(e):
        print(f"   {line}")
try:
    try:
        raise Low("l")
    except Low as low:
        raise High("h") from low
except High as e:
    print("   ... and with an explicit from:")
    for line in sentences(e):
        print(f"   {line}")

print("6. no except in progress: both are None")
try:
    raise High("no context")
except High as e:
    print(f"   e.__context__ {e.__context__!r}; e.__cause__ {e.__cause__!r}")

print("7. no loop check: a cycle is accepted, and the printer stops at a repeat")
a, b = Low("a"), High("b")
a.__cause__ = b
b.__cause__ = a
print(f"   a.__cause__ is b and b.__cause__ is a: {a.__cause__ is b and b.__cause__ is a}")
print(f"   format_exception(a) mentions 'Low: a' {sum(1 for s in sentences(a) if s == 'Low: a')} time(s)")

print("8. a raise inside finally, while another exception is in flight, gets a __context__ too")
try:
    try:
        raise Low("from the body")
    finally:
        try:
            raise High("from finally")
        except High as inner:
            print(f"   inner.__context__ {type(inner.__context__).__name__}")
except Low as e:
    print(f"   the body's {type(e).__name__} still reaches the outer except")

print("9. __cause__ is writable")
e = High("h")
e.__cause__ = Low("set by hand")
print(f"   e.__cause__ after assignment: {type(e.__cause__).__name__}")
