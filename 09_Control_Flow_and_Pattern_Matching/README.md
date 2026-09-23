# 09 — Control flow and pattern matching

**One line:** Every Ruby construct is an expression with a value, `case` comes in two forms — `when` asks `===` and `in` matches a shape — and the loops that open no scope are the ones Ruby programmers avoid.

This chapter is about the statements a Python programmer already knows — `if`, `while`, `for`, `and`/`or`, a `switch` of some kind — and what Ruby does differently with each. The first three lessons are the grammar: there are no statements, only expressions, so `x = if … end` and `def` returning a Symbol are ordinary; `unless`, `until` and the trailing modifiers are the Perl-flavoured spellings *(Not machine-checked here.)*, with `begin … end while` as the do-while; and `and`/`or` are a second pair of boolean operators that bind *below* `=`, which is the trap behind `x = a or b`. The middle five are `case`. `case`/`when` sorts by `===`, a method every class answers in its own way — class membership, range cover, regex match, a lambda call — and `case`/`in` (2.7) matches *shapes*: array patterns, hash patterns, pins, guards, alternatives, and the two methods, `deconstruct` and `deconstruct_keys`, that let any object take part, with `NoMatchingPatternError` when nothing fits. The last lesson explains why Ruby code says `each` and not `for`: a `for` loop is `each` without the scope.

For a Python reader the model carries over more often than not. Python's `match`/`case` (3.10) has the same four families of pattern — sequence, mapping, class and capture — the same rule that a bare name binds, guards with `if`, and alternatives with `|`; `for` and `while` leak their variables in both languages; `and`/`or` return an operand in both. It breaks in the details, and every page measures them: Python has statements with no value and three expression-level crossings (`x if c else y`, `:=`, `lambda`); one pair of boolean operators with `and` above `or`; no `unless`, `until`, modifiers or do-while, but a `for … else` Ruby lacks; a `match` that silently does nothing when no case fits, where Ruby raises; `__match_args__` and `Sequence`/`Mapping` registration where Ruby has two duck-typed methods; and no pin, with dotted names as value patterns instead. Each lesson's Python twin prints the same numbered rows as the Ruby program, so the two can be read side by side.

| Lesson | Level | The one thing |
|---|---|---|
| [Everything is an expression, even `def` and `class`](everything_is_an_expression/README.md) | 101 | `if`, `case`, `begin`, `while`, `def` and `class` all evaluate to a value; Python has statements and three crossings |
| [`unless` negates `if`; modifiers hang off the end of a line](unless_until_and_modifiers/README.md) | 101 | `unless`, `until`, `x if c`, `begin … end while` (the do-while), `loop do`, and how `elsif` must be spelled |
| [`and`/`or` bind lower than `=`](and_or_precedence/README.md) | 201 | `x = false or true` assigns `false`; `and`/`or` share one precedence; `||=` keeps `0` and `""`; comparisons do not chain |
| [`case`/`when` asks `===`, and every class answers it its own way](case_when_uses_threequals/README.md) | 201 | one `case` sorts by class, Range, Regexp, lambda and splat, with no fall-through and a value at the end |
| [`case`/`in` matches shape, not just value](case_in_pattern_matching/README.md) | 201 | array, hash, nested and find patterns, `=>` on one line, `in` as a boolean, and what Python's `match` lacks |
| [A pin compares; a bare name binds](pin_guards_and_alternatives/README.md) | 201 | `in expected` matches anything; `^expected` compares; guards, `\|` alternatives and the two syntax errors |
| [`deconstruct` and `deconstruct_keys` let any object be matched](deconstruct_and_deconstruct_keys/README.md) | 301 | two duck-typed methods, the `keys` argument, `Struct`/`Data`/`MatchData` for free; Python's `__match_args__` |
| [Nothing matched: `case`/`in` raises, `case`/`when` returns `nil`](no_matching_pattern_error/README.md) | 201 | `NoMatchingPatternError` and `NoMatchingPatternKeyError#key`; Python's `match` is silent unless you `raise` |
| [`for` loops do not make a scope](for_loops_do_not_scope/README.md) | 201 | `for` and `while` leak every variable; a block does not; lambdas made in a `for` share one variable |

## Read more

- [Ruby docs: control expressions ↗](https://docs.ruby-lang.org/en/4.0/syntax/control_expressions_rdoc.html) — `if`, `unless`, `case`, `while`, `until`, `for`, the modifiers and `begin … end while`
- [Ruby docs: pattern matching ↗](https://docs.ruby-lang.org/en/4.0/syntax/pattern_matching_rdoc.html) — every pattern form, the pin, guards, `deconstruct` and `deconstruct_keys`
- [Ruby docs: precedence ↗](https://docs.ruby-lang.org/en/4.0/syntax/precedence_rdoc.html) — the operator table with `!` at the top and `and`/`or` at the bottom
- [Python docs: compound statements ↗](https://docs.python.org/3/reference/compound_stmts.html) — `if`, `while`, `for … else` and the `match` statement
- [PEP 636: structural pattern matching tutorial ↗](https://peps.python.org/pep-0636/) — Python's `match`/`case`, worked through the same way these pages do
