# The Python twin: sys.settrace installs a global trace function that gets
# 'call' for every Python frame; returning a local trace function from it
# subscribes to that frame's 'line', 'return' and 'exception' events.
# sys.setprofile sees C calls too. Both filter by the code object's name.

import sys

OURS = {"add", "double", "fail_hard", "create"}


class Calculator:
    def add(self, a, b):
        return a + b

    def double(self, x):
        return self.add(x, x)

    def fail_hard(self):
        raise ValueError("bad input")

    @classmethod
    def create(cls):
        return cls()


def helper():
    return 42


def row(n, label, value):
    print(f"{n:2d}. {label:<52} {value!r}")


def trace_with(events, names, watch=("call", "return")):
    """Return a trace function appending (event, name, arg) for our frames."""
    def tracer(frame, event, arg):
        name = frame.f_code.co_name
        if name not in names:
            return None
        if event == "return":
            events.append(("return", name, arg))
        elif event == "exception":
            events.append(("exception", name, type(arg[1]).__name__))
        elif event in watch:
            events.append((event, name, None))
        return tracer
    return tracer


def traced(fn, events, names, watch=("call", "return")):
    sys.settrace(trace_with(events, names, watch))
    try:
        fn()
    finally:
        sys.settrace(None)


# 1-4: call and return, filtered to our names, with the return value
events = []
traced(lambda: (Calculator().double(3), helper()), events, OURS)
for i, e in enumerate(events):
    row(i + 1, "double(3) traced; helper is not ours" if i == 0 else "", e)

row(5, "sys.gettrace() is None after settrace(None)", sys.gettrace() is None)

# 6: every event for one call of add
seq = []
traced(lambda: Calculator().add(1, 2), seq, {"add"}, watch=("call", "line", "return"))
row(6, "events for one add(1, 2): call, line, return", [e[0] for e in seq])

# 7: C functions fire c_call / c_return, but only under setprofile
cseq = []
def profiler(frame, event, arg):
    if event in ("c_call", "c_return") and getattr(arg, "__name__", "") == "len":
        cseq.append((event, arg.__name__, type(arg).__name__))
sys.setprofile(profiler)
len([1, 2, 3])
sys.setprofile(None)
row(7, "len([1, 2, 3]) is a C function (sys.setprofile)", cseq)

# 8: 'exception' event
raised = []
def raise_and_rescue():
    try:
        Calculator().fail_hard()
    except ValueError:
        pass
traced(raise_and_rescue, raised, {"fail_hard"}, watch=())
row(8, "'exception' inside fail_hard, then its 'return'", raised)

# 9: only one function: the global tracer returns a local tracer for add alone
only = []
traced(lambda: Calculator().double(2), only, {"add"})
row(9, "local trace for add only while double(2) runs", [e[:2] for e in only])

# 10: the return arg and the code object's parameter names
ret = []
def with_params(frame, event, arg):
    if frame.f_code.co_name != "add":
        return None
    if event == "return":
        code = frame.f_code
        ret.append((code.co_name, arg, code.co_varnames[:code.co_argcount]))
    return with_params
sys.settrace(with_params)
Calculator().add(1, 2)
sys.settrace(None)
row(10, "'return' carries the value; co_varnames the parameters", ret)

# 11: a classmethod's frame: its first local is cls
cls = []
def cls_tracer(frame, event, arg):
    if frame.f_code.co_name == "create" and event == "call":
        cls.append((frame.f_code.co_name, frame.f_locals["cls"].__name__))
    return None
sys.settrace(cls_tracer)
Calculator.create()
sys.settrace(None)
row(11, "Calculator.create(): co_name, the cls local", cls)

# 12: tracing is off inside the trace function, so a traced call there does not recurse
inside = []
def reentrant(frame, event, arg):
    if frame.f_code.co_name == "add" and event == "call":
        inside.append("add")
        if len(inside) < 5:
            Calculator().add(1, 1)
    return None
sys.settrace(reentrant)
Calculator().add(1, 2)
sys.settrace(None)
row(12, "calls made inside the trace function are not traced", inside)

# 13: settrace / gettrace
t = trace_with([], set())
sys.settrace(t)
was_set = sys.gettrace() is t
sys.settrace(None)
row(13, "[gettrace() is t after settrace(t), is None after]", [was_set, sys.gettrace() is None])
