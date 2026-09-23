# The Python twin: the same twelve rows. Where Ruby has a value and Python has
# only a statement, the row prints the class of the error that compile() raises,
# then the expression form Python offers instead, when it has one.


def row(n, label, value):
    print("%2d. %-38s -> %s" % (n, label, value))


def compiles(src, mode="exec"):
    """The class of the compile-time error for src, or 'compiles'."""
    try:
        compile(src, "<row>", mode)
        return "compiles"
    except SyntaxError as e:
        return type(e).__name__


c = True

# 1. the conditional expression is the one branch that is an expression
x = 1 if c else 2
row(1, "if/else as a value", "%r  (x = 1 if c else 2; statement form: %s)"
    % (x, compiles("x = if c: 1\nelse: 2")))

# 2. match is a statement
row(2, "case/when as a value", "%s  (match is a statement)"
    % compiles("x = match 2:\n    case 1: 'one'\n    case 2: 'two'"))

# 3. try is a statement
row(3, "begin...end as a value", "%s  (try is a statement)"
    % compiles("x = try:\n    40 + 2\nfinally:\n    pass"))

# 4. while is a statement
row(4, "while loop as a value", "%s  (while is a statement)"
    % compiles("x = while False: pass"))

# 5. print returns None, so an assignment from it is None
x = (print("hi"))
row(5, 'x = (print("hi")) leaves x =', repr(x))

# 6. def is a statement
row(6, "def greet(): pass evaluates to", "%s  (def is a statement)"
    % compiles("x = def greet(): pass"))

# 7. class is a statement
row(7, "class Foo: 99 evaluates to", "%s  (class is a statement)"
    % compiles("x = class Foo: 99"))

# 8. chained assignment is its own syntax, not a nested expression
x = y = 1
row(8, "chained x = y = 1 gives [x, y]", repr([x, y]))

# 9. an assignment statement cannot nest; the walrus := can
y = (a := 1)
row(9, "nested y = (a = 1) gives [y, a]", "%s  (y = (a := 1) gives %r)"
    % (compiles("y = (a = 1)"), [y, a]))

# 10. a lambda body is exactly one expression
g = (lambda: (t := 1) + 1)
row(10, "lambda body with two statements", "%s  ((lambda: (t := 1) + 1)() gives %r)"
    % (compiles("f = lambda: t = 1; t + 1"), g()))

# 11-12. eval takes an expression; exec takes statements and returns None
row(11, 'eval("1 + 2")', repr(eval("1 + 2")))
row(12, 'eval("x = 1; x + 1")', "%s  (exec(\"x = 1\") returns %r)"
    % (compiles("x = 1; x + 1", "eval"), exec("x = 1")))


# 13. a decorator receives the function object, not a name
def private(f):
    seen.append(f.__name__)
    return f


seen = []


class Toolbox:
    @private
    def helper(self):
        pass


row(13, "class ...; @private def helper", "%r  (the decorator received the function object)" % seen)
