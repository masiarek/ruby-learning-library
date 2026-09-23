"""Python has the same model: the twin of variables_are_references_rb.rb.

A name refers to an object; mutation is shared, rebinding is not. One row
differs: += on a list mutates in place. A str has no << at all, so row 4 says
so.
"""
import copy


def row(label, shown):
    print(f"   {label:<48} {shown}")


print("1. two names, one object")
a = [1]
b = a
b.append(2)
row("a = [1]; b = a; b.append(2); a", repr(a))
row("b", repr(b))
row("a is b", repr(a is b))

print("2. + makes a new object; = rebinds the name")
b = b + [3]
row("b = b + [3]; a", repr(a))
row("b", repr(b))
row("a is b", repr(a is b))

print("3. += on a list mutates in place in Python")
b = a
b += [4]
row("b = a; b += [4]; a", repr(a))
row("b", repr(b))
row("a is b", repr(a is b))

print("4. the same with a string: no << exists")
s = "x"
t = s
try:
    t[0] = "y"
except TypeError as e:
    row('s = "x"; t = s; t[0] = "y"', type(e).__name__)
t += "y"
row('t += "y"; s', repr(s))
row("t", repr(t))
row("s is t", repr(s is t))

print("5. a function receives the reference")


def push_four(lst):
    lst.append(4)


def reassign(lst):
    lst = [9]
    return lst


def shout(text):
    return text.upper()


orig = [1]
push_four(orig)
row("push_four(orig); orig", repr(orig))
returned = reassign(orig)
row("reassign(orig) returns", repr(returned))
row("orig after reassign", repr(orig))
word = "hi"
shout(word)
row("shout(word); word  (upper() returns new)", repr(word))

print("6. copy.copy breaks the sharing, one level deep")
base = [1, 2]
c = copy.copy(base)
row("base = [1, 2]; c = copy.copy(base); c is base", repr(c is base))
c.append(9)
row("c.append(9); base", repr(base))
row("c", repr(c))
nested = [[1]]
shallow = copy.copy(nested)
shallow[0].append(2)
row("nested = [[1]]; copy.copy(nested)[0].append(2)", repr(nested))
deep = copy.deepcopy(nested)
deep[0].append(3)
row("copy.deepcopy, then [0].append(3); nested", repr(nested))

print("7. the shared-default trap")
shared = [[]] * 3
shared[0].append("!")
row("[[]] * 3, then [0].append('!')", repr(shared))
fresh = [[] for _ in range(3)]
fresh[0].append("!")
row("[[] for _ in range(3)], then the same", repr(fresh))
