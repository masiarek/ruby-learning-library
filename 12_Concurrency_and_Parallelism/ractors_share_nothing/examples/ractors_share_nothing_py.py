"""Processes share nothing -- multiprocessing is the Python twin of Ractors.

Every argument, message and result crosses the process boundary as a pickle,
which is a copy, so nothing a child changes reaches the parent. The "spawn"
start method is chosen explicitly so the program behaves the same on Linux
and macOS, and the `if __name__ == "__main__":` guard is required because a
spawned child re-imports this file.
"""
import multiprocessing
import pickle
from concurrent.futures import ProcessPoolExecutor


def row(n, label, value):
    print(f"{n:2d}. {label:<52} {value}")


def six_times_seven():
    return 6 * 7


def plus_one(n):
    return n + 1


def append_and_count(items):
    items.append(4)
    return len(items)


CONFIG = ["a"]


def mutate_config():
    CONFIG.append("b")
    return list(CONFIG)


def raise_inside():
    raise ValueError("inside")


def send_pair(q, n):
    q.put((n, n * 10))


def upper_first(conn):
    items = conn.recv()
    items[0] = items[0].upper()
    conn.send(items)


def echo(conn):
    conn.send(conn.recv())
    conn.send(conn.recv())


def is_main():
    return multiprocessing.parent_process() is None


def square(n):
    return n * n


def double(n):
    return n * 2


def picklable(obj):
    try:
        pickle.dumps(obj)
        return True
    except Exception:
        return False


def main():
    ctx = multiprocessing.get_context("spawn")
    with ProcessPoolExecutor(max_workers=2, mp_context=ctx) as pool:
        # 1-2. A value computed in another process; arguments passed in
        row(1, "pool.submit(six_times_seven).result()", pool.submit(six_times_seven).result())
        row(2, "pool.submit(plus_one, 10).result()", pool.submit(plus_one, 10).result())

        # 3. A list argument is pickled: the child appends to its copy
        items = [1, 2, 3]
        seen = pool.submit(append_and_count, items).result()
        row(3, "a list argument is copied: inside len / outside", f"{seen} / {items}")

        # 4-5. No shareable?: whatever crosses is pickled; a round trip is a deep copy
        row(4, "picklable? \"s\" / 1 / [1, \"a\"] / a lambda", f"[{picklable('s')}, {picklable(1)}, {picklable([1, 'a'])}, {picklable(lambda: 1)}]")
        x = [1, ["a"]]
        y = pickle.loads(pickle.dumps(x))
        row(5, "pickle round trip: == / is / inner is", f"[{x == y}, {x is y}, {x[1] is y[1]}]")

        # 6. A nested function that reads an outer local cannot be sent either
        z = 5

        def reads_z():
            return z

        row(6, "a nested function that reads an outer local", f"picklable? {picklable(reads_z)}: it never leaves this process")

        # 7. A module-level list is copied into the child, not shared
        row(7, "a module-level list appended to in the child / here", f"{pool.submit(mutate_config).result()} / {CONFIG}")

        # 8. An exception inside comes back through the Future
        fut = pool.submit(raise_inside)
        exc = fut.exception()
        try:
            fut.result()
        except ValueError as e:
            row(8, "an exception inside: exception() / result() raises", f"{type(exc).__name__}: {exc} / {type(e).__name__}: {e}")

        # 9. Three processes report through a Queue; the parent sorts
        q = ctx.Queue()
        workers = [ctx.Process(target=send_pair, args=(q, i)) for i in range(3)]
        for w in workers:
            w.start()
        got = sorted(q.get() for _ in range(3))
        for w in workers:
            w.join()
        row(9, "3 Processes send through a Queue, sorted; exitcodes", f"{got}, {[w.exitcode for w in workers]}")

        # 10. A Pipe: the child changes its copy of a list
        here, there = ctx.Pipe()
        items = ["hello"]
        p = ctx.Process(target=upper_first, args=(there,))
        p.start()
        here.send(items)
        back = here.recv()
        p.join()
        row(10, "send a list; the child upper()s its copy", f"{back} / sender still {items}")

        # 11. Nothing passes by reference: an immutable tuple is copied like a list
        here, there = ctx.Pipe()
        p = ctx.Process(target=echo, args=(there,))
        p.start()
        tup, lst = ("shared",), ["hello"]
        here.send(tup)
        here.send(lst)
        same, copy = here.recv() is tup, here.recv() is lst
        p.join()
        row(11, "echoed object is the sent one: a tuple / a list", f"{same} / {copy}")

        # 12. No move: the sender keeps its object
        moved = "moved"
        pool.submit(len, moved).result()
        row(12, "send with move?", f"no move semantics; the sender still has {moved!r}")

        # 13-14. Which process am I; several processes, values in order
        row(13, "parent_process() is None: outside / inside", f"{is_main()} / {pool.submit(is_main).result()}")
        row(14, "pool.map(square, range(4))", list(pool.map(square, range(4))))

        # 15. A lambda cannot cross; a module-level function can
        row(15, "pass a lambda / a module-level def", f"picklable? {picklable(lambda a: a * 2)} / {pool.submit(double, 4).result()}")


if __name__ == "__main__":
    main()
