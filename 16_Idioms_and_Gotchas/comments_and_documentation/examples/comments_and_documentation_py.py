# Python comments: `#` only. There is no block comment (a bare triple-quoted
# string is an expression statement), no data section, and documentation is
# a docstring the running program can read back.
import ast
import subprocess
import sys
import tempfile
from pathlib import Path


def row(n, label, value):
    print(f"{n:2d}. {label:<46} {value}")


def run_child(*args, cwd):
    done = subprocess.run([sys.executable, "-I", *args], cwd=cwd, capture_output=True, text=True)
    return done.stdout.strip(), done.stderr.strip().splitlines()[-1:] or [""], done.returncode


x = 1  # a trailing comment; the assignment before it ran
row(1, "x = 1  # trailing comment", f"x = {x}")

"""
x = 2
this is a bare triple-quoted string, not a comment: it is evaluated and dropped
"""
node = ast.parse('"""x = 2"""').body[0]
row(2, '""" ... """ around x = 2', f"x = {x}  (still 1: the string is an {type(node).__name__} statement, its value a {type(node.value).__name__})")

with tempfile.TemporaryDirectory() as tmp:
    d = Path(tmp)
    (d / "begin.py").write_text("x = 1\n=begin\nx = 2\n=end\nprint(x)\n")
    out, err, code = run_child("begin.py", cwd=tmp)
    row(3, "=begin ... =end in a Python file", f"exit {code}, {err[0].split(':')[0]}")

    (d / "literal.py").write_text("print(type('lit'), 'lit' is 'lit'.__str__())\n")
    row(4, "no frozen-literal comment: str is immutable", "hasattr(str, '__setitem__') is " + str(hasattr(str, "__setitem__")))

    (d / "latin.py").write_bytes(b"# coding: latin-1\ns = 'caf\xe9'\nprint(len(s), len(s.encode('latin-1')))\n")
    out, err, code = run_child("latin.py", cwd=tmp)
    (d / "nocoding.py").write_bytes(b"s = 'caf\xe9'\nprint(len(s))\n")
    out2, err2, code2 = run_child("nocoding.py", cwd=tmp)
    row(5, "# coding: latin-1, then 'caf' + byte e9 / without it", f"{out.replace(' ', ' / ')}  (length / bytes) / exit {code2}, {err2[0].split(':')[0]}")

    (d / "end.py").write_text("x = 1\n__END__\nline one\n")
    out, err, code = run_child("end.py", cwd=tmp)
    row(6, "__END__ in a Python file", f"exit {code}, {err[0].split(':')[0]}  (no data section: use a string or a file)")

    (d / "shebang.py").write_text("#!/usr/bin/env python3\nprint('the shebang line is a comment')\n")
    row(7, "#!/usr/bin/env python3 as line 1", run_child("shebang.py", cwd=tmp)[0])


def documented(a):
    """Return a unchanged; this docstring is the documentation."""
    return a


row(8, "documented.__doc__", repr(documented.__doc__))


def double(value):  # type: (int) -> int   <- a type comment, ignored at runtime
    return value * 2


row(9, "# type: comment above; double(4), __annotations__", f"{double(4)}  {double.__annotations__!r}  (a type comment is an ordinary comment)")
