# Floats are binary: 0.1 + 0.2 is not 0.3, a half rounds away from zero
# unless asked otherwise, overflow is Infinity, NaN is unequal to itself,
# and to_r shows the exact value a Float holds.

def row(n, expr, value, note = "")
  puts format("%2d. %-34s -> %-22s %s", n, expr, value, note)
end

def caught
  yield.inspect
rescue ArgumentError => e
  "#{e.class}: #{e.message}"
end

nan = Float::NAN

row 1,  "0.1 + 0.2",                          (0.1 + 0.2).inspect,                  "== 0.3 is #{0.1 + 0.2 == 0.3}"
row 2,  "(0.1 + 0.2).round(2)",               (0.1 + 0.2).round(2).inspect,         "== 0.3 is #{(0.1 + 0.2).round(2) == 0.3}"
row 3,  "(0.1 + 0.2 - 0.3).abs",              (0.1 + 0.2 - 0.3).abs.inspect,        "< Float::EPSILON is #{(0.1 + 0.2 - 0.3).abs < Float::EPSILON}"
row 4,  "2.5.round, 3.5.round, -2.5.round",   "#{2.5.round}, #{3.5.round}, #{-2.5.round}", "a half rounds away from zero; the result is an #{2.5.round.class}"
row 5,  "2.5.round(half: :even)",             2.5.round(half: :even).inspect,       "banker's rounding on request; 3.5 gives #{3.5.round(half: :even)}, -2.5 gives #{-2.5.round(half: :even)}"
row 6,  "2.675.round(2)",                     2.675.round(2).inspect,               "the Float is #{format('%.20f', 2.675)}, but 2.675 * 100 is #{2.675 * 100}, and that half rounds up"
row 7,  "0.125.round(2)",                     0.125.round(2).inspect,               "0.125 is exact in binary: a true half, rounded away from zero"
row 8,  "2.567.floor(2), 2.567.ceil(2)",      "#{2.567.floor(2)}, #{2.567.ceil(2)}", "digits arguments; 1234.567.round(-2) is #{1234.567.round(-2)}, an #{1234.567.round(-2).class}"
row 9,  "Float::EPSILON",                     Float::EPSILON.inspect,               "MAX #{Float::MAX}, MIN #{Float::MIN}, DIG #{Float::DIG}, MANT_DIG #{Float::MANT_DIG}"
row 10, "2.0 ** 1024",                        (2.0 ** 1024).inspect,                "overflow is Infinity, not an error; Float::MAX * 10 is #{Float::MAX * 10}"
row 11, "nan == nan, nan.nan?",               "#{nan == nan}, #{nan.nan?}",          "NaN is unequal to everything, itself included; nan <=> 1.0 is #{(nan <=> 1.0).inspect}"
row 12, "[nan].include?(nan), [nan] == [nan]", "#{[nan].include?(nan)}, #{[nan] == [nan]}", "a container checks identity before ==, so the same NaN object is found"
row 13, "[1.0, nan].max",                     caught { [1.0, nan].max },            "max and sort refuse a NaN"
row 14, "0.1.to_r",                           0.1.to_r.inspect,                     "the exact binary value; 0.5.to_r is #{0.5.to_r.inspect}"
row 15, "0.1.rationalize(Rational(1, 100))",  0.1.rationalize(Rational(1, 100)).inspect, "the simplest fraction within 1/100 of it"
row 16, "1e16 + 1",                           (1e16 + 1).inspect,                   "== 1e16 is #{1e16 + 1 == 1e16}: the doubles are 2 apart here; 1e16 + 2 is #{1e16 + 2}"
row 17, "1.0.next_float",                     1.0.next_float.inspect,               "next_float - 1.0 == Float::EPSILON is #{1.0.next_float - 1.0 == Float::EPSILON}; 1e16.next_float is #{1e16.next_float}"
