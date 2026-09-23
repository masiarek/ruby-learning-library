"""A generator is a suspended frame on the same thread -- the Python twin.

Python has no internal/external split: list() and next() both resume the same
generator frame, on the calling thread, and there is no fiber underneath.
The rows match the Ruby program's; where Ruby reports a fiber, Python reports
the frame and the thread.
"""
import inspect
import operator
import threading
from itertools import islice


def row(n, label, value):
    print(f"{n:2d}. {label:<52} {value}")


MAIN = threading.get_ident()


def gen():
    yield threading.get_ident() == MAIN
    yield threading.get_ident() == MAIN
    return "finished"


def main():
    # 1. All at once: the frame runs on the calling thread
    row(1, "list() (all at once): on the calling thread?", list(gen()))

    # 2-3. One at a time: the same frame, suspended between calls
    g = gen()
    row(2, "next() (one at a time): on the calling thread?", next(g))
    row(3, "next() again: the same frame, resumed", f"{next(g)} (gi_suspended {g.gi_suspended})")

    # 4-6. The end of the frame
    try:
        next(g)
    except StopIteration as e:
        row(4, "next() past the end", f"{type(e).__name__} (state {inspect.getgeneratorstate(g)})")
        row(5, "StopIteration.value is the return value", repr(e.value))
    try:
        next(g)
    except StopIteration as e:
        row(6, "next() once more", f"{type(e).__name__} (value {e.value!r})")

    # 7. No rewind: make a new generator
    row(7, "no rewind: gen() again, then next()", next(gen()))

    # 8-9. No peek; for and next(it, default) end quietly
    it = iter([10, 20])
    row(8, "(no peek) / next / next on iter([10, 20])", f"(no peek) / {next(it)} / {next(it)}")
    row(9, "for swallows StopIteration; next(it, default)", repr(next(it, "the default")))

    # 10. What the yield expression evaluates to
    def en():
        got = yield 1
        yield f"yield returned {got!r}"

    h = en()
    first = next(h)
    second = h.send(10)
    row(10, "the yield expression: under list() / after send(10)", f"{list(en())} / {[first, second]}")

    # 11. islice and list are the same frame on the same thread
    row(11, "next(gen()) / islice / list: on the calling thread?", f"{next(gen())} / {list(islice(gen(), 1))} / {list(gen())[:1]}")

    # 12. No size: len() fails, length_hint() is 0
    try:
        len(gen())
    except TypeError as e:
        row(12, "size: len(gen()) / operator.length_hint(gen())", f"{type(e).__name__} / {operator.length_hint(gen())}")

    # 13. The frame runs on the calling thread
    def where():
        yield threading.current_thread() is threading.main_thread()

    row(13, "under next(), the frame is on the calling thread", next(where()))

    # 14. The generator object's own attributes
    row(14, "a generator object's gi_ attributes", [a for a in dir(gen()) if a.startswith("gi_")])


if __name__ == "__main__":
    main()
