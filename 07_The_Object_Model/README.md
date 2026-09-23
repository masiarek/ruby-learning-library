# 07 — The Object Model

**One line:** Ruby's objects are built from a handful of moving parts — a singleton class per object, `allocate` then `initialize` behind `new`, `Kernel` mixed into `Object` above `BasicObject`, two equalities and two string forms, `dup` against `clone` — and each lesson here measures one part against Python's data model.

A Python programmer arrives with a good model: everything is an object, a class is an object too, `__init__` fills in what `__new__` allocated, `__repr__` is for programmers and `__str__` for people, a dict key needs `__hash__` and `__eq__`, `copy.copy` is shallow. Most of it carries over, and the pages below say where. The surprises are structural. Ruby gives *every object* a hidden class of its own, so a method on one object and a class method are the same mechanism; `Object` defines no methods itself and borrows everything from the `Kernel` module, so a `BasicObject` subclass starts with nothing, not even `puts`; `to_s` never falls back to `inspect`; `1` and `1.0` are two Hash keys; and a class can be changed for one file only, with a refinement, where Python's `mock.patch` changes it for everyone while it is on.

Every page runs a Ruby program and a Python twin that print the same numbered rows, so the two blocks read side by side. The defaults here print object addresses — `#<Foo:0x…>` and `<Foo object at 0x…>` — so every class in the chapter defines `inspect` or `__repr__`, or prints a test of the string's shape, and nothing in a key depends on where an object happened to live.

| Lesson | Level | The one thing |
|---|---|---|
| [Every object has a class of its own](singleton_classes/README.md) | 301 | `def obj.x`, `class << self`, `extend` and class methods all live in the singleton class; `dup` drops it, `clone` keeps it |
| [`new` is `allocate` then `initialize`](new_allocate_and_initialize/README.md) | 201 | `new` is an ordinary class method that allocates and then calls the automatically private `initialize`; overriding it gives caches and factories |
| [`puts` calls `to_s`, `p` calls `inspect`](to_s_inspect_and_p/README.md) | 201 | Two string forms, and which printing route calls which; defining one never defines the other, unlike Python's `__repr__` |
| [A Hash key needs `eql?` and `hash`, not `==`](eql_and_hash_for_hash_keys/README.md) | 201 | Hash, Set, `uniq` and `tally` use `hash` then `eql?`; `1` and `1.0` are two keys in Ruby and one in Python |
| [Refinements are lexical, not global](refinements/README.md) | 301 | `using` switches a change on from that line to the end of the file, for code written there; Python's `mock.patch` is dynamic |
| [`Object` sits on `Kernel` on `BasicObject`](basic_object_and_kernel/README.md) | 301 | `Object` owns no methods; `puts` is a private method of `Kernel`; a `BasicObject` subclass has eight methods and no constants |
| [`dup` is a fresh copy, `clone` is a faithful one](dup_clone_and_frozen_state/README.md) | 201 | Both are shallow and copy the instance variables; `clone` also copies frozen state and singleton methods; `Marshal` deep-copies |

## Read more

- [Ruby docs: modules and classes ↗](https://docs.ruby-lang.org/en/4.0/syntax/modules_and_classes_rdoc.html) — the syntax reference, including singleton classes
- [Ruby docs: `Object` ↗](https://docs.ruby-lang.org/en/4.0/Object.html) — the methods every object has, as documented on `Object` and `Kernel`
- [Ruby docs: `BasicObject` ↗](https://docs.ruby-lang.org/en/4.0/BasicObject.html) — the root class and its proxy example
- [Ruby docs: refinements ↗](https://docs.ruby-lang.org/en/4.0/syntax/refinements_rdoc.html) — the scope rules for `using`
- [Python docs: the data model ↗](https://docs.python.org/3/reference/datamodel.html) — `__new__`, `__init__`, `__repr__`, `__hash__`, `__getattr__` and metaclasses, the other side of every page here
- [Python docs: `copy` ↗](https://docs.python.org/3/library/copy.html) — shallow and deep copy, and the `__copy__`/`__deepcopy__` hooks
