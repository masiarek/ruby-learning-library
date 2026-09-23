# 01 — Objects and values

**One line:** Every Ruby value is an object with a class, an identity and a set of messages it answers — and the surprises for a Python programmer are which values count as false, what a symbol is, four equality methods where Python has two, strings that change in place, and a `freeze` that protects one object at a time.

This chapter is the ground the rest of the library stands on. A literal is a receiver (`1.class`, `3.times`), an operator is a method (`1.+(2)`), `nil` is an object with methods, and the top level of a script is an object called `main`. From there the chapter takes the ideas a Python programmer already holds — truthiness, identity, equality, references, immutability — and prints where each one carries over and where it breaks: only `nil` and `false` are falsy, so `0` and `""` are true; a symbol is a name with exactly one object per spelling, which Python covers with interning and `Enum`; `==`, `eql?`, `equal?` and `===` are four different questions, and Python folds the second into the first; assignment shares objects in both languages, but Python's `+=` on a list mutates while Ruby's always rebinds.

The last three pages are about change. A Ruby string is a mutable buffer, so `<<` keeps the object and `+=` makes a new one, where a Python `str` cannot change at all; `freeze` makes an object immutable but is shallow, `Ractor.make_shareable` freezes all the way down, and the magic comment freezes a file's literals, where Python gets immutability from the type and its frozen dataclass has a back door; and duck typing — `respond_to?`, the implicit conversions `to_str`/`to_ary`/`to_proc`/`to_int`, and `Array()`/`Integer()` — is the same philosophy Python spells `hasattr`, `__iter__`/`__call__`/`__index__` and `list()`/`int()`, with a `Protocol` that Ruby lacks. Every page runs a Ruby program and a Python twin that print the same numbered rows, so each comparison is a measurement.

| Lesson | Level | The one thing |
|---|---|---|
| [Everything is an object, even `1` and `nil`](everything_is_an_object/README.md) | 101 | `1.class`, `nil.to_a` and `1.+(2)` all work, `Class.class` is `Class`, and `self` at the top level is an object called `main` |
| [Only `nil` and `false` are falsy](nil_false_and_truthiness/README.md) | 101 | `!!0`, `!!""` and `!![]` are all `true`, an or-default replaces only `nil` and `false`, and no class can opt in to falsiness |
| [A symbol is a name, not a string](symbols_are_names/README.md) | 101 | `:a.equal?(:a)` is `true` while two `"a"` literals are two objects; symbols name methods, key hashes and answer `to_proc` |
| [Ruby has four kinds of equality](four_kinds_of_equality/README.md) | 201 | `equal?` is identity, `==` is value, `eql?` refuses `1 == 1.0` (so `Hash` keeps `1` and `1.0` apart), and `===` is what `case`/`when` calls |
| [A variable is a reference, not a box](variables_are_references/README.md) | 101 | `b = a; b << x` is seen through `a`, `b += x` is not, a method can mutate but not rebind, and `dup` copies one level |
| [`freeze` is shallow and raises `FrozenError`](freeze_and_frozen_error/README.md) | 201 | a frozen array still holds mutable strings, `Ractor.make_shareable` freezes deeply, and `# frozen_string_literal: true` freezes a file's literals |
| [Strings are mutable; `<<` keeps the object](strings_are_mutable/README.md) | 101 | `s << "x"` keeps `equal?` true, `s += "x"` makes a new object, `upcase!` returns `nil` when nothing changed, and a literal is chilled |
| [Duck typing asks `respond_to?`, not `class`](duck_typing_and_respond_to/README.md) | 201 | `respond_to?(:each)`, `is_a?` versus `instance_of?`, the `to_str`/`to_ary`/`to_proc`/`to_int` protocol, and strict `Array()`/`Integer()` |

## Read more

- [Object ↗](https://docs.ruby-lang.org/en/4.0/Object.html) — the methods every object has, including `equal?`, `==`, `eql?`, `===`, `freeze`, `dup`, `respond_to?` and `is_a?`
- [Symbol ↗](https://docs.ruby-lang.org/en/4.0/Symbol.html) and [NilClass ↗](https://docs.ruby-lang.org/en/4.0/NilClass.html) — the two classes that have no Python counterpart in the shape Ruby gives them
- [Data model ↗](https://docs.python.org/3/reference/datamodel.html) — Python's account of objects, identity, `__eq__`, `__hash__`, `__bool__` and the dunder protocols the twins call
- [Python crosswalk ↗](https://masiarek.github.io/python-learning-library/CROSSWALK.html) — the Python library's one-table map, for the reader going the other way
