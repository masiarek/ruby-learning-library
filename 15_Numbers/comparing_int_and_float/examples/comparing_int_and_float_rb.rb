# 1 == 1.0 is true, but they are different objects of different classes:
# eql? and hash keep them apart, so a Hash, uniq and Set see two keys where
# == sees one value. Comparison across the line is exact, not rounded.

def row(n, expr, value, note = "")
  puts format("%2d. %-36s -> %-22s %s", n, expr, value, note)
end

big = 2 ** 53 + 1
h = { 1 => :int }
h[1.0] = :float

row 1,  "1 == 1.0",                              (1 == 1.0).inspect,                  "== compares by numeric value across classes"
row 2,  "1.eql?(1.0)",                           1.eql?(1.0).inspect,                 "eql? also wants the same class; 1.eql?(1) is #{1.eql?(1)}"
row 3,  "1.equal?(1.0)",                         1.equal?(1.0).inspect,               "identity; 1.equal?(1) is #{1.equal?(1)}: a small Integer is an immediate value"
row 4,  "1.hash == 1.0.hash",                    (1.hash == 1.0.hash).inspect,        "a Hash key is found by hash then eql?, so these are two keys"
row 5,  "{1 => :a}[1.0]",                        ({ 1 => :a }[1.0]).inspect,          "no key 1.0; {1.0 => :a}[1] is #{({ 1.0 => :a }[1]).inspect} too"
row 6,  "h = {1 => :int}; h[1.0] = :float; h",   h.inspect,                           "two entries; h.size is #{h.size}"
row 7,  "[1, 1.0].uniq",                         [1, 1.0].uniq.inspect,               "uniq uses hash and eql?: two elements; Set[1, 1.0].size is #{Set[1, 1.0].size}, tally #{[1, 1.0].tally.inspect}"
row 8,  "[1].include?(1.0), [1].index(1.0)",     "#{[1].include?(1.0)}, #{[1].index(1.0)}", "include?, index and count use ==, so they cross the line"
row 9,  "1 <=> 1.0",                             (1 <=> 1.0).inspect,                 "ordered as equal; 1 === 1.0 is #{1 === 1.0}, so case 1.0 when 1 matches"
row 10, "Integer === 1.0, Float === 1",          "#{Integer === 1.0}, #{Float === 1}", "a class test does not convert: case 1.0 when Integer does not match; 1.0.integer? is #{1.0.integer?}"
row 11, "2 ** 53 + 1 == (2 ** 53 + 1).to_f",     (big == big.to_f).inspect,           "exact comparison: the Float is #{big.to_f.to_i}, so 2 ** 53 + 1 > it is #{big > big.to_f}"
row 12, "10 ** 20 + 1 == 1e20",                  (10 ** 20 + 1 == 1e20).inspect,      "but 10 ** 20 == 1e20 is #{10 ** 20 == 1e20}: the Integer is not rounded to a Float first"
row 13, "0.1 == 1/10r",                          (0.1 == 1/10r).inspect,              "true, yet 0.1.to_r == 1/10r is #{0.1.to_r == 1/10r}: a Rational meets a Float as a Float, not exactly"
row 14, "0 == -0.0, 0.0.eql?(-0.0)",             "#{0 == -0.0}, #{0.0.eql?(-0.0)}",    "one value and one key: {0.0 => :a}[-0.0] is #{({ 0.0 => :a }[-0.0]).inspect}"
row 15, "1 == 1r, 1 == Complex(1, 0)",           "#{1 == 1r}, #{1 == Complex(1, 0)}",  "== crosses every numeric class; eql? crosses none: 1.eql?(1r) is #{1.eql?(1r)}"
