# The Python twin: for and while open no scope either; only a function and a
# comprehension do. The same eleven rows.


def row(n, label, value):
    print("%2d. %-40s -> %s" % (n, label, value))


def compiles(src):
    try:
        compile(src, "<row>", "exec")
        return "compiles"
    except SyntaxError as e:
        return type(e).__name__


def read(name):
    try:
        return repr(eval(name))
    except NameError as e:
        return type(e).__name__


# 1. the loop variable and a body variable are both still there
for i in range(1, 4):
    x = i
row(1, "for i in 1..3; x = i; end; then", "i = %r, x = %r" % (i, x))

# 2. a comprehension is Python's one loop with a scope of its own
squares = [j * j for j in [10, 20]]
row(2, "[10, 20].each { |j| y = j }; then", "after [j * j for j in [10, 20]]: j -> %s" % read("j"))


# 3. for calls the collection's __iter__
class Bag:
    def __iter__(self):
        CALLS.append("Bag.__iter__ called")
        yield "a"
        yield "b"


CALLS = []
for v in Bag():
    pass
row(3, "for v in Bag.new", "%s; v after the loop = %r" % (CALLS[0], v))

# 4. while opens no scope either
n = 0
while n < 2:
    w = n
    n += 1
row(4, "while n < 2; w = n; ...; then", "n = %r, w = %r" % (n, w))


# 5. a function is the scope to reach for
def count():
    for t in range(3):
        tt = t
    return tt


count()
row(5, "times / upto / step / loop", "inside def count(): t and tt; outside: t -> %s, tt -> %s" % (read("t"), read("tt")))

# 6. a loop assigns an outer variable; an assignment inside a def makes a local instead
z = None
for q in [1]:
    z = q
loop_z = z


def assign():
    z = 2  # noqa: F841 -- a new local, not the module's z
    return z


assign()
row(6, "z = nil; [1].each { |q| z = q }", "for: z = %r; after `def assign(): z = 2`: z = %r" % (loop_z, z))

# 7. for destructures, and those variables leak too
for a, b in [[1, 2], [3, 4]]:
    pass
row(7, "for a, b in [[1, 2], [3, 4]]; then", "a = %r, b = %r" % (a, b))

# 8. for is a statement, not a value; del removes the leaked name
del i
row(8, "for ... end as a value", "%s for x = for ...; after del i: i -> %s" % (compiles("x = for m in [1, 2]: pass"), read("i")))

# 9. a comprehension shadows an outer name instead of assigning it
outer = "outer"
[outer for outer in ["shadow"]]
row(9, "[1].each { |q; outer| outer = ... }", "outer = %r" % outer)

# 10. an empty loop never binds its variable
for none in []:
    pass
row(10, "for none in []; end; then none", "none -> %s" % read("none"))

# 11. lambdas made in a loop share its one variable; a default argument freezes each value
procs = []
for c in range(1, 4):
    procs.append(lambda: c)
comp = [lambda: d for d in range(1, 4)]
fixed = [lambda d=d: d for d in range(1, 4)]
row(11, "lambdas capturing the loop variable", "for -> %r; comprehension -> %r; lambda d=d -> %r"
    % ([f() for f in procs], [f() for f in comp], [f() for f in fixed]))
