# Integers never overflow: one Integer class holds 2 ** 200 as easily as 2,
# and it comes with bit_length, digits, to_s(base), Integer.sqrt, modular
# pow, gcd and lcm. The only place a big Integer loses digits is on the way
# through a Float.

def row(n, expr, value, note = "")
  puts format("%2d. %-27s -> %-22s %s", n, expr, value, note)
end

def caught
  yield.inspect
rescue NameError => e
  "#{e.class}: #{e.message}"
end

row 1,  "2 ** 200",                   (2 ** 200).to_s,                "(#{(2 ** 200).to_s.size} digits, and no overflow)"
row 2,  "(2 ** 200).class",           (2 ** 200).class.inspect,       "one class for every size; 1.class is #{1.class} too"
row 3,  "Fixnum",                     caught { Fixnum },              "the size classes are gone; Bignum is a NameError too"
row 4,  "255.bit_length",             255.bit_length.inspect,         "256.bit_length is #{256.bit_length}"
row 5,  "(-1).bit_length",            (-1).bit_length.inspect,        "two's complement without the sign bit: (-256).bit_length is #{(-256).bit_length}"
row 6,  "1234.digits",                1234.digits.inspect,            "least significant first; 255.digits(16) is #{255.digits(16).inspect}"
row 7,  "255.to_s(2)",                255.to_s(2).inspect,            "to_s(16) is #{255.to_s(16).inspect}, to_s(36) is #{255.to_s(36).inspect}, (-255).to_s(2) is #{(-255).to_s(2).inspect}"
row 8,  "Integer.sqrt(10 ** 40)",     Integer.sqrt(10 ** 40).to_s,    "exact; Math.sqrt(10 ** 40) is #{Math.sqrt(10 ** 40)}, a Float"
row 9,  "3.pow(200, 1000)",           3.pow(200, 1000).inspect,       "modular pow, never building the #{(3 ** 200).to_s.size}-digit power"
row 10, "12.gcd(18), 12.lcm(18)",     "#{12.gcd(18)}, #{12.lcm(18)}", "gcdlcm gives both: #{12.gcdlcm(18).inspect}"
row 11, "2 ** -1",                    (2 ** -1).inspect,              "a negative exponent gives a Rational, not a Float"
row 12, "(2 ** 53 + 1).to_f.to_i",    (2 ** 53 + 1).to_f.to_i.to_s,   "the +1 is lost: a Float holds 53 bits of integer"
row 13, "(10 ** 5000).to_s.size",     (10 ** 5000).to_s.size.inspect, "no limit on the digits of to_s"
row 14, "(10 ** 5000).to_s(16).size", (10 ** 5000).to_s(16).size.inspect, "nor in any other base"
row 15, "0b1010, 0o17, 0x1f, 1_000",  "#{0b1010}, #{0o17}, #{0x1f}, #{1_000}", "literal forms; a leading 0 alone is octal: 017 is #{017}"
