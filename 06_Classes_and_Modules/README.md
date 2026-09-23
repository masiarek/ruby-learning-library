# 06 — Classes and modules

**One line:** A Ruby class is an object whose method table is never closed, its `@variables` can be reached only through methods, and a module is a namespace, a mixin, or both — and each of those rules is one a Python programmer half-knows and needs to see measured.

This chapter is the object-oriented core: where state lives and who can see it (`@x`, `private`, `protected`, `@@count`), how a class is assembled (`class String` reopened, `include`, `extend`, `prepend`) and how a call finds its method (`ancestors`, `super`, `method_missing`), then the two things that give names their meaning — constants with their lexical lookup, and modules as namespaces. Every page builds a small class, asks it a numbered list of questions, and prints the answers; the Python twin asks the same questions of a Python class and prints its answers in the same rows.

For a Python programmer most of the vocabulary carries over and most of the rules do not. Attributes are public in Python and unreachable without a method in Ruby; `private` in Ruby restricts the *receiver*, not the calling class; a class attribute assigned through a subclass creates a shadow in Python and changes the parent's value in Ruby; a second `class Foo` statement reopens the class in Ruby and replaces it in Python. Where the two agree — inheritance through a chain, an explicit `super` in a constructor, a mutable class-level list that everybody shares — the twin's output makes that visible too. The model-level questions (singleton classes, `new` versus `initialize`, `eql?`/`hash`, refinements) are the next chapter, [07 — The object model](../07_The_Object_Model/README.md).

| Lesson | Level | The one thing |
|---|---|---|
| [Instance variables are private](instance_variables_are_private/README.md) | 101 | `acct.owner` is a method call, so `@owner` is unreachable until `attr_reader` writes that method; an unset `@x` reads as `nil` |
| [`private` means "no receiver"](private_means_no_receiver/README.md) | 201 | a private method may be called only receiverless or as `self.x`; `protected` admits another instance; `send` bypasses, `public_send` does not |
| [Classes are open](classes_are_open/README.md) | 201 | a second `class String` adds to the one `String`; a redefinition warns under `-w`; only the superclass may not change |
| [Mixins: `include`, `extend`, `prepend`](mixins_include_extend_prepend/README.md) | 201 | `include` goes behind the class in `ancestors`, `prepend` in front so its method runs first, `extend` into one object |
| [Method lookup walks `ancestors`; `super` continues it](method_lookup_and_super/README.md) | 301 | a call walks the chain left to right; bare `super` passes the parameters' current values, `super()` passes nothing; the walk ends in `method_missing` |
| [Constants are found lexically, then through ancestors](constants_and_lexical_scope/README.md) | 301 | `Module.nesting` first, then ancestors, then `Object`; `class Foo::Bar` cannot see `Foo`'s constants; reassignment warns by default |
| [Class variables are shared with subclasses](class_variables_are_shared/README.md) | 201 | `@@count` is one slot for the whole hierarchy and a subclass assignment changes the parent's; a class-level `@count` is per class |
| [A module is a namespace, and cannot be instantiated](modules_as_namespaces/README.md) | 101 | `Shop::Cart`, `Shop::VERSION`, `Shop.version`; `::` reaches a constant and `.` calls a method; `Shop.new` does not exist |

## Read more

- [Modules and Classes ↗](https://docs.ruby-lang.org/en/4.0/syntax/modules_and_classes_rdoc.html) — the syntax page: `class`, `module`, nesting, visibility, `alias` and `undef`
- [Module ↗](https://docs.ruby-lang.org/en/4.0/Module.html) — the class that `include`, `prepend`, `attr_reader`, `private`, `const_get` and `module_function` are methods of
- [Refinements ↗](https://docs.ruby-lang.org/en/4.0/syntax/refinements_rdoc.html) — the scoped alternative to reopening a class, measured in [07 — The object model](../07_The_Object_Model/README.md)
- [Classes (Python tutorial) ↗](https://docs.python.org/3/tutorial/classes.html) — scopes, class and instance variables, inheritance, private variables, name mangling: the Python side of every page here
- [Modules (Python tutorial) ↗](https://docs.python.org/3/tutorial/modules.html) — a module is a file and a package a folder, beside Ruby's `module` keyword
- [The Python 2.3 Method Resolution Order ↗](https://docs.python.org/3/howto/mro.html) — C3 linearization, the counterpart of `ancestors`
