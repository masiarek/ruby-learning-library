# standard_error_is_the_default_py.py -- the same six rows put to Python: the tree under
# BaseException, what `except Exception` catches, the bare `except:` as the anti-pattern,
# and a real RecursionError and a NotImplementedError, which ARE ordinary Exceptions.

import sys

print("1. the hierarchy, up to BaseException")
for klass in (Exception, RuntimeError, ValueError, TypeError, NameError, AttributeError,
              ZeroDivisionError, KeyError, StopIteration, IndexError, OSError, FileNotFoundError,
              RecursionError, NotImplementedError, ModuleNotFoundError, SyntaxError,
              SystemExit, KeyboardInterrupt, MemoryError):
    chain = [c.__name__ for c in klass.__mro__ if c is not object]
    print(f"   {klass.__name__:<20} {' < '.join(chain)}")

print("2. what except Exception catches (except Exception inside, except BaseException outside)")
for klass in (RuntimeError, ValueError, StopIteration, FileNotFoundError,
              SystemExit, KeyboardInterrupt, MemoryError, NotImplementedError, ModuleNotFoundError, RecursionError):
    try:
        try:
            raise klass
        except Exception as e:
            print(f"   {klass.__name__:<20} caught by except Exception")
    except BaseException as e:
        print(f"   {klass.__name__:<20} SLIPPED PAST it; except BaseException caught {type(e).__name__}")

print("3. a bare except is except BaseException -- the opposite default")
try:
    raise SystemExit(1)
except:
    e = sys.exception()
    print(f"   bare except caught {type(e).__name__}; isinstance(e, Exception): {isinstance(e, Exception)}")
print(f"   isinstance(Exception(), BaseException)  {isinstance(Exception(), BaseException)}")
print(f"   Exception.__mro__[1].__name__           {Exception.__mro__[1].__name__}")

print("4. a bare except swallows sys.exit (the anti-pattern)")
try:
    sys.exit(1)
except:
    e = sys.exception()
    print(f"   swallowed {type(e).__name__} (code {e.code}); the program goes on")

print("5. a real stack overflow IS an Exception here")
def down():
    down()
try:
    try:
        down()
    except Exception as e:
        print(f"   except Exception caught {type(e).__name__}")
except BaseException as e:
    print(f"   slipped past except Exception: {type(e).__name__}")

print("6. NotImplementedError is a RuntimeError, so except Exception catches it")
class Shape:
    def area(self):
        raise NotImplementedError(f"{type(self).__name__} must define area")
try:
    try:
        Shape().area()
    except Exception as e:
        print(f"   except Exception caught {type(e).__name__}")
except BaseException as e:
    print(f"   slipped past except Exception: {type(e).__name__}")
