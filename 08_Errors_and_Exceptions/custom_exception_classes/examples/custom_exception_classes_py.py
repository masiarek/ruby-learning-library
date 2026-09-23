# custom_exception_classes_py.py -- the same ten rows put to Python: a subclass of
# Exception with a default message, attributes, __str__, a family, the last traceback
# line, no exception protocol, add_note, __init__ without super, == is identity,
# and ExceptionGroup with except*.

import traceback


class AppError(Exception):
    def __init__(self, msg="the application failed"):
        super().__init__(msg)


class NotFound(AppError):
    def __init__(self, msg="not found", code=404):
        super().__init__(msg)
        self.code = code


class Loud(AppError):
    def __str__(self):
        return "LOUD: " + super().__str__()


print("1. a default message via super().__init__")
try:
    raise AppError
except AppError as e:
    print(f"   raise AppError                  -> {str(e)!r}")
try:
    raise AppError("given instead")
except AppError as e:
    print(f'   raise AppError("given instead") -> {str(e)!r}')

print("2. extra attributes")
try:
    raise NotFound
except NotFound as e:
    print(f"   {type(e).__name__}: {str(e)!r}, code {e.code}")
try:
    raise NotFound("no such user", code=410)
except NotFound as e:
    print(f"   {type(e).__name__}: {str(e)!r}, code {e.code}")

print("3. overriding __str__")
try:
    raise Loud("x")
except Loud as e:
    print(f"   str(e) {str(e)!r}   e.args {e.args!r}")

print("4. a family is caught by its base class")
for klass in (AppError, NotFound, Loud):
    try:
        raise klass
    except AppError as e:
        print(f"   except AppError caught {type(e).__name__}")

print("5. format_exception_only: the last line of a traceback")


def boom():
    raise NotFound("gone", code=410)


try:
    boom()
except Exception as e:
    print(f"   {traceback.format_exception_only(e)[-1].rstrip()}")

print("6. no exception protocol: raise needs a BaseException class or instance")


class Ticket:
    def __init__(self, id):
        self.id = id


try:
    raise Ticket(7)
except TypeError as e:
    print(f"   raise Ticket(7)  -> {type(e).__name__}")

print("7. add_note (3.11) is shown by the traceback; str(e) is untouched")
try:
    raise AppError("bad setting")
except AppError as e:
    e.add_note("hint: check the config")
    print(f"   str(e)                 {str(e)!r}")
    print(f"   e.__notes__            {e.__notes__!r}")
    print(f"   format_exception_only  {[line.rstrip() for line in traceback.format_exception_only(e)]!r}")

print("8. __init__ without super().__init__: args are kept anyway")


class NoSuper(AppError):
    def __init__(self, code):
        self.code = code


try:
    raise NoSuper(5)
except NoSuper as e:
    print(f"   {type(e).__name__}: str {str(e)!r}, args {e.args!r}")

print("9. == is identity")
print(f'   AppError("a") == AppError("a")  {AppError("a") == AppError("a")}')
a = AppError("a")
print(f"   a == a                            {a == a}")

print("10. ExceptionGroup and except* (3.11): several errors at once")
try:
    raise ExceptionGroup("3 errors", [ValueError("a"), TypeError("b"), ValueError("c")])
except* ValueError as group:
    print(f"   except* ValueError got {len(group.exceptions)} of them")
except* TypeError as group:
    print(f"   except* TypeError  got {len(group.exceptions)} of them")
