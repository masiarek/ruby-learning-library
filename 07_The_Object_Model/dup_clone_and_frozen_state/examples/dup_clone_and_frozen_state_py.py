# copy.copy copies the instance dictionary, shallowly, and there is only one
# kind of copy because there is no frozen state and no singleton class to
# carry. copy.deepcopy and a pickle round-trip are the deep copies. Prints
# the same numbered rows as dup_clone_and_frozen_state_rb.rb.

import copy
import dataclasses
import pickle
import types
from dataclasses import FrozenInstanceError, dataclass


def section(n, title):
    print(f"{n}. {title}")


def row(label, value):
    print(f"   {label:<46} {value}")


class Doc:
    def __init__(self, title, tags):
        self.title, self.tags = title, tags

    def __repr__(self):
        return f"Doc({self.title!r}, {self.tags!r})"


@dataclass(frozen=True)
class FrozenDoc:
    title: str
    tags: list


class Loud:
    def __init__(self):
        print("   (__init__ runs)")
        self.x = 1


class Tracked:
    def __init__(self):
        self.log, self.items = [], []

    def __copy__(self):
        self.log.append("__copy__")
        new = object.__new__(type(self))
        new.__dict__.update(self.__dict__)
        new.items = list(self.items)
        return new

    def __deepcopy__(self, memo):
        self.log.append("__deepcopy__")
        new = object.__new__(type(self))
        new.__dict__ = copy.deepcopy(self.__dict__, memo)
        return new


original = Doc("draft", ["a"])
original.shout = types.MethodType(lambda self: "singleton!", original)

section(1, "copy.copy copies the instance dictionary")
row("original", repr(original))
row("copy.copy(original)", repr(copy.copy(original)))
row("sorted(vars(copy.copy(original)))", sorted(vars(copy.copy(original))))
row("copy.copy(original) is original", copy.copy(original) is original)

section(2, "frozen state: none to copy; a frozen dataclass is frozen by its class")
frozen = FrozenDoc("f", ["a"])
frozen_copy = copy.copy(frozen)
row("type(copy.copy(frozen)).__name__", type(frozen_copy).__name__)
row("copy.copy(frozen) == frozen", frozen_copy == frozen)
try:
    frozen_copy.title = "x"
except FrozenInstanceError as e:
    row("copy.copy(frozen).title = 'x'", type(e).__name__)
row("issubclass(FrozenInstanceError, AttributeError)", issubclass(FrozenInstanceError, AttributeError))
fresh = copy.copy(original)
fresh.title = "copy"
row("fresh = copy.copy(original); fresh.title = 'copy'", repr(fresh))

section(3, "functions stored on the object: copied, still bound to the original")
row("'shout' in vars(original)", "shout" in vars(original))
row("'shout' in vars(copy.copy(original))", "shout" in vars(copy.copy(original)))
row("copy.copy(original).shout.__self__ is original", copy.copy(original).shout.__self__ is original)
deep = copy.deepcopy(original)
row("copy.deepcopy(original).shout.__self__ is the copy", deep.shout.__self__ is deep)

section(4, "copy.copy is shallow")
row("fresh.tags is original.tags", fresh.tags is original.tags)
fresh.tags.append("b")
row("fresh.tags.append('b'); original.tags", original.tags)
row("copy.copy(original).tags is original.tags", copy.copy(original).tags is original.tags)

section(5, "copy.deepcopy and a pickle round-trip are the deep copies")
plain = Doc("plain", ["a"])
deep = copy.deepcopy(plain)
row("copy.deepcopy(plain)", repr(deep))
row("deep.tags is plain.tags", deep.tags is plain.tags)
unpickled = pickle.loads(pickle.dumps(plain))
row("pickle.loads(pickle.dumps(plain))", repr(unpickled))
row("unpickled.tags is plain.tags", unpickled.tags is plain.tags)
plain.f = lambda: 1
try:
    pickle.dumps(plain)
except pickle.PicklingError as e:
    row("pickle.dumps(plain)  (holds a lambda)", type(e).__name__)
try:
    copy.copy(types.MappingProxyType({}))
except TypeError as e:
    row("copy.copy(MappingProxyType({}))  (via __reduce_ex__)", type(e).__name__)

section(6, "the hooks: __copy__ and __deepcopy__(memo)")
tracked = Tracked()
shallow = copy.copy(tracked)
row("copy.copy(tracked); tracked.log", tracked.log)
row("shallow.items is tracked.items  (copied in the hook)", shallow.items is tracked.items)
row("shallow.log is tracked.log  (not copied: shared)", shallow.log is tracked.log)
tracked2 = Tracked()
deep2 = copy.deepcopy(tracked2)
row("copy.deepcopy(tracked2); tracked2.log", tracked2.log)
row("deep2.log is tracked2.log", deep2.log is tracked2.log)

section(7, "immutables are handed back as is")
one, text, pair = 1, "x", (1, [2])
row("copy.copy(1) is 1", copy.copy(one) is one)
row("copy.copy('x') is 'x'", copy.copy(text) is text)
row("copy.copy(None) is None", copy.copy(None) is None)
row("copy.copy((1, [2])) is the tuple", copy.copy(pair) is pair)
row("copy.deepcopy((1, [2])) is the tuple", copy.deepcopy(pair) is pair)
row("frozen-ness of  'lit'  1  None  []  (1, 2)", "n/a: Python has no frozen flag; types are immutable or not")

section(8, "dataclasses.replace and copy on a frozen dataclass")
replaced = dataclasses.replace(frozen, title="r")
row("dataclasses.replace(frozen, title='r')", repr(replaced))
row("replaced.tags is frozen.tags  (shallow)", replaced.tags is frozen.tags)
row("copy.deepcopy(frozen).tags is frozen.tags", copy.deepcopy(frozen).tags is frozen.tags)
row("copy.copy(frozen).tags is frozen.tags", copy.copy(frozen).tags is frozen.tags)

section(9, "where they live")
row("copy.copy.__module__", copy.copy.__module__)
row("hasattr(object, '__copy__')", hasattr(object, "__copy__"))
row("hasattr(object, '__reduce_ex__')  (what copy uses)", hasattr(object, "__reduce_ex__"))
loud = Loud()
row("copy.copy(loud)  (no __init__ line follows)", vars(copy.copy(loud)))
row("copy.deepcopy(loud)  (nor here)", vars(copy.deepcopy(loud)))
