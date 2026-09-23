# 10 — Metaprogramming

**One line:** In Ruby a class body is code that runs, a method call is a message, and a class is an object — so the program can write, inspect and reroute its own methods at run time, and every one of those moves has a Python spelling that is close enough to be useful and different enough to be measured.

This chapter is the eight moves that Ruby libraries are built from: calling a method by a name computed at run time (`send`), making methods in a loop (`define_method`), answering messages nobody defined (`method_missing`), running a block as somebody else (`instance_eval`, `class_eval`), being told when code is defined (`inherited`, `included`, `method_added`), turning those moves into a readable DSL, making classes without a `class` keyword (`Class.new`), and asking any object what it is (`methods`, `parameters`, `defined?`). Each lesson is one Ruby program and one Python twin that print the same numbered rows, so the comparison is a diff you can read.

For a Python programmer the map is mostly one-to-one and worth learning precisely, because this is where the two object models differ most. `send` is `getattr(...)()` — but Ruby has a `private` to bypass and Python has only a naming convention and compile-time mangling. `define_method` is `setattr(Cls, name, func)` — but a Ruby block gets a fresh loop variable per call and a Python lambda binds late, so Python needs the `c=c` default. `method_missing` is `__getattr__` — but Python's `hasattr` sees ghosts for free and Ruby needs `respond_to_missing?`. `instance_eval` has no twin at all, because Python cannot move `self`; `exec`, `setattr`, `classmethod` and `types.MethodType` do its jobs one at a time. Ruby's seven definition hooks are Python's single `__init_subclass__` plus a metaclass, and where Python lets you subclass `type` — that is what a metaclass is — Ruby refuses `Class.new(Class)` and uses singleton classes and hooks instead. `Class.new` is `type(name, bases, ns)`, except that a Ruby class is anonymous until a constant names it, and a Python class is named at birth.

| Lesson | Level | The one thing |
|---|---|---|
| [`send` reaches private methods; `public_send` does not](send_and_public_send/README.md) | 301 | `send` ignores `private`, `public_send` honours it, `__send__` survives an overridden `send`; `getattr` has no visibility to ignore |
| [`define_method` turns a block into a method](define_method/README.md) | 301 | the block is a closure with a fresh loop variable per `each` call; Python's `setattr` + lambda binds late and needs `c=c` |
| [`method_missing` needs `respond_to_missing?`](method_missing_and_respond_to_missing/README.md) | 301 | the hook runs only after lookup fails and must call `super`; `respond_to?` and `method` stay blind without the second hook, while `hasattr` sees `__getattr__` through |
| [`instance_eval` moves `self`, `class_eval` moves `def`](instance_eval_and_class_eval/README.md) | 301 | both change `self`; only the default definee differs, so `class_eval { def }` makes instance methods and `instance_eval { def }` singleton ones; Python cannot move `self` |
| [Hooks fire when code is defined, not when it runs](hooks_inherited_included_method_added/README.md) | 301 | `inherited`, `included`, `extended`, `prepended`, `method_added`, `const_added` are private callbacks; Python has `__init_subclass__` and a metaclass's `__prepare__`/`__new__` |
| [A DSL is `instance_eval` plus stored blocks](building_a_dsl/README.md) | 301 | bare words are methods of the object being built, blocks are filed for later, and the block loses the caller's `@ivars`; Python uses class bodies, decorators, `with` and `**kwargs` |
| [`Class.new` makes a class; a constant names it](classes_at_runtime/README.md) | 301 | a class is anonymous until first assigned to a constant, and `Class.new(Class)` is refused; `type()` names at birth and subclassing `type` is a metaclass |
| [An object can list its methods and variables](introspection/README.md) | 301 | `methods`, `instance_methods(false)`, `parameters`, `source_location`, `ancestors`, `defined?`, `__method__`; Python's `dir`, `vars`, `inspect` and the frame |

## Read more

- [`Object#send` ↗](https://docs.ruby-lang.org/en/4.0/Object.html#method-i-send) — the Ruby docs entry, with `public_send` and `__send__` beside it
- [`Module#define_method` ↗](https://docs.ruby-lang.org/en/4.0/Module.html#method-i-define_method) — the three things it accepts: a block, a `Method`, a `Proc`
- [`BasicObject#method_missing` ↗](https://docs.ruby-lang.org/en/4.0/BasicObject.html#method-i-method_missing) — and `instance_eval`, `instance_exec`, `__send__` on the same page
- [`Class#inherited` ↗](https://docs.ruby-lang.org/en/4.0/Class.html#method-i-inherited) — with `subclasses` and `attached_object`; the `Module` page has `included`, `method_added` and `const_added`
- [Python data model: customizing class creation ↗](https://docs.python.org/3/reference/datamodel.html#customizing-class-creation) — `__init_subclass__`, `__set_name__`, metaclasses and `__prepare__`
- [Python `getattr`, `setattr`, `type` ↗](https://docs.python.org/3/builtins/functions.html) — the builtins that do what `send`, `define_method` and `Class.new` do
- [Python `inspect` ↗](https://docs.python.org/3/library/inspect.html) — `signature`, `getsourcefile`, `getmembers`: the introspection twin
- [Python `types.new_class` ↗](https://docs.python.org/3/library/types.html#types.new_class) — `type()` with keyword options for `__init_subclass__`
