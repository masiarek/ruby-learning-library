# 08 — Errors and Exceptions

**One line:** Ruby's exceptions are objects raised by a method and rescued by class, with a default — `StandardError` — that decides what a plain `rescue` sees, a `cause` chain that keeps the original error, and two things Python folds into exceptions kept apart: the `throw`/`catch` jump and the warning channel.

A Python programmer arrives with the right model: `try`/`except`/`else`/`finally` is `begin`/`rescue`/`else`/`ensure`, `raise` is `raise`, custom errors are subclasses, and `sys.exit` really raises `SystemExit` in both languages. What changes is the defaults and the extras. A bare `rescue` catches `StandardError` — the half of the tree a program should handle — and lets `SystemExit`, `Interrupt`, `NoMemoryError`, `SystemStackError` and every `ScriptError` (including, surprisingly, `NotImplementedError`) pass, which is the opposite of Python's bare `except:` and the same as its `except Exception:`. `raise` has four spellings and a hook (`Klass.exception`, `obj.exception`) that lets any object become an error. `retry` re-runs a block from inside its `rescue`; Python needs a loop. `rescue` has a one-line modifier form; Python rejected the idea (PEP 463). A `raise` inside a `rescue` records a `cause`, one field where Python has `__context__`, `__cause__` and `__suppress_context__`.

The extras are the two mechanisms Ruby keeps separate. `throw`/`catch` is a labelled non-local jump that `rescue` never sees; Python uses an exception class for the same job, and an `except Exception` in between will intercept it. `warn` and `Warning` are a channel to stderr with category switches and a lint mode (`-w`), not exceptions; Python's `Warning` *is* an `Exception`, which is why `-W error` works there. The chapter ends with the library's errors page — twenty-nine messages, what each means, the fix, and the lesson that explains it. Every claim on every page is printed by a program: Ruby 4.0 messages are stable and appear in full; the Python twins print exception types only, because CPython rewords its messages between 3.12 and 3.14.

| Lesson | Level | The one thing |
|---|---|---|
| [`rescue`, `else` and `ensure` run in a fixed order](rescue_ensure_else_and_retry/README.md) | 101 | body, then `rescue` or `else`, then `ensure` — even on `return`; `retry` re-runs the body; `begin … end` is an expression |
| [A bare `rescue` catches `StandardError`, not everything](standard_error_is_the_default/README.md) | 201 | `SystemExit`, `Interrupt`, `SystemStackError` and `NotImplementedError` slip past `rescue => e`; `rescue Exception` swallows `exit` |
| [`raise` has four forms](raise_has_four_forms/README.md) | 201 | `raise "msg"`, `raise Klass`, `raise Klass, "msg"`, `raise Klass.new`; a bare `raise` re-raises `$!`; a non-exception is a `TypeError` |
| [Custom exceptions subclass `StandardError`](custom_exception_classes/README.md) | 201 | a default message via `super`, readers for extra data, a family caught by its base, `detailed_message`, the `exception` hook |
| [Exceptions have a `cause`](exceptions_have_a_cause/README.md) | 201 | a `raise` inside `rescue` records the handled exception; `cause:` sets it, `cause: nil` hides it, a loop is an `ArgumentError` |
| [`rescue` works as a modifier, for `StandardError` only](rescue_as_a_modifier/README.md) | 201 | `expr rescue fallback` binds after `=`, cannot stand bare in an argument list, is legal in `{ }` where a `rescue` clause is not, and hides typos |
| [`throw` and `catch` are not exceptions](throw_and_catch/README.md) | 201 | a labelled jump that returns a value, skips `rescue`, runs `ensure`, matches tags by identity; unmatched, it is `UncaughtThrowError` |
| [`exit` raises `SystemExit`](exit_at_exit_and_system_exit/README.md) | 201 | `exit` unwinds and runs `at_exit` handlers in reverse; `exit!` does not; `abort` is `exit 1` plus stderr; an unrescued `Interrupt` ends the process by the signal |
| [Warnings go to stderr, and `-w` finds more of them](warnings_and_dash_w/README.md) | 201 | `warn`, `$VERBOSE`, `Warning[:deprecated]`, what `-w` reports on a sloppy file, and capturing warnings in-process |
| [Common error messages](common_error_messages/README.md) | 101 | twenty-nine messages with the code, the mistake, the fix and the lesson — and the Python type that means the same |

## Read more

- [Exceptions ↗](https://docs.ruby-lang.org/en/4.0/syntax/exceptions_rdoc.html) — the Ruby syntax reference for `begin`, `rescue`, `else`, `ensure` and `retry`
- [Exception ↗](https://docs.ruby-lang.org/en/4.0/Exception.html) — the class reference, with the built-in hierarchy
- [Kernel#raise ↗](https://docs.ruby-lang.org/en/4.0/Kernel.html#method-i-raise), [Kernel#catch ↗](https://docs.ruby-lang.org/en/4.0/Kernel.html#method-i-catch), [Warning ↗](https://docs.ruby-lang.org/en/4.0/Warning.html) — the methods and the module the chapter measures
- [Errors and Exceptions ↗](https://docs.python.org/3/tutorial/errors.html) — the Python tutorial chapter, the twin of the first five lessons
- [Built-in Exceptions ↗](https://docs.python.org/3/library/exceptions.html) — Python's hierarchy and its reference table of types
- [The `warnings` module ↗](https://docs.python.org/3/library/warnings.html) — Python's warning filters and `-W`
