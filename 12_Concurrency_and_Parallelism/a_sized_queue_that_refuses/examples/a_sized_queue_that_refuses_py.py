# The Python twin: the same pool, the same queue, the same timetables, on the
# same millisecond clock -- and then queue.Queue(maxsize=100), which is the
# class a request queue would be written with in Python.

import queue
from dataclasses import dataclass, field

POOL = 6              # passenger_max_pool_size, the default
CAP = 100             # passenger_max_request_queue_size, the default
GATEWAY_TIMEOUT = 30_000   # HAProxy's `timeout server`, in ms: after this it answers 504 itself
CHECKPOINTS = (5, 20, 40, 60)   # the seconds whose peak queue is reported


@dataclass
class Run:
    offered: int = 0
    served: int = 0
    refused: int = 0
    timed_out: int = 0
    full_at: int | None = None
    longest_wait: int = 0
    last_arrival: int = 0
    cleared: int = 0
    snapshots: list[int] = field(default_factory=list)


def simulate(pool, cap, service, seconds, timetable):
    """Requests arrive on a timetable; each process answers one at a time."""
    waiting = []   # arrival time of each request waiting for a process
    busy = []      # the moment each busy process becomes free
    run = Run()
    peak = 0       # the most in the queue at any moment of the current second
    t = 0
    while True:
        busy = [free_at for free_at in busy if free_at > t]
        for _ in range(timetable(t)):
            run.offered += 1
            run.last_arrival = t
            if cap is not None and len(waiting) >= cap:
                run.refused += 1
                if run.full_at is None:
                    run.full_at = t
            else:
                waiting.append(t)
        while len(busy) < pool and waiting:
            waited = t - waiting.pop(0)
            run.longest_wait = max(run.longest_wait, waited)
            if waited + service > GATEWAY_TIMEOUT:
                run.timed_out += 1
            busy.append(t + service)
            run.served += 1
            run.cleared = t + service
        peak = max(peak, len(waiting))
        if (t + 1) % 1000 == 0:
            if (t + 1) // 1000 in CHECKPOINTS:
                run.snapshots.append(peak)
            peak = 0
        t += 1
        if t >= seconds * 1000 and not waiting and not busy:
            return run


def steady(per_second, seconds):
    gap = 1000 // per_second
    return lambda t: 1 if t < seconds * 1000 and t % gap == 0 else 0


def burst(seconds):
    def timetable(t):
        if t < 1000:
            return 1 if t % 5 == 0 else 0
        if t < seconds * 1000:
            return 1 if t % 50 == 0 else 0
        return 0
    return timetable


def tenths(ms):
    return f"{ms // 1000}.{ms % 1000 // 100} s"


def line(label, value):
    print(f"   {label:<42} {value}")


def report(number, title, run):
    print(f"{number:>2}. {title}")
    snapshots = " / ".join(str(n) for n in run.snapshots)
    full = f"full from {tenths(run.full_at)}" if run.full_at is not None else "never full"
    line(f"peak queue in second {' / '.join(str(s) for s in CHECKPOINTS)}", f"{snapshots}    {full}")
    line("longest wait in the queue", tenths(run.longest_wait))
    line("refused with 503 (Passenger: queue full)", f"{run.refused} of {run.offered}")
    line("timed out with 504 (HAProxy: 30 s passed)", f"{run.timed_out} of {run.offered}")
    line("queue empty again", f"{tenths(run.cleared - run.last_arrival)} after the last arrival")
    print()


print(f"Passenger's defaults: a pool of {POOL} processes, each answering one request")
print(f"at a time, in front of a request queue of {CAP}. When a request takes 200 ms,")
print(f"the pool answers at most {POOL * 1000 // 200} a second. HAProxy, in front, waits")
print(f"{GATEWAY_TIMEOUT // 1000} s for an answer and then sends a 504 itself.")
print("(A simulation on a millisecond clock, not Passenger or HAProxy themselves.)")
print()

report(1, "25 requests/s for 60 s: under the 30/s the pool clears",
       simulate(POOL, CAP, 200, 60, steady(25, 60)))
report(2, f"40 requests/s for 60 s: over 30/s, queue capped at {CAP}",
       simulate(POOL, CAP, 200, 60, steady(40, 60)))
report(3, "the same 40 requests/s, queue uncapped",
       simulate(POOL, None, 200, 60, steady(40, 60)))
report(4, "25 requests/s again, but a slow database: 2000 ms per request",
       simulate(POOL, CAP, 2000, 60, steady(25, 60)))
report(5, "a registration window: 200 requests in the first second, then 20/s",
       simulate(POOL, CAP, 200, 60, burst(60)))
report(6, "the same window, queue uncapped",
       simulate(POOL, None, 200, 60, burst(60)))
report(7, "the database locks up: 5 requests/s, 40 000 ms per request",
       simulate(POOL, CAP, 40_000, 60, steady(5, 60)))


def row(n, label, value):
    print(f"{n:>2}. {label:<52} {value}")


# 8. The class itself: put_nowait raises queue.Full when the queue is full
sq = queue.Queue(maxsize=CAP)
for i in range(CAP):
    sq.put(i)
try:
    sq.put_nowait("one more")
except queue.Full as e:
    row(8, f"Queue(maxsize={CAP}): put {CAP}, then put_nowait(job)", type(e).__name__)

# 9. put with timeout=0 gives up at once -- by raising, where Ruby returns nil
try:
    sq.put("one more", timeout=0)
except queue.Full as e:
    row(9, "put(job, timeout=0) on the full queue", f"{type(e).__name__} (raised, not None)")

# 10. maxsize=0, the default, means no cap
q = queue.Queue()
for i in range(CAP * 1000 + 1):
    q.put(i)
row(10, f"Queue() has no cap: put number {CAP * 1000 + 1}", f"qsize {q.qsize()}, maxsize {q.maxsize}")
