# Python's REPL is the same loop: a child `python3 -q -i` fed through a pipe
# prints expression values to stdout and its prompts to stderr, and
# code.InteractiveConsole is that loop as an object, usable in-process.
import builtins
import code
import contextlib
import io
import subprocess
import sys


def repl_session(text):
    return subprocess.run([sys.executable, "-q", "-i", "-c", "pass"], input=text,
                          capture_output=True, text=True)


def transcript(n, title, text):
    done = repl_session(text)
    print(f"{n}. {title}")
    for line in text.splitlines():
        print(f"   in:  {line}".rstrip())
    for line in done.stdout.splitlines():
        print(f"   out: {line}")
    prompts = done.stderr.count(">>> ")
    other = done.stderr.replace(">>> ", "").replace("... ", "").strip()
    print(f"   stderr: {prompts} prompts" + (f", and: {other.splitlines()[-1]}" if other else "")
          + f"   exit: {done.returncode}")


transcript(1, "every expression's value is echoed, one per line:",
           "1 + 1\nx = 2\nx * 3\n_\n[v * 2 for v in [1, 2]]\nprint('side effect')\nNone\n"
           "def f(x): return x * 2\n\nf(21)\n")
transcript(2, "an error is printed (to stderr) and the session goes on:", "1 / 0\n'after'\n")
print("3. no --noecho flag: a script (python3 file.py) is the mode that never echoes")
transcript(4, "exit() ends the session; later lines are never read:",
           "print('before')\nexit()\nprint('never')\n")

print("5. the same loop in-process, code.InteractiveConsole:")
console = code.InteractiveConsole()
for src in ["1 + 1", "y = 5", "y * 2", "_", "def g():"]:
    shown = io.StringIO()
    with contextlib.redirect_stdout(shown):
        more = console.push(src)
    print(f"   push {src!r:10} -> printed: {shown.getvalue().strip()!r:6}   needs more input: {more}")
print(f"   _ lives in builtins: {hasattr(builtins, '_')}   value: {builtins._}")
