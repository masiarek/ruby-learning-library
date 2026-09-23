"""The Python twin: a function returns None unless a `return` statement runs,
`def` and assignment are statements with no value, and `print` returns None."""


def add(a, b):
    a + b


def early(n):
    if n < 0:
        return "early"
    return "late"


def negative_or_nothing(n):
    if n < 0:
        return "negative"


def ends_with_print():
    print("   (printing from inside)")


def pair():
    return 1, 2


def assigns():
    y = 5


def empty_body():
    pass


def ensured():
    try:
        return "the body"
    finally:
        "the finally clause"


def compiles(source):
    try:
        compile(source, "<lesson>", "exec")
        return "compiles"
    except SyntaxError as e:
        return type(e).__name__


print("1. no return statement:       add(1, 2)               ->", repr(add(1, 2)))
print("2. early return:              early(-1), early(1)     ->", repr(early(-1)) + ",", repr(early(1)))
print("3. if with no branch taken:   negative_or_nothing(5)  ->", repr(negative_or_nothing(5)), "(fell off the end)")
print("4. def is a statement:        r = def named(): pass   ->", compiles("r = def named(): pass"))
print("5. a function ending in print: ends_with_print        -> prints:")
v = ends_with_print()
print("   then returns", repr(v))
print('6. print itself:              v = print("hi")         -> prints ', end="")
v = print("hi")
print("   and v is", repr(v))
print("7. return with two values:    pair                    ->", repr(pair()), "(a", type(pair()).__name__ + ")")
print("8. assignment as last line:   assigns                 ->", repr(assigns()))
print("9. a body that is only pass:  empty_body              ->", repr(empty_body()))
print("10. finally does not replace: ensured                 ->", repr(ensured()))
