# The Python twin: subprocess.run, Popen, check_output and os.system, asked the
# same nineteen questions. Child Pythons start from sys.executable.
import os
import subprocess
import sys
import tempfile

PY = sys.executable


def row(n, text, value=""):
    print(f"{n:2d}. {text:<54} {value}")


def run(*args, **kw):
    return subprocess.run(list(args), capture_output=True, text=True, **kw)


with tempfile.TemporaryDirectory() as d:
    os.chdir(d)
    open("a.txt", "w").close()
    open("b.txt", "w").close()

    r = run(PY, "-c", "raise SystemExit(0)")
    row(1, "run([py, '-c', 'exit 0']).returncode; == 0", f"{r.returncode}; {r.returncode == 0}")
    r = run(PY, "-c", "raise SystemExit(2)")
    row(2, "run([py, '-c', 'exit 2']).returncode; == 0", f"{r.returncode}; {r.returncode == 0}")
    try:
        run("definitely_not_a_command_xyz")
    except OSError as e:
        row(3, "run(['definitely_not_a_command_xyz']) raises", type(e).__name__)

    r = run("echo", "hello")
    row(4, "run(['echo', 'hello'], capture_output=True).stdout", f"{r.stdout!r}; {r.returncode == 0}")
    row(5, "check_output(['echo', 'hi', 'there'], text=True)", repr(subprocess.check_output(["echo", "hi", "there"], text=True)))
    row(6, "shell=True goes through /bin/sh: 'echo *' expands", repr(subprocess.run("echo *", shell=True, capture_output=True, text=True).stdout))
    row(7, "a list skips the shell: run(['echo', '*'])", repr(run("echo", "*").stdout))

    p = subprocess.Popen([PY, "-c", "raise SystemExit(4)"])
    code = p.wait()
    row(8, "Popen gives an object with a pid; wait() returns", f"{type(p.pid).__name__}; {code}")
    p = subprocess.Popen([PY, "-c", "raise SystemExit(5)"])
    p.wait()
    row(9, "after wait(), Popen.returncode holds it", f"pid matches: {p.pid == p.pid}; {p.returncode}")

    r = run(PY, "-c", "import sys; print('out'); print('err', file=sys.stderr); sys.exit(3)")
    row(10, "run(capture_output=True): stdout, stderr, returncode", f"{r.stdout!r}, {r.stderr!r}, {r.returncode}")
    r = subprocess.run([PY, "-c", "import sys; print('out'); print('err', file=sys.stderr)"], stdout=subprocess.PIPE, stderr=subprocess.STDOUT, text=True)
    row(11, "stderr=STDOUT merges; a piped stdout is buffered, so", repr(r.stdout))
    r = subprocess.run([PY, "-c", "import sys; print('out', flush=True); print('err', file=sys.stderr)"], stdout=subprocess.PIPE, stderr=subprocess.STDOUT, text=True)
    row(12, "  with flush=True in the child", repr(r.stdout))

    r = run(PY, "-c", "print(1); print(2)")
    row(13, "run(...).stdout.splitlines(keepends=True)", r.stdout.splitlines(keepends=True))
    p = subprocess.Popen([PY, "-c", "import sys; print(sys.stdin.read().upper())"], stdin=subprocess.PIPE, stdout=subprocess.PIPE, text=True)
    out, _ = p.communicate("abc")
    row(14, "Popen(stdin=PIPE, stdout=PIPE).communicate('abc')", repr(out))
    r = run(PY, "-c", "import sys; print(repr(sys.stdin.read()))", input="fed")
    row(15, "run(input='fed') feeds the child", repr(r.stdout))
    r = run(PY, "-c", "import os; print(os.environ['GREETING'])", env={**os.environ, "GREETING": "hi"})
    row(16, "env={**os.environ, ...} is the child's whole environment", repr(r.stdout))

    r = run(PY, "-c", "import os; os.execvp('echo', ['echo', 'replaced']); print('never')")
    row(17, "os.execvp replaces the process: nothing after it runs", repr(r.stdout))
    try:
        subprocess.run([PY, "-c", "raise SystemExit(2)"], check=True)
    except subprocess.CalledProcessError as e:
        row(18, "run(check=True) raises on failure", f"{type(e).__name__} returncode={e.returncode}")
    status = os.system("exit 5")
    row(19, "os.system returns a wait status; waitstatus_to_exitcode", f"{status}; {os.waitstatus_to_exitcode(status)}")
    os.chdir("/")
