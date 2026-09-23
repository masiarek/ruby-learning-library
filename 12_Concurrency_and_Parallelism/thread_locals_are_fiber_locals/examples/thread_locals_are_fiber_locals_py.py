"""threading.local is thread-local; contextvars is the inherited kind -- the twin.

Python has no fiber, so a generator on the same thread sees the thread's
threading.local() values, and a new thread sees none of them. A ContextVar is
Python's Fiber[]: copied into a child context, not shared, and not carried
into a new thread by default.
"""
import contextvars
import threading


def row(n, label, value):
    print(f"{n:2d}. {label:<52} {value}")


def in_thread(fn):
    box = []
    th = threading.Thread(target=lambda: box.append(fn()))
    th.start()
    th.join()
    return box[0]


def main():
    tl = threading.local()

    # 1-3. threading.local(): a generator is the same thread, so it sees and changes it
    tl.x = 1
    row(1, "threading.local(): tl.x = 1; read back", tl.x)

    def read_x():
        yield getattr(tl, "x", None)

    row(2, "tl.x inside a generator (no fibers: same thread)", next(read_x()))

    def set_x():
        tl.x = 9
        yield

    next(set_x())
    row(3, "a generator set tl.x = 9; the caller now sees", tl.x)

    # 4-5. There is no second store: the same attribute again
    tl.y = 2

    def read_y():
        yield getattr(tl, "y", None)

    row(4, "tl.y inside a generator", next(read_y()))

    def set_y():
        tl.y = 3
        yield

    next(set_y())
    row(5, "a generator set tl.y = 3; the thread now sees", tl.y)

    # 6. A new thread starts with neither
    seen = in_thread(lambda: (getattr(tl, "x", None), getattr(tl, "y", None)))
    row(6, "a new Thread sees tl.x / tl.y", f"{seen[0]!r} / {seen[1]!r}")

    # 7. A generator driven by list() or by next(): the same thread either way
    def both():
        yield getattr(tl, "x", None)
        yield getattr(tl, "y", None)

    g = both()
    row(7, "in a generator: list() / next() twice", f"{list(both())} / {[next(g), next(g)]}")

    # 8-11. contextvars: copied into a child context, not shared with it
    req = contextvars.ContextVar("req", default="none")
    req.set("abc")
    row(8, "ContextVar req.set(\"abc\"); in copy_context().run", repr(contextvars.copy_context().run(req.get)))

    def child():
        req.set("child")
        return req.get()

    row(9, "a copied context set \"child\": child / caller", f"{contextvars.copy_context().run(child)!r} / {req.get()!r}")

    def read_req():
        yield req.get()

    row(10, "req in a new Thread / in a generator", f"{in_thread(req.get)!r} / {next(read_req())!r}")
    row(11, "contextvars.Context() (empty) .run(req.get)", repr(contextvars.Context().run(req.get)))

    # 12-13. Looking at the two stores, and at a missing name
    ctx = {var.name: val for var, val in contextvars.copy_context().items()}
    row(12, "vars(tl) / the copied context's items", f"{vars(tl)} / {ctx}")
    try:
        tl.nope
    except AttributeError as e:
        row(13, "a missing name: getattr(tl, 'nope', None) / tl.nope", f"{getattr(tl, 'nope', None)!r} / {type(e).__name__}")


if __name__ == "__main__":
    main()
