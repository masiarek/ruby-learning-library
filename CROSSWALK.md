# The crosswalk

**Level:** reference · for anyone who knows one of the two languages

**One line:** One idea per row — what Ruby calls it, what Python calls it, and the page here that runs both — so a concept you already understand in one language can be looked up rather than relearned.

Every row names an idea once and then gives its two spellings. The last column is this library's lesson on it, where a Ruby program and its Python twin print the answer side by side; where the [Python library ↗](https://masiarek.github.io/python-learning-library/) has its own page on the idea, that page is linked too, marked ↗. A dash means the language has no counterpart, which is itself the answer. The rows are grouped the way the chapters are; [Topics A–Z](TOPICS.md) has the same pages under every name you might search for.

## Values and objects

| The idea | Ruby | Python | The page here |
|---|---|---|---|
| Nothing | `nil` — an object of `NilClass`; only `nil` and `false` are falsy | `None` — and `0`, `""`, `[]`, `{}` are falsy too | [nil, false and truthiness](01_Objects_and_Values/nil_false_and_truthiness/README.md) |
| Everything is an object | `1.class`, `nil.class`, `Class.class`, `1.+(2)` | `type(1)`, `type(None)`, `type(int)`; operators are dunder methods | [Everything is an object](01_Objects_and_Values/everything_is_an_object/README.md) |
| A name as a value | `:symbol` — one object per name | an interned `str`, or `enum.Enum` | [Symbols](01_Objects_and_Values/symbols_are_names/README.md) |
| Identity and value | `equal?` · `==` · `eql?` · `===` | `is` · `==` · `__hash__` · nothing like `===` | [Four kinds of equality](01_Objects_and_Values/four_kinds_of_equality/README.md) |
| Assignment | shares the object; `dup` copies | shares the object; `copy.copy` copies | [Variables are references](01_Objects_and_Values/variables_are_references/README.md) |
| Immutability | `freeze`, `frozen?`, `FrozenError`; literals are chilled | by type: `tuple`, `frozenset`, `dataclass(frozen=True)` | [freeze](01_Objects_and_Values/freeze_and_frozen_error/README.md) |
| Strings | mutable — `<<` changes the object | immutable — `+=` makes a new one; [`str` is not `bytes` ↗](https://masiarek.github.io/python-learning-library/01_Text_and_Bytes/str_is_not_bytes/index.html) | [Strings are mutable](01_Objects_and_Values/strings_are_mutable/README.md) |
| Duck typing | `respond_to?`, `to_str`/`to_ary`/`to_proc` | `hasattr`, `__iter__`/`__index__`, `Protocol` | [Duck typing](01_Objects_and_Values/duck_typing_and_respond_to/README.md) |

## Methods and arguments

| The idea | Ruby | Python | The page here |
|---|---|---|---|
| Calling | parentheses optional; a bare name may be a call | parentheses mandatory; a bare name is a reference | [Parentheses are optional](02_Methods_and_Arguments/parentheses_are_optional/README.md) |
| What a method returns | its last expression | `None` unless `return` says otherwise | [The last expression is the value](02_Methods_and_Arguments/the_last_expression_is_the_value/README.md) |
| Parameters | `a, b = 1, *rest, key:, **opts, &blk` | `a, b=1, *args, key, **kwargs`, with `/` and `*` markers | [Arguments](02_Methods_and_Arguments/arguments_positional_keyword_and_splat/README.md) |
| Default arguments | evaluated on every call | evaluated once, at `def` — the mutable-default trap | [Defaults are evaluated each call](02_Methods_and_Arguments/default_arguments_are_evaluated_each_call/README.md) |
| Naming | `sort!` and `empty?` | `sort()` returns `None`; `is_` prefixes; no `?` | [`!` and `?`](02_Methods_and_Arguments/bang_and_question_methods/README.md) |
| Operators | methods: `def +(other)`, `def <=>(other)` | dunders: `__add__`, `__lt__`, `__radd__` | [Operators are methods](02_Methods_and_Arguments/operators_are_methods/README.md) |
| The receiver | implicit `self` | explicit `self` parameter | [`self` is implicit](02_Methods_and_Arguments/self_is_implicit/README.md) |
| A call on nothing | `x&.length` | `x.length if x else None`, `getattr(x, "y", None)` | [Safe navigation](02_Methods_and_Arguments/safe_navigation/README.md) |
| Setters | `def x=(v)`; the assignment's value is the argument | `@property` + `.setter`; assignment is a statement | [Setters return the argument](02_Methods_and_Arguments/setters_return_the_argument/README.md) |
| A method as a value | `method(:f)`, `UnboundMethod#bind` | `obj.f` (bound), `Cls.f` (a plain function) | [Method objects](11_Under_the_Hood/method_objects_and_unbound_methods/README.md) |

## Blocks, procs and lambdas

| The idea | Ruby | Python | The page here |
|---|---|---|---|
| Passing code to a method | a block, run with `yield` | a callable argument | [Blocks are not objects](03_Blocks_Procs_and_Lambdas/blocks_are_not_objects/README.md) |
| Anonymous functions | `lambda` / `->` (strict) and `proc` (lenient) | `lambda` — one expression — or a nested `def` | [Procs and lambdas differ](03_Blocks_Procs_and_Lambdas/procs_and_lambdas_differ/README.md) |
| Closures | share outer variables; a block parameter is fresh per call | `nonlocal`; loop variables bind late | [Closures capture variables](03_Blocks_Procs_and_Lambdas/closures_capture_variables/README.md) |
| A method by name | `&:upcase` | `str.upper`, `operator.methodcaller` | [`&:symbol`](03_Blocks_Procs_and_Lambdas/symbol_to_proc/README.md) |
| The implicit parameter | `it`, `_1` | — | [`it` and numbered parameters](03_Blocks_Procs_and_Lambdas/it_and_numbered_parameters/README.md) |
| Leaving a block | `next`, `break`, `return` | `continue`, `break`, `return` | [`next`, `break` and `return`](03_Blocks_Procs_and_Lambdas/next_break_and_return_in_blocks/README.md) |
| Writing an iterator | `each` + `Enumerable`, `Enumerator.new { \|y\| … }` | a generator function with `yield` | [Writing an iterator](03_Blocks_Procs_and_Lambdas/writing_an_iterator/README.md) |
| Partial application | `curry`, `>>`, `<<` | `functools.partial`; no composition operator | [Currying and composition](03_Blocks_Procs_and_Lambdas/curry_and_composition/README.md) |

## Collections

| The idea | Ruby | Python | The page here |
|---|---|---|---|
| Arrays | `a[10]` is `nil`; `a[1, 2]` is start and length | `a[10]` raises; `a[1:3]` is start and stop — [Slicing is not indexing ↗](https://masiarek.github.io/python-learning-library/01_Text_and_Bytes/slicing_is_not_indexing/index.html) | [Arrays and negative indexes](04_Collections/arrays_and_negative_indexes/README.md) |
| Hashes | ordered; `h[:x]` is `nil`; `Hash.new(0)`; `fetch` | ordered; `d["x"]` raises; `defaultdict`; `.get` | [Hashes and default values](04_Collections/hashes_and_default_values/README.md) |
| Ranges | `1..5` inclusive, `1...5` exclusive, endless `1..` | `range(1, 6)`, half-open only | [Ranges](04_Collections/ranges_two_dots_and_three/README.md) |
| Sets | `Set` — core in 4.0, keeps insertion order | `{1, 2}`, `frozenset` — unordered | [`Set` is a core class](04_Collections/set_is_a_core_class/README.md) |
| Unpacking | `a, *b = arr`; block parameters auto-splat | `a, *b = seq`; `for k, v in …` | [Destructuring](04_Collections/destructuring_assignment/README.md) |
| Records | `Struct` (mutable), `Data` (immutable) | `namedtuple`, `dataclass`, `dataclass(frozen=True)` | [`Struct` and `Data`](04_Collections/struct_and_data/README.md) |
| Ordering | `<=>` and `Comparable` | `__lt__` and `functools.total_ordering` | [`Comparable` and `<=>`](04_Collections/comparable_and_spaceship/README.md) |
| The iteration protocol | `each` + the `Enumerable` mixin | `__iter__` + builtins; `collections.abc.Sequence` as a mixin | [`Enumerable` is a mixin](05_Enumerable_and_Iteration/enumerable_is_a_mixin/README.md) |
| The toolbox | `map`, `select`, `group_by`, `tally`, `each_slice`, `zip` | comprehensions, `itertools.groupby`, `Counter`, `batched`, `zip` | [The Enumerable toolbox](05_Enumerable_and_Iteration/the_enumerable_toolbox/README.md) |
| Folding | `inject`, `sum` (compensated), `each_with_object` | `functools.reduce`, `sum`, `math.fsum` | [`inject` and `each_with_object`](05_Enumerable_and_Iteration/inject_and_each_with_object/README.md) |
| Laziness | opt in with `lazy` | generators are lazy by default | [Lazy enumerators](05_Enumerable_and_Iteration/lazy_enumerators/README.md) |
| External iteration | `Enumerator#next`, `StopIteration` | `next(it)`, `StopIteration` | [External enumerators](05_Enumerable_and_Iteration/external_enumerators/README.md) |
| Sorting | `sort_by`; stability not guaranteed | `sorted(key=)`; stable — [Sorting is not comparing ↗](https://masiarek.github.io/python-learning-library/01_Text_and_Bytes/sorting_is_not_comparing/index.html) | [Sort stability and `sort_by`](05_Enumerable_and_Iteration/sort_stability_and_sort_by/README.md) |

## Classes and the object model

| The idea | Ruby | Python | The page here |
|---|---|---|---|
| Attributes | `@x` is private; `attr_accessor` opens it | attributes are public; `@property` computes one | [Instance variables are private](06_Classes_and_Modules/instance_variables_are_private/README.md) |
| Visibility | `private` means no explicit receiver; `protected` | `_x` by convention; `__x` is mangled | [`private` means no receiver](06_Classes_and_Modules/private_means_no_receiver/README.md) |
| Open classes | reopen `String` and add a method | builtins are closed; user classes are open | [Classes are open](06_Classes_and_Modules/classes_are_open/README.md) |
| Mixins | `include`, `extend`, `prepend` | multiple inheritance and the MRO | [Mixins](06_Classes_and_Modules/mixins_include_extend_prepend/README.md) |
| Lookup | `ancestors`, `super` | `__mro__`, `super()` | [Method lookup and `super`](06_Classes_and_Modules/method_lookup_and_super/README.md) |
| Constants | lexical scope, then ancestors | `UPPER_CASE` by convention; `Final` has no runtime | [Constants and lexical scope](06_Classes_and_Modules/constants_and_lexical_scope/README.md) |
| Class-level state | `@@x` is shared with subclasses; class-level `@x` is not | class attributes, shadowed by instance assignment | [Class variables are shared](06_Classes_and_Modules/class_variables_are_shared/README.md) |
| Namespaces | `module Shop; class Cart` | packages and modules | [Modules as namespaces](06_Classes_and_Modules/modules_as_namespaces/README.md) |
| Per-object methods | the singleton class, `class << self` | `types.MethodType`, `classmethod`, the metaclass | [Singleton classes](07_The_Object_Model/singleton_classes/README.md) |
| Construction | `new` = `allocate` + `initialize` | `__new__` + `__init__` | [`new`, `allocate` and `initialize`](07_The_Object_Model/new_allocate_and_initialize/README.md) |
| Display | `to_s` / `inspect`; `puts` / `p` | `__str__` / `__repr__`; `print` / `repr` — [`repr` is not `str` ↗](https://masiarek.github.io/python-learning-library/01_Text_and_Bytes/repr_is_not_str/index.html) | [`to_s`, `inspect` and `p`](07_The_Object_Model/to_s_inspect_and_p/README.md) |
| Being a hash key | `eql?` + `hash` | `__eq__` + `__hash__` | [`eql?` and `hash`](07_The_Object_Model/eql_and_hash_for_hash_keys/README.md) |
| Scoped patches | refinements | — (`unittest.mock.patch` is the nearest) | [Refinements](07_The_Object_Model/refinements/README.md) |
| The root of everything | `BasicObject`; `Kernel` | `object`; the `builtins` module | [`BasicObject` and `Kernel`](07_The_Object_Model/basic_object_and_kernel/README.md) |
| Copies | `dup`, `clone`, `Marshal` round-trip | `copy.copy`, `copy.deepcopy`, `pickle` | [`dup`, `clone` and frozen state](07_The_Object_Model/dup_clone_and_frozen_state/README.md) |

## Errors and exceptions

| The idea | Ruby | Python | The page here |
|---|---|---|---|
| Handling | `begin`/`rescue`/`else`/`ensure`; `retry` | `try`/`except`/`else`/`finally`; no retry | [`rescue`, `ensure`, `else` and `retry`](08_Errors_and_Exceptions/rescue_ensure_else_and_retry/README.md) |
| The default catch | `StandardError` | `Exception`; a bare `except:` is `BaseException` — [Ctrl-C is a signal ↗](https://masiarek.github.io/python-learning-library/02_Projects_and_Environments/ctrl_c_is_a_signal/index.html) | [`StandardError` is the default](08_Errors_and_Exceptions/standard_error_is_the_default/README.md) |
| Raising | `raise "msg"`, `raise Klass, "msg"` | `raise Klass("msg")` | [`raise` has four forms](08_Errors_and_Exceptions/raise_has_four_forms/README.md) |
| Custom classes | `class AppError < StandardError` | `class AppError(Exception)`; exception groups | [Custom exception classes](08_Errors_and_Exceptions/custom_exception_classes/README.md) |
| Chaining | `cause`, set automatically | `__context__` automatically; `raise … from` | [Exceptions have a cause](08_Errors_and_Exceptions/exceptions_have_a_cause/README.md) |
| Expression-level handling | `expr rescue default` | — (`contextlib.suppress`) | [`rescue` as a modifier](08_Errors_and_Exceptions/rescue_as_a_modifier/README.md) |
| Non-local exit | `throw` / `catch` | an exception, or `for … else` | [`throw` and `catch`](08_Errors_and_Exceptions/throw_and_catch/README.md) |
| Exiting | `exit`, `at_exit`, `SystemExit` | `sys.exit`, `atexit`, `SystemExit` | [`exit`, `at_exit` and `SystemExit`](08_Errors_and_Exceptions/exit_at_exit_and_system_exit/README.md) |
| Warnings | `warn`, `-w`, `Warning[:deprecated]` | `warnings.warn`, `-W`, `DeprecationWarning` | [Warnings and `-w`](08_Errors_and_Exceptions/warnings_and_dash_w/README.md) |
| The messages you will meet | `NoMethodError` for `nil`, `ArgumentError` … | `AttributeError` for `None`, `TypeError` … | [Common error messages](08_Errors_and_Exceptions/common_error_messages/README.md) |

## Control flow and pattern matching

| The idea | Ruby | Python | The page here |
|---|---|---|---|
| Statements and expressions | everything is an expression | statements; the conditional expression and `:=` | [Everything is an expression](09_Control_Flow_and_Pattern_Matching/everything_is_an_expression/README.md) |
| Negated and trailing forms | `unless`, `until`, `x if c`, `begin … end while` | `if not`, `while`; `for … else` | [`unless`, `until` and modifiers](09_Control_Flow_and_Pattern_Matching/unless_until_and_modifiers/README.md) |
| Boolean operators | `&&`/`\|\|` and the low-precedence `and`/`or` | `and`/`or`; chained comparisons | [`and`/`or` precedence](09_Control_Flow_and_Pattern_Matching/and_or_precedence/README.md) |
| Switching on a value | `case`/`when` with `===` | `match` with class patterns, or `if`/`elif` | [`case`/`when` uses `===`](09_Control_Flow_and_Pattern_Matching/case_when_uses_threequals/README.md) |
| Structural matching | `case`/`in`, `=>` | `match`/`case` | [`case`/`in` pattern matching](09_Control_Flow_and_Pattern_Matching/case_in_pattern_matching/README.md) |
| Variables in patterns | `^pin` compares; a bare name binds | dotted names compare; a bare name binds | [Pins, guards and alternatives](09_Control_Flow_and_Pattern_Matching/pin_guards_and_alternatives/README.md) |
| Matching your own class | `deconstruct`, `deconstruct_keys` | `__match_args__` | [`deconstruct` and `deconstruct_keys`](09_Control_Flow_and_Pattern_Matching/deconstruct_and_deconstruct_keys/README.md) |
| When nothing matches | `NoMatchingPatternError` | silently nothing | [`NoMatchingPatternError`](09_Control_Flow_and_Pattern_Matching/no_matching_pattern_error/README.md) |
| Loop scope | `for` leaks its variable; a block does not | `for` leaks; a comprehension does not | [`for` loops do not scope](09_Control_Flow_and_Pattern_Matching/for_loops_do_not_scope/README.md) |

## Metaprogramming and under the hood

| The idea | Ruby | Python | The page here |
|---|---|---|---|
| Calling by name | `send`, `public_send` | `getattr(obj, name)(…)` | [`send` and `public_send`](10_Metaprogramming/send_and_public_send/README.md) |
| Defining methods at runtime | `define_method` | `setattr(Cls, name, func)` | [`define_method`](10_Metaprogramming/define_method/README.md) |
| Ghost methods | `method_missing`, `respond_to_missing?` | `__getattr__` | [`method_missing`](10_Metaprogramming/method_missing_and_respond_to_missing/README.md) |
| Evaluating in a context | `instance_eval`, `class_eval` | `exec` with explicit namespaces | [`instance_eval` and `class_eval`](10_Metaprogramming/instance_eval_and_class_eval/README.md) |
| Hooks | `inherited`, `included`, `method_added` | `__init_subclass__`, `__set_name__`, metaclasses | [Hooks](10_Metaprogramming/hooks_inherited_included_method_added/README.md) |
| A small language | `instance_eval` and blocks | class bodies, decorators, `with` | [Building a DSL](10_Metaprogramming/building_a_dsl/README.md) |
| Classes at runtime | `Class.new(Base) { … }` | `type(name, bases, namespace)` | [Classes at runtime](10_Metaprogramming/classes_at_runtime/README.md) |
| Looking inside | `methods`, `instance_variables`, `defined?` | `dir`, `vars`, `inspect` | [Introspection](10_Metaprogramming/introspection/README.md) |
| A scope as an object | `Binding`, `eval` | `locals()`, `eval(expr, globals, locals)` | [`Binding` and `eval`](11_Under_the_Hood/binding_and_eval/README.md) |
| Tracing | `TracePoint` | `sys.settrace`, `sys.monitoring` | [`TracePoint`](11_Under_the_Hood/tracepoint/README.md) |
| Memory | `ObjectSpace`, `GC`, `WeakRef` | `gc`, `weakref` | [`ObjectSpace` and GC](11_Under_the_Hood/object_space_and_gc/README.md) |
| Bytecode | `RubyVM::InstructionSequence` — YARV | `dis`, code objects | [The bytecode you can see](11_Under_the_Hood/the_bytecode_you_can_see/README.md) |
| JITs | YJIT, ZJIT | the 3.13 JIT; free-threading | [JITs and the interpreter](11_Under_the_Hood/jits_and_the_interpreter/README.md) |

## Concurrency and parallelism

| The idea | Ruby | Python | The page here |
|---|---|---|---|
| Threads | `Thread`, the GVL | `threading`, the GIL | [Threads and the GVL](12_Concurrency_and_Parallelism/threads_and_the_gvl/README.md) |
| Locks and queues | `Mutex`, `Queue`, `ConditionVariable` | `Lock`, `queue.Queue`, `Condition` | [`Mutex`, `Queue` and `ConditionVariable`](12_Concurrency_and_Parallelism/mutex_queue_and_condition_variable/README.md) |
| Coroutines | `Fiber` | generators, `async def` | [Fibers are coroutines](12_Concurrency_and_Parallelism/fibers_are_coroutines/README.md) |
| Where an enumerator runs | on a Fiber | as a suspended frame | [Enumerators run on fibers](12_Concurrency_and_Parallelism/enumerators_run_on_fibers/README.md) |
| Per-thread state | `Thread#[]` (fiber-local!), `thread_variable_get` | `threading.local`, `contextvars` | [Thread locals are fiber locals](12_Concurrency_and_Parallelism/thread_locals_are_fiber_locals/README.md) |
| Isolated parallelism | `Ractor` | `multiprocessing`; subinterpreters | [Ractors share nothing](12_Concurrency_and_Parallelism/ractors_share_nothing/README.md) |
| Processes | `fork`, `spawn`, `Process.wait` | `os.fork`, `subprocess`, `os.waitpid` | [Processes](12_Concurrency_and_Parallelism/processes_fork_and_wait/README.md) |
| Timeouts | `Timeout.timeout`, `Thread#kill` | `join(timeout)`, futures with `timeout=` | [Timeouts and killing threads](12_Concurrency_and_Parallelism/timeouts_and_killing_threads/README.md) |

## IO, files and the system

| The idea | Ruby | Python | The page here |
|---|---|---|---|
| Files | `File.open(p) { \|f\| … }` | `with open(p) as f:` — [Opening a file ↗](https://masiarek.github.io/python-learning-library/01_Text_and_Bytes/opening_a_file/index.html) | [`File.open` with a block](13_IO_Files_and_the_System/file_open_with_a_block/README.md) |
| Printing | `puts`, `print`, `p`, `pp` | `print`, `repr`, `pprint` | [`puts`, `print`, `p` and `pp`](13_IO_Files_and_the_System/puts_print_p_and_pp/README.md) |
| Arguments and environment | `ARGV`, `ENV`, `$0` | `sys.argv`, `os.environ`, `__name__` | [`ARGV`, `ENV` and the exit status](13_IO_Files_and_the_System/argv_env_and_exit_status/README.md) |
| Other programs | `system`, backticks, `Open3` | `subprocess.run` | [Running other programs](13_IO_Files_and_the_System/running_other_programs/README.md) |
| Standard input | `gets`, `$stdin`, `ARGF` | `input()`, `sys.stdin`, `fileinput` — [Standard in, standard out, and pipes ↗](https://masiarek.github.io/python-learning-library/01_Text_and_Bytes/stdin_stdout_and_pipes/index.html) | [`gets` and `ARGF`](13_IO_Files_and_the_System/stdin_gets_and_argf/README.md) |
| Paths | `Pathname`, `Dir.glob` | `pathlib.Path` — [Filenames are not text ↗](https://masiarek.github.io/python-learning-library/01_Text_and_Bytes/filenames_are_not_text/index.html) | [`Pathname`, `Dir` and glob](13_IO_Files_and_the_System/pathname_dir_and_glob/README.md) |
| Serialization | `JSON`, `YAML`, `Marshal` | `json`, no YAML, `pickle`, `tomllib` | [JSON, YAML and `Marshal`](13_IO_Files_and_the_System/json_yaml_and_marshal/README.md) |
| Time | `Time`, `Date` | `datetime`, `date`, `timedelta` | [Time and date](13_IO_Files_and_the_System/time_and_date/README.md) |
| Formatting | `"#{x}"`, `format`, `%` | f-strings, `format`, `%` — [The format mini-language ↗](https://masiarek.github.io/python-learning-library/01_Text_and_Bytes/the_format_mini_language/index.html) | [String formatting](13_IO_Files_and_the_System/string_formatting_and_interpolation/README.md) |
| Text and encodings | one `String` type carrying an encoding label — the [Ruby text library ↗](https://masiarek.github.io/ruby-text-learning-library/) | `str` and `bytes` — [`str` is not `bytes` ↗](https://masiarek.github.io/python-learning-library/01_Text_and_Bytes/str_is_not_bytes/index.html) | [Text lives in the text library](13_IO_Files_and_the_System/text_lives_in_the_text_library/README.md) |

## Tooling, testing and gems

| The idea | Ruby | Python | The page here |
|---|---|---|---|
| Loading code | `require`, `require_relative`, `load` | `import`, `importlib.reload` | [`require`, `require_relative` and `load`](14_Tooling_Testing_and_Gems/require_require_relative_and_load/README.md) |
| Packages | gems, Bundler, `Gemfile` | pip, `pyproject.toml`, venv — [`pyproject.toml` ↗](https://masiarek.github.io/python-learning-library/02_Projects_and_Environments/pyproject_toml/index.html) | [Gems, Bundler and the Gemfile](14_Tooling_Testing_and_Gems/gems_bundler_and_gemfile/README.md) |
| Tests | Minitest | `unittest` | [Minitest and `unittest`](14_Tooling_Testing_and_Gems/minitest_and_unittest/README.md) |
| The command line | `ruby -e -c -w -n -p` | `python3 -c -m -I -W` — [`-c` is not the prompt ↗](https://masiarek.github.io/python-learning-library/02_Projects_and_Environments/dash_c_is_not_the_prompt/index.html) | [The command-line flags](14_Tooling_Testing_and_Gems/the_command_line_flags/README.md) |
| The REPL | `irb` | `python3 -i`, `>>>` | [`irb` and the REPL](14_Tooling_Testing_and_Gems/irb_and_the_repl/README.md) |
| Versions | 1.9 → 4.0 | 3.8 → 3.14 | [Ruby versions — what changed](14_Tooling_Testing_and_Gems/ruby_versions_what_changed/README.md) |
| Backtraces | `caller`, `backtrace` | `traceback`, `inspect.stack` | [Backtraces and `caller`](14_Tooling_Testing_and_Gems/backtraces_and_caller/README.md) |
| Documentation | comments, YARD, `ri` — no docstrings | `__doc__`, `help()` | [No docstrings](14_Tooling_Testing_and_Gems/no_docstrings/README.md) |

## Numbers

| The idea | Ruby | Python | The page here |
|---|---|---|---|
| Integer division | `7 / 2` is `3` | `7 / 2` is `3.5`; `7 // 2` is `3` | [Integer division floors](15_Numbers/integer_division_floors/README.md) |
| Big integers | one unbounded `Integer` | unbounded `int` — [`bin()` is not the bits ↗](https://masiarek.github.io/python-learning-library/01_Text_and_Bytes/bin_is_not_the_bits/index.html) | [Integers are unbounded](15_Numbers/integers_are_unbounded/README.md) |
| Floats and rounding | `2.5.round` is `3` | `round(2.5)` is `2` — [Float equality and NaN ↗](https://masiarek.github.io/python-learning-library/03_Numbers/float_equality_and_nan/index.html) | [Floats and rounding](15_Numbers/floats_and_rounding/README.md) |
| Exact arithmetic | `Rational`, `BigDecimal` | `Fraction`, `Decimal` | [`Rational` and `BigDecimal`](15_Numbers/rational_and_bigdecimal/README.md) |
| `1 == 1.0` | true — but `{1 => x}[1.0]` is `nil` | `True` — and `{1: x}[1.0]` finds it — [Comparing an `int` with a `float` ↗](https://masiarek.github.io/python-learning-library/03_Numbers/comparing_int_and_float/index.html) | [Comparing `Integer` and `Float`](15_Numbers/comparing_int_and_float/README.md) |
| Mixed arithmetic | `coerce` | `__radd__` and `NotImplemented` | [Numeric coercion](15_Numbers/numeric_coercion/README.md) |
| Randomness | `Random.new(seed)`, `SecureRandom` | `random.Random(seed)`, `secrets` | [Random with a seed](15_Numbers/random_with_a_seed/README.md) |
| Formatting numbers | `format`, `to_s(2)`; no thousands flag | `format`, `bin`, `f"{n:,}"` | [Number formatting](15_Numbers/number_formatting/README.md) |

## Idioms and gotchas

| The idea | Ruby | Python | The page here |
|---|---|---|---|
| The philosophy | more than one way to do it | one obvious way | [The Ruby way and the Pythonic way](16_Idioms_and_Gotchas/the_ruby_way_and_the_pythonic_way/README.md) |
| Defaults | `x \|\|= value` | `x = x or value`, `:=`, `setdefault` | [`\|\|=` and nil guards](16_Idioms_and_Gotchas/or_equals_and_nil_guards/README.md) |
| Pipelines | `tap`, `then` | — | [`tap`, `then` and chaining](16_Idioms_and_Gotchas/tap_then_and_chaining/README.md) |
| Several results | an Array | a tuple | [Multiple return values](16_Idioms_and_Gotchas/multiple_return_values/README.md) |
| Keys | `"a"` and `:a` are different keys | one string type | [String and symbol keys](16_Idioms_and_Gotchas/string_and_symbol_keys/README.md) |
| Style | two spaces, `snake_case`, `?`/`!` | PEP 8, four spaces | [Style and naming](16_Idioms_and_Gotchas/style_and_naming/README.md) |
| Comments | `#`, `=begin`, `__END__` | `#`, docstrings | [Comments and documentation](16_Idioms_and_Gotchas/comments_and_documentation/README.md) |
| The traps | [for a Python programmer](16_Idioms_and_Gotchas/gotchas_for_python_programmers/README.md) | [for a Ruby programmer](16_Idioms_and_Gotchas/gotchas_for_ruby_programmers_in_python/README.md) | both pages, one measured line per trap |

The pattern across the whole table: where Python has one spelling, Ruby often has two — `lambda` and `proc`, `&&` and `and`, `equal?`/`==`/`eql?`/`===`, `dup` and `clone`, `puts` and `p` — and the second spelling is where a Python programmer's model breaks. Where Ruby has one type, Python often has two — `str`/`bytes`, `list`/`tuple`, `set`/`frozenset` — and the second type is where a Ruby programmer's model breaks. Each of those pairs has a row above and a page behind it.
