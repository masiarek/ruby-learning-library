# Rational and BigDecimal are exact where Float is not: 1/3r is one third,
# BigDecimal("0.1") is one tenth, and 0.1 + 0.2 == 0.3 holds in both.
# BigDecimal ships with Ruby as a default gem and needs a require.
require "bigdecimal"

def row(n, expr, value, note = "")
  puts format("%2d. %-38s -> %-22s %s", n, expr, value, note)
end

def caught
  yield.inspect
rescue StandardError => e
  "#{e.class}: #{e.message}"
end

third = 1/3r
tenth = BigDecimal("0.1")
price = BigDecimal("1234.5678")

row 1,  "1/3r",                                   third.inspect,                          "the r suffix makes a Rational literal; class #{third.class}"
row 2,  "Rational(1, 3), Rational(\"1/3\"), 3.to_r, 0.1r", "#{Rational(1, 3).inspect}, #{Rational("1/3").inspect}, #{3.to_r.inspect}, #{0.1r.inspect}", "four spellings; 0.1r is exactly one tenth"
row 3,  "Rational(0.1)",                          Rational(0.1).inspect,                  "from a Float you get the Float's exact value, not one tenth"
row 4,  "1/3r + 1/6r",                            (1/3r + 1/6r).inspect,                  "exact arithmetic; (1/3r) * 3 == 1 is #{(1/3r) * 3 == 1}"
row 5,  "(1/3r).to_f",                            (1/3r).to_f.inspect,                    "a Float on request; 1/3r + 0.5 is #{(1/3r + 0.5).inspect}, a #{(1/3r + 0.5).class}"
row 6,  "Rational(5, 2).round",                   Rational(5, 2).round.inspect,           "half away from zero, like Float; round(half: :even) is #{Rational(5, 2).round(half: :even)}; Rational(1, 3).round(2) is #{Rational(1, 3).round(2).inspect}"
row 7,  "BigDecimal(\"0.1\") + BigDecimal(\"0.2\") == BigDecimal(\"0.3\")", (tenth + BigDecimal("0.2") == BigDecimal("0.3")).inspect, "decimal digits, so there is no binary fraction to miss by"
row 8,  "(BigDecimal(\"0.1\") + BigDecimal(\"0.2\")).to_s", (tenth + BigDecimal("0.2")).to_s.inspect, "to_s is scientific; to_s(\"F\") is #{(tenth + BigDecimal("0.2")).to_s("F").inspect}"
row 9,  "BigDecimal(\"1234.5678\").to_s(\"3F\")",  price.to_s("3F").inspect,               "grouped by 3; to_f #{price.to_f}, to_i #{price.to_i}, to_r #{price.to_r.inspect}"
row 10, "BigDecimal(\"2.675\").round(2).to_s(\"F\")", BigDecimal("2.675").round(2).to_s("F").inspect, "ROUND_HALF_UP on decimal digits by default; round(2, :half_even) gives #{BigDecimal("2.675").round(2, :half_even).to_s("F")}, and 2.665 gives #{BigDecimal("2.665").round(2, :half_even).to_s("F")}"
row 11, "BigDecimal(\"1\").div(3, 10).to_s(\"F\")", BigDecimal("1").div(3, 10).to_s("F").inspect, "division takes a precision; BigDecimal(\"1\") / 3 * 3 == 1 is #{BigDecimal("1") / 3 * 3 == 1}, while 1/3r * 3 == 1 is #{1/3r * 3 == 1}"
row 12, "BigDecimal(\"0.1\") == 0.1",              (tenth == 0.1).inspect,                 "and BigDecimal(\"0.3\") == 0.1 + 0.2 is #{BigDecimal("0.3") == 0.1 + 0.2}: the Float is rounded to a short decimal first, not read at its exact binary value"
row 13, "BigDecimal(\"0.1\") + 0.1",               (tenth + 0.1).inspect,                  "a Float operand is converted the same way; class #{(tenth + 0.1).class}"
row 14, "Complex(1, 2) * Complex(1, 2)",           (Complex(1, 2) * Complex(1, 2)).inspect, "2i is a literal; Complex(3, 4).abs is #{Complex(3, 4).abs}; rectangular #{Complex(1, 2).rectangular.inspect}"
row 15, "Math.sqrt(-1)",                           caught { Math.sqrt(-1) },               "no Complex unless asked: Complex::I ** 2 is #{(Complex::I ** 2).inspect}"
row 16, "BigDecimal.ancestors.take(3)",            BigDecimal.ancestors.take(3).inspect,   "Rational, BigDecimal and Complex are all Numeric; Rational.ancestors.take(3) is #{Rational.ancestors.take(3).inspect}"
