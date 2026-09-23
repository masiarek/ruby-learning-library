# Python's indentation is grammar: mis-indented code does not compile, and the
# standard library ships `tabnanny` for the tab-versus-space case. Names are
# PEP 8 conventions with almost nothing enforced.
import subprocess
import sys
import tempfile
import typing
from pathlib import Path


def row(n, label, value):
    print(f"{n:2d}. {label:<46} {value}")


def run_child(*args, cwd):
    done = subprocess.run([sys.executable, "-I", *args], cwd=cwd, capture_output=True, text=True)
    return done.stdout.strip(), done.stderr.strip().splitlines()[-1:] or [""], done.returncode


with tempfile.TemporaryDirectory() as tmp:
    d = Path(tmp)
    (d / "mismatch.py").write_text("def greet(name):\n    if name:\n        print(name)\n      return\n")
    out, err, code = run_child("mismatch.py", cwd=tmp)
    row(1, "python3 mismatch.py (a dedent that matches nothing)", f"stdout {out!r}, exit {code}")
    print(f"       stderr: {err[0]}")

    (d / "unused.py").write_text("unused = 1\nprint('ok')\n")
    out, err, code = run_child("unused.py", cwd=tmp)
    row(2, "python3 unused.py (assigned, never read)", f"stdout {out!r}, stderr {err[0]!r}, exit {code}  (no lint in the stdlib)")

    (d / "tabs.py").write_text("if True:\n\tx = 1\n        y = 2\n")
    out, err, code = run_child("-m", "tabnanny", "tabs.py", cwd=tmp)
    row(3, "python3 -m tabnanny tabs.py (a tab line, a space line)", f"stdout {out!r}, exit {code}")
    out, err, code = run_child("tabs.py", cwd=tmp)
    print(f"       running it instead: exit {code}, stderr: {err[0]}")

    out, err, code = run_child("-m", "py_compile", "unused.py", cwd=tmp)
    row(4, "python3 -m py_compile unused.py (syntax check only)", f"stdout {out!r}, exit {code}")

    (d / "literal.py").write_text("s = 'lit'\ntry:\n    s[0] = 'L'\nexcept TypeError as e:\n    print(type(e).__name__)\n")
    out, err, code = run_child("literal.py", cwd=tmp)
    literal_row = f"{out}  (no magic comment needed or possible)"

try:
    compile("class parseError: pass", "<style>", "exec")
    named = "compiled (PEP 8 says CapWords; nothing enforces it)"
except SyntaxError as e:
    named = type(e).__name__
row(5, "class parseError: pass", named)

try:
    compile("def empty_bag?(): return True", "<style>", "exec")
    pred = "compiled"
except SyntaxError as e:
    pred = f"{type(e).__name__} (PEP 8 spells it is_empty)"
row(6, "def empty_bag?()  (a ? in a name)", pred)

MAX_RETRIES: typing.Final = 3
MAX_RETRIES = 4
row(7, "MAX_RETRIES: Final = 3; MAX_RETRIES = 4 ->", f"{MAX_RETRIES}  (UPPER_CASE is a convention; Final is for type checkers)")

one_line = [v * 2 for v in [1, 2, 3]]
long = []
for v in [1, 2, 3]:
    long.append(v * 2)
row(8, "comprehension on one line / for block over lines", f"{one_line!r} / {long!r}  (same result)")
row(9, "'lit'[0] = 'L'   (every str is immutable)", literal_row)


def describe(name):
    if not name:
        return "nobody"
    if len(name) > 5:
        return "too long"
    return f"hello, {name}"


print('10. guard clauses: describe(None) / describe("ann") / describe("jonathan")')
print(f"       {describe(None)!r} / {describe('ann')!r} / {describe('jonathan')!r}")
try:
    exec("def flat(x):\nif x:\nreturn 1\nreturn 2\n")
    flat_result = "ran"
except SyntaxError as e:
    flat_result = type(e).__name__
print(f"11. mis-indented code cannot run: exec of a def with every line at column 0 -> {flat_result}")
