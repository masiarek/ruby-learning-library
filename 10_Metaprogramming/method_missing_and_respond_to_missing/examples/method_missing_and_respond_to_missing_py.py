"""method_missing_and_respond_to_missing_py.py -- the same rows, asked of __getattr__."""


def row(n, label, value):
    head = "   " if n == "" else f"{n:>2}."
    print(f"{head} {label:<46} {value}")


class Db:
    def __init__(self, rows):
        self._rows = rows
        self.hook_calls = 0

    def rows(self):                                    # a real method
        return self._rows

    def __getattr__(self, name):                       # runs only when lookup failed
        self.hook_calls += 1
        if name.startswith("find_by_"):
            field = name.removeprefix("find_by_")

            def finder(value):
                return next((r for r in self._rows if r.get(field) == value), None)
            return finder
        raise AttributeError(name)                     # keep the AttributeError for the rest


class ListedDb(Db):                                    # the honest version: __dir__
    def __dir__(self):
        return sorted(set(super().__dir__()) | {"find_by_name", "find_by_lang"})


class Record:                                          # attribute-style ghosts
    def __init__(self, attrs):
        self._attrs = attrs

    def __getattr__(self, name):
        if name in self._attrs:
            return self._attrs[name]
        raise AttributeError(name)


class Probe:                                           # what the hook receives
    def __getattr__(self, name):
        return lambda *args: [type(name).__name__, name, "args arrive at the call, later"]


class Counted:                                         # __getattribute__ vs __getattr__
    def __init__(self):
        object.__setattr__(self, "always", 0)
        object.__setattr__(self, "only_missing", 0)

    def __getattribute__(self, name):                  # every attribute access
        d = object.__getattribute__(self, "__dict__")
        if name not in ("always", "only_missing", "__dict__"):
            d["always"] += 1
        return object.__getattribute__(self, name)

    def __getattr__(self, name):                       # only after the above failed
        object.__getattribute__(self, "__dict__")["only_missing"] += 1
        return "ghost"

    def real(self):
        return "real"


class Swallow:                                         # the bug: never raising
    def __getattr__(self, name):
        return None


class Memo:                                            # a ghost that becomes real
    def __init__(self):
        self.hits = 0

    def __getattr__(self, name):
        if not name.startswith("say_"):
            raise AttributeError(name)
        self.hits += 1
        word = name.removeprefix("say_")
        fn = lambda: word.upper()
        setattr(self, name, fn)                        # next access is a normal lookup
        return fn


rows = [{"name": "Ada", "lang": "Ruby"}, {"name": "Guido", "lang": "Python"}]
db = Db(rows)
listed = ListedDb(rows)

row(1, 'db.find_by_name("Ada") -- a ghost method', db.find_by_name("Ada"))
row(2, 'Record({"name": "Ada"}).name -- attribute ghost', repr(Record({"name": "Ada"}).name))
try:
    db.nope
except AttributeError as e:
    row(3, "db.nope -- raise AttributeError keeps it", type(e).__name__)
    missing = e
row(4, 'Probe().find_by_x("Ada") receives', Probe().find_by_x("Ada"))
row(5, 'hasattr(db, "find_by_name") -- no extra hook needed', hasattr(db, "find_by_name"))
row("", 'callable(getattr(db, "find_by_name"))', callable(getattr(db, "find_by_name")))
row(6, 'hasattr(listed, "find_by_name")', hasattr(listed, "find_by_name"))
row("", 'getattr(listed, "find_by_lang")("Python")', getattr(listed, "find_by_lang")("Python"))
row(7, '"find_by_name" in dir(db) / in dir(listed)', f'{"find_by_name" in dir(db)} / {"find_by_name" in dir(listed)}')
c = Counted()
c.real()
c.real()
c.ghost
row(8, "Counted: real, real, ghost -> always / only_missing", f"{c.always} / {c.only_missing}")
row(9, "Swallow().typo -- __getattr__ that never raises", Swallow().typo)
row("", 'hasattr(Swallow(), "typo")', hasattr(Swallow(), "typo"))
memo = Memo()
row(10, "memo.say_hello() twice -> value, hits", f"{memo.say_hello()!r} {memo.say_hello()!r}, hits = {memo.hits}")
row("", '"say_hello" in vars(memo)', "say_hello" in vars(memo))
row(11, 'db.__getattr__("find_by_name")("Ada") explicitly', db.__getattr__("find_by_name")("Ada"))
row(12, "from row 3: e.name / e.obj is db", f"{missing.name!r} / {missing.obj is db}")
