"""A Python str is immutable: the twin of strings_are_mutable_rb.rb.

+= always rebinds, nothing edits in place, and the mutable routes are
bytearray, io.StringIO and a list of characters joined at the end. The rows
follow the Ruby program's numbering.
"""
import io
import sys


def row(label, shown):
    print(f"   {label:<48} {shown}")


print("1. no <<; += makes a new string")
s = "abc"
before = s
s += "d"
row('s = "abc"; before = s; s += "d"; s', repr(s))
row("s is before", repr(s is before))
s += "e"
row('s += "e"; s', repr(s))
row("s is before", repr(s is before))
row("before", repr(before))

print("2. every str method returns a copy; none ends in !")
v = "abc"
w = v.upper()
row('v = "abc"; w = v.upper(); v', repr(v))
row("w.upper() is w", repr(w.upper() is w))
row('[m for m in dir(str) if m.endswith("!")]', repr([m for m in dir(str) if m.endswith("!")]))
row("w", repr(w))
row("w is v", repr(w is v))

print("3. no editing in place: every step rebinds")
t = "abc"
try:
    t[0] = "X"
except TypeError as e:
    row('t = "abc"; t[0] = "X"', type(e).__name__)
t = "X" + t[1:]
row('t = "X" + t[1:]', repr(t))
t = t[:1] + "-" + t[1:]
row('t = t[:1] + "-" + t[1:]', repr(t))
t = t.replace("b", "B")
row('t = t.replace("b", "B")', repr(t))
t = "new"
row('t = "new"', repr(t))

print("4. a literal is immutable, like every str")
row('type("a").__name__', type("a").__name__)
lit = "lit"
lit += "!"
row('lit = "lit"; lit += "!"; lit  (a new object)', repr(lit))
row('hasattr(str, "__iadd__")  (so += rebinds)', repr(hasattr(str, "__iadd__")))
row('sys.intern("a") is sys.intern("a")  (like -"a")', repr(sys.intern("a") is sys.intern("a")))
row('hasattr(str, "__setitem__")', repr(hasattr(str, "__setitem__")))

print("5. building a string: the mutable routes")
buf = io.StringIO()
buf.write("a")
buf.write("b")
row('buf = io.StringIO(); write("a"); write("b")', repr(buf.getvalue()))
ba = bytearray(b"x")
for _ in range(5):
    ba += b"x"
row('ba = bytearray(b"x"); 5 times ba += b"x"', repr(ba.decode()))
row('"".join(["a", "b", "c"])', repr("".join(["a", "b", "c"])))
chars = list("abc")
chars[0] = "X"
row('chars = list("abc"); chars[0] = "X"; join', repr("".join(chars)))

print("6. what immutability buys: a str key needs no copying")
key = "key"
d = {key: 1}
row('key = "key"; d = {key: 1}', repr(d))
row("next(iter(d)) is key  (the very object)", repr(next(iter(d)) is key))
try:
    {bytearray(b"key"): 1}
except TypeError as e:
    row("{bytearray(b'key'): 1}  (a mutable key)", type(e).__name__)
key += "!"
row('key += "!"; d["key"]  (key was rebound)', repr(d["key"]))
