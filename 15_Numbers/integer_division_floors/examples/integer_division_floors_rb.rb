# Integer division floors: what `/`, `%`, `div`, `remainder`, `fdiv` and
# `divmod` do to 7 and -7, and what dividing by zero does.

def row(n, expr, value, note = "")
  puts format("%2d. %-18s -> %-32s %s", n, expr, value, note)
end

def caught
  yield.inspect
rescue ZeroDivisionError, FloatDomainError => e
  "#{e.class}: #{e.message}"
end

row 1,  "7 / 2",           (7 / 2).inspect,           "Integer / Integer stays an Integer"
row 2,  "-7 / 2",          (-7 / 2).inspect,          "it floors: towards minus infinity, not towards zero"
row 3,  "7.fdiv(2)",       7.fdiv(2).inspect,         "fdiv asks for a Float; 7.quo(2) is #{7.quo(2).inspect}, a Rational"
row 4,  "7 / 2.0",         (7 / 2.0).inspect,         "one Float operand makes the answer a Float"
row 5,  "7.divmod(2)",     7.divmod(2).inspect,       "quotient and modulo as a pair"
row 6,  "-7.divmod(2)",    (-7).divmod(2).inspect,    "the pair floors too: -4 * 2 + 1 == -7"
row 7,  "-7 % 2",          (-7 % 2).inspect,          "% takes the sign of the divisor"
row 8,  "7 % -2",          (7 % -2).inspect,          "so a negative divisor gives a negative result"
row 9,  "-7.remainder(2)", (-7).remainder(2).inspect, "remainder takes the sign of the dividend, like C's %"
row 10, "7.0.div(2)",      7.0.div(2).inspect,        "div floors and returns an Integer, even for Floats"
row 11, "7.ceildiv(2)",    7.ceildiv(2).inspect,      "the quotient rounded up (Ruby 3.2+)"
row 12, "7.0 / 0",         (7.0 / 0).inspect,         "Float division by zero is Infinity, not an error"
row 13, "0.0 / 0",         (0.0 / 0).inspect,         "NaN; (0.0 / 0).nan? is #{(0.0 / 0).nan?}"
row 14, "7 / 0",           caught { 7 / 0 },          "Integer division by zero raises"
row 15, "7.0 % 0",         caught { 7.0 % 0 },        "so does modulo, even on a Float"
row 16, "(7.0 / 0).to_i",  caught { (7.0 / 0).to_i }, "Infinity has no Integer value"
