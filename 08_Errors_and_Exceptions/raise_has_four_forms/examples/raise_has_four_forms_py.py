# raise_has_four_forms_py.py -- Python has one form, `raise <instance>`, plus the
# class shorthand; the same eleven rows put to Python.

import sys
import traceback


def report(f, args=False):
    try:
        f()
    except BaseException as e:
        print(f"   {type(e).__name__}" + (f": args={e.args!r}" if args else ""))


def raiser(exc):
    def go():
        raise exc
    return go


print('1. raise "msg": a string is not an exception')
report(raiser("just a message"))

print("2. raise Klass instantiates it with no arguments")
report(raiser(ValueError), args=True)

print('3. raise Klass, "msg" is Python 2 syntax')
try:
    compile('raise ValueError, "with a message"', "<string>", "exec")
except SyntaxError as e:
    print(f"   {type(e).__name__}")

print('4. raise Klass("msg") is the one form; nothing replaces a message afterwards')
report(raiser(ValueError("an instance")), args=True)

print("5. a bare raise inside except re-raises the same object")
try:
    try:
        raise OSError("inner")
    except OSError as inner:
        kept = inner
        raise
except OSError as outer:
    print(f"   outer got {type(outer).__name__}; same object: {outer is kept}")

print("6. a bare raise outside any except: a RuntimeError")


def bare():
    raise


report(bare)

print("7. with_traceback replaces the traceback (frames, not strings)")


def deep():
    raise ValueError("deep")


try:
    deep()
except ValueError as e:
    borrowed = e.__traceback__
try:
    raise TypeError("blame elsewhere").with_traceback(borrowed)
except TypeError as e:
    before, after = len(traceback.extract_tb(borrowed)), len(traceback.extract_tb(e.__traceback__))
    print(f"   frames in the borrowed traceback: {before}; after re-raising with it: {after}")

print("8. no fail alias")
print("   raise is the only spelling")

print("9. raising something that is not an exception")
report(raiser(42))
report(raiser(int))
report(raiser("a"))

print("10. sys.exception() inside except, and after it")
try:
    raise RuntimeError("boom")
except RuntimeError as e:
    print(f"   sys.exception() is e                    {sys.exception() is e}")
    print(f"   sys.exc_info()[2] is e.__traceback__    {sys.exc_info()[2] is e.__traceback__}")
print(f"   sys.exception() after the except        {sys.exception()!r}")

print("11. raise Klass calls Klass(): the constructor, not a hook")


class Custom(Exception):
    def __init__(self, *args):
        print(f"   Custom.__init__ called with {args!r}")
        super().__init__(*args)


report(raiser(Custom))
report(raiser(Custom("msg")))
