"""hooks_inherited_included_method_added_py.py -- the same rows, asked of __init_subclass__ and a metaclass."""

import inspect


def row(n, label, value):
    head = "   " if n == "" else f"{n:>2}."
    print(f"{head} {label:<46} {value}")


class Exporter:
    registry = []

    def __init_subclass__(cls, tag=None, **kwargs):    # 1. called as each subclass appears
        super().__init_subclass__(**kwargs)
        Exporter.registry.append(cls.__name__)
        cls.tag = tag                                  # 3. keyword options arrive here


class CsvExporter(Exporter, tag="csv"):
    pass


class JsonExporter(Exporter):
    pass


row(1, "Exporter.registry after two `class X(Exporter)`", Exporter.registry)
anon = type("Anon", (Exporter,), {})
row(2, 'type("Anon", (Exporter,), {}): registry[-1]', f"{Exporter.registry[-1]!r} -- named at birth")
row("", "anon.__name__", repr(anon.__name__))
row(3, 'class CsvExporter(Exporter, tag="csv")', f"CsvExporter.tag = {CsvExporter.tag!r}")
try:
    class Oops(JsonExporter, unknown=1):
        pass
except TypeError as e:
    row("", "an option nobody consumes", type(e).__name__)

LOG = []


class Persist:                                         # 4. a mixin is a base class
    def __init_subclass__(cls, **kwargs):
        LOG.append(f"Persist mixed into {cls.__name__}, already in mro: {Persist in cls.__mro__}")
        super().__init_subclass__(**kwargs)

    @classmethod
    def table_name(cls):
        return cls.__name__.lower() + "s"

    def save(self):
        return f"saved {self.table_name()}"


class Watch(type):                                     # 8-10. a metaclass sees the whole body
    @classmethod
    def __prepare__(mcls, name, bases, **kwargs):
        class LogDict(dict):
            def __setitem__(self, key, value):
                if not key.startswith("__"):
                    LOG.append(f"body defined {key}")
                super().__setitem__(key, value)
        return LogDict()

    def __new__(mcls, name, bases, ns, **kwargs):
        cls = super().__new__(mcls, name, bases, dict(ns), **kwargs)
        cls.added = [k for k, v in ns.items() if inspect.isfunction(v)]
        cls.sadded = [k for k, v in ns.items() if isinstance(v, classmethod)]
        cls.consts = [k for k, v in ns.items() if not k.startswith("__") and not callable(v)
                      and not isinstance(v, classmethod)]
        return cls


class Field:
    def __set_name__(self, owner, name):               # a descriptor learns its own name
        LOG.append(f"set_name {owner.__name__}.{name}")


class Model(Persist, metaclass=Watch):
    def load(self):
        return 2
    id = Field()
    fetch = load
    touch = lambda self: None
    def _hidden(self):
        return 4
    @classmethod
    def create(cls):
        return 3
    VERSION = "1"


row(4, "class Model(Persist): table_name(), ().save()", f"{Model.table_name()!r}, {Model().save()!r}")
row(5, "LOG order while the class was built", LOG)
LOG.clear()


class Loud:
    def __init_subclass__(cls, **kwargs):
        LOG.append(f"Loud mixed into {cls.__name__}")
        super().__init_subclass__(**kwargs)

    def hi(self):
        return "hi"


o = Model()
o.__class__ = type("LoudModel", (Loud, type(o)), {})   # 6. extend ONE object: swap its class
row(6, "o.__class__ = type('LoudModel', (Loud, Model), {})", f"{LOG}; isinstance(o, Loud) = {isinstance(o, Loud)}")
LOG.clear()


class Audit:
    def save(self):
        return "audit then " + super().save()


Audited = type("Audited", (Audit, Model), {})          # 7. no prepend: a subclass whose MRO puts Audit first
row(7, "Audited = type(..., (Audit, Model), {})", f"{LOG}; mro[:2] = {[c.__name__ for c in Audited.__mro__[:2]]}")
row("", "Audited().save()", repr(Audited().save()))
row(8, "metaclass saw functions (def, alias, lambda, _hidden)", Model.added)
row(9, "metaclass saw classmethods", Model.sadded)
row(10, "metaclass saw the rest of the body", Model.consts)
row(11, "sorted(c.__name__ for c in Exporter.__subclasses__())", sorted(c.__name__ for c in Exporter.__subclasses__()))


class Base2:
    all = []

    def __init_subclass__(cls, **kwargs):              # 12. super() keeps the chain
        Base2.all.append(cls.__name__)
        super().__init_subclass__(**kwargs)


class Mid(Base2):
    def __init_subclass__(cls, **kwargs):
        LOG.append(f"Mid saw {cls.__name__}")
        super().__init_subclass__(**kwargs)


LOG.clear()


class Leaf(Mid):
    pass


row(12, "class Leaf(Mid): Base2.all, and Mid's own hook", f"{Base2.all}, {LOG}")
row(13, "__init_subclass__ is implicitly a classmethod", type(vars(Exporter)["__init_subclass__"]).__name__)
