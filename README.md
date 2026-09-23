# Ruby — a learning library

**Ruby, one idea per page, each measured beside the same idea in Python.** A page here makes one claim about Ruby, proves it with a program whose output a tool pastes in, and then asks Python the same question with a second program — so every comparison is a measurement, not a memory. CI runs every program on Ubuntu and macOS, under Ruby 4.0 and each runner's own Python 3, and fails the build when a page stops printing what it says.

**Read it as a website:** <https://masiarek.github.io/ruby-learning-library/>

## Who it is for

Someone who knows Python and is learning Ruby; someone who knows Ruby and wants to see, printed, what Python does differently; and anyone who has been told "everything is an object" or "a block is not a closure" and would like to watch it happen. The first half is the language as a Python programmer meets it — objects, methods, blocks, collections, classes, errors. The second half is where the two designs diverge most and a comparison teaches the most: the object model, metaprogramming, fibers and Ractors, the bytecode, the tooling.

## Start here

[**00 — Start here**](00_Start_Here/README.md) — how to read a page, the pages to read first, and the scorecard: where Ruby and Python agree, where they differ, and where each one will surprise you.

## The chapters

| | Chapter | What it covers |
|---|---|---|
| 01 | [Objects and values](01_Objects_and_Values/README.md) | everything is an object, truthiness, symbols, four equalities, references, `freeze`, mutable strings, duck typing |
| 02 | [Methods and arguments](02_Methods_and_Arguments/README.md) | optional parentheses, implicit return, argument kinds, per-call defaults, `!` and `?`, operators as methods, `self`, `&.`, setters |
| 03 | [Blocks, procs and lambdas](03_Blocks_Procs_and_Lambdas/README.md) | `yield`, proc vs lambda, closures, `&:sym`, `it`, `next`/`break`/`return`, writing an iterator, currying |
| 04 | [Collections](04_Collections/README.md) | arrays, hashes and defaults, ranges, `Set`, destructuring, `Struct` and `Data`, `Comparable` |
| 05 | [Enumerable and iteration](05_Enumerable_and_Iteration/README.md) | the mixin, the toolbox, `inject`, lazy and external enumerators, sort stability |
| 06 | [Classes and modules](06_Classes_and_Modules/README.md) | instance variables, `private`, open classes, `include`/`extend`/`prepend`, lookup and `super`, constants, `@@`, namespaces |
| 07 | [The object model](07_The_Object_Model/README.md) | singleton classes, `new`/`allocate`/`initialize`, `to_s`/`inspect`, `eql?`/`hash`, refinements, `BasicObject`, `dup`/`clone` |
| 08 | [Errors and exceptions](08_Errors_and_Exceptions/README.md) | `rescue`/`ensure`/`retry`, the hierarchy, `raise`, custom classes, `cause`, `throw`/`catch`, `exit`, warnings, the error messages |
| 09 | [Control flow and pattern matching](09_Control_Flow_and_Pattern_Matching/README.md) | expressions everywhere, `unless`/`until`, `and`/`or`, `case`/`when`, `case`/`in`, pins and guards, `deconstruct`, `for` scope |
| 10 | [Metaprogramming](10_Metaprogramming/README.md) | `send`, `define_method`, `method_missing`, `instance_eval`/`class_eval`, hooks, a DSL, classes at runtime, introspection |
| 11 | [Under the hood](11_Under_the_Hood/README.md) | `Method` objects, `Binding`, `TracePoint`, `ObjectSpace` and GC, the bytecode, the JITs |
| 12 | [Concurrency and parallelism](12_Concurrency_and_Parallelism/README.md) | threads and the GVL, `Mutex`/`Queue`, fibers, fiber-local storage, Ractors, processes, timeouts |
| 13 | [IO, files and the system](13_IO_Files_and_the_System/README.md) | `File.open`, `puts`/`p`/`pp`, `ARGV`/`ENV`, running programs, stdin and `ARGF`, `Pathname`, JSON/YAML/Marshal, time, formatting |
| 14 | [Tooling, testing and gems](14_Tooling_Testing_and_Gems/README.md) | `require`, gems and Bundler, Minitest, the command line, `irb`, what changed per version, backtraces, no docstrings |
| 15 | [Numbers](15_Numbers/README.md) | `7 / 2`, unbounded integers, floats and rounding, `Rational`/`BigDecimal`, `1 == 1.0`, coercion, seeded randomness, formatting |
| 16 | [Idioms and gotchas](16_Idioms_and_Gotchas/README.md) | the Ruby way and the Pythonic way, `||=`, `tap`/`then`, multiple returns, symbol keys, style, comments, the traps in both directions |
| 17 | [Resources](17_Resources/README.md) | the docs, the books, the talks — and for each, the Python counterpart |

