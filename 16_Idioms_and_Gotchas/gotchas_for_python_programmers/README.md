# Twenty-three Ruby traps for a Python programmer

**Level:** 201 · someone who writes Python and has just started reading Ruby

**One line:** The twenty-three places where a Python reflex gives the wrong answer in Ruby — `0` is truthy, `a[10]` is `nil`, `7 / 2` is `3`, `x = 5 if false` still defines `x`, `{"a": 1}` has a symbol key, `puts [1].map do … end` prints an Enumerator — each measured on one line, with the lesson that explains it.

Most of these are not bugs in either language; they are two consistent designs meeting. Ruby has two false values and everything else is true; a missing index or key is `nil` rather than an error; integer division floors; strings are mutable objects; `and`/`or` are control-flow operators that bind below `=`; a `do … end` block binds to the outermost method call on its line; a leading `0` in `Integer()` means octal; `for` shares the enclosing scope and a block does not; `private` restricts the *receiver*, not the caller. The program prints one line per row, in the table's order, and the Python twin prints what Python does in the same spot.

| # | The trap | Ruby says | Python would say | Lesson |
|---|---|---|---|---|
| 1 | `0` and `""` are truthy | only `nil` and `false` are false | `bool(0)` and `bool("")` are `False` | [nil, false and truthiness](../../01_Objects_and_Values/nil_false_and_truthiness/README.md) |
| 2 | `a[10]` is `nil` | no error for a missing index | `IndexError` | [Arrays and negative indexes](../../04_Collections/arrays_and_negative_indexes/README.md) · [slicing is not indexing ↗](https://masiarek.github.io/python-learning-library/01_Text_and_Bytes/slicing_is_not_indexing/index.html) |
| 3 | `7 / 2` is `3` | integer division floors; `fdiv` or `2.0` for a float | `7 / 2` is `3.5`, `7 // 2` is `3` | [Integer division floors](../../15_Numbers/integer_division_floors/README.md) |
| 4 | strings are mutable | `s << "d"` changes the object in place | `s += "d"` makes a new string; `s[0] = "x"` raises | [Strings are mutable](../../01_Objects_and_Values/strings_are_mutable/README.md) · [bytearray is mutable ↗](https://masiarek.github.io/python-learning-library/01_Text_and_Bytes/bytearray_is_mutable/index.html) |
| 5 | `"a" == :a` is false | a `String` and a `Symbol` never compare equal | there is one string type | [Symbols are names](../../01_Objects_and_Values/symbols_are_names/README.md) |
| 6 | `x = false or true` leaves `x` false | `or` binds below `=` | `or` has ordinary precedence | [`and`/`or` bind below `=`](../../09_Control_Flow_and_Pattern_Matching/and_or_precedence/README.md) |
| 7 | `puts` returns `nil` | a method ending in `puts` returns `nil` | `print` returns `None` too | [The last expression is the value](../../02_Methods_and_Arguments/the_last_expression_is_the_value/README.md) |
| 8 | `x = 5 if false` defines `x` as `nil` | the parser creates the local; the body never runs | `if False: x = 5` leaves `x` undefined; `x = 5 if False` will not parse | [`unless`, `until` and modifiers](../../09_Control_Flow_and_Pattern_Matching/unless_until_and_modifiers/README.md) |
| 9 | `elsif` | `elif` is a syntax error | `elif` | [`unless`, `until` and modifiers](../../09_Control_Flow_and_Pattern_Matching/unless_until_and_modifiers/README.md) |
| 10 | `end` closes every block | a missing `end` is a syntax error | a dedent closes the block | [Indentation is convention in Ruby, syntax in Python](../style_and_naming/README.md) |
| 11 | `2.5.round` is `3` | half away from zero; `half: :even` for banker's | `round(2.5)` is `2` | [Floats and rounding](../../15_Numbers/floats_and_rounding/README.md) |
| 12 | `uniq!` returns `nil` when nothing changed | the bang methods signal "no change" with `nil` | `sort()` returns `None` always | [Bang and question methods](../../02_Methods_and_Arguments/bang_and_question_methods/README.md) |
| 13 | `Hash.new([])` shares one default array | `h[:a] << 1` mutates the default, and stores no key | `defaultdict(list)` makes a fresh list per key | [Hashes and default values](../../04_Collections/hashes_and_default_values/README.md) |
| 14 | `{"a": 1}` has a symbol key | quotes then a colon make a `Symbol` | `{"a": 1}` has a `str` key | [A string key and a symbol key are two keys](../string_and_symbol_keys/README.md) |
| 15 | `puts [1].map do … end` prints an Enumerator | `do … end` binds to `puts`, `{ }` to `map` | a lambda sits inside the parentheses | [Blocks are not objects](../../03_Blocks_Procs_and_Lambdas/blocks_are_not_objects/README.md) |
| 16 | `?a` is the string `"a"` | a character literal is a one-character `String` | `"a"` is a `str`; there is no character type | [String literals ↗](https://masiarek.github.io/python-learning-library/01_Text_and_Bytes/string_literals/index.html) |
| 17 | `Integer("08")` raises | a leading `0` means octal; `"08".to_i` is `8` | `int("08")` is `8`; the literal `08` will not parse | [`to_i` never fails; `Integer()` does ↗](https://masiarek.github.io/ruby-text-learning-library/07_Parsing_and_Formatting/to_i_never_fails/index.html) |
| 18 | `%w[a b c]` | a word list literal | `"a b c".split()` | [Text lives in the text library](../../13_IO_Files_and_the_System/text_lives_in_the_text_library/README.md) |
| 19 | a `for` loop leaks its variable | `for` shares the scope; a block does not | `for` leaks too; a comprehension does not | [`for` loops do not scope](../../09_Control_Flow_and_Pattern_Matching/for_loops_do_not_scope/README.md) |
| 20 | `1.equal?(1)` is true | `equal?` is identity, `==` is value | `256 is 256` on variables is `True`, `[] is []` is `False` | [Four kinds of equality](../../01_Objects_and_Values/four_kinds_of_equality/README.md) |
| 21 | `private` means "no explicit receiver" | `obj.secret` raises; `send` bypasses | `_secret` is a convention, nothing is enforced | [Private means no receiver](../../06_Classes_and_Modules/private_means_no_receiver/README.md) |
| 22 | `attr_accessor` | reader and writer methods, generated | attributes are public by default | [Instance variables are private](../../06_Classes_and_Modules/instance_variables_are_private/README.md) |
| 23 | `require`, not `import` | returns `true`, then `false` | `import` returns a module | [`require`, `require_relative` and `load`](../../14_Tooling_Testing_and_Gems/require_require_relative_and_load/README.md) |

<!-- output:gotchas_for_python_programmers_rb -->
*Verified output of [`gotchas_for_python_programmers_rb.rb`](examples/gotchas_for_python_programmers_rb.rb) — regenerated by `tools/run_examples.py`, never hand-typed.*

```text
 1. 0 and "" in a condition                    truthy / truthy
 2. [1, 2, 3][10]                              nil
 3. 7 / 2 / 7.fdiv(2) / 7 / 2.0                3 / 3.5 / 3.5
 4. s = "abc"; s << "d"                        "abcd", same object? true
 5. "a" == :a                                  false
 6. x1 = false or true / x2 = false || true    x1=false / x2=true
 7. puts "hi" returns  (printed "hi\n")        nil
 8. y = 5 if false; y / defined?(y)            nil / "local-variable"
 9. elsif / elif                               compiles / SyntaxError
10. an if without end / with end               SyntaxError / compiles
11. 2.5.round / (-2.5).round / 2.5.round(half: :even) 3 / -3 / 2
12. [1, 2].uniq! / [1, 1].uniq!                nil / [1]
13. h = Hash.new([]); h[:a] << 1; h[:b] / h.size [1] / 0  (one array, no keys)
14. {"a": 1}.keys.first.class                  Symbol
15. show [1].map do |v| v * 2 end / with { }   #<Enumerator: [1]:map> / [2]
16. ?a / ?a.class                              "a" / String
17. Integer("08") / "08".to_i / Integer("010") ArgumentError / 8 / 8  (a leading 0 means octal)
18. %w[a b c]                                  ["a", "b", "c"]
19. for i in 1..3: i after / each { |elem| }: defined?(elem) 3 / nil
20. 1.equal?(1) / "a".equal?("a") / "a" == "a" true / false / true
21. private: obj.secret / obj.reveal / obj.send(:secret) NoMethodError / "s3cret" / "s3cret"
22. attr_accessor :name defines                [:name, :name=]
23. require "json" / import json               true / NameError
```
<!-- /output -->

## Reading the output

- **Rows 1–2**: `0` and `""` take the truthy branch; `[1, 2, 3][10]` is `nil`, no exception.
- **Rows 3–5**: `7 / 2` is `3` and only `fdiv` or a float operand gives `3.5`; `<<` appended to the *same* string object; `"a" == :a` is `false`.
- **Rows 6–7**: `x1` is `false` because the line parsed as `(x1 = false) or true`; `puts` printed `hi` and returned `nil`.
- **Row 8**: `y` is `nil` and `defined?(y)` reports a local variable — the parser declared it when it read the assignment, even though the assignment never ran.
- **Rows 9–10**: `elsif` compiles, `elif` does not; an `if` without `end` does not compile.
- **Rows 11–12**: `2.5.round` is `3` and `-2.5` rounds to `-3` (away from zero); `[1, 2].uniq!` returned `nil` because nothing changed.
- **Row 13**: the default `[]` was shared: `h[:b]` already holds `[1]` and the hash has no keys at all.
- **Rows 14–15**: `{"a": 1}` made a `Symbol` key; `show [1].map do … end` handed the block to `show`, so `map` got no block and returned an `Enumerator`, while the `{ }` form gave `[2]`.
- **Rows 16–18**: `?a` is a one-character `String`; `Integer("08")` is an `ArgumentError` because `0` starts an octal literal and `8` is not an octal digit, while `"08".to_i` is `8` and `Integer("010")` is `8`; `%w[a b c]` is three strings.
- **Rows 19–20**: `i` survives the `for` loop while `elem` from the block does not exist afterwards (`defined?` is `nil`); `1.equal?(1)` is `true` because small integers are one object, and two `"a"` literals are two objects that are `==`.
- **Rows 21–23**: `obj.secret` is a `NoMethodError`, a method inside the class may call `secret` with no receiver, and `send` reaches it from outside; `attr_accessor :name` defined `name` and `name=`; `require` returned `true`, and `import json` is a `NameError` because Ruby has no such keyword — `json` is read as a variable.

## Compared with Python

The twin prints the Python behaviour behind each expectation. Rows 1–3 are the three most common first-day bugs: `bool(0)` is `False`, a bad index raises `IndexError`, and `/` is true division. Row 4 shows that `+=` on a `str` rebinds the name (`is` says the object changed) and that item assignment raises. Rows 6 and 8 are opposite corners: `or` has ordinary precedence, and an assignment inside a false `if` leaves the name undefined (`NameError`) — while Ruby's modifier form does not even parse in Python. Row 10 measures the missing `end`: the `ast` shows the dedent closed the `if` after one statement. Rows 11–13 are banker's rounding, `sort()` returning `None` whether or not anything moved, and `defaultdict` making a fresh list per key — and storing it on first access, which is why the dict grew to two keys where Ruby's `Hash.new([])` stored none. Row 15 has no block syntax to bind wrongly; row 17 accepts `"08"` as decimal but rejects the literal `08` at compile time; row 19 shows Python's `for` leaks the same way and a comprehension does not; row 20 is CPython's small-integer cache, which this page keys only for `256` (the cache's documented upper bound), because `257 is 257` on variables is not a promise. *(Not machine-checked here.)* Rows 21–22: `_secret` and `__hidden` are conventions the interpreter does not enforce, and attributes need no declaration. Row 23: `require` is a `NameError` in Python, just as `import` is in Ruby.

<!-- output:gotchas_for_python_programmers_py -->
*Verified output of [`gotchas_for_python_programmers_py.py`](examples/gotchas_for_python_programmers_py.py) — regenerated by `tools/run_examples.py`, never hand-typed.*

```text
 1. bool(0) / bool("")                         False / False
 2. [1, 2, 3][10]                              IndexError
 3. 7 / 2 / 7 // 2 / 7 / 2.0                   3.5 / 3 / 3.5
 4. s = "abc"; s += "d" / s[0] = "x"           'abcd', same object? False / TypeError
 5. "a" == "a"  (no symbol type)               True
 6. x1 = False or True                         x1=True  (or has ordinary precedence)
 7. print("hi") returns  (printed 'hi\n')      None
 8. if False: y = 5; y / x = 5 if False        NameError / SyntaxError
 9. elif / elsif                               compiles / SyntaxError
10. no end: a dedent closes the block          module has 2 statements, the if holds 1
11. round(2.5) / round(-2.5) / round(3.5)      2 / -2 / 4
12. [1, 2].sort() / [2, 1].sort()  (always None) None / None
13. defaultdict(list): dd["a"].append(1); dd["b"] [] / len 2  (a fresh list per key, stored on access)
14. {"a": 1}: type of the key                  str
15. list(map(lambda v: v * 2, [1]))  (no blocks) [2]
16. "a" / type("a").__name__ / ord("a")        'a' / str / 97  (no character type)
17. int("08") / int("010") / the literal 08    8 / 10 / SyntaxError
18. "a b c".split()                            ['a', 'b', 'c']
19. for i in range(1, 4): i after / [j for j in ...]: 'j' in dir() 3 / False
20. m = 256; n = 256; m is n / [] is [] / [] == [] True / False / True
21. obj._secret() / obj.reveal() / obj._Safe__hidden() 's3cret' / 's3cret' / 'mangled'  (nothing enforced)
22. self.name = ...: attributes are public     vars(Person()) = {'name': 'ann'}
23. import json / require("json")              module / NameError
```
<!-- /output -->

## Try it

1. Write `py_truthy?(value)` in Ruby that answers as Python's `bool()` would — `nil`, `false`, numeric zero and every empty `String`, `Array` or `Hash` are false — and print a table of ten values with Ruby's `!!value` beside it, marking the rows where the two disagree.
2. Write `safe_div(a, b)` that mimics Python's `/` (always a `Float`) and `//` (floor) in Ruby, and print both for `7, 2`, `-7, 2` and `7, 0` — rescuing what Ruby raises for the last one and printing its class.

<details markdown="1">
<summary><strong>Solution to 1</strong></summary>

<!-- source:gotchas_for_python_programmers_kata_rb -->
*[`gotchas_for_python_programmers_kata_rb.rb`](examples/gotchas_for_python_programmers_kata_rb.rb) in full — pasted here by `tools/run_examples.py` from the file CI runs.*

```ruby
# Kata: Python's truthiness, implemented in Ruby, beside Ruby's own.
# Python treats None, False, zero of any numeric type and every empty
# container or string as false; Ruby treats only nil and false as false.

def py_truthy?(value)
  case value
  when nil, false then false
  when Numeric then !value.zero?
  when String, Array, Hash then !value.empty?
  else true
  end
end

values = [nil, false, 0, 0.0, "", " ", [], {}, :a, [0]]

puts format("%-8s %-12s %s", "value", "Ruby !!v", "py_truthy?(v)")
values.each do |v|
  mark = !!v == py_truthy?(v) ? "" : "  <- differ"
  puts format("%-8s %-12s %s%s", v.inspect, !!v, py_truthy?(v), mark)
end
```
<!-- /source -->

<!-- output:gotchas_for_python_programmers_kata_rb -->
*Verified output of [`gotchas_for_python_programmers_kata_rb.rb`](examples/gotchas_for_python_programmers_kata_rb.rb) — regenerated by `tools/run_examples.py`, never hand-typed.*

```text
value    Ruby !!v     py_truthy?(v)
nil      false        false
false    false        false
0        true         false  <- differ
0.0      true         false  <- differ
""       true         false  <- differ
" "      true         true
[]       true         false  <- differ
{}       true         false  <- differ
:a       true         true
[0]      true         true
```
<!-- /output -->

</details>

## See also

- [Twenty-three Python traps for a Ruby programmer](../gotchas_for_ruby_programmers_in_python/README.md) — the same crossing, walked the other way
- [There is more than one way, and one obvious way](../the_ruby_way_and_the_pythonic_way/README.md) — the idioms behind these traps, one measured line each
- [`x ||= v` assigns when `x` is nil or false](../or_equals_and_nil_guards/README.md) — what row 1's truthiness does to the memoization idiom
- [Common error messages](../../08_Errors_and_Exceptions/common_error_messages/README.md) — the `NoMethodError`, `NameError` and `ArgumentError` of rows 17, 21 and 23, with their full messages
- [Parentheses are optional](../../02_Methods_and_Arguments/parentheses_are_optional/README.md) — why row 15's block went to the wrong method
