# The Python twin: the same twelve rows. A syntax claim is measured by
# compiling a string and printing the class of the error, or "compiles".


def row(n, label, value):
    print("%2d. %-40s -> %s" % (n, label, value))


def compiles(src):
    try:
        compile(src, "<row>", "exec")
        return "compiles"
    except SyntaxError as e:
        return type(e).__name__


# 1. no unless: negate the condition
x = "body" if not 1 > 2 else "else branch"
row(1, "unless 1 > 2 ... else ... end", "%s  (if not 1 > 2: gives %r)"
    % (compiles("unless 1 > 2:\n    pass"), x))

# 2. a negated if still takes elif
row(2, "unless ... elsif ... end", "%s  (if not c: ... elif d: ...)"
    % compiles("if not False:\n    1\nelif True:\n    2"))

# 3. no until: while not
n = 0
while not n >= 4:
    n += 1
row(3, "n = 0; until n >= 4 ... n += 1", "%s  (while not n >= 4: gives %r)"
    % (compiles("until n >= 4:\n    n += 1"), n))

# 4. no trailing modifier statement; only the conditional expression
row(4, "r << x if c; r << y unless c", "%s  (an expression needs else: x if c else y)"
    % compiles("r.append(1) if True"))

# 5. no `body while cond`
n = 10
while n < 3:
    n += 1
row(5, "n = 10; n += 1 while n < 3", "%s  (while n < 3: n += 1 gives %r)"
    % (compiles("n += 1 while n < 3"), n))

# 6. no do-while: while True with a break at the end
n = 10
while True:
    n += 1
    if not n < 3:
        break
row(6, "n = 10; begin n += 1 end while n < 3", "%s  (while True: ... if not c: break gives %r)"
    % (compiles("do:\n    n += 1\nwhile n < 3"), n))

# 7. no loop keyword: while True; break carries no value
i = 0
while True:
    i += 1
    if i == 3:
        v = i * 10
        break
row(7, "loop do ... break i * 10 ... end", "%s  (while True: ... v = i * 10; break gives %r)"
    % (compiles("loop:\n    pass"), v))

# 8. elif is the spelling
row(8, "if/elsif/else/end", compiles("if False:\n    1\nelsif True:\n    2\nelse:\n    3"))

# 9. elif compiles, and there is no method-call reading of it
row(9, "if ... elif true ... end", compiles("if False:\n    1\nelif True:\n    2"))

# 10. else if is not Python; else: with a nested if is
one = compiles("if False:\n    1\nelse if True:\n    2")
two = compiles("if False:\n    1\nelse:\n    if True:\n        2")
row(10, "else if ... with one end / two ends", "%s / %s  (else if / else: nested if)" % (one, two))

# 11. a branch that never runs never defines the name
try:
    if False:
        y = 5
    y
    later = repr(y)
except NameError as e:
    later = type(e).__name__
row(11, "y = 5 if false; then y", "%s  (if False: y = 5; then y -> %s)"
    % (compiles("y = 5 if False"), later))

# 12. for ... else: else runs only when no break happened
def search(xs):
    for v in xs:
        if v > 5:
            return "break at %d" % v
    else:
        return "else ran"

row(12, "for ... else (search with no hit)", "compiles; %s / %s" % (search([1, 2, 9]), search([1, 2, 3])))
