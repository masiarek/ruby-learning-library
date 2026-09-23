# 12 — Concurrency and parallelism

**One line:** Ruby has four units of execution — the thread, the fiber, the Ractor and the process — and each page here starts one, drives it to a fixed end, and prints only what that end is, beside the Python tool that does the same job.

A Ruby thread is a real OS thread that shares every object with the others and takes turns with them under the Global VM Lock, which is CPython's GIL under another name; the same three tools — a mutex, a queue, a condition variable — make shared state safe in both languages, and the same ideas fail in both when they are missing. The rest of the chapter is where a Python programmer's model needs adjusting. A `Fiber` is a coroutine resumed by hand, the machine under a Python generator, but exposed as an object; `Enumerator#next` runs on one, which is why `Thread.current[:x]` — a *fiber*-local despite its name — vanishes inside it. A `Ractor` is Ruby's answer to the GVL: a block that runs in parallel because it can reach only frozen objects and copies everything else, the line Python draws one process further out with `multiprocessing`. And `fork`, `spawn`, `system` and `Process.wait` are the Unix calls with `$?` attached, where Python has `os.fork`, `os.waitpid` and `subprocess`.

Every program here is deterministic on purpose. Threads are joined before anything about them is printed, results come back through a `Queue` or an array under a `Mutex` and are sorted, every timeout is a fifth of a second set against a five-second sleep, and no page prints a pid, a timing or an interleaving. What that costs is the one claim these pages cannot make from a run: that Ractors, unlike threads, use more than one core. That claim stays in prose, marked as such.

| Lesson | Level | The one thing |
|---|---|---|
| [Threads are OS threads that take turns under the GVL](threads_and_the_gvl/README.md) | 301 | `join` re-raises, `value` returns the block's last expression, and a finishing main thread kills the rest — where Python waits for them |
| [Mutex guards, Queue hands over, ConditionVariable waits](mutex_queue_and_condition_variable/README.md) | 301 | ten threads adding 1 a thousand times inside `synchronize` give exactly 10000; a closed `Queue` ends the consumer with `nil` |
| [A Fiber is a coroutine you resume by hand](fibers_are_coroutines/README.md) | 301 | values go in through `resume` and out through `Fiber.yield`, and nothing else moves control — a generator's `send` and `yield` |
| [`Enumerator#next` runs the block on its own Fiber](enumerators_run_on_fibers/README.md) | 301 | `to_a` runs the block on the calling fiber, `next` on a private one; a Python generator is a suspended frame on the same thread |
| [`Thread.current[:x]` is fiber-local, not thread-local](thread_locals_are_fiber_locals/README.md) | 301 | a value set with `Thread.current[]` is `nil` inside `Enumerator#next`; `thread_variable_get` and `Fiber[]` are the other two stores |
| [Ractors share nothing that is not frozen](ractors_share_nothing/README.md) | 301 | a Ractor copies every unfrozen argument and message, refuses an outer local, and wraps an inner exception in `Ractor::RemoteError` |
| [`fork` copies the process; `wait` collects its status](processes_fork_and_wait/README.md) | 301 | `fork` returns `nil` in the child and a pid in the parent, a signalled child has no `exitstatus`, and `system` returns `true`, `false` or `nil` |
| [`Timeout.timeout` interrupts a thread from outside](timeouts_and_killing_threads/README.md) | 301 | a watcher thread calls `Thread#raise` on yours; `ensure` still runs, and Python can only time out a wait, never a thread |

## Read more

- [Thread ↗](https://docs.ruby-lang.org/en/4.0/Thread.html) — the class reference, with the GVL under *Thread* and the fiber-local `[]` documented as such
- [Fiber ↗](https://docs.ruby-lang.org/en/4.0/Fiber.html) — `resume`, `Fiber.yield`, `kill`, storage and the scheduler hook
- [Ractor ↗](https://docs.ruby-lang.org/en/4.0/Ractor.html) — shareable objects, ports, `value` and the errors
- [Process ↗](https://docs.ruby-lang.org/en/4.0/Process.html) — `fork`, `spawn`, `wait`, `wait2` and `Process::Status`
- [Timeout ↗](https://docs.ruby-lang.org/en/4.0/Timeout.html) — how `Timeout.timeout` works and why it is dangerous, in its own words
- [threading ↗](https://docs.python.org/3/library/threading.html) — `Thread`, `Lock`, `RLock`, `Condition`, `Event` and `local`
- [queue ↗](https://docs.python.org/3/library/queue.html) — `Queue`, `task_done` and `join`
- [multiprocessing ↗](https://docs.python.org/3/library/multiprocessing.html) — processes, queues, pipes and the start methods
- [subprocess ↗](https://docs.python.org/3/library/subprocess.html) — `run`, `Popen` and `CalledProcessError`
- [contextvars ↗](https://docs.python.org/3/library/contextvars.html) — Python's counterpart of `Fiber[]`
