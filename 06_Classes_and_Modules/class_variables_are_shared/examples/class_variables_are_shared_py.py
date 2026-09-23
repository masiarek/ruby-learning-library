# The Python twin: a class attribute is inherited until someone assigns
# through the subclass or the instance, which creates a new attribute that
# shadows it. Each numbered row is printed by the Ruby program too.

import dataclasses
from typing import ClassVar


def row(n, label, value):
    print(f"{n:2d}. {label:<58} {value}")


def failing(thunk):
    try:
        return thunk()
    except AttributeError as e:
        return type(e).__name__          # messages are reworded between Python releases


class Base:
    count = 0                            # one attribute on Base, visible through subclasses
    items = []                           # a mutable one: the list itself is shared
    count_ivar = 0

    def instance_reads(self):
        return self.count                # found through the class

    def instance_writes(self):
        self.count = 7                   # creates an instance attribute; Base.count unchanged


class Sub(Base):
    @classmethod
    def bump(cls):
        cls.count += 1                   # reads Base.count, then assigns Sub.count: a shadow

    @classmethod
    def assign(cls, v):
        cls.count = v

    @classmethod
    def push(cls, v):
        cls.items.append(v)              # no assignment: the shared list is mutated


row(1, "count set in Base, read through Sub", str(Sub.count))
Sub.bump()
row(2, "Sub.bump() does cls.count += 1 -- Base.count / Sub.count", f"{Base.count} / {Sub.count}")
Sub.assign(100)
row(3, "Sub assigns cls.count = 100 -- Base.count / Sub's own?",
    f"{Base.count} / {'count' in vars(Sub)} ('count' in vars(Sub))")
row(4, "an instance method reads self.count", str(Base().instance_reads()))
b = Base()
b.instance_writes()
row(5, "an instance method assigns self.count = 7 -- Base.count",
    f"{Base.count} (vars(b): {vars(b)!r})")
row(6, "count_ivar -- Base's / Sub's (inherited, not per class)",
    f"{Base.count_ivar!r} / {Sub.count_ivar!r}")
Sub.push(1)
row(7, "items = []; Sub.push(1) -- Base.items", repr(Base.items))
row(8, "getattr / names in vars(Base) / hasattr",
    f"{getattr(Base, 'count')} / {sorted(k for k in vars(Base) if not k.startswith('_') and not callable(vars(Base)[k]))!r} / {hasattr(Base, 'nope')}")
row(9, "getattr(Base, \"nope\")", failing(lambda: getattr(Base, "nope")))


class Early(Base):
    fresh = 1                            # 10. the subclass defines it first...


Base.fresh = 2                           # ...then the superclass does: Early keeps its own
row(10, "fresh set in Early, then in Base -- Early.fresh", str(Early.fresh))


@dataclasses.dataclass
class Point:
    x: int
    registry: ClassVar[list] = []        # 11. ClassVar: a type-checker annotation; dataclass skips it


row(11, "no class variable outside a class; ClassVar in a dataclass",
    f"{[f.name for f in dataclasses.fields(Point)]!r} (registry is a class attribute)")
