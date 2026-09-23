# The Python twin: print, pprint and sys.stdout.write, each captured with
# contextlib.redirect_stdout so the row shows the exact characters written.
import contextlib
import io
import pprint
import sys


def row(n, text, value=""):
    print(f"{n:2d}. {text:<52} {value}")


def captured(fn):
    buf = io.StringIO()
    with contextlib.redirect_stdout(buf):
        result = fn()
    return buf.getvalue(), result


def out(fn):
    return captured(fn)[0]


class Foo:
    def __str__(self):
        return "Foo-str"

    def __repr__(self):
        return "Foo-repr"


row(1, 'print("a") writes', repr(out(lambda: print("a"))))
row(2, 'print("a\\n") adds its newline anyway', repr(out(lambda: print("a\n"))))
row(3, "print(1, 2) joins with sep=' ' on one line", repr(out(lambda: print(1, 2))))
row(4, "print([1, [2, 3]]) writes the list's repr", repr(out(lambda: print([1, [2, 3]]))))
row(5, "print(None) writes the word None", repr(out(lambda: print(None))))
row(6, "print([]) writes []", repr(out(lambda: print([]))))
row(7, "print() with no argument", repr(out(lambda: print())))
row(8, 'print("a", "b", sep="", end="") is Ruby\'s print', repr(out(lambda: print("a", "b", sep="", end=""))))
row(9, "print(None, 1.0, end='') uses str, None included", repr(out(lambda: print(None, 1.0, end=""))))
row(10, 'print(repr("s")) is the p spelling', repr(out(lambda: print(repr("s")))))
row(11, "print(repr(1), repr(2)) stays on one line", repr(out(lambda: print(repr(1), repr(2)))))
row(12, "  print returns", repr(captured(lambda: print(1, 2))[1]))
row(13, "  there is no p; repr(x) returns the string", repr(repr("s")))
row(14, "  print returns", repr(captured(lambda: print("x"))[1]))
row(15, "print(obj) uses str; print(repr(obj)) uses repr", f"{out(lambda: print(Foo()))!r}; {out(lambda: print(repr(Foo())))!r}")
row(16, 'f"{obj}" uses str; print([obj]) uses repr of each', f"{out(lambda: print(f'{Foo()}'))!r}; {out(lambda: print([Foo()]))!r}")
row(17, "print([obj]) uses repr of each element", repr(out(lambda: print([Foo()]))))

h = {"name": "Ada Lovelace", "languages": ["ruby", "python", "perl"], "address": {"city": "London", "country": "United Kingdom"}, "notes": "a fairly long string to push past eighty columns"}
row(18, "print(h) writes one line, this long", len(out(lambda: print(h))))
row(19, "pprint(h, sort_dicts=False) wraps at 80, in order:")
pprint.pprint(h, sort_dicts=False)
row(20, "  pprint(h) default sort_dicts=True: first line", out(lambda: pprint.pprint(h)).splitlines()[0])
row(21, "  pprint returns", repr(captured(lambda: pprint.pprint(h))[1]))
row(22, "sys.stdout.write('caf\\N{...}\\n') returns characters", captured(lambda: sys.stdout.write("caf\N{LATIN SMALL LETTER E WITH ACUTE}\n"))[1])
row(23, "sys.stdout.write takes one string, not several", captured(lambda: sys.stdout.write("ab" + "cd\n"))[1])
row(24, 'print("%05.1f|%s" % (3.14159, "x")) is format + write', repr(out(lambda: print("%05.1f|%s" % (3.14159, "x")))))
row(25, "no << on streams: write returns an int, no chain", "n/a")

buf = io.StringIO()
with contextlib.redirect_stderr(buf):
    print("to stderr", file=sys.stderr)
    print("warned", "twice", file=sys.stderr)
errs = buf.getvalue()
row(26, "print(file=sys.stderr) is the spelling of both", repr(errs))
row(27, "  several arguments stay on one line, like print", len(errs.splitlines()))
