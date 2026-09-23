# rescue_as_a_modifier_py.py -- the same eight rows put to Python: no expression form of
# try, contextlib.suppress, a try in a lambda, int() versus to_i, and the same trap.

import contextlib


def compiles(source):
    try:
        compile(source, "<string>", "exec")
        return "compiles"
    except SyntaxError:
        return "SyntaxError"


def or_default(f, default):
    try:
        return f()
    except Exception:
        return default


print("1. no expression form: try is a statement")
print(f"   x = int('abc') except ValueError: 0  -> {compiles('x = int(\"abc\") except ValueError: 0')}")
print(f"   or_default(lambda: int('abc'), 0)    -> {or_default(lambda: int('abc'), 0)!r}")
print(f"   or_default(lambda: int('42'), 0)     -> {or_default(lambda: int('42'), 0)!r}")

print("2. contextlib.suppress catches only what it is given")
try:
    with contextlib.suppress(ValueError):
        raise NotImplementedError("abstract")
except NotImplementedError as e:
    print(f"   suppress(ValueError) around raise NotImplementedError -> propagated {type(e).__name__}")

print("3. how it binds: suppress skips the rest of its block, assignment included")
x = "unchanged"
with contextlib.suppress(ValueError):
    x = int("abc")
print(f"   x after a suppressed int('abc') -> {x!r} (set the default before the block)")

print("4. no def-level except: the try is written out")


def parse(text):
    try:
        return int(text)
    except ValueError:
        return "function-level except"


print(f"   parse('q') -> {parse('q')!r}")

print("5. try cannot appear in a lambda or any expression")
print(f"   f = lambda: try: 1 except: 2   {compiles('f = lambda: try: 1 except: 2')}")
print(f"   f = lambda: (try: 1 except: 2) {compiles('f = lambda: (try: 1 except: 2)')}")

print("6. the built-in defaults that replace most rescue modifiers")
d = {"a": 1}
print(f"   d.get('b', 0)                 -> {d.get('b', 0)!r}")
print(f"   getattr(None, 'upper', 'dflt') -> {getattr(None, 'upper', 'dflt')!r}")
print(f"   next(iter([]), 'empty')        -> {next(iter([]), 'empty')!r}")

print("7. int() raises where Ruby's to_i does not")
for text in ("abc", "12abc", " 42 "):
    try:
        print(f"   int({text!r:<8}) -> {int(text)!r}")
    except ValueError as e:
        print(f"   int({text!r:<8}) -> {type(e).__name__}")

print("8. the same trap: a catch-all hides a typo")
print(f"   or_default(lambda: None.upcse(), 'default') -> {or_default(lambda: None.upcse(), 'default')!r} (the AttributeError is gone)")
