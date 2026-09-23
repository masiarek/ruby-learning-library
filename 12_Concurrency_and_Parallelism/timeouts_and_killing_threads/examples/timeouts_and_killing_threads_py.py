"""No thread can be interrupted from outside -- the Python twin.

Python has no Timeout.timeout, no Thread.kill, no Thread.raise and no wakeup.
A *wait* can have a timeout -- Future.result, Thread.join, Event.wait,
Queue.get -- and when it runs out the caller moves on while the worker keeps
running; a worker stops only when it checks a flag. Limits are 0.2 s against
5 s waits, and every worker is released before the program ends.
"""
import concurrent.futures
import queue
import threading
from concurrent.futures import ThreadPoolExecutor


def row(n, label, value):
    print(f"{n:2d}. {label:<52} {value}")


def main():
    # 1-3. A Future with a timeout; no watcher thread, only the pool's worker
    row(1, "threads before any timeout (names)", [t.name for t in threading.enumerate()])
    pool = ThreadPoolExecutor(max_workers=1)
    stop = threading.Event()
    fut = pool.submit(stop.wait, 5)
    try:
        fut.result(timeout=0.2)
    except TimeoutError as e:
        row(2, "future.result(timeout=0.2) on a 5 s wait", f"{type(e).__name__}; the task is still running: {fut.running()}")
    stop.set()
    fut.result()
    row(3, "after: no watcher, only the pool's worker (names)", [t.name for t in threading.enumerate()])

    # 4-6. In time, no limit, no custom error
    row(4, "a task that finishes in time returns its value", repr(pool.submit(lambda: "fast").result(timeout=1)))
    stop2 = threading.Event()
    running = pool.submit(stop2.wait, 5)
    try:
        running.result(timeout=0)
    except TimeoutError as e:
        at_once = type(e).__name__
    stop2.set()
    row(5, "result(timeout=None) waits / timeout=0 gives up at once", f"{running.result(timeout=None)} / {at_once}")
    row(6, "your own class and message?", f"no: always TimeoutError (futures.TimeoutError is TimeoutError: {concurrent.futures.TimeoutError is TimeoutError})")

    # 7. The task is never interrupted: finally runs only when its wait ends
    seen = []
    stop3 = threading.Event()

    def task():
        try:
            stop3.wait(5)
            seen.append("inside: the wait ended normally")
        finally:
            seen.append("inside: finally ran")

    f7 = pool.submit(task)
    try:
        f7.result(timeout=0.2)
    except TimeoutError:
        seen.append("outside: TimeoutError, task still running")
    stop3.set()
    f7.result()
    row(7, "what the task sees / what the caller sees", seen)

    # 8-9. TimeoutError is an OSError; a busy loop stops only when it checks a flag
    row(8, "TimeoutError's bases", [c.__name__ for c in TimeoutError.__mro__[:3]])
    flag = threading.Event()

    def busy():
        n = 0
        while not flag.is_set():
            n += 1
        return "stopped when it saw the flag"

    f9 = pool.submit(busy)
    try:
        f9.result(timeout=0.2)
    except TimeoutError:
        pass
    flag.set()
    row(9, "a busy loop cannot be interrupted; it checks a flag", f9.result())

    # 10. No kill: a daemon thread is simply abandoned at exit
    row(10, "Thread.kill exists? / the alternative", f"{hasattr(threading.Thread, 'kill')} / daemon=True threads die with the process")

    # 11. join with a limit
    gate = threading.Event()
    t2 = threading.Thread(target=gate.wait, args=(5,))
    t2.start()
    row(11, "join(0.2) on a 5 s thread / is_alive()", f"{t2.join(0.2)!r} / {t2.is_alive()}")
    gate.set()
    t2.join()

    # 12-13. Event.wait is the wakeup: it returns False on timeout, True when set
    ev = threading.Event()
    before = ev.wait(0.2)
    ev.set()
    row(12, "Event.wait(0.2) before set / after set", f"{before} / {ev.wait(0.2)}")
    ev2 = threading.Event()
    box = []
    t3 = threading.Thread(target=lambda: box.append(ev2.wait(5)))
    t3.start()
    ev2.set()
    t3.join()
    row(13, "no Thread.run: time.sleep(5) cannot be cut short; Event.wait(5) can", f"returned {box[0]} once set")

    # 14. No Thread.raise
    row(14, "Thread.raise exists?", f"{hasattr(threading.Thread, 'raise')} (PyThreadState_SetAsyncExc is the C-level hack)")

    # 15. The safe kind of timeout: one built into the wait
    try:
        queue.Queue().get(timeout=0.2)
    except queue.Empty as e:
        row(15, "queue.get(timeout=0.2) on an empty queue", type(e).__name__)
    pool.shutdown()


if __name__ == "__main__":
    main()
