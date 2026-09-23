# exit_at_exit_and_system_exit_py.py -- the same nine rows put to Python through child
# interpreters (sys.executable -I -c ...): sys.exit raises SystemExit, except Exception
# misses it, exit codes (True is 1), atexit in reverse, os._exit skipping it,
# sys.exit("msg") as abort, an uncaught exception's status, KeyboardInterrupt.
# Only the last line of a child's stderr is printed: CPython's traceback layout
# differs between 3.12 and 3.14, its last line does not.

import atexit
import subprocess
import sys

atexit.register(lambda: print("9. this program's own atexit handler prints last"))


def child(label, code):
    done = subprocess.run([sys.executable, "-I", "-c", code], capture_output=True, text=True)
    print(f"   {label}")
    for line in done.stdout.splitlines():
        print(f"      stdout: {line}")
    err = done.stderr.splitlines()
    if err:
        print(f"      stderr (last line): {err[-1]}")
    how = f"killed by signal {-done.returncode}" if done.returncode < 0 else f"exit status {done.returncode}"
    print(f"      {how}")


print("1. sys.exit raises SystemExit, which a handler can catch")
child('try: sys.exit() except SystemExit as e: ...; print("still running")',
      'import sys\ntry:\n    sys.exit()\nexcept SystemExit as e:\n    print(f"caught {type(e).__name__}: code {e.code!r}")\nprint("still running")')

print("2. except Exception does not see it")
child('try: sys.exit(3) except Exception: print("caught"); print("after")',
      'import sys\ntry:\n    sys.exit(3)\nexcept Exception:\n    print("caught")\nprint("after")')

print("3. the exit status: an Integer -- and True is 1, False is 0")
child("sys.exit(3)", "import sys; sys.exit(3)")
child("sys.exit(True)", "import sys; sys.exit(True)")
child("sys.exit(False)", "import sys; sys.exit(False)")

print("4. atexit handlers run in reverse order of registration")
child('three atexit.register calls, then print("main done")',
      'import atexit\nfor name in ("first", "second", "third"):\n    atexit.register(lambda name=name: print(name, "registered"))\nprint("main done")')

print("5. os._exit skips them")
child('atexit.register(...); os._exit(4)', 'import atexit, os; atexit.register(lambda: print("atexit ran")); os._exit(4)')

print("6. sys.exit with a string writes it to stderr, runs atexit, and exits 1")
child('atexit.register(...); sys.exit("fatal: giving up")', 'import atexit, sys; atexit.register(lambda: print("atexit ran")); sys.exit("fatal: giving up")')

print("7. an uncaught exception prints a traceback and exits 1; atexit still runs, but sys.exception() is gone")
child('atexit.register(...); print("before"); raise RuntimeError("boom")',
      'import atexit, sys; atexit.register(lambda: print("atexit sees sys.exception():", sys.exception())); print("before"); raise RuntimeError("boom")')

print("8. KeyboardInterrupt is a BaseException; an uncaught one ends the process by the signal")
child("raise KeyboardInterrupt, caught as BaseException",
      'try:\n    raise KeyboardInterrupt\nexcept BaseException as e:\n    print(f"{type(e).__name__} < {type(e).__mro__[1].__name__}")')
child("a real SIGINT, not caught: os.kill(os.getpid(), signal.SIGINT); time.sleep(5)",
      'import os, signal, time; os.kill(os.getpid(), signal.SIGINT); time.sleep(5); print("never")')
child("a real SIGINT, caught as KeyboardInterrupt",
      'import os, signal, time\ntry:\n    os.kill(os.getpid(), signal.SIGINT); time.sleep(5)\nexcept KeyboardInterrupt as e:\n    print(f"caught {type(e).__name__}")')
