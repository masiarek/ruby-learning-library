# 14 — Tooling, testing and gems

**One line:** The machinery around a Ruby program — loading files, gems and Bundler, Minitest, the command line, `irb`, the release history, backtraces and the missing docstring — measured against Python's `import`, `pip`, `unittest`, `python3 -i`, `traceback` and `__doc__`.

A Python programmer arrives with a working model of all of this: `import` runs a module once and caches it in `sys.modules`; `pip` and a `venv` hold the packages a project needs and `pyproject.toml` declares them; `unittest` is a `TestCase` class with `assert*` methods; the `>>>` prompt echoes values; `traceback` and `inspect` read the stack; every function has a `__doc__`. Most of that model carries over with the names changed — `require` for `import`, `$LOADED_FEATURES` for `sys.modules`, `gem`/`bundle` for `pip`, `Gemfile` for the dependency list, `Minitest::Test` for `TestCase`, `irb` for the prompt, `caller` and `backtrace` for the stack.

Where it breaks is the interesting part. Ruby has three loading verbs to Python's one (`require`, `require_relative`, `load`) plus `autoload`; RubyGems can *activate* a gem version at run time, which `import` cannot; Minitest runs tests in a seeded random order and, as of Ruby 4.0's Minitest 6, no longer ships `Minitest::Mock`; the `-I`, `-s` and `-S` flags mean different things in the two interpreters; the Ruby prompt echoes assignments and `def`s because they are expressions; backtrace labels are `Klass#method` strings; and there is no docstring at all — a method knows only its `source_location`, and documentation is a comment convention that RDoc, YARD and `ri` read from the file.

| Lesson | Level | The one thing |
|---|---|---|
| [`require` loads once; `load` runs every time](require_require_relative_and_load/README.md) | 201 | `require` and `require_relative` share one once-list, `load` ignores it, `autoload` defers |
| [Gems are versioned; Bundler pins them](gems_bundler_and_gemfile/README.md) | 201 | default gems, bundled gems and core classes are three different things; `Gem::Version` compares as numbers |
| [A Minitest test is a plain class](minitest_and_unittest/README.md) | 201 | the seeded, shuffled run and its `runs, assertions, failures, errors, skips` line, next to `unittest` |
| [The command line is part of the language](the_command_line_flags/README.md) | 201 | `-e -c -w -r -I -n -p -a -l -E --yjit --disable-gems --dump`, each run in a child and compared with `python3`'s letters |
| [`irb` echoes every value; a script does not](irb_and_the_repl/README.md) | 101 | the read–eval–print loop driven through a pipe, values only, beside `python3 -i` and `code.InteractiveConsole` |
| [What changed, 1.9 to 4.0](ruby_versions_what_changed/README.md) | 201 | a timeline table, and a program that checks which of its features this Ruby and this Python have |
| [A backtrace is data you can read](backtraces_and_caller/README.md) | 201 | `caller`, `caller_locations`, `backtrace`, `full_message` as labels, next to `traceback` and `inspect` |
| [Ruby has no docstrings](no_docstrings/README.md) | 101 | `source_location` plus the comment above the `def`, read from the file, next to `__doc__` and `inspect.getcomments` |

## Read more

- [Ruby: `Kernel#require` ↗](https://docs.ruby-lang.org/en/4.0/Kernel.html#method-i-require) — the loading rules, `$LOAD_PATH` and `$LOADED_FEATURES`
- [RubyGems guides ↗](https://guides.rubygems.org/) — what a gem is, `gem` commands, writing a gemspec
- [Bundler docs ↗](https://bundler.io/docs.html) — `Gemfile`, `Gemfile.lock`, `bundle install` and `bundle exec`
- [Minitest ↗](https://docs.seattlerb.org/minitest/) — assertions, spec DSL, the runner's options
- [Ruby: command-line options ↗](https://docs.ruby-lang.org/en/4.0/ruby/options_md.html) — every flag, with `-n`, `-p`, `-a`, `-l` explained
- [Ruby: `Thread::Backtrace::Location` ↗](https://docs.ruby-lang.org/en/4.0/Thread/Backtrace/Location.html) — `label`, `base_label`, `path`, `lineno`
- [Ruby: release notes ↗](https://www.ruby-lang.org/en/news/) — each release's "what's new"
- [Python: the import system ↗](https://docs.python.org/3/reference/import.html) — `sys.modules`, finders, packages and relative imports
- [Python: `unittest` ↗](https://docs.python.org/3/library/unittest.html) — `TestCase`, `mock`, the runner
- [Python: command line and environment ↗](https://docs.python.org/3/using/cmdline.html) — `-c`, `-m`, `-I`, `-W`, `-X`
- [Python: `traceback` ↗](https://docs.python.org/3/library/traceback.html) — `extract_stack`, `extract_tb`, `format_exception_only`
- [Python: What's New ↗](https://docs.python.org/3/whatsnew/index.html) — the per-release changes the timeline lesson summarizes
