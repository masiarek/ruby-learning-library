# Twenty-three Python traps for a Ruby programmer

**Level:** 201 · someone who writes Ruby and has just started reading Python

**One line:** The twenty-three places where a Ruby reflex gives the wrong answer in Python — a `[]` default argument is shared across calls, a closure in a loop sees the last value, `round(2.5)` is `2`, `self` must be declared, indentation is grammar, `x = 5 if False` will not parse and `if False: x = 5` leaves `x` undefined, `d[key]` raises — each measured on one line in Python, with Ruby's answer beside it.

This is the mirror of the previous page, and here the Python twin is the primary program: it measures the trap, and the Ruby program prints what Ruby does in the same spot so the two outputs read side by side. The pattern behind most rows: Python evaluates a default argument once at `def` time where Ruby evaluates it per call; Python closures capture variables where Ruby block parameters are fresh per iteration; Python has a larger set of false values; Python's `is` is Ruby's `equal?`; Python's functions and methods are the same thing, so `self` is a parameter; and Python's grammar owns the indentation, the `elif`, the `for … else` and the chained comparison that Ruby leaves to conventions or does not have.

| # | The trap | Python says | Ruby says | Lesson |
|---|---|---|---|---|
| 1 | a mutable default argument is shared | `f()` then `f()` gives `[1, 1]` | a fresh `[]` per call | [Default arguments are evaluated each call](../../02_Methods_and_Arguments/default_arguments_are_evaluated_each_call/README.md) |
| 2 | closures bind late | `[lambda: i for i in range(3)]` all give `2` | block parameters are fresh: `1, 2, 3` | [Closures capture variables](../../03_Blocks_Procs_and_Lambdas/closures_capture_variables/README.md) |
| 3 | `is` is identity, `==` is value | `[] is []` is `False` | `equal?` versus `==` | [Four kinds of equality](../../01_Objects_and_Values/four_kinds_of_equality/README.md) · [comparing int and float ↗](https://masiarek.github.io/python-learning-library/03_Numbers/comparing_int_and_float/index.html) |
| 4 | `/` is true division, `//` floors | `7 / 2` is `3.5` | `7 / 2` is `3` | [Integer division floors](../../15_Numbers/integer_division_floors/README.md) |
| 5 | `round` is banker's | `round(2.5)` is `2` | `2.5.round` is `3` | [Floats and rounding](../../15_Numbers/floats_and_rounding/README.md) |
| 6 | `self` is explicit | a method without `self` cannot be called on an instance | `self` is implicit | [`self` is implicit](../../02_Methods_and_Arguments/self_is_implicit/README.md) |
| 7 | indentation is syntax | `IndentationError` at compile time | mis-indented code runs | [Indentation is convention in Ruby, syntax in Python](../style_and_naming/README.md) |
| 8 | `print` is a function | `print 'x'` is a `SyntaxError` | `puts "x"` needs no parentheses | [Parentheses are optional](../../02_Methods_and_Arguments/parentheses_are_optional/README.md) · [repr is not str ↗](https://masiarek.github.io/python-learning-library/01_Text_and_Bytes/repr_is_not_str/index.html) |
| 9 | `elif` | `elsif` is a `SyntaxError` | `elsif` | [`unless`, `until` and modifiers](../../09_Control_Flow_and_Pattern_Matching/unless_until_and_modifiers/README.md) |
| 10 | `for … else` | `else` runs when the loop did not `break` | no such clause; `find` returns `nil` | [`for` loops do not scope](../../09_Control_Flow_and_Pattern_Matching/for_loops_do_not_scope/README.md) |
| 11 | `list.sort()` returns `None` | `sorted()` returns the new list | `sort!` returns the receiver | [Bang and question methods](../../02_Methods_and_Arguments/bang_and_question_methods/README.md) |
| 12 | strings are immutable | `s[0] = "x"` is a `TypeError` | `s[0] = "x"` works | [Strings are mutable](../../01_Objects_and_Values/strings_are_mutable/README.md) · [bytearray is mutable ↗](https://masiarek.github.io/python-learning-library/01_Text_and_Bytes/bytearray_is_mutable/index.html) |
| 13 | no `?` or `!` in names | `def empty?()` is a `SyntaxError` | `empty?` and `save!` are ordinary names | [Bang and question methods](../../02_Methods_and_Arguments/bang_and_question_methods/README.md) |
| 14 | `range` is half-open | `range(1, 4)` is `1, 2, 3` | `1..3` is closed, `1...3` half-open | [Ranges: two dots and three](../../04_Collections/ranges_two_dots_and_three/README.md) · [slicing is not indexing ↗](https://masiarek.github.io/python-learning-library/01_Text_and_Bytes/slicing_is_not_indexing/index.html) |
| 15 | `d[key]` raises `KeyError` | `d.get(key)` is the `nil`-returning form | `h[:k]` is `nil`; `fetch` raises | [Hashes and default values](../../04_Collections/hashes_and_default_values/README.md) |
| 16 | `x = 5 if False` will not parse | and `if False: x = 5` leaves `x` undefined | `x = 5 if false` defines `x` as `nil` | [`unless`, `until` and modifiers](../../09_Control_Flow_and_Pattern_Matching/unless_until_and_modifiers/README.md) |
| 17 | `__init__`, not `initialize` | a `def initialize` is never called | `new` calls `initialize` | [`new`, `allocate` and `initialize`](../../07_The_Object_Model/new_allocate_and_initialize/README.md) |
| 18 | `global` and `nonlocal` | assigning in an inner `def` makes a new local | a block assigns the outer local; a `def` is a new scope | [Closures capture variables](../../03_Blocks_Procs_and_Lambdas/closures_capture_variables/README.md) |
| 19 | `lambda` is one expression | `lambda: x = 1` is a `SyntaxError` | a lambda body holds statements | [Procs and lambdas differ](../../03_Blocks_Procs_and_Lambdas/procs_and_lambdas_differ/README.md) |
| 20 | `[]` and `0` are falsy | `bool([])` is `False` | both are truthy | [nil, false and truthiness](../../01_Objects_and_Values/nil_false_and_truthiness/README.md) |
| 21 | `len(x)` is a function | `"abc".len` is an `AttributeError` | `"abc".length` | [Everything is an object](../../01_Objects_and_Values/everything_is_an_object/README.md) |
| 22 | `(1,)` is a tuple | `(1)` is just `1` | no tuple; a frozen Array | [`return a, b` returns one Array](../multiple_return_values/README.md) |
| 23 | `1 < x < 3` chains | `1 < 3 < 2` is `False` | `1 < 2 < 3` is a `NoMethodError` on `true` | [`and`/`or` bind below `=`](../../09_Control_Flow_and_Pattern_Matching/and_or_precedence/README.md) |

<!-- output:gotchas_for_ruby_programmers_in_python_py -->
*Verified output of [`gotchas_for_ruby_programmers_in_python_py.py`](examples/gotchas_for_ruby_programmers_in_python_py.py) — regenerated by `tools/run_examples.py`, never hand-typed.*

```text
 1. def f(a=[]): a.append(1); f() / f()          [1] / [1, 1]  (one list, shared)
 2. [lambda: i for i in range(3)] / lambda i=i: i [2, 2, 2] / [0, 1, 2]
 3. m = 256; n = 256; m is n / [] is [] / [] == [] True / False / True
 4. 7 / 2 / 7 // 2 / -7 // 2                     3.5 / 3 / -4
 5. round(2.5) / round(3.5) / round(-2.5)        2 / 4 / -2
 6. class NoSelf: def m(): ...; NoSelf().m()     TypeError  (self is a real parameter)
 7. compile('if True:\nprint(1)')                IndentationError
 8. print 'x' / print('a', 'b', sep='-')         SyntaxError / printed 'a-b\n'
 9. elif / elsif                                 compiles / SyntaxError
10. for ... else, without and with a break       ['else ran (no break)']
11. a = [3, 1]; a.sort() / sorted([3, 1])        None / [1, 3]
12. s = "abc"; s[0] = "x"                        TypeError
13. def empty?(): ... / def save!(): ...         SyntaxError / SyntaxError
14. list(range(1, 4)) / list(range(1, 3))        [1, 2, 3] / [1, 2]  (half-open)
15. d = {}; d["k"] / d.get("k")                  KeyError / None
16. if False: y = 5; y / x = 5 if False          NameError / SyntaxError
17. def initialize(self) is never called: Account().balance AttributeError
18. count += 1 in an inner def / with nonlocal   UnboundLocalError / 1
19. lambda: x = 1 / lambda v: v * 2              SyntaxError / 4
20. bool([]) / bool(0) / bool(0.0)               False / False / False
21. len("abc") / "abc".len                       3 / AttributeError
22. type((1,)) / type((1)) / type([1])           tuple / int / list
23. 1 < 2 < 3 / 1 < 3 < 2                        True / False  (chained comparison)
```
<!-- /output -->

## Reading the output

- **Rows 1–2** are the two classic Python questions: the default list is one object created at `def` time, so the second call sees the first call's append; the lambdas in the comprehension all read `i` after the loop ended, and the `i=i` default freezes each value.
- **Rows 3–5**: `is` is identity — `256` is cached so two variables holding it are one object, while two empty lists are two objects; `/` always gives a float and `//` floors toward negative infinity; `round` goes to the even neighbour on a half.
- **Rows 6–8**: a method defined without `self` cannot take the instance it is called on (`TypeError`); a body at the wrong column is an `IndentationError` before anything runs; `print` without parentheses is a `SyntaxError` and with them takes `sep=`.
- **Rows 9–10**: `elsif` does not parse; the `for … else` clause ran only in the loop that did not `break`.
- **Rows 11–13**: `sort()` returns `None`, `sorted()` a new list; item assignment on a `str` raises; a `?` or `!` in a name is a `SyntaxError`.
- **Rows 14–16**: `range(1, 4)` stops before `4`; `d["k"]` raises where `d.get("k")` returns `None`; the modifier `if` does not parse and the block `if` leaves `y` undefined — a `NameError`.
- **Rows 17–18**: a `def initialize` is an ordinary method nobody calls, so `balance` was never set (`AttributeError`); `count += 1` in an inner function makes `count` local to it and reads it before assignment (`UnboundLocalError`), and `nonlocal` fixes it.
- **Rows 19–23**: a `lambda` holds one expression; `[]`, `0` and `0.0` are all `False`; `len` is a function and `.len` an `AttributeError`; the comma makes the tuple, not the parentheses; and `1 < 3 < 2` is `False` because the comparison chained as `1 < 3 and 3 < 2`.

## Compared with Python

Here the Python output *is* the measurement, so this section reads Ruby's program instead. Rows 1–2: Ruby evaluates `a = []` on every call and gives each block invocation a fresh `i`, so neither trap exists. Row 3 is the same distinction under other names, `equal?` and `==`. Rows 4–5 flip: `7 / 2` is `3`, `2.5.round` is `3`, and `half: :even` is the option that reproduces Python. Rows 6–8 are the language shape: `self` is implicit, a `def` with every line at column 0 runs, and `puts "x"` is a call. Row 10 has no `for … else` — `find` returns `nil` when nothing matched and `each` returns its receiver. Row 11: `sort!` returns the receiver, and the bang family returns `nil` only to say "nothing changed". Rows 12–14: the string was changed in place, `empty?` and `save!` compile, and Ruby has both range forms. Rows 15–16 are the two `nil`s where Python raises — a missing key and the never-run modifier assignment — and `fetch` is the raising form. Row 17: `def __init__` is ignored by `new`, so `@balance` is `nil`. Row 18: a block assigned the outer `count`, and a `def` cannot see it at all (`NameError`), so Ruby needs neither `nonlocal` nor `global`. Rows 19–23: a lambda body holds statements, `[]` and `0` are truthy, `length` is a method, there is no tuple (a frozen Array stands in), and `1 < 2 < 3` is a `NoMethodError` because `true < 3` has no meaning.

<!-- output:gotchas_for_ruby_programmers_in_python_rb -->
*Verified output of [`gotchas_for_ruby_programmers_in_python_rb.rb`](examples/gotchas_for_ruby_programmers_in_python_rb.rb) — regenerated by `tools/run_examples.py`, never hand-typed.*

```text
 1. def f(a = []); a << 1; end; f / f            [1] / [1]  (a fresh array per call)
 2. (1..3).map { |i| -> { i } }.map(&:call)      [1, 2, 3]
 3. 256.equal?(256) / "a".equal?("a") / "a" == "a" true / false / true
 4. 7 / 2 / 7.fdiv(2) / -7 / 2                   3 / 3.5 / -4
 5. 2.5.round / 3.5.round / 2.5.round(half: :even) 3 / 4 / 2
 6. def m = self.class.name; WithSelf.new.m      "WithSelf"  (self is implicit)
 7. eval of a def with every line at column 0    1  (ran)
 8. puts "x" is a method call without parentheses compiles / compiles
 9. elsif / elif                                 compiles / SyntaxError
10. no for-else: [1, 2].find { it == 9 } / each returns nil / [1, 2]
11. a = [3, 1]; a.sort! / [1, 2].uniq!           [1, 3] / nil  (bang returns self, or nil for no change)
12. s = "abc"; s[0] = "x"; s                     "xbc"
13. def empty?; end / def save!; end             compiles / compiles
14. (1..3).to_a / (1...3).to_a                   [1, 2, 3] / [1, 2]  (.. is closed, ... half-open)
15. h = {}; h[:k] / h.fetch(:k)                  nil / KeyError
16. y = 5 if false; y / defined?(y)              nil / "local-variable"
17. def __init__ is never called: @balance after new nil
18. a block assigns the outer local / a def sees it? 1 / NameError  (no nonlocal; a def is a new scope)
19. ->(v) { w = v * 2; w + 1 }.call(2)           5  (a lambda holds statements)
20. [] and 0 in a condition                      truthy / truthy
21. "abc".length / length("abc")                 3 / NoMethodError
22. [1].class / (1).class / no tuple: [1].freeze.frozen? Array / Integer / true
23. 1 < 2 < 3                                    NoMethodError  (no chained comparison: (1 < 2) < 3 asks true < 3)
```
<!-- /output -->

## Try it

1. Reproduce Python's arithmetic in Ruby: write `py_floor_div(a, b)` with `Integer#div` and `py_round(x)` with `round(half: :even)`, and print a table for `7, 2`, `-7, 2`, `7, -2`, `-7, -2` and for `0.5`, `1.5`, `2.5`, `3.5`, `-2.5`, beside Ruby's own `/` and `round`.
2. Write a `make_counters` method in Ruby that returns three lambdas from a loop, one per index, and show each returns its own index; then write the Python version twice, once with the late-binding bug and once with the `i=i` fix, and run it under `python3 -I`.

<details markdown="1">
<summary><strong>Solution to 1</strong></summary>

<!-- source:gotchas_for_ruby_programmers_in_python_kata_rb -->
*[`gotchas_for_ruby_programmers_in_python_kata_rb.rb`](examples/gotchas_for_ruby_programmers_in_python_kata_rb.rb) in full — pasted here by `tools/run_examples.py` from the file CI runs.*

```ruby
# Kata: Python's `//` and `round()` reproduced in Ruby, so the numbers a Ruby
# programmer sees in Python stop being surprising.

def py_floor_div(a, b) = a.div(b)          # Integer#div floors, like Python's //
def py_round(x) = x.round(half: :even)     # Python rounds half to even

puts format("%-10s %-8s %s", "a, b", "a / b", "a // b")
[[7, 2], [-7, 2], [7, -2], [-7, -2]].each do |a, b|
  puts format("%-10s %-8s %s", "#{a}, #{b}", a.fdiv(b), py_floor_div(a, b))
end

puts
puts format("%-6s %-12s %s", "x", "x.round", "py_round(x)")
[0.5, 1.5, 2.5, 3.5, -2.5].each do |x|
  puts format("%-6s %-12s %s", x, x.round, py_round(x))
end
```
<!-- /source -->

<!-- output:gotchas_for_ruby_programmers_in_python_kata_rb -->
*Verified output of [`gotchas_for_ruby_programmers_in_python_kata_rb.rb`](examples/gotchas_for_ruby_programmers_in_python_kata_rb.rb) — regenerated by `tools/run_examples.py`, never hand-typed.*

```text
a, b       a / b    a // b
7, 2       3.5      3
-7, 2      -3.5     -4
7, -2      -3.5     -4
-7, -2     3.5      3

x      x.round      py_round(x)
0.5    1            0
1.5    2            2
2.5    3            2
3.5    4            4
-2.5   -3           -2
```
<!-- /output -->

</details>

## See also

- [Twenty-three Ruby traps for a Python programmer](../gotchas_for_python_programmers/README.md) — the same crossing, walked the other way
- [There is more than one way, and one obvious way](../the_ruby_way_and_the_pythonic_way/README.md) — the idioms these traps sit inside
- [`x ||= v` assigns when `x` is nil or false](../or_equals_and_nil_guards/README.md) — how row 20's falsy `0` and `""` break `x = x or 5`
- [`return a, b` returns one Array](../multiple_return_values/README.md) — the tuple of row 22, from the Ruby side
- [Python FAQ: programming ↗](https://docs.python.org/3/faq/programming.html) — the maintainers' own answers to rows 1, 2 and 18
