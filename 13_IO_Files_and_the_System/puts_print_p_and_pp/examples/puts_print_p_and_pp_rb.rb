# puts, print, p and pp all write to $stdout, so each demonstration below runs
# with $stdout swapped for a StringIO; the row then shows the exact characters
# that were written, and the return value where it is the point.
require "stringio"
require "pp"

def row(n, text, value = "")
  puts format("%2d. %-52s %s", n, text, value)
end

def captured
  saved, $stdout = $stdout, StringIO.new
  result = yield
  [$stdout.string, result]
ensure
  $stdout = saved
end

def out(&block) = captured(&block).first

class Foo
  def to_s = "Foo-to_s"
  def inspect = "Foo-inspect"
end

row 1, 'puts "a" writes', out { puts "a" }.inspect
row 2, 'puts "a\n" adds no second newline', out { puts "a\n" }.inspect
row 3, "puts 1, 2 puts each argument on its own line", out { puts 1, 2 }.inspect
row 4, "puts [1, [2, 3]] flattens, one element per line", out { puts [1, [2, 3]] }.inspect
row 5, "puts nil writes an empty line", out { puts nil }.inspect
row 6, "puts [] writes nothing at all", out { puts [] }.inspect
row 7, "puts with no argument", out { puts }.inspect
row 8, 'print "a", "b" adds no separator and no newline', out { print "a", "b" }.inspect
row 9, "print nil, 1.0 uses to_s, and nil.to_s is empty", out { print nil, 1.0 }.inspect
row 10, 'p "s" writes inspect, so the quotes are visible', out { p "s" }.inspect
row 11, "p 1, 2 writes two lines", out { p 1, 2 }.inspect
written, returned = captured { p 1, 2 }
row 12, "  and returns its arguments as an Array", returned.inspect
row 13, "  p with one argument returns it; p alone returns", "#{captured { p "s" }.last.inspect}; #{captured { p }.last.inspect}"
row 14, "  puts returns", captured { puts "x" }.last.inspect
row 15, "puts obj uses to_s; p obj uses inspect", "#{out { puts Foo.new }.inspect}; #{out { p Foo.new }.inspect}"
row 16, '"#{obj}" uses to_s; puts [obj] uses to_s of each', "#{out { puts "#{Foo.new}" }.inspect}; #{out { puts [Foo.new] }.inspect}"
row 17, "p [obj] uses inspect of each element", out { p [Foo.new] }.inspect

ENV.delete("COLUMNS") # pp reads COLUMNS when stdout is not a terminal; 80 is the default
h = {name: "Ada Lovelace", languages: %w[ruby python perl], address: {city: "London", country: "United Kingdom"}, notes: "a fairly long string to push past eighty columns"}
row 18, "p h writes one line, this long", out { p h }.length
row 19, "pp h wraps at 80 columns, keeping insertion order:"
pp h
row 20, "  pp's first line", out { pp h }.lines.first.chomp
row 21, "  pp returns its argument (equal?)", captured { pp h }.last.equal?(h)
row 22, '$stdout.write("caf\u{e9}\n") returns bytes written', captured { $stdout.write("caf\u{e9}\n") }.last
row 23, '$stdout.write("ab", "cd\n") takes several arguments', captured { $stdout.write("ab", "cd\n") }.last
row 24, 'printf("%05.1f|%s\n", 3.14159, "x") formats, writes', out { printf("%05.1f|%s\n", 3.14159, "x") }.inspect
row 25, '$stdout << "a" << 1 << "\n" chains', out { $stdout << "a" << 1 << "\n" }.inspect

saved_err, $stderr = $stderr, StringIO.new
$stderr.puts "to stderr"
warn "warned", "twice"
errs = $stderr.string
$stderr = saved_err
row 26, "$stderr.puts and warn both write to $stderr", errs.inspect
row 27, "  warn takes several arguments, one per line", errs.lines.length
