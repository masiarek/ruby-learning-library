# throw_and_catch_py.py -- Python has no throw/catch; the same eight rows use an
# exception class as the jump, and show where that differs: an except in between
# DOES intercept it unless the class derives from BaseException.


class Found(Exception):
    pass


class Escape(BaseException):
    pass


def catch(f):
    try:
        return f()
    except Found as jump:
        return jump.args[0] if jump.args else None


print("1. a control-flow exception carries the value; the helper returns it")


def search():
    for n in (1, 2, 3):
        if n == 2:
            raise Found(n * 10)
    return "function finished without a raise"


print(f"   with a raise:    {catch(search)!r}")
print(f"   without a raise: {catch(lambda: 'function finished without a raise')!r}")

print("2. escaping nested loops")


def grid():
    for i in (1, 2, 3):
        for j in (1, 2, 3):
            print(f"   visiting {i},{j}")
            if i * j == 4:
                raise Found([i, j])
    return None


print(f"   first cell whose product is 4: {catch(grid)!r}")

print("3. a raise with no matching except is just an uncaught exception")
try:
    raise Found(1)
except Exception as e:
    print(f"   {type(e).__name__}; args {e.args!r}")
    print(f"   isinstance(e, Exception) {isinstance(e, Exception)}")

print("4. an except Exception in between DOES intercept it; finally runs either way")


def through_except(exc):
    try:
        raise exc
    except Exception:
        print(f"   except Exception intercepted {type(exc).__name__}")
    finally:
        print(f"   finally ran on the way out for {type(exc).__name__}")
    return "function finished"


try:
    print(f"   returned {through_except(Found('x'))!r}")
except Found:
    print("   Found reached the outer handler")
try:
    print(f"   returned {through_except(Escape('x'))!r}")
except Escape:
    print("   Escape (a BaseException) reached the outer handler")

print("5. no tagless form: the exception class is the tag")
print("   any class works as a tag; there is nothing to generate")

print("6. a raise with no value: args is empty, the helper returns None")
print(f"   catch(lambda: (_ for _ in ()).throw(Found())) -> {catch(lambda: (_ for _ in ()).throw(Found()))!r}")

print("7. matching is by class, not identity")
print(f"   isinstance(Found(), Found) {isinstance(Found(), Found)}; Found() is Found() {Found() is Found()}")

print("8. the jump unwinds through function calls")


def descend(n):
    if n == 0:
        raise Found("reached the bottom")
    return descend(n - 1)


print(f"   catch(lambda: descend(5)) -> {catch(lambda: descend(5))!r}")
