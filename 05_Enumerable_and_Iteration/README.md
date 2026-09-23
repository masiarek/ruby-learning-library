# 05 — Enumerable and iteration

**One line:** One method, `each`, buys Ruby's whole collection toolbox, and the same toolbox comes lazy, external and sorted — with a Python twin for every row and one warning about ties.

This chapter is about the machinery behind `map`, `select`, `inject` and `sort_by`: the module `Enumerable` that supplies them to any class with an `each`, the thirty-odd methods a working Rubyist reaches for instead of writing a loop, the fold that `inject` and `each_with_object` spell two ways, the `lazy` switch that turns a chain of arrays into a pipeline of single elements, the `Enumerator` object with a cursor that `next` moves, and the one thing `sort` and `sort_by` do not promise. Every page runs the same numbered rows in Ruby and in Python, so the two outputs read side by side.

For a Python programmer most of the model carries over: a comprehension is a `map` or `select`, a generator expression is a `lazy` chain, `iter()` and `next()` are `each` and `next`, `functools.reduce` is `inject`, and `sorted(key=)` is `sort_by`. Where it breaks is the interesting part. Python keeps the toolbox in builtins and `itertools` while Ruby mixes it into the object; `itertools.groupby` is Ruby's `chunk`, not its `group_by`; Python is lazy by default where Ruby is lazy on request; Python's `for` loop shares its iterator's cursor where Ruby's `to_a` leaves the cursor alone; both languages' `sum` compensate float rounding (Ruby always, Python since 3.12) while `inject(:+)` and `reduce` do not; and Python's sort is guaranteed stable where Ruby's is not — which is why the last page prints validity checks and stable idioms rather than the order this machine happened to produce.

| Lesson | Level | The one thing |
|---|---|---|
| [Enumerable is a mixin: write `each`, get the rest](enumerable_is_a_mixin/README.md) | 201 | one `each` plus `include Enumerable` buys `map`, `select`, `sort_by`, `lazy` and fifty more; Python's only mixin of the kind is `collections.abc.Sequence` |
| [Most loops you would write are one Enumerable call](the_enumerable_toolbox/README.md) | 201 | thirty methods, one row each, beside their comprehension, `itertools` and `collections` spellings; `groupby` is `chunk` |
| [`inject` makes the block's value the next accumulator](inject_and_each_with_object/README.md) | 201 | the `inject({})` trap, `each_with_object`'s memo, and `sum` beating `inject(:+)` on floats in both languages |
| [`lazy` runs the chain one element at a time](lazy_enumerators/README.md) | 201 | the traced order of the blocks, endless ranges, adapters versus consumers; Python's generators do it by default |
| [An Enumerator has a cursor: `next`, `peek`, `rewind`](external_enumerators/README.md) | 201 | external iteration, `StopIteration` with a `result`, `loop`, and a cursor Python's `for` shares but Ruby's `to_a` does not |
| [`sort_by` keys once, `sort` many times, neither is stable](sort_stability_and_sort_by/README.md) | 201 | key-call counts, the `with_index` idiom for ties, `ArgumentError` on mixed types; Python's `sorted` is stable and says so |

## Read more

- [Enumerable ↗](https://docs.ruby-lang.org/en/4.0/Enumerable.html) — the module's method list, grouped by what each returns
- [Enumerator ↗](https://docs.ruby-lang.org/en/4.0/Enumerator.html) and [Enumerator::Lazy ↗](https://docs.ruby-lang.org/en/4.0/Enumerator/Lazy.html) — external iteration and the lazy adapters, with `produce`, `Yielder` and `size`
- [Enumerable#sort_by ↗](https://docs.ruby-lang.org/en/4.0/Enumerable.html#method-i-sort_by) — where the docs say the ordering of equal elements is indeterminate and may be unstable
- [itertools ↗](https://docs.python.org/3/library/itertools.html) — Python's lazy toolbox, and the recipes section for the rest
- [Sorting Techniques ↗](https://docs.python.org/3/howto/sorting.html) — the HOWTO that states stability, `key=` and `reverse=` in one page
- [Iterator Types ↗](https://docs.python.org/3/builtins/stdtypes.html#iterator-types) and [collections.abc ↗](https://docs.python.org/3/library/collections.abc.html) — the protocol behind `for`, and the table of mixin methods each ABC provides
