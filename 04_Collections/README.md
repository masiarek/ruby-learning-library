# 04 — Collections

**One line:** Ruby's `Array`, `Hash`, `Range`, `Set`, `Struct` and `Data` are Python's `list`, `dict`, `range`, `set`, `namedtuple` and frozen `dataclass` — with `nil` where Python raises, insertion order where Python has hash-table order, and one `<=>` method where Python has six.

The containers a Python programmer already knows are all here, and most of a Python mental model carries over: arrays index from zero and count backwards from −1, hashes keep insertion order, sets do the algebra, ranges slice, and records compare by value. The chapter is about where that model breaks. The first break is the missing case: `a[10]` and `h[:zz]` answer `nil` where Python's `list` and `dict` raise, and `fetch` is the method that raises. The second is the default: a Hash carries one, and the difference between a value given to `Hash.new` (returned, never stored), a block (stored), and a mutable object (shared by every miss) is the trap that `Hash.new([])` and `Array.new(3, [])` set for a newcomer, exactly as `[[]] * 3` and `dict.fromkeys(keys, [])` do in Python. The third is that a Range is an object with two ends rather than a list of numbers — inclusive or exclusive, endless, made of Strings — where Python's `range` is a half-open integer sequence.

The second half of the chapter is about identity and order. A `Set` is a core class in 4.0, written in C, and it keeps insertion order where a Python `set` walks its hash table; in both languages an element is identified by `hash` and `eql?` (`__hash__` and `__eq__`), but Ruby lets a class in that defines neither and Python refuses one that defines only `__eq__`. Destructuring is the same syntax with different rules at the edges: Ruby fills a missing value with `nil` and drops an extra one, unpacks only Arrays (and `to_ary`), and lets a block spread an Array across its parameters; Python raises `ValueError`, unpacks any iterable, and never spreads. `Struct` and `Data` are the two records — one mutable, one not — beside `namedtuple` and the two flavours of `dataclass`. And `Comparable` is the mixin that turns one `<=>` method into `<`, `==`, `between?` and `clamp`, where Python's `functools.total_ordering` turns `__eq__` and `__lt__` into the other four — and where `nil` from `<=>` and `NotImplemented` from `__lt__` are the two ways to say "these do not compare".

| Lesson | Level | The one thing |
|---|---|---|
| [Past the end, an array gives nil, not an error](arrays_and_negative_indexes/README.md) | 101 | `a[10]` is `nil` and `a[5] = x` pads with `nil`; Python raises on both. |
| [A missing key is nil, and `Hash.new([])` shares its default](hashes_and_default_values/README.md) | 101 | Three kinds of default, and which one stores. |
| [Two dots include the end, three dots exclude it](ranges_two_dots_and_three/README.md) | 101 | A Range is two ends and a flag, not a list; `cover?` is not `include?`. |
| [Set is a core class in 4.0 and keeps insertion order](set_is_a_core_class/README.md) | 201 | No `require`, C underneath, insertion order kept, elements by `hash`/`eql?`. |
| [Assignment destructures, and blocks auto-splat](destructuring_assignment/README.md) | 201 | Missing is `nil`, extra is dropped, only Arrays unpack, blocks spread. |
| [Struct is mutable, Data is not](struct_and_data/README.md) | 201 | Two records that compare by value; `with` instead of a setter. |
| [Define `<=>` and Comparable gives you the rest](comparable_and_spaceship/README.md) | 201 | One method buys six; `nil` means "does not compare" and `sort` raises on it. |

## Read more

- [Array ↗](https://docs.ruby-lang.org/en/4.0/Array.html) — every method, with the slice forms under `[]`.
- [Hash ↗](https://docs.ruby-lang.org/en/4.0/Hash.html) — default values and default procs are in the introduction.
- [Range ↗](https://docs.ruby-lang.org/en/4.0/Range.html) — beginless and endless ranges, `cover?` against `include?`.
- [Set ↗](https://docs.ruby-lang.org/en/4.0/Set.html) — the core class as of 4.0.
- [Struct ↗](https://docs.ruby-lang.org/en/4.0/Struct.html) and [Data ↗](https://docs.ruby-lang.org/en/4.0/Data.html) — the two record classes.
- [Comparable ↗](https://docs.ruby-lang.org/en/4.0/Comparable.html) — what one `<=>` provides.
- [Python tutorial: data structures ↗](https://docs.python.org/3/tutorial/datastructures.html) — lists, tuples, sets and dicts in one chapter.
- [collections ↗](https://docs.python.org/3/library/collections.html) — `namedtuple`, `Counter`, `defaultdict`, `deque`.
- [dataclasses ↗](https://docs.python.org/3/library/dataclasses.html) — `frozen`, `order`, `kw_only`, `replace`.
- [functools.total_ordering ↗](https://docs.python.org/3/library/functools.html#functools.total_ordering) — the Python side of Comparable.
