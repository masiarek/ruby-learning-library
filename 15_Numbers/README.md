# 15 — Numbers

**One line:** Ruby's numbers are Python's numbers with different defaults — `/` floors, `round` goes away from zero, `1.0` is not the Hash key `1`, a Float divided by zero is `Infinity` — plus `Rational` and `BigDecimal` literals and a `coerce` protocol for classes of your own.

The types line up one to one: `Integer` is `int` (unbounded in both), `Float` is `float` (the same 64-bit double), `Rational` is `Fraction`, `BigDecimal` is `Decimal`, `Complex` is `complex`, and `Random` is `random.Random` — both Mersenne Twisters. A Python programmer's model of what a number *is* carries over completely, and every page here prints the same rows from both languages to show it: `0.1 + 0.2` misses `0.3` by the same `5.55e-17`, `2 ** 53 + 1` fails the same exact comparison with its own Float, and `pow(3, 200, 1000)` is `1` in both.

What does not carry over is the defaults. Ruby's one `/` floors on Integers where Python needed a second operator; `2.5.round` is `3` and `round(2.5)` is `2`; `format("%.2f", 2.675)` is `2.68` and `format(2.675, ".2f")` is `2.67`; `7.0 / 0` is `Infinity` and so is `2.0 ** 1024`, where Python raises for both; `{1 => :a}[1.0]` is `nil` because `1.eql?(1.0)` is false, where a Python dict finds the key; `2 ** -1` is a `Rational`, not `0.5`; and Python's `str(10 ** 5000)` raises under a 4300-digit guard that Ruby does not have. Each of those is one row in one lesson below, and each lesson ends by putting the two outputs side by side.

| Lesson | Level | The one thing |
|---|---|---|
| [`7 / 2` is `3`: integer division floors](integer_division_floors/README.md) | 101 | Ruby's `/` is Python's `//` on Integers; `%` follows the divisor and `remainder` the dividend; a Float over zero is `Infinity`, not an error |
| [Integers never overflow: `2 ** 200` is just an Integer](integers_are_unbounded/README.md) | 101 | one `Integer` class of any size, with `bit_length`, `digits`, `Integer.sqrt` and modular `pow`; only a Float loses digits, and only Python caps `str(int)` |
| [`0.1 + 0.2 != 0.3`, and `2.5.round` is `3`](floats_and_rounding/README.md) | 201 | the same double as Python's, but a half rounds away from zero, overflow is `Infinity`, and `max` with a NaN raises |
| [`1/3r` and `BigDecimal("0.1")` are exact where Float is not](rational_and_bigdecimal/README.md) | 201 | `Rational` and `BigDecimal` make `0.1 + 0.2 == 0.3` true; `Fraction` and `Decimal` are their twins, except that Python refuses to mix a `Decimal` with a float |
| [`1 == 1.0` is true, but `{1 => :a}[1.0]` is `nil`](comparing_int_and_float/README.md) | 201 | `==` crosses the Integer–Float line exactly; `eql?` and `hash` do not, so a Hash, `uniq` and a Set see two keys where Python sees one |
| [`1 + 1.5` works because Integer asks Float to `coerce`](numeric_coercion/README.md) | 201 | `coerce` is Ruby's `__radd__` and `NotImplemented`; `to_str` and `to_int` are the implicit conversions that arithmetic never uses |
| [`Random.new(42)` gives the same numbers every run](random_with_a_seed/README.md) | 201 | a seeded generator is repeatable on every machine, `shuffle` and `sample` take it as `random:`, and `SecureRandom` is the one you cannot seed |
| [Numbers become text with `format`, `to_s(16)` and `%`](number_formatting/README.md) | 201 | `format` has `..` two's-complement negatives and no thousands flag; `Integer()` is strict where `to_i` never fails; `Float#to_s` is the shortest round trip |

## Read more

- [Integer ↗](https://docs.ruby-lang.org/en/4.0/Integer.html), [Float ↗](https://docs.ruby-lang.org/en/4.0/Float.html), [Rational ↗](https://docs.ruby-lang.org/en/4.0/Rational.html), [Complex ↗](https://docs.ruby-lang.org/en/4.0/Complex.html) — the core classes, with every method used here
- [BigDecimal ↗](https://docs.ruby-lang.org/en/4.0/BigDecimal.html) — the default gem: rounding modes, precision and the `to_s` formats
- [Random ↗](https://docs.ruby-lang.org/en/4.0/Random.html) and [SecureRandom ↗](https://docs.ruby-lang.org/en/4.0/SecureRandom.html) — the seedable generator and the unseedable one
- [Format specifications ↗](https://docs.ruby-lang.org/en/4.0/language/format_specifications_rdoc.html) — every directive `format` and `String#%` accept
- [Numeric types ↗](https://docs.python.org/3/library/stdtypes.html#numeric-types-int-float-complex) — Python's `int`, `float` and `complex`, and the widening rule for arithmetic
- [Floating-point arithmetic: issues and limitations ↗](https://docs.python.org/3/tutorial/floatingpoint.html) — the Python tutorial's chapter on `0.1`
- [fractions ↗](https://docs.python.org/3/library/fractions.html), [decimal ↗](https://docs.python.org/3/library/decimal.html), [random ↗](https://docs.python.org/3/library/random.html) — the twins of `Rational`, `BigDecimal` and `Random`
- [Format specification mini-language ↗](https://docs.python.org/3/library/string.html#formatspec) — the spec that f-strings and `format()` share
- [Comparing an `int` with a `float` ↗](https://masiarek.github.io/python-learning-library/03_Numbers/comparing_int_and_float/index.html) and [Float equality and NaN ↗](https://masiarek.github.io/python-learning-library/03_Numbers/float_equality_and_nan/index.html) — the Python library's Numbers chapter, the twin of this one
