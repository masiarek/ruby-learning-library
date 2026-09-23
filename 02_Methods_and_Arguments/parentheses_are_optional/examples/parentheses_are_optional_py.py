"""The Python twin: parentheses are the call operator, so `print "x"` does
not parse, a bare name is a reference, and the space before a `(` changes
nothing. Row 9 proves the last point by compiling both spellings."""


def greeting():
    return "the method"


def f(a, b):
    return a + b


def rest(*args):
    return args


def compiles(source):
    try:
        compile(source, "<lesson>", "exec")
        return "compiles"
    except SyntaxError as e:
        return f"SyntaxError: {e.msg}"


print('1. a call without parentheses:    print "x"        ->', compiles('print "x"'))
print('2. a def without parentheses:     def f a, b:      ->', compiles('def f a, b:\n    return a + b'))
print('3. a bare name, no local exists:  greeting         -> a', type(greeting).__name__, 'object, not a call')
greeting = "the local"
print('4. after greeting = "the local": greeting       ->', repr(greeting))
try:
    greeting()
except TypeError as e:
    print('5. parentheses call the binding:  greeting()       ->', f"{type(e).__name__}: {e}")
print('6. a receiver forces it too:      self.greeting    -> (no counterpart: the function was overwritten by row 4)')

print('7. one space before the paren:    print (1+2)*3    -> prints ', end="")
try:
    print (1+2)*3
except TypeError as e:
    print(f"   then {type(e).__name__}: {e}")
print('8. no space before the paren:     print(1+2)*3     -> prints ', end="")
try:
    print(1+2)*3
except TypeError as e:
    print(f"   then {type(e).__name__}: {e}")
same = compile("print (1+2)*3", "<a>", "exec").co_code == compile("print(1+2)*3", "<b>", "exec").co_code
print("9. rows 7 and 8 compile to the same bytecode:", same)

p = print
try:
    p -1
except TypeError as e:
    print("10. minus, one space:             p -1             ->", f"{type(e).__name__}: {e}")
print("11. python3 -W error on row 10:   nothing to warn about: the space never changes the parse")
try:
    p - 1
except TypeError as e:
    print("12. minus, two spaces:            p - 1            ->", f"{type(e).__name__}: {e}")

try:
    rest *[1, 2]
except TypeError as e:
    print("13. star, one space:              rest *[1, 2]     ->", f"{type(e).__name__}: {e}")
print("14. the star unpacks only inside the call's parentheses: rest(*[1, 2]) ->", rest(*[1, 2]))
