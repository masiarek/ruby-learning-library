# Python has docstrings: a string literal first in a def or class body is kept
# as __doc__. inspect.getdoc cleans it; inspect.getcomments reads the comment
# above an object from the file -- the same trick as the Ruby program.
import inspect


# Adds two numbers.
# Both must be numeric.
def add(a, b):
    return a + b


def sub(a, b):
    """Subtract b from a.

    Returns a number.
    """
    return a - b


class Calc:
    """A calculator."""

    # the multiply helper
    def mul(self, a, b):
        return a * b

    def undocumented(self):
        return None


source_file = inspect.getsourcefile(add).rsplit("/", 1)[-1]
line = inspect.getsourcelines(add)[1]
print(f" 1. inspect.getsourcefile/lines:  [{source_file}, {line}] -- a {type(source_file).__name__} and an {type(line).__name__}")
try:
    inspect.getsourcefile(len)
except TypeError as e:
    print(f" 2. a C-implemented function:     getsourcefile(len) raises {type(e).__name__}, yet len.__doc__ starts {len.__doc__[:26]!r}")
print(f" 3. comment above def add:        {inspect.getcomments(add)!r}")
print(f" 4. comment above Calc.mul:       {inspect.getcomments(Calc.mul)!r}")
print(f" 5. no comment, no docstring:     getcomments {inspect.getcomments(Calc.undocumented)!r}, __doc__ {Calc.undocumented.__doc__!r}")
print(f" 6. the real thing, __doc__:      inspect.getdoc(sub) = {inspect.getdoc(sub)!r}")
print(f" 7. a docstring is an object:     Calc.__doc__ = {Calc.__doc__!r}, add.__doc__ = {add.__doc__!r} (a comment is not)")
print(f" 8. getdoc cleans indentation:    lines of getdoc(sub): {inspect.getdoc(sub).splitlines()}")
