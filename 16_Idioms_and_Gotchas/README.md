# 16 — Idioms and Gotchas

**One line:** The habits that make Ruby read like Ruby, the habits that make Python read like Python, and the two lists of traps each side walks into when they cross over — every trap a measured line.

This chapter is the crossing itself. The first fifteen chapters ask one question at a time; this one collects the answers a Python programmer keeps getting wrong in Ruby (`0` is truthy, `a[10]` is `nil`, `7 / 2` is `3`, `x = 5 if false` still defines `x`) and the answers a Ruby programmer keeps getting wrong in Python (a `[]` default argument is shared, `round(2.5)` is `2`, `x = 5 if False` will not even parse, `d[key]` raises). Between the two hubs sit the idioms that have no one-line twin: `||=` and its false-value trap, `tap` and `then`, multiple return values, string keys against symbol keys, style, comments and the `__END__` data section.

Where the Python model carries over: `and`/`or` return their operands in both languages, both leak a `for` variable, both return the last thing from `print`/`puts` as nothing, and both unpack `a, b = f()`. Where it breaks: Ruby's truthiness has exactly two false values, Ruby's block syntax has a precedence rule Python never needed, Ruby has a symbol type and a data section and no docstrings, and Ruby indentation is a convention that `ruby -w` only partly checks, while Python's is grammar.

| Lesson | Level | The one thing |
|---|---|---|
| [There is more than one way, and one obvious way](the_ruby_way_and_the_pythonic_way/README.md) | 101 | nineteen idiom pairs printed side by side, and `import this` |
| [`x \|\|= v` assigns when `x` is nil or false](or_equals_and_nil_guards/README.md) | 201 | a memoized `false` is recomputed every call |
| [`tap` returns the receiver, `then` returns the block's value](tap_then_and_chaining/README.md) | 201 | debugging inside a chain without breaking it |
| [`return a, b` returns one Array](multiple_return_values/README.md) | 101 | Ruby's tuple is an Array; Python's is a `tuple` |
| [A string key and a symbol key are two keys](string_and_symbol_keys/README.md) | 201 | `{"a": 1}` makes a symbol key and `JSON.parse` makes string keys |
| [Indentation is convention in Ruby, syntax in Python](style_and_naming/README.md) | 101 | `ruby -w` warns about a mismatched `end`; Python refuses to compile |
| [Ruby has block comments and a data section](comments_and_documentation/README.md) | 101 | `=begin`/`=end`, `__END__` and `DATA`, and no docstrings |
| [Twenty-three Ruby traps for a Python programmer](gotchas_for_python_programmers/README.md) | 201 | one measured line per trap, each linking its lesson |
| [Twenty-three Python traps for a Ruby programmer](gotchas_for_ruby_programmers_in_python/README.md) | 201 | the reverse list, measured in Python beside Ruby's answer |

## Read more

- [Ruby syntax: assignment ↗](https://docs.ruby-lang.org/en/4.0/syntax/assignment_rdoc.html) — `||=`, `&&=`, multiple assignment and splats, the reference behind three of these pages
- [Ruby syntax: comments ↗](https://docs.ruby-lang.org/en/4.0/syntax/comments_rdoc.html) — `#`, `=begin`/`=end`, magic comments and where `__END__` is allowed
- [The Ruby Style Guide ↗](https://rubystyle.guide/) — the community conventions RuboCop enforces
- [PEP 8 ↗](https://peps.python.org/pep-0008/) — Python's style guide, the twin of the page above
- [PEP 20 ↗](https://peps.python.org/pep-0020/) — the Zen of Python, the text `import this` prints
- [Python FAQ: programming ↗](https://docs.python.org/3/faq/programming.html) — the mutable-default and late-binding questions, answered by the Python maintainers
