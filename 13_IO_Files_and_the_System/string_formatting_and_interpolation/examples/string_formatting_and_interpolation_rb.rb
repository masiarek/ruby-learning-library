# Interpolation calls to_s; format (printf's language) does the rest --
# widths, precisions, radixes, named fields -- and ljust/rjust/center pad.
class Foo
  def to_s = "Foo!"
  def inspect = "#<Foo>"
end

def row(n, text, value = "")
  puts format("%2d. %-52s %s", n, text, value)
end

x = 5
row 1, '"x is #{x}" interpolates; \'x is #{x}\' does not', "#{"x is #{x}".inspect} #{'x is #{x}'.inspect}"
row 2, '"#{obj}" calls to_s; nil, an Array, a Symbol, a Hash', "#{"#{Foo.new}".inspect} #{"#{nil}|#{[1, 2]}|#{:sym}|#{1.0}|#{{a: 1}}".inspect}"
row 3, 'any expression, even a nested string with its own #{}', "#{"#{1 + 2}".inspect} #{"#{"in #{x}"}".inspect}"
row 4, 'format("%05.2f", pi); "%.3e"; "%x %o %b %08b %X"', "#{format("%05.2f", 3.14159)}; #{format("%.3e", 123456.789)}; #{format("%x %o %b %08b %X", 255, 8, 5, 5, 255)}"
row 5, '"%+d % d" signs; "%5d|%-5d|" width and left-justify', "#{format("%+d % d", 5, 5)}; #{format("%5d|%-5d|", 42, 42)}"
row 6, 'String#%: "%s and %s" % [a, b]; "%s" % one; "%d%%" % 50', "#{"%s and %s" % ["a", "b"]}; #{"%s" % "one"}; #{"%d%%" % 50}"
row 7, '%p is inspect: "%p %s" % ["str", "str"]; %p and %s of nil', "#{"%p %s" % ["str", "str"]}; #{("%p|%s|" % [nil, nil]).inspect}"
row 8, 'named: "%{name} is %<age>d" with a Hash; "%<f>.2f"', "#{format("%{name} is %<age>d", name: "Ada", age: 36)}; #{format("%<f>.2f", f: 3.14159)}"
row 9, 'ljust(6, "."), rjust(6), center(6, "*"); "%-10s|"; "%10s|"', "#{"ab".ljust(6, ".")}| #{"ab".rjust(6)}| #{"ab".center(6, "*")}| #{"%-10s|" % "left"} #{"%10s|" % "right"}"
row 10, '255.to_s(2), to_s(16); "ff".to_i(16), "ff".hex; "%#x %#o %#b"', "#{255.to_s(2)} #{255.to_s(16)}; #{"ff".to_i(16)} #{"ff".hex}; #{"%#x %#o %#b" % [255, 8, 5]}"
row 11, 'format("%.2f", 2.675) and 2.675.round(2); "%.0f" of 2.5, 3.5', "#{format("%.2f", 2.675)} #{2.675.round(2)}; #{format("%.0f", 2.5)} #{format("%.0f", 3.5)}"
row 12, '"%.10g" % (1/3.0); 1e20.to_s; 100.0.to_s; 1e-5.to_s', "#{"%.10g" % (1 / 3.0)}; #{1e20}; #{100.0}; #{1e-5}"
row 13, 'positional "%3$s %1$s %2$s"; width from an argument "%*d"', "#{format("%3$s %1$s %2$s", "a", "b", "c")}; #{format("%*d|", 5, 42)}"
row 14, 'a precision on %s truncates: "%.2s" % "abcdef"', "%.2s" % "abcdef"
sep_err = begin
  "%,d" % 1000
rescue ArgumentError => e
  "#{e.class}: #{e.message}"
end
row 15, 'no thousands flag: "%,d" raises; the gsub idiom', "#{sep_err}; #{1234567.to_s.gsub(/\B(?=(\d{3})+(?!\d))/, ",")}"
row 16, 'padding counts characters: "%-6s|" % "caf\u{e9}"; ljust', "#{"%-6s|" % "caf\u{e9}"} #{"caf\u{e9}".ljust(6, ".")}|"
row 17, "<<~ strips the common indentation; <<- keeps it", "#{<<~ONE.inspect} #{<<-TWO.inspect}"
  indented
    more
  back
ONE
  kept
  TWO
row 18, '"%c" of an Integer and of a String', "#{"%c" % 65} #{"%c" % "hello"}"
row 19, 'format("%s", 3.0); ("%d", 3.99) truncates; ("%f", 3)', "#{format("%s", 3.0)}; #{format("%d", 3.99)}; #{format("%f", 3)}"
str = "x"
row 20, 'an interpolated string is a new object: equal?; ==', "#{"#{str}".equal?(str)}; #{"#{str}" == str}"
