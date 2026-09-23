# The same questions put to a child Python (sys.executable): which flag does
# the job Ruby's flag does, and which letters mean something else entirely.
import os
import subprocess
import sys
import tempfile

PY = sys.executable


def quote(arg):
    if not any(c in arg for c in " \"'|$"):
        return arg
    return f'"{arg}"' if "'" in arg else f"'{arg}'"


def show(n, *args, stdin=None, d=None, env=None):
    done = subprocess.run([PY, *args], input=stdin, capture_output=True, text=True, env=env)
    shown = " ".join(quote(a) for a in args)
    if d:
        shown = shown.replace(d, "DIR")
    print(f"{n:2d}. python3 {shown}")
    if stdin is not None:
        print(f"    stdin:  {stdin!r}")
    out, err = done.stdout, done.stderr
    if d:
        out, err = out.replace(d, "DIR"), err.replace(d, "DIR")
    if out:
        print("    stdout: " + " | ".join(out.splitlines()))
    if err:
        print("    stderr: " + " | ".join(err.splitlines()[-1:]) + "   (last line only)")
    print(f"    exit:   {done.returncode}")
    return out, err, done.returncode


with tempfile.TemporaryDirectory() as d:
    ok = os.path.join(d, "ok.py")
    bad = os.path.join(d, "bad.py")
    lib = os.path.join(d, "lib")
    os.mkdir(lib)
    with open(ok, "w") as f:
        f.write("x = 1\nprint(x)\n")
    with open(bad, "w") as f:
        f.write("def f(\n")
    with open(os.path.join(lib, "helper2.py"), "w") as f:
        f.write("print('helper2 here')\n")

    show(1, "-c", "print(1 + 1)")
    show(2, "-m", "py_compile", ok, d=d)
    _, err, _ = show(2, "-m", "py_compile", bad, d=d)
    print(f"    (stderr mentions 'SyntaxError': {'SyntaxError' in err})")
    show(3, "-W", "error", "-c", "import warnings; warnings.warn('careful')")
    show(3, "-c", "import warnings; warnings.warn('careful')")
    show(4, "-X", "dev", "-c", "import sys; print(sys.flags.dev_mode)")
    show(4, "-W", "ignore", "-c", "import warnings; warnings.warn('careful'); print('silenced')")
    show(4, "-c", "import sys; print(sys.flags.dev_mode)")
    show(5, "-m", "json.tool", "--compact", stdin='[1, {"a": 2}]')
    show(6, "-I", "-c", "import sys; print('isolated:', sys.flags.isolated, 'safe_path:', sys.flags.safe_path)")
    show(6, "-c", "import helper2", env={**os.environ, "PYTHONPATH": lib}, d=d)
    print("    (the include-directory job is PYTHONPATH=DIR/lib, not a flag)")
    show(7, "-c", "import sys\nfor line in sys.stdin: print(line.rstrip().upper())", stdin="ab\ncd\n")
    print("    (no -n, -p, -a or -l: the loop is written out)")
    show(8, "-X", "utf8", "-c", "import sys; print(sys.flags.utf8_mode)")
    show(8, "-c", "import sys; print(sys.stdout.encoding)")
    show(9, "-O", "-c", "print(__debug__)")
    show(9, "-c", "print(__debug__)")
    print("    (no JIT switch in 3.12; -X jit exists only in later builds made with it)")
    show(10, "-S", "-c", "import sys; print(sys.flags.no_site, 'site' in sys.modules)")
    show(10, "-c", "import sys; print(sys.flags.no_site, 'site' in sys.modules)")
    show(11, "-OO", "-c", "import json; print(json.dumps.__doc__ is None)")
    show(11, "-c", "import json; print(json.dumps.__doc__ is None)")
    show(12, "-c", "print(3000 in compile('a = 1000 + 2000', '', 'exec').co_consts)")
    print("    (the compiler folded 1000 + 2000; -m dis shows the bytecode, whose text changes per release)")
    out = subprocess.run([PY, "-V"], capture_output=True, text=True).stdout
    print(f"13. python3 -V   -> starts with 'Python 3.': {out.startswith('Python 3.')}")
    out = subprocess.run([PY, "-h"], capture_output=True, text=True).stdout
    print(f"13. python3 -h   -> first line starts with 'usage:': {out.splitlines()[0].startswith('usage:')}")
    show(14, "-c", "import sys; print(sys.argv)", "-x", "y")
    show(15, "-s", "-c", "import sys; print('no_user_site:', sys.flags.no_user_site)")
    print("    (-s means 'no user site-packages' here; Ruby's -s parses -flag=value switches)")
