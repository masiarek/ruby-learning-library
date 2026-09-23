# The Python twin: one pair of boolean operators, `and` and `or`, which bind
# above `=` and where `and` binds tighter than `or`. The same ten rows.


def row(n, label, value):
    print("%2d. %-40s -> %s" % (n, label, value))


def compiles(src):
    try:
        compile(src, "<row>", "exec")
        return "compiles"
    except SyntaxError as e:
        return type(e).__name__


# 1. there is no ||; `or` binds above =
x = False or True
row(1, "x = false || true; x", "%s for ||, %s for &&; x = False or True gives %r" % (compiles("x = False || True"), compiles("x = True && False"), x))

# 2. the same spelling, the same result: one `or`, no low-precedence pair
x = False or True
row(2, "x = false or true; x", "%r  (the whole expression is %r)" % (x, (False or True)))

# 3. so a default value assigns as expected
y = None or "d"
row(3, 'y = nil or "d"; y', repr(y))

# 4. and/or return an operand, not a boolean
row(4, 'nil || "d", 1 && 2, nil && 2', ", ".join(repr(v) for v in [None or "d", 1 and 2, None and 2]))

# 5. and binds tighter than or
v = True or False and False
row(5, "true or false and false", "%r  (True or (False and False))" % v)

# 6. there is no !; `not` applies to the whole comparison
row(6, "!nil == false / not nil == false", "%s for !None / %r" % (compiles("!None"), (not None == False)))


# 7. not, and, or all consult __bool__, so truthiness is the object's to define
class Loud:
    def __bool__(self):
        calls.append("__bool__")
        return True


calls = []
a = not Loud()
b = Loud() and 1
row(7, "!obj is a method; && and || are not",
    "not Loud() -> %r; Loud() and 1 -> %r; both via %r" % (a, b, calls))

# 8. no ||=; a = a or 5 also replaces 0 and "", which are falsy
vals = []
for a in [None, False, 0, ""]:
    a = a or 5
    vals.append(repr(a))
row(8, 'a ||= 5 for nil / false / 0 / ""', "%s for ||=; a = a or 5 gives %s" % (compiles("a ||= 5"), " / ".join(vals)))

# 9. comparisons chain, and the middle operand is evaluated once
seen = []


def val(v):
    seen.append(v)
    return v


x = 2
row(9, "1 < x < 3 with x = 2", "%r; 1 < 2 < 0 -> %r; x evaluated %d time(s)" % (1 < val(x) < 3, 1 < 2 < 0, len(seen)))

# 10. and/or are ordinary expressions, welcome inside an argument list
row(10, "p(true or false) / p((true or false))", "%s / %s" % (compiles("print(True or False)"), compiles("print((True or False))")))
