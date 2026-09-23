"""Lock guards, Queue hands over, Condition waits -- the Python twin.

Same rows, same order as the Ruby program: a Lock has no owner and is not
re-entrant (RLock is), queue.Queue has no close in 3.12 so a sentinel ends the
consumer, and Condition.wait_for is the loop Ruby writes by hand.
"""
import queue
import threading
import time


def row(n, label, value):
    print(f"{n:2d}. {label:<52} {value}")


def main():
    # 1. A Lock makes `count += 1` exact
    lock = threading.Lock()
    count = 0

    def bump():
        nonlocal count
        for _ in range(1000):
            with lock:
                count += 1

    threads = [threading.Thread(target=bump) for _ in range(10)]
    for t in threads:
        t.start()
    for t in threads:
        t.join()
    row(1, "10 threads x 1000 `with lock: count += 1`", count)

    # 2. locked(); a Lock has no owner, so there is no owned()
    outside = lock.locked()
    with lock:
        inside = lock.locked()
    row(2, "locked() outside -> inside `with lock` (no owned?)", f"{outside} -> {inside}")

    # 3. acquire(blocking=False) never blocks
    with lock:
        held = lock.acquire(blocking=False)
    free = lock.acquire(blocking=False)
    lock.release()
    row(3, "acquire(blocking=False) while held / while free", f"{held} / {free}")

    # 4. Releasing a lock nobody holds
    try:
        lock.release()
    except RuntimeError as e:
        row(4, "release() when not locked", type(e).__name__)

    # 5-6. A Lock taken twice blocks forever (measured with a timeout); an RLock is re-entrant
    with lock:
        again = lock.acquire(timeout=0.2)
    row(5, "acquire again inside `with lock` (Lock)", f"acquire(timeout=0.2) -> {again}: it would block forever")
    rlock = threading.RLock()
    with rlock:
        with rlock:
            row(6, "the same on an RLock (re-entrant)", "'ok'")

    # 7. with is a statement
    row(7, "`with lock:` returns", "nothing: with is a statement, not an expression")

    # 8. Queue: get blocks; a None sentinel ends the loop (no close in 3.12)
    q = queue.Queue()
    got = []

    def consume():
        while (item := q.get()) is not None:
            got.append(item)

    consumer = threading.Thread(target=consume)
    consumer.start()
    q.put(1)
    q.put(2)
    q.put(3)
    q.put(None)
    consumer.join()
    row(8, "get until a None sentinel (no close in 3.12)", f"{got}, closed? n/a")

    # 9. Putting after the sentinel: nothing stops it
    q.put(4)
    row(9, "put after the sentinel", f"accepted; qsize() is {q.qsize()}")

    # 10. get with a timeout, and get_nowait
    empty = queue.Queue()
    try:
        empty.get(timeout=0.2)
    except queue.Empty as e:
        timed = type(e).__name__
    try:
        empty.get_nowait()
    except queue.Empty as e:
        row(10, "get(timeout=0.2) / get_nowait() on an empty queue", f"{timed} / {type(e).__name__}")

    # 11. Queue(maxsize=2): the producer blocks when the queue is full
    sq = queue.Queue(maxsize=2)

    def produce():
        for i in range(5):
            sq.put(i)
        sq.put(None)

    producer = threading.Thread(target=produce)
    producer.start()
    taken = []
    while (item := sq.get()) is not None:
        taken.append(item)
    producer.join()
    row(11, "Queue(maxsize=2): maxsize, 5 items through it", f"{sq.maxsize}, {taken}")

    # 12. Condition: wait_for releases the lock and sleeps; notify wakes one waiter
    cond = threading.Condition()
    ready = False
    log = queue.Queue()

    def waiter():
        with cond:
            log.put("waiter: entering wait")
            cond.wait_for(lambda: ready)
            log.put(f"waiter: woke, ready is {ready}")

    w = threading.Thread(target=waiter)
    w.start()
    while log.qsize() < 1:
        time.sleep(0.01)
    with cond:
        ready = True
        log.put("signaller: set ready, notifying")
        cond.notify()
    w.join()
    row(12, "Condition wait_for/notify, in order", [log.get() for _ in range(log.qsize())])

    # 13. task_done and join: the queue itself can be waited for
    jq = queue.Queue()
    for i in range(3):
        jq.put(i)

    def work():
        while (item := jq.get()) is not None:
            jq.task_done()

    worker = threading.Thread(target=work)
    worker.start()
    jq.join()
    jq.put(None)
    worker.join()
    row(13, "Queue.task_done / Queue.join exist?", "True / True: join() returned after 3 task_done() calls")


if __name__ == "__main__":
    main()
