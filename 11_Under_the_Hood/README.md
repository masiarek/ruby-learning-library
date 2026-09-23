# 11 — Under the hood

**One line:** Everything the Ruby VM works with — a method, a scope, a call, the heap, the bytecode, the JITs — has an object or a switch you can print from inside the program, and CPython exposes the same layers with one large difference in *when* things happen.

This chapter goes below the language. A method becomes a `Method` object with a receiver, an owner and parameters; a scope becomes a `Binding` that `eval` and ERB can read later; every call and return becomes a `TracePoint` event; the heap answers through `GC`, `ObjectSpace` and `WeakRef`; the code itself is visible as YARV instruction sequences and as Prism's syntax tree; and the JITs — YJIT and, new in 4.0, ZJIT — are switches a child process or a running program can flip. Every page prints names, booleans and comparisons: never an address, an offset, a count of live objects or a timing, because those are the things that change between one run and the next.

For a Python programmer most of the model carries over. A bound method is `obj.f`; `locals()` and frame objects stand in for a `Binding`; `sys.settrace` and `sys.setprofile` are the trace hooks; `gc` and `weakref` are the heap's API; `compile`, `dis` and `ast` show the code. Three things do not carry over. Python 3 has no unbound method and `types.MethodType` binds a function to anything without checking, where Ruby's `bind` is type-checked. CPython frees an object the instant its reference count reaches zero, so `__del__` and a dead weak reference happen on a predictable line, where Ruby's tracing collector promises only "eventually". And CPython folds `1 + 2` at compile time while YARV emits a real `opt_plus`, because `Integer#+` can be redefined and `int.__add__` cannot. The chapter's Python twins were written to print the same rows under 3.12 and 3.14 — which meant leaving `dis` listings, `co_consts`, `locals()` write-through, reference-count numbers and the 3.13 JIT and free-threading switches in prose.

| Lesson | Level | The one thing |
|---|---|---|
| [A method is a value once you ask for it](method_objects_and_unbound_methods/README.md) | 301 | `method(:x)` reifies a method with its receiver and owner; `instance_method` gives an `UnboundMethod` whose `bind` is type-checked, and Python's `Cls.f` is just a function |
| [A Binding is a scope you can carry around](binding_and_eval/README.md) | 301 | a `Binding` keeps a method's locals and `self` alive for `eval` and ERB; a variable created through it lives in the binding, and Python's `locals()` is only a snapshot dict |
| [TracePoint sees every call and return](tracepoint/README.md) | 301 | `:call`/`:return`/`:raise` events carry the method, its class and its return value, `enable(target:)` narrows to one method, and tracing is off inside the hook — as it is in `sys.settrace` |
| [The GC answers comparisons, not counts](object_space_and_gc/README.md) | 301 | `GC.count` and `GC.stat` only grow, a `WeakRef` may or may not be dead after `GC.start`, a finalizer runs at exit at the latest; CPython's refcount frees on the line `del` runs |
| [Ruby shows you its bytecode and its syntax tree](the_bytecode_you_can_see/README.md) | 301 | `InstructionSequence.compile(src).disasm` and `Prism.parse(src).value` expose both layers; `1 + 2` stays an `opt_plus` in Ruby and folds to `3` in CPython |
| [YJIT and ZJIT are switches, not defaults](jits_and_the_interpreter/README.md) | 301 | `RubyVM::YJIT.enabled?` is false until `--yjit` or `RubyVM::YJIT.enable`, ZJIT likewise; CPython's JIT and free-threading have no switch both CI Pythons share |

## Read more

- [`RubyVM` ↗](https://docs.ruby-lang.org/en/4.0/RubyVM.html) — the namespace for the instruction sequences, the JITs and the VM's statistics
- [`Method` ↗](https://docs.ruby-lang.org/en/4.0/Method.html), [`Binding` ↗](https://docs.ruby-lang.org/en/4.0/Binding.html), [`TracePoint` ↗](https://docs.ruby-lang.org/en/4.0/TracePoint.html), [`GC` ↗](https://docs.ruby-lang.org/en/4.0/GC.html) — the four core classes the chapter reads
- [`sys` ↗](https://docs.python.org/3/library/sys.html) — Python's trace hooks, flags and implementation record
- [`dis` ↗](https://docs.python.org/3/library/dis.html) and [`gc` ↗](https://docs.python.org/3/library/gc.html) — the bytecode disassembler and the cycle collector, Python's side of the last three lessons
