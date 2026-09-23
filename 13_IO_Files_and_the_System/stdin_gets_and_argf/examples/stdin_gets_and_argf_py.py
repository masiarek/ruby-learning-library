# The Python twin: input(), sys.stdin and fileinput, measured through child
# Pythons fed with subprocess.run(input=...).
import os
import subprocess
import sys
import tempfile

PY = sys.executable


def row(n, text, value=""):
    print(f"{n:2d}. {text:<56} {value}")


def child(code, *args, stdin=""):
    done = subprocess.run([PY, "-I", "-c", code, *args], capture_output=True, text=True, input=stdin)
    return done.stdout.rstrip("\n")


with tempfile.TemporaryDirectory() as d:
    os.chdir(d)
    with open("a.txt", "w") as f:
        f.write("a1\na2\n")
    with open("b.txt", "w") as f:
        f.write("b1\n")

    row(1, "input() returns the next line, newline stripped", child("print(repr(input()))", stdin="first\nsecond\n"))
    row(2, "input() three times on two lines: EOFError at EOF", child("r = []\ntry:\n    for _ in range(3): r.append(input())\nexcept EOFError as e: r.append(type(e).__name__)\nprint(r)", stdin="first\nsecond\n"))
    row(3, "so there is no None to call a method on; input() raises", child("try: input().strip()\nexcept EOFError as e: print(type(e).__name__)"))
    row(4, "  sys.stdin.readline() returns '' at EOF instead", child("import sys; print([sys.stdin.readline(), sys.stdin.readline()])"))
    row(5, "for line in sys.stdin is the read loop", repr(child("import sys\nfor line in sys.stdin: print(line.upper(), end='')", stdin="x\ny\n")))
    row(6, "  the same loop, another body", repr(child("import sys\nfor l in sys.stdin: print(l.rstrip('\\n')[::-1])", stdin="abc\ndef\n")))
    row(7, "readlines() keeps newlines; read().splitlines() strips", f"{child('import sys; print(sys.stdin.readlines())', stdin='x' + chr(10) + 'y' + chr(10))}; {child('import sys; print(sys.stdin.read().splitlines())', stdin='x' + chr(10) + 'y' + chr(10))}")
    row(8, "sys.stdin.read(3) takes three characters; read() the rest", child("import sys; print([sys.stdin.read(3), sys.stdin.read()])", stdin="abcdef"))
    row(9, "input() at EOF raises, like Ruby's readline", child("try: input()\nexcept EOFError as e: print(type(e).__name__)"))
    row(10, "no paragraph mode: read().split('\\n\\n') is the idiom", child("import sys; print(sys.stdin.read().split('\\n\\n', 1))", stdin="p1\nl2\n\n\np2\nrest"))

    row(11, "python -c 'print(input())' a.txt reads STDIN anyway", child("print(repr(input()))", "a.txt", stdin="from stdin\n"))
    row(12, "  sys.stdin.readline() too; argv is never a file to it", child("import sys; print(repr(sys.stdin.readline()))", "a.txt", stdin="from stdin\n"))
    row(13, "  fileinput.input() is ARGF: it joins argv's files", child("import fileinput; print(repr(''.join(fileinput.input())))", "a.txt", "b.txt", stdin="from stdin\n"))
    row(14, "  sys.argv before and after: fileinput leaves it alone", child("import fileinput, sys; before = list(sys.argv[1:]); list(fileinput.input()); print([before, sys.argv[1:]])", "a.txt", "b.txt"))
    row(15, "fileinput.filename(), lineno() (total), filelineno() (per file):")
    for line in child("import fileinput\nfor l in fileinput.input(): print(f'{fileinput.filename()}:{fileinput.lineno()}:{fileinput.filelineno()}: {l}', end='')", "a.txt", "b.txt").splitlines():
        print(f"      {line}")
    row(16, "with argv empty, fileinput reads stdin; filename() is", child("import fileinput; lines = list(fileinput.input()); print([''.join(lines), fileinput.filename()])", stdin="from stdin\n"))
    row(17, "a bare '-' in argv means stdin", child("import fileinput; print(repr(next(iter(fileinput.input()))))", "-", stdin="dash means stdin\n"))
    row(18, "a name in argv that does not exist", child("import fileinput\ntry: list(fileinput.input())\nexcept OSError as e: print(type(e).__name__)", "nope.txt"))
    row(19, "sys.stdin.isatty() when fed by a pipe, as here", child("import sys; print(sys.stdin.isatty())"))
    row(20, "no eof(): readline() twice on one line", child("import sys; print([sys.stdin.readline(), sys.stdin.readline()])", stdin="only\n"))
    row(21, "sys.stdin is sys.__stdin__; its type", child("import sys; print([sys.stdin is sys.__stdin__, type(sys.stdin).__name__])"))
    os.chdir("/")
