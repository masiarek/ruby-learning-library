"""The Python twin: there is no naming rule for danger. sorted(xs) returns a
new list and xs.sort() returns None whether or not it changed anything; str
methods always return a string because str is immutable; a predicate is
spelled is_x or has_x, and a `?` or `!` in a name does not parse. Row 7
starts two child Pythons to show os._exit skipping the atexit handlers."""
import subprocess
import sys


def child(source):
    done = subprocess.run([sys.executable, "-I", "-c", source], capture_output=True, text=True)
    return f"stdout {done.stdout!r}, status {done.returncode}"


def compiles(source):
    try:
        compile(source, "<lesson>", "exec")
        return "compiles"
    except SyntaxError as e:
        return type(e).__name__


a = [3, 1, 2]
s = sorted(a)
print("1. sorted returns a new list:     sorted(a)             ->", s, "a is still", a)
r = a.sort()
print("2. sort() changes the receiver:   a.sort()              ->", r, "a is now", a)
print("3. nothing-changed returns:       [1, 2].sort()         ->", [1, 2].sort(), "(None whether or not anything changed)")
print("                                  'x'.strip()           ->", repr("x".strip()))
print("                                  'abc'.replace('z','y') ->", repr("abc".replace("z", "y")))
print("                                  'ABC'.upper()         ->", repr("ABC".upper()), "(str is immutable: always a string)")
print("                                  [1, 2].reverse()      ->", [1, 2].reverse())
print("                                  [1, 2].clear()        ->", [1, 2].clear())
print("   the new value when it did:     sorted([1, 1])        ->", sorted([1, 1]), "(a copy, so nothing to signal)")
print("                                  ' x '.strip()         ->", repr(" x ".strip()))
try:
    a.sort().append(1)
except AttributeError as e:
    print("4. so chaining sort() breaks:     a.sort().append(1)    ->", f"{type(e).__name__}: {e}")
print("   chain the copying versions:    ' abc '.strip().upper() ->", repr(" abc ".strip().upper()))
print("5. predicates are is_/has_ names: len([]) == 0", len([]) == 0, "0 == 0", 0 == 0, "2 in [1, 2]", 2 in [1, 2], "'a'.isalpha()", "a".isalpha(), "1 % 2 == 0", 1 % 2 == 0, "None is None", None is None)
print("6. ? and ! do not parse:          def ready?(): ->", compiles("def ready?(): pass"), "; def go!(): ->", compiles("def go!(): pass"), "; hasattr(str, 'strip')", hasattr(str, "strip"))
print("7. the dangerous exit:            sys.exit()  ->", child('import atexit, sys\natexit.register(lambda: print("atexit ran"))\nprint("exiting")\nsys.exit()'))
print("                                  os._exit(0) ->", child('import atexit, os, sys\natexit.register(lambda: print("atexit ran"))\nprint("exiting")\nsys.stdout.flush()\nos._exit(0)'))
b = [1, 2]
appended = b.append(3)
b.extend([4])
popped = b.pop()
print("8. mutation returns None:         b.append(3) ->", appended, "; b.pop() ->", popped, "; b is", b)
print("                                  (no naming rule: append, extend, remove, reverse all return None)")
