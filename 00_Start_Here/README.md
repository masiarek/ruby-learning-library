# 00 — Start here

**Level:** 101 · read this first

This library is for someone who writes Python and is learning Ruby, someone who writes Ruby and wants to see what Python does with the same idea, and anyone who has been told "everything is an object" or "a block is not a closure" and would rather watch it happen than take it on trust. Every page asks one question of both languages and prints both answers.

## What it assumes

That you can read a short program in at least one of the two languages. Nothing else: a page that needs an idea from another page links it, and a page that needs an idea about text, encodings or regular expressions links the [Ruby text library ↗](https://masiarek.github.io/ruby-text-learning-library/), which owns those subjects.

## How to read a page

Each has the same shape: a **one-line** claim, the idea in prose, an output block from a Ruby program in that page's `examples/` folder, a reading of that output, then *Compared with Python* — the same question put to Python by a second program, with its output beside the first — then an exercise with a solution you can unfold, and links. The output blocks are generated, never typed: if a page shows a value, Ruby 4.0 or Python 3 printed it, on Ubuntu and on macOS, and the build fails the day it stops.

Two programs per page is the point. A comparison you remember is a claim; a comparison you can run is a measurement, and the two languages are close enough that memory gets it wrong more often than you would think — which of them rounds `2.5` up, which one leaks a loop variable, which one lets you index past the end of an array.

## The eight to read first

1. [**`nil`, `false` and truthiness**](../01_Objects_and_Values/nil_false_and_truthiness/README.md) — the first thing a Python programmer gets wrong in Ruby: `0` and `""` are true.
2. [**Blocks are not objects**](../03_Blocks_Procs_and_Lambdas/blocks_are_not_objects/README.md) — the construct Ruby has and Python does not, and what `yield` actually does.
3. [**Default arguments are evaluated on each call**](../02_Methods_and_Arguments/default_arguments_are_evaluated_each_call/README.md) — the mutable-default trap, present in one language and absent in the other.
4. [**Hashes and default values**](../04_Collections/hashes_and_default_values/README.md) — `nil` instead of `KeyError`, and the shared-default trap both languages have.
5. [**`private` means no receiver**](../06_Classes_and_Modules/private_means_no_receiver/README.md) — visibility that is enforced, against visibility that is a naming convention.
6. [**`StandardError` is the default**](../08_Errors_and_Exceptions/standard_error_is_the_default/README.md) — what a bare `rescue` catches, and what a bare `except:` catches.
7. [**`case`/`in` pattern matching**](../09_Control_Flow_and_Pattern_Matching/case_in_pattern_matching/README.md) — the two languages added the same feature in the same year with different spellings.
8. [**Gotchas for Python programmers**](../16_Idioms_and_Gotchas/gotchas_for_python_programmers/README.md) — every trap on one page, one measured line each, and its [mirror image](../16_Idioms_and_Gotchas/gotchas_for_ruby_programmers_in_python/README.md) for the other direction.

Then go by chapter, or by [the crosswalk](../CROSSWALK.md), which puts every idea in one table with its Ruby and Python spellings, or by [Topics A–Z](../TOPICS.md).

## Where the two languages agree

More than either community says. Both are dynamically typed, garbage-collected, object-based languages with duck typing, first-class functions, ordered hashes, unbounded integers, IEEE floats, generators, a global interpreter lock and a `match` statement. Assignment shares objects in both ([Variables are references](../01_Objects_and_Values/variables_are_references/README.md)); integer division floors toward negative infinity in both, and `%` takes the sign of the divisor in both ([Integer division floors](../15_Numbers/integer_division_floors/README.md)); `and`/`or` return an operand rather than a boolean in both ([`and`/`or` precedence](../09_Control_Flow_and_Pattern_Matching/and_or_precedence/README.md)); a `for` loop leaks its variable in both ([`for` loops do not scope](../09_Control_Flow_and_Pattern_Matching/for_loops_do_not_scope/README.md)); containers print their elements with the programmer-facing form in both ([`to_s`, `inspect` and `p`](../07_The_Object_Model/to_s_inspect_and_p/README.md)).

## Where they differ, and which side surprises whom

**Ruby will surprise a Python programmer with:**

- `0`, `""` and `[]` are truthy — [`nil`, `false` and truthiness](../01_Objects_and_Values/nil_false_and_truthiness/README.md).
- `a[10]` on a three-element array is `nil`, not an error — [Arrays and negative indexes](../04_Collections/arrays_and_negative_indexes/README.md).
- `7 / 2` is `3` — [Integer division floors](../15_Numbers/integer_division_floors/README.md).
- Strings are mutable — [Strings are mutable](../01_Objects_and_Values/strings_are_mutable/README.md).
- `"a"` and `:a` are different hash keys, and `{"a": 1}` makes the symbol — [String and symbol keys](../16_Idioms_and_Gotchas/string_and_symbol_keys/README.md).
- `x = false or true` leaves `x` false — [`and`/`or` precedence](../09_Control_Flow_and_Pattern_Matching/and_or_precedence/README.md).
- `puts` returns `nil`, so a method that ends with `puts` returns nothing — [The last expression is the value](../02_Methods_and_Arguments/the_last_expression_is_the_value/README.md).
- `2.5.round` is `3` — [Floats and rounding](../15_Numbers/floats_and_rounding/README.md).
- A class is never finished: anyone can reopen `String` — [Classes are open](../06_Classes_and_Modules/classes_are_open/README.md).
- `Thread.current[:x]` is local to the *fiber*, and an `Enumerator#next` runs on one — [Thread locals are fiber locals](../12_Concurrency_and_Parallelism/thread_locals_are_fiber_locals/README.md).

**Python will surprise a Ruby programmer with:**

- `def f(a=[])` shares one list across every call — [Default arguments are evaluated on each call](../02_Methods_and_Arguments/default_arguments_are_evaluated_each_call/README.md).
- Every lambda made inside a loop returns the loop's *last* value — [Closures capture variables](../03_Blocks_Procs_and_Lambdas/closures_capture_variables/README.md).
- `round(2.5)` is `2` — [Floats and rounding](../15_Numbers/floats_and_rounding/README.md).
- `list.sort()` returns `None` — [`!` and `?` methods](../02_Methods_and_Arguments/bang_and_question_methods/README.md).
- A `match` with no matching `case` does nothing at all — [`NoMatchingPatternError`](../09_Control_Flow_and_Pattern_Matching/no_matching_pattern_error/README.md).
- `{1: "a"}[1.0]` finds the value; Ruby's `{1 => "a"}[1.0]` is `nil` — [Comparing `Integer` and `Float`](../15_Numbers/comparing_int_and_float/README.md).
- Defining `__eq__` silently makes a class unhashable — [`eql?` and `hash`](../07_The_Object_Model/eql_and_hash_for_hash_keys/README.md).
- `str(10**5000)` raises — [Integers are unbounded](../15_Numbers/integers_are_unbounded/README.md).
- There is no `unless`, no `until`, no do-while, and no trailing `if` — [`unless`, `until` and modifiers](../09_Control_Flow_and_Pattern_Matching/unless_until_and_modifiers/README.md).

**The pattern:** Ruby has two spellings where Python has one — `lambda` and `proc`, `&&` and `and`, `==` and `eql?`, `dup` and `clone` — and the second spelling is where a Python programmer's model breaks. Python has two types where Ruby has one — `str` and `bytes`, `list` and `tuple`, `set` and `frozenset` — and the second type is where a Ruby programmer's model breaks. [The crosswalk](../CROSSWALK.md) has a row for each pair.

## The advanced half

Chapters 07 to 12 are where the designs diverge most: [the object model](../07_The_Object_Model/README.md) (singleton classes, `allocate`, refinements), [metaprogramming](../10_Metaprogramming/README.md) (`define_method`, `method_missing`, hooks, a DSL), [under the hood](../11_Under_the_Hood/README.md) (`Binding`, `TracePoint`, the garbage collector, the bytecode, the JITs) and [concurrency](../12_Concurrency_and_Parallelism/README.md) (threads under the GVL, fibers, Ractors, processes). Each of those pages still carries a Python twin, because `__init_subclass__`, `__getattr__`, `sys.settrace`, `dis` and `multiprocessing` are the nearest Python has, and seeing exactly how near is the lesson.
