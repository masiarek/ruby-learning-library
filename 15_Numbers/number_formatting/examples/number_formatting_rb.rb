# Numbers become text with format, to_s(base) and String#%, and come back
# with to_i(base), hex and Integer(). Float#to_s is the shortest round-trip
# form; format rounds to a width; Integer#round(-n) rounds to tens and
# hundreds, half away from zero.

def row(n, expr, value, note = "")
  puts format("%2d. %-42s -> %-26s %s", n, expr, value, note)
end

def caught
  yield.inspect
rescue ArgumentError, TypeError => e
  "#{e.class}: #{e.message}"
end

row 1,  "format(\"%.2f\", 3.14159)",                   format("%.2f", 3.14159).inspect,             "fixed decimals; \"%.2f\" % 3.14159 is the String#% spelling"
row 2,  "format(\"%08.3f\", 3.14159)",                 format("%08.3f", 3.14159).inspect,           "width 8, zero-filled, 3 decimals"
row 3,  "format(\"%e\", 123456.789)",                  format("%e", 123456.789).inspect,            "scientific; %.3e of 0.000123456 is #{format('%.3e', 0.000123456).inspect}, %g picks a form: #{format('%g', 1234567.0).inspect}"
row 4,  "format(\"%x %b %o\", 255, 255, 255)",         format("%x %b %o", 255, 255, 255).inspect,   "bases without a prefix; %#x %#b %#o give #{format('%#x %#b %#o', 255, 255, 255).inspect}"
row 5,  "format(\"%+d|%05d|%-5d|\", 5, 42, 42)",       format("%+d|%05d|%-5d|", 5, 42, 42).inspect, "a sign, zero fill, left alignment"
row 6,  "format(\"%08b\", -5)",                        format("%08b", -5).inspect,                  "a negative in a base is two's complement behind a .. prefix; %x of -255 is #{format('%x', -255).inspect}"
row 7,  "format(\"%.2f\", 2.675)",                     format("%.2f", 2.675).inspect,               "not 2.67: 2.665 gives #{format('%.2f', 2.665)} and 2.685 gives #{format('%.2f', 2.685)}, half to even on the decimal digits"
row 8,  "1234567.to_s.gsub(/\\B(?=(\\d{3})+\\z)/, \",\")", 1234567.to_s.gsub(/\B(?=(\d{3})+\z)/, ",").inspect, "no thousands flag in format, so an idiom; %,d is #{caught { format('%,d', 1) }}"
row 9,  "255.to_s(16), 255.to_s(2), 255.to_s(36)",     "#{255.to_s(16).inspect}, #{255.to_s(2).inspect}, #{255.to_s(36).inspect}", "to_s takes a base from 2 to 36"
row 10, "\"ff\".hex, \"ff\".to_i(16), \"0x1f\".to_i(0)", "#{'ff'.hex}, #{'ff'.to_i(16)}, #{'0x1f'.to_i(0)}", "back from a base; base 0 reads the prefix; \"zz\".hex is #{'zz'.hex}, because to_i never fails"
row 11, "Integer(\"0x1f\", 16), Integer(\"0b101\"), Integer(\"1_000\")", "#{Integer('0x1f', 16)}, #{Integer('0b101')}, #{Integer('1_000')}", "Integer() reads prefixes and underscores, and raises on junk"
row 12, "Integer(\"08\")",                             caught { Integer("08") },                    "a leading 0 means octal, where 8 is not a digit; \"08\".to_i is #{'08'.to_i}"
row 13, "(0.1 + 0.2).to_s, 1e20.to_s",                 "#{(0.1 + 0.2).to_s.inspect}, #{1e20.to_s.inspect}", "to_s is the shortest string that reads back as the same Float; 100.0.to_s is #{100.0.to_s.inspect}, never without the .0"
row 14, "999999999999999.9.to_s, 1e15.to_s",           "#{999999999999999.9.to_s.inspect}, #{1e15.to_s.inspect}", "exponent form once the integer part has 16 digits; and below 0.0001: 1e-4.to_s is #{1e-4.to_s.inspect}, 1e-5.to_s is #{1e-5.to_s.inspect}"
row 15, "1234.5678.round(2), .floor(2), .round(-2)",   "#{1234.5678.round(2)}, #{1234.5678.floor(2)}, #{1234.5678.round(-2)}", "round(-2) returns an Integer; 1250.round(-2) is #{1250.round(-2)}, half away from zero"
row 16, "3.1.round(2).to_s, format(\"%.2f\", 3.1)",     "#{3.1.round(2).to_s.inspect}, #{format('%.2f', 3.1).inspect}", "round drops trailing zeros, format keeps them: money wants format"
