# 03 — Blocks, procs and lambdas

**One line:** A block is syntax on one method call, a proc or lambda is the object it can become, and all of them are closures — where Python has one kind of function object and spells each of these ideas differently.

This chapter is the part of Ruby a Python programmer has no word for. A block — the `{ |x| … }` or `do … end` after a call — is not a value: it cannot be assigned, a call carries at most one, and `yield` runs it from inside the method. It becomes an object only through an `&block` parameter, and the object it becomes is a `Proc`, of which there are two kinds: a proc, which pads and drops arguments and `return`s from the method that wrote it, and a lambda, which checks its argument count and `return`s from itself. Both are closures over the variables around them — the variables, not their values — and a block parameter is a fresh variable per call, which is why the lambda-in-a-loop trap is rarer here than in Python and still present when the variable lives outside the block. The chapter then covers the short spellings, `&:sym` and `it`/`_1`; the three exits, `next`, `break` and `return`, each reaching a different distance; writing an iterator with one `each` and `include Enumerable`; and `curry` with the composition operators `>>` and `<<`.

The Python model carries over in two places: a nested `def` or `lambda` closes over its enclosing function's variables in the same way, and `return` inside a `for` loop leaves the function just as `return` inside a block leaves the method. It breaks everywhere else. Python passes callables — a `lambda` of one expression, an inner `def`, a `functools.partial` — where Ruby attaches a block; it has no lenient proc, no non-local `return` from a callback, no `break` with a value, no `redo`, no implicit `it`, no `curry` and no composition operator; and its iterator is a protocol of `__iter__` and `next` rather than a method that yields, with `filter` and `map` lazy by default where Ruby asks for `lazy`. Every page measures both sides: the Ruby program and its Python twin print the same numbered rows, and where the languages differ, the row prints two different values.

| Lesson | Level | The one thing |
|---|---|---|
| [Blocks are not objects](blocks_are_not_objects/README.md) | 101 | a block rides on one call: `yield`, `block_given?`, `LocalJumpError`, `&block` reifies it, `{ }` binds tighter than `do … end` |
| [Procs and lambdas differ in arity and `return`](procs_and_lambdas_differ/README.md) | 201 | a lambda checks its arguments and returns from itself; a proc pads, drops, and returns from the enclosing method |
| [Closures capture variables, not values](closures_capture_variables/README.md) | 201 | a closure sees later assignments; a block parameter is fresh per call, an outer variable is shared; a `def` is not a closure |
| [`&:sym` calls `Symbol#to_proc`](symbol_to_proc/README.md) | 201 | `&x` calls `x.to_proc`; a symbol's proc calls the method on its first argument, so `map(&:upcase)` and `inject(&:+)` are one trick |
| [`it` and `_1` name the block's parameter](it_and_numbered_parameters/README.md) | 201 | `_1`, `_2` and `it` are parameters the parser polices: no mixing, no nested `_1`, none beside `\|x\|`; a local `it` shadows them |
| [`next`, `break` and `return` leave a block differently](next_break_and_return_in_blocks/README.md) | 201 | `next v` is the block's value, `break v` is the call's value, `return` leaves the method; `redo` repeats the iteration |
| [An iterator is a method that yields](writing_an_iterator/README.md) | 201 | one `each` plus `include Enumerable` earns the toolbox; `to_enum` and `Enumerator.new` build lazy, even infinite, enumerators |
| [Procs curry and compose](curry_and_composition/README.md) | 201 | `curry` chains one-argument lambdas, `>>` and `<<` compose any callables, `parameters` and `arity` describe the shape |

## Read more

- [Proc ↗](https://docs.ruby-lang.org/en/4.0/Proc.html) — the class page: lambda semantics, `curry`, `>>`, `parameters`, `arity`, and the table of proc-versus-lambda differences
- [Calling methods: block argument ↗](https://docs.ruby-lang.org/en/4.0/syntax/calling_methods_rdoc.html) — how a block or an `&` argument attaches to a call
- [Control expressions ↗](https://docs.ruby-lang.org/en/4.0/syntax/control_expressions_rdoc.html) — `next`, `break`, `redo` and `return`, and what each one leaves
- [Enumerator ↗](https://docs.ruby-lang.org/en/4.0/Enumerator.html) — `Enumerator.new`, `next`, `lazy`, `produce`, and the size block of `to_enum`
- [Functional programming HOWTO ↗](https://docs.python.org/3/howto/functional.html) — Python's view of iterators, generators, `functools` and `itertools`
- [`functools` ↗](https://docs.python.org/3/library/functools.html) — `partial` and `reduce`, the twins of `curry` and `inject`
- [Naming and binding ↗](https://docs.python.org/3/reference/executionmodel.html#naming-and-binding) — the closure rules behind `nonlocal` and the loop trap
