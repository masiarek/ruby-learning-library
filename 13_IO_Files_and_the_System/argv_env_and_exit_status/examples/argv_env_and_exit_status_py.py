# The Python twin: sys.argv, __name__, os.environ and the return code, measured
# from the outside by running three small scripts as child Pythons.
import os
import subprocess
import sys
import tempfile

PY = sys.executable


def row(n, text, value=""):
    print(f"{n:2d}. {text:<50} {value}")


def run(*args, env=None, stdin=""):
    done = subprocess.run([PY, "-E", *args], capture_output=True, text=True, input=stdin, env={**os.environ, **(env or {})})
    return done.stdout.splitlines(), done.stderr.splitlines(), done.returncode


CHILD = '''
import os
import sys
def helper():
    return "helper from child.py"
print(f"__file__={os.path.basename(__file__)} sys.argv[0]={sys.argv[0]} __name__={__name__} main?={__name__ == '__main__'}")
if __name__ == "__main__":
    print(f"sys.argv={sys.argv!r} classes={[type(a).__name__ for a in sys.argv]}")
    print(f"os.environ.get('DEMO_X')={os.environ.get('DEMO_X')!r} os.environ.get('DEMO_MISSING')={os.environ.get('DEMO_MISSING')!r}")
    print(f"get with defaults: {os.environ.get('DEMO_X', 'd')!r} {os.environ.get('DEMO_MISSING', 'd')!r}")
    try:
        os.environ["DEMO_MISSING"]
    except KeyError as e:
        print(f"{type(e).__name__}: {e}")
    try:
        os.environ["N"] = 1
    except TypeError as e:
        print(type(e).__name__)
    print(f"type={type(os.environ).__name__} isinstance(dict)={isinstance(os.environ, dict)} dict(os.environ) is a {type(dict(os.environ)).__name__} iterable={hasattr(os.environ, '__iter__')}")
    sys.exit(2)
'''

MAIN = '''
import sys
import child
print(child.helper())
print(f"in main.py: sys.argv[0]={sys.argv[0]}")
'''

OPTS = '''
import argparse
parser = argparse.ArgumentParser(prog="opts.py")
parser.add_argument("file")
parser.add_argument("-n", "--count", type=int, default=1, help="How many times")
parser.add_argument("-v", "--verbose", action="store_true", help="Say more")
args = parser.parse_args()
print(f"count={args.count} verbose={args.verbose} file={args.file!r}")
'''

with tempfile.TemporaryDirectory() as d:
    os.chdir(d)
    for name, text in [("child.py", CHILD), ("main.py", MAIN), ("opts.py", OPTS)]:
        with open(name, "w") as f:
            f.write(text)

    out, _, code = run("child.py", "1", "two", env={"DEMO_X": "1"})
    row(1, "python child.py 1 two -- sys.argv holds strs", out[1])
    row(2, "  argv[0] is the script as invoked; __name__", out[0])
    row(3, "  os.environ.get gives a str or None", out[2])
    row(4, "  os.environ.get with a default", out[3])
    row(5, "  os.environ[] without one", out[4])
    row(6, "  os.environ values must be strs", out[5])
    row(7, "  os.environ is not a dict, but it is a Mapping", out[6])
    row(8, "  the child ran sys.exit(2): returncode, ok?", f"{code}, {code == 0}")
    row(9, "  the status is just an int", type(code).__name__)

    out, _, code = run("main.py")
    row(10, "python main.py, which imports child", out[0])
    row(11, "  the helper is defined, the guarded part did not run", f"{out[1]}; {out[2]}; exit={code}")

    _, _, code = run("-c", "import sys; sys.exit()")
    row(12, "sys.exit() with no argument", code)
    _, _, code = run("-c", "import sys; sys.exit(True)")
    row(13, "sys.exit(True) -- True is the int 1", code)
    _, _, code = run("-c", "import sys; sys.exit(False)")
    row(14, "sys.exit(False) -- False is the int 0", code)
    _, err, code = run("-c", "import sys; sys.exit('bye')")
    row(15, "sys.exit('bye'): status, and stderr", f"{code}, {err!r}")
    _, _, code = run("-c", "raise RuntimeError('boom')")
    row(16, "an uncaught exception", code)

    out, _, code = run("opts.py", "-n", "3", "--verbose", "in.txt")
    row(17, "argparse: -n 3 --verbose in.txt", f"{out[0]} exit={code}")
    _, err, code = run("opts.py", "--nope", "in.txt")
    row(18, "  an unknown option: exit, stderr starts with usage:", f"{code}, {err[0].startswith('usage:')}")
    _, err, code = run("opts.py", "-n", "x", "in.txt")
    row(19, "  a non-int for -n: exit, stderr starts with usage:", f"{code}, {err[0].startswith('usage:')}")
    out, _, code = run("opts.py", "-h")
    row(20, "  -h prints the generated help and exits", f"{code} (text differs between 3.12 and 3.14, so it is not shown)")
    os.chdir("/")
