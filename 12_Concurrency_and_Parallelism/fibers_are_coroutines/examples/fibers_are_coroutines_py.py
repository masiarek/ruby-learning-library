"""A generator is a coroutine you resume by hand -- the Python twin.

Same rows, same order as the Ruby program: next()/send() are resume,
`yield` as an expression is Fiber.yield, throw() is Fiber#raise, close() is
Fiber#kill, and a finished generator raises StopIteration.
"""
import inspect
import threading


def row(n, label, value):
    print(f"{n:2d}. {label:<52} {value}")


def coroutine(x):
    y = yield x * 2
    z = yield y + 1
    return f"done {z}"


def main():
    # 1-5. Values travel both ways: in through send, out through yield
    it = coroutine(1)
    row(1, "next(): the frame starts, yields x * 2", repr(next(it)))
    row(2, "getgeneratorstate() while suspended", inspect.getgeneratorstate(it))
    row(3, "send(10): the yield expression was 10, yields y + 1", repr(it.send(10)))
    try:
        it.send(100)
    except StopIteration as e:
        row(4, "send(100): return raises StopIteration; its .value", repr(e.value))
    row(5, "getgeneratorstate() after the return", inspect.getgeneratorstate(it))

    # 6-7. The two errors a beginner meets
    try:
        next(it)
    except StopIteration as e:
        row(6, "next() on a finished generator", f"{type(e).__name__} again, value {e.value!r}")
    try:
        compile("yield 1", "<s>", "exec")
    except SyntaxError as e:
        row(7, "yield outside any function", f"{type(e).__name__} at compile time")

    # 8. throw(): the exception appears at the generator's yield
    def catcher():
        try:
            yield 1
        except RuntimeError as e:
            return f"rescued {type(e).__name__}: {e}"

    g = catcher()
    next(g)
    try:
        g.throw(RuntimeError("stop"))
    except StopIteration as e:
        row(8, "gen.throw() delivers an exception at the yield", f"{e.value!r}, state {inspect.getgeneratorstate(g)}")

    # 9-10. No Fiber object; the generator is a suspended frame on the calling thread
    it2 = coroutine(1)
    next(it2)
    row(9, "no Fiber object: type / gi_frame is not None?", f"{type(it2).__name__} / {it2.gi_frame is not None}")

    def same_thread():
        yield threading.current_thread() is threading.main_thread()

    row(10, "a generator runs on the thread that resumed it", next(same_thread()))

    # 11. A generator: an endless loop that yields
    def fibonacci():
        a, b = 0, 1
        while True:
            yield a
            a, b = b, a + b

    fib = fibonacci()
    row(11, "a generator: 8 next() calls on a Fibonacci generator", [next(fib) for _ in range(8)])

    # 12. No preemption: control moves only at next and yield
    log = []

    def outer():
        log.append("outer 1")

        def inner():
            log.append("inner 1")
            yield
            log.append("inner 2")

        inn = inner()
        next(inn)
        log.append("outer 2")
        next(inn, None)
        log.append("outer 3")
        yield

    next(outer())
    row(12, "no preemption: control moves only at next/yield", log)

    # 13. close() raises GeneratorExit inside; finally runs
    log2 = []

    def guarded():
        try:
            yield 1
        finally:
            log2.append("finally ran")

    k = guarded()
    next(k)
    k.close()
    row(13, "gen.close() unwinds the frame; finally runs", f"state {inspect.getgeneratorstate(k)}, {log2}")

    # 14. Several values at once: one tuple each way
    def pair():
        got = yield 1, 2
        yield got

    p = pair()
    row(14, "several values: `yield 1, 2` / send((3, 4))", f"{p.send(None)!r} / {p.send((3, 4))!r}")

    # 15. An `async def` coroutine is the same machine, driven by send(None)
    async def five():
        return 5

    c = five()
    try:
        c.send(None)
    except StopIteration as e:
        row(15, "an async def coroutine driven by send(None)", f"StopIteration.value {e.value!r} (no asyncio needed)")


if __name__ == "__main__":
    main()
