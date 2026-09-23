# rescue_ensure_else_and_retry_py.py -- the same nine questions put to Python:
# try / except / else / finally, a loop where Ruby has retry, finally on return,
# the return-inside-finally trap, and try as a statement rather than an expression.

import traceback


def full_form(fail):
    try:
        print("   try body runs")
        if fail:
            raise ZeroDivisionError("divided by 0")
        print("   try body finished")
    except (ZeroDivisionError, ValueError) as e:
        print(f"   except runs: {type(e).__name__}")
    else:
        print("   else runs: no exception was raised")
    finally:
        print("   finally runs")


print("1. the full form, no exception")
full_form(False)

print("2. the full form, an exception")
full_form(True)

print("3. except (A, B) as e catches either class, and their subclasses")
for klass in (ZeroDivisionError, LookupError, KeyError):
    try:
        raise klass("raised on purpose")
    except (ZeroDivisionError, LookupError) as e:
        print(f"   caught {type(e).__name__}, isinstance(e, LookupError): {isinstance(e, LookupError)}")

print("4. no retry keyword: a loop around the try")
for attempt in range(1, 4):
    try:
        print(f"   attempt {attempt}")
        if attempt < 3:
            raise RuntimeError("flaky")
        print(f"   succeeded on attempt {attempt}")
        break
    except RuntimeError:
        continue

print("5. finally runs on return")


def early_return():
    try:
        return "the return value"
    finally:
        print("   finally ran on the way out")


print(f"   function returned {early_return()!r}")

print("6. return inside finally swallows the exception (never do this)")
print("   not run here: it swallows the same way, and Python 3.14 warns at compile time")

print("7. no def-level except: the try is written out")


def parse(text):
    try:
        return int(text)
    except ValueError as e:
        return f"rescued {type(e).__name__}"


print(f'   parse("12")  -> {parse("12")!r}')
print(f'   parse("abc") -> {parse("abc")!r}')

print("8. what the caught object carries")
try:
    1 / 0
except Exception as e:
    print(f"   type(e).__name__   {type(e).__name__}")
    print(f"   str(e)             a {type(str(e)).__name__} (CPython rewords messages; not printed)")
    print(f"   e.__traceback__    a {type(e.__traceback__).__name__} object")
    print(f"   extract_tb(...)    a {type(traceback.extract_tb(e.__traceback__)).__name__} (paths inside, not printed)")

print("9. try is a statement, not an expression")
try:
    compile("v = try: 1 except: 2", "<string>", "exec")
except SyntaxError as e:
    print(f"   v = try: ...  ->  {type(e).__name__}")
print("   (no else/ensure value to read: the block has no value at all)")
