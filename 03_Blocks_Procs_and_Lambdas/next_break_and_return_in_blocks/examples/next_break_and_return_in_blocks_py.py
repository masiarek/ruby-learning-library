"""Python's loops are statements: continue skips, break ends the loop, and
return ends the function -- none of them carries a value, and none can
appear in an expression. The rows match the Ruby program's rows."""

import itertools

W = 50


def row(n, label, value):
    print(f"{n:>2}. {label:<{W}} {value}")


def first_even(xs):
    for x in xs:
        if x % 2 == 0:
            return x                    # return leaves first_even
    return "none"


def two_levels():
    for a in [1, 2]:
        for b in [10, 20]:
            if a * b == 20:
                return [a, b]           # one return leaves both loops
    return None


def three():
    yield 1
    return "done"                       # return ends a generator
    yield 2                             # noqa: unreachable


def with_finally(fn):
    try:
        return fn()
    finally:
        print("    finally ran")


def compiles(src):
    try:
        compile(src, "<string>", "exec")
        return "compiles"
    except SyntaxError as e:
        return type(e).__name__


skipped = []
for x in [1, 2, 3]:
    if x % 2 == 0:
        continue
    skipped.append(x)
row(1, "a conditional expression supplies a value; continue skips:", f"{[0 if x % 2 == 0 else x for x in [1, 2, 3]]}, {skipped}")

found = None
for x in [1, 2, 3]:
    if x == 2:
        found = 42
        break
row(2, "break ends the loop; the loop has no value:", f"found = {found}, x = for ...: {compiles('x = for a in b: pass')}")
row(3, "break inside a comprehension:", f"{compiles('[break for x in xs]')}; the early exit is a generator + next: {next(v for v in [1, 2, 3] if v > 1)}")

for i in itertools.count(1):
    if i * i > 50:
        break
row(4, "break leaves an endless loop; the value is a variable:", f"i = {i}, while True: {compiles('x = while True: break')}")
row(5, "return leaves the function the loop is in:", f"{first_even([1, 4, 6])}, {first_even([1, 3])}, two levels: {two_levels()}")

tries = 0
seen = []
items = [1, 2]
k = 0
while k < len(items):
    tries += 1
    seen.append(items[k])
    if tries == 1:
        continue                        # redo by hand: the index did not move
    k += 1
row(6, "no redo: a while loop that does not advance:", f"tries {tries}, seen {seen}")

gen = three()
next(gen)
try:
    next(gen)
    value = "no StopIteration (unexpected)"
except StopIteration as e:
    value = f"StopIteration.value = {e.value!r}"
row(7, "return inside a generator ends it:", f"list(three()) = {list(three())}, {value}")
row(8, "break outside a loop, even inside a lambda:", f"{compiles('break')}, {compiles('lambda: (break)')}, in a function body: {compiles('def f(): break')}")

print(" 9. finally still runs on the way out:")
print(f"    with_finally(lambda: 'out') = {with_finally(lambda: 'out')!r}")

for x in [1, 2, 3]:
    if x == 99:
        break
else:
    ran = "else ran (no break)"
for x in [1, 2, 3]:
    if x == 2:
        break
else:
    ran += " (unexpected)"
row(10, "for ... else: else runs only when no break happened:", ran)
