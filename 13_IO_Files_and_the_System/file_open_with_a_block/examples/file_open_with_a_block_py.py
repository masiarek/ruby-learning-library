# The Python twin: `with open() as f` closes the file for you. Same rows, same
# order, inside a temporary directory that is removed at the end.
import os
import sys
import tempfile
from pathlib import Path


def row(n, text, value=""):
    print(f"{n:2d}. {text:<58} {value}")


with tempfile.TemporaryDirectory() as d:
    os.chdir(d)
    with open("notes.txt", "w") as f:
        print("one", file=f)
    row(1, "with open() as f: f.closed afterwards", f.closed)
    row(2, "  a with statement has no value (it is a statement)", "n/a")

    row(3, "Path.write_text returns what it wrote, in characters", Path("a.txt").write_text("x\ny\n"))
    row(4, "Path.read_text gives the whole file as one str", repr(Path("a.txt").read_text()))
    with open("a.txt") as f:
        row(5, "f.readlines() keeps each newline", f.readlines())
    row(6, "read().splitlines() drops them", Path("a.txt").read_text().splitlines())
    lines = []
    with open("a.txt") as f:
        for line in f:
            lines.append(line)
    row(7, "for line in f yields one line at a time", " then ".join(repr(l) for l in lines))
    with open("a.txt") as f:
        row(8, "[line.rstrip('\\n') for line in f] inside the with", [line.rstrip("\n") for line in f])

    with open("a.txt", "a") as f:
        f.write("z\n")
    row(9, 'mode "a" appends', repr(Path("a.txt").read_text()))
    with open("a.txt", "w") as f:
        print("fresh", file=f)
    row(10, 'mode "w" truncates first', repr(Path("a.txt").read_text()))
    with open("a.txt", "r+") as f:
        f.write("F")
        f.seek(0)
        row(11, 'mode "r+" reads and writes in place', repr(f.read()))
    try:
        with open("a.txt", "x"):
            pass
    except OSError as e:
        row(12, 'mode "x" (exclusive create) exists and raises', type(e).__name__)
    row(13, "  os.O_CREAT | os.O_EXCL is the flag form of the same idea", "os.open")

    row(14, "os.path.exists for a file that is there / not there", [os.path.exists("a.txt"), Path("nope.txt").exists()])
    try:
        Path("nope.txt").read_text()
    except OSError as e:
        row(15, "reading a missing file raises", f"{type(e).__name__}: {e.strerror} - {e.filename}")

    f = open("a.txt")
    row(16, "without a with the file stays open: closed", f.closed)
    first = f.readline()
    f.close()
    row(17, "  after readline and close: line, closed", f"{first!r}, {f.closed}")
    try:
        f.readline()
    except ValueError as e:
        row(18, "  reading a closed file", type(e).__name__)

    Path("u.txt").write_text("caf\N{LATIN SMALL LETTER E WITH ACUTE}\n", encoding="utf-8")
    with open("u.txt") as f:
        text = f.read()
        row(19, "default encoding (UTF-8 mode via the C locale): read gives", f"{text!r} {f.encoding.lower()} len={len(text)} bytes={len(text.encode())} utf8_mode={sys.flags.utf8_mode}")
    latin = Path("u.txt").read_text(encoding="latin-1")
    row(20, 'encoding="latin-1" decodes the same bytes differently', f"latin-1 len={len(latin)}")
    data = Path("u.txt").read_bytes()
    row(21, 'mode "rb" gives bytes, a different type', f"{type(data).__name__} len={len(data)}")
    row(22, "write_text counts characters, so 'caf\\N{...}\\n' is", Path("u2.txt").write_text("caf\N{LATIN SMALL LETTER E WITH ACUTE}\n", encoding="utf-8"))

    Path("crlf.txt").write_bytes(b"a\r\nb\n")
    row(23, "CRLF file, text mode translates \\r\\n to \\n", repr(Path("crlf.txt").read_text()))
    row(24, "  newline='' keeps the \\r; splitlines() strips both", f"{open('crlf.txt', newline='').read()!r} {Path('crlf.txt').read_text().splitlines()}")
    row(25, "the temp directory still exists inside the with", os.path.exists(d))
    os.chdir("/")
row(26, "and is gone after it", os.path.exists(d))
