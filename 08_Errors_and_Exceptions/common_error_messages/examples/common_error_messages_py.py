# common_error_messages_py.py -- the same twenty-nine rows put to Python: the code that
# raises the counterpart error and the type's name. Messages are not printed, because
# CPython rewords them between releases (3.12 and 3.14 differ on several of these).

import io
import pickle


class Vault:
    def __secret(self):
        return 1


def two(a, b):
    return None


def kw(*, k=1):
    return None


def apply(f):
    return f()


def down():
    down()


def show(n, code, f):
    try:
        f()
        print(f"{n:>2}. {'(no error)':<26} {code}")
    except BaseException as e:
        print(f"{n:>2}. {type(e).__name__:<26} {code}")


def assign_char():
    s = "abc"
    s[0] = "d"


def match_int():
    match 5:
        case str():
            return 1


def match_dict():
    match {"a": 1}:
        case {"name": _}:
            return 1


def read_closed():
    with open(__file__) as f:
        pass
    f.read()


def index_none():
    idx = None
    return [1, 2][idx]


show(1, "None.length", lambda: None.length)
show(2, "Vault().__secret()", lambda: Vault().__secret())
show(3, '"s".zzz()', lambda: "s".zzz())
show(4, "nope", lambda: nope)
show(5, "Nope  (no constants: the same NameError)", lambda: Nope)
show(6, "two(1)", lambda: two(1))
show(7, "kw(z=1)  (a missing keyword is the same TypeError)", lambda: kw(z=1))
show(8, "kw(k=1, z=1)", lambda: kw(k=1, z=1))
show(9, "sorted([3, None])", lambda: sorted([3, None]))
show(10, '"a" + 1', lambda: "a" + 1)
show(11, '1 + "a"', lambda: 1 + "a")
show(12, "1 / 0", lambda: 1 / 0)
show(13, '{"a": 1}["x"]', lambda: {"a": 1}["x"])
show(14, "[1, 2, 3][5]", lambda: [1, 2, 3][5])
show(15, 's = "abc"; s[0] = "d"  (str is immutable)', assign_char)
show(16, "next(iter([]))", lambda: next(iter([])))
show(17, "apply(None)  (no blocks: a missing callable is None)", lambda: apply(None))
show(18, "down()  (def down(): down())", down)
show(19, "match 5: case str(): ...", match_int)
show(20, 'match {"a": 1}: case {"name": _}: ...', match_dict)
show(21, 'int(float("nan"))', lambda: int(float("nan")))
show(22, 'int(float("inf"))', lambda: int(float("inf")))
show(23, "import nope_nothing", lambda: __import__("nope_nothing"))
show(24, 'open("missing.txt")', lambda: open("missing.txt"))
show(25, "f.read() on a closed file", read_closed)
show(26, 'pickle.load(io.BytesIO(b""))  (readline at EOF returns "")', lambda: pickle.load(io.BytesIO(b"")))
show(27, "(no throw/catch: a control-flow exception is just an exception)", lambda: None)
show(28, "raise NotImplementedError", lambda: (_ for _ in ()).throw(NotImplementedError()))
show(29, 'compile("def", "<string>", "exec")', lambda: compile("def", "<string>", "exec"))