Across the chapters: [**the crosswalk**](CROSSWALK.md) puts every idea in one table with its Ruby and Python spellings, and [**Topics A–Z**](TOPICS.md) finds a page from any name you might call it by.

## Running the examples

You need **Ruby 4.0 or later**. macOS still ships Ruby 2.6 as `/usr/bin/ruby`; `brew install ruby` puts a current one in Homebrew's prefix. Every example is a single file that needs nothing beyond what Ruby ships:

```bash
ruby 03_Blocks_Procs_and_Lambdas/closures_capture_variables/examples/closures_capture_variables_rb.rb
```

Beside every Ruby program sits a Python one making the same point, standard library only, so a comparison on a page is a measurement rather than a memory:

```bash
python3 03_Blocks_Procs_and_Lambdas/closures_capture_variables/examples/closures_capture_variables_py.py
```

To run all of them and check every recorded output:

```bash
python3 tools/run_examples.py --check
```

The tool finds a Ruby 4.0 by itself — `$RUBY`, then `ruby` on `PATH`, then Homebrew's — and refuses anything older.

## The one rule

No page hand-types what a program prints. A lesson marks the spot and the runner fills it from a real run, so an example that changes behaviour in a new Ruby or a new Python breaks the build instead of quietly making a page wrong. See [CONTRIBUTING.md](CONTRIBUTING.md).

## Sibling libraries

The same house rule, and many of the same questions asked of another language. Every page here links its Python counterpart; the others are linked where the comparison teaches something.

- [**Python** ↗](https://masiarek.github.io/python-learning-library/) — the twin of this library: `str` and `bytes`, the format language, numbers, the interpreter and its projects.
- [**Ruby text** ↗](https://masiarek.github.io/ruby-text-learning-library/) — every Ruby string carries its own encoding: strings, Unicode, regex, literals, what Ruby kept from Perl. This library links there rather than repeating it.
- [**Regex** ↗](https://masiarek.github.io/regex-learning-library/) — one regular-expression question per page, put to Ruby, Python and six other engines.
- [**Concurrency** ↗](https://masiarek.github.io/concurrency-learning-library/) — the ideas behind threads, locks and message passing, in Rust, Go, C, C++, Java and Python.
- [**Encodings** ↗](https://masiarek.github.io/encodings-learning-library/) — bits, bytes, code points and UTF-8 from the bottom up.
- [**Perl** ↗](https://masiarek.github.io/perl-learning-library/) — where Ruby's one-liner switches, `split` and `pack` came from.
- [**Rust** ↗](https://masiarek.github.io/rust-learning-library/), [**C** ↗](https://masiarek.github.io/c-learning-library/), [**Go** ↗](https://masiarek.github.io/go-learning-library/), [**Java text** ↗](https://masiarek.github.io/java-text-learning-library/), [**Linux** ↗](https://masiarek.github.io/linux-learning-library/), [**Math** ↗](https://masiarek.github.io/math-learning-library/), [**ABAP** ↗](https://masiarek.github.io/abap-learning-library/).
