"""Threads are OS threads that take turns under the GIL -- the Python twin.

Same rows, same order as the Ruby program. Python has no Thread#value, so a
result comes back through a list, a Queue or a Future; an exception in a thread
is not re-raised by join(), it goes to threading.excepthook.
"""
import queue
import subprocess
import sys
import threading
from concurrent.futures import ThreadPoolExecutor


def row(n, label, value):
    print(f"{n:2d}. {label:<52} {value}")


def in_thread(fn, *args):
    """Run fn in a thread, join it, and hand back what it returned."""
    box = []
    th = threading.Thread(target=lambda: box.append(fn(*args)))
    th.start()
    th.join()
    return box[0]


def main():
    # 1-3. Thread, start, join; a value needs a Future (or a list)
    t = threading.Thread(target=lambda: 1 + 1)
    t.start()
    row(1, "join returns", repr(t.join()))
    with ThreadPoolExecutor(max_workers=1) as ex:
        row(2, "no Thread.value: a Future's result()", repr(ex.submit(lambda: 1 + 1).result()))
    row(3, "after it ends: is_alive() / status", f"{t.is_alive()} / (no status attribute)")

    # 4. current_thread() and main_thread()
    inside = in_thread(lambda: threading.current_thread() is threading.main_thread())
    row(4, "current_thread() is main_thread(): outside / inside", f"{threading.current_thread() is threading.main_thread()} / {inside}")

    # 5. Each Python thread is an OS thread of its own
    row(5, "a new thread has its own get_native_id()", in_thread(threading.get_native_id) != threading.get_native_id())

    # 6. Threads share every object; nonlocal reaches the outer local
    x = 10

    def bump():
        nonlocal x
        x += 1

    in_thread(bump)
    row(6, "a thread did x += 1 on the outer local; x is now", x)

    # 7. Arguments are handed in through args=
    row(7, "Thread(target=add, args=(1, 2)) -> result", in_thread(lambda a, b: a + b, 1, 2))

    # 8-9. An exception ends the thread; join() does not re-raise it
    seen = []
    old_hook = threading.excepthook
    threading.excepthook = lambda args: seen.append(f"{args.exc_type.__name__}: {args.exc_value}")

    def boom():
        raise ValueError("boom")

    bad = threading.Thread(target=boom)
    bad.start()
    joined = bad.join()
    threading.excepthook = old_hook
    row(8, "join returns normally; excepthook got", f"{seen[0]} (join returned {joined!r})")
    row(9, "is_alive() after an exception", bad.is_alive())

    # 10. No status string: only is_alive()
    gate = threading.Event()
    sleeper = threading.Thread(target=gate.wait)
    sleeper.start()
    row(10, "a waiting thread / the current thread", f"is_alive() {sleeper.is_alive()} / (no status attribute)")
    gate.set()
    sleeper.join()

    # 11. The closest to Thread.pass; the GIL switch interval
    row(11, "time.sleep(0) is the hint; sys.getswitchinterval()", sys.getswitchinterval())

    # 12. Results from several threads: a Queue, then sort after joining
    q = queue.Queue()
    workers = [threading.Thread(target=lambda n: q.put((n, n * n)), args=(i,)) for i in range(3)]
    for w in workers:
        w.start()
    for w in workers:
        w.join()
    row(12, "results through a Queue, sorted after join", sorted(q.get() for _ in range(q.qsize())))

    # 13. When the main thread ends, Python WAITS for non-daemon threads (a child Python)
    code = 'import threading, time\nthreading.Thread(target=lambda: (time.sleep(1), print("worker done")), daemon={d}).start()\nprint("main done")'
    outs = [subprocess.run([sys.executable, "-I", "-c", code.format(d=d)], capture_output=True, text=True).stdout for d in (False, True)]
    row(13, "main ends -> child stdout: non-daemon / daemon=True", f"{outs[0]!r} / {outs[1]!r}")

    # 14. An unhandled exception in a thread is printed to stderr by the default excepthook
    code = 'import threading\ndef boom(): raise ValueError("boom")\nt = threading.Thread(target=boom); t.start(); t.join()'
    err = subprocess.run([sys.executable, "-I", "-c", code], capture_output=True, text=True).stderr
    row(14, "default excepthook -> child's stderr, line 1", repr(err.splitlines()[0]))


if __name__ == "__main__":
    main()
