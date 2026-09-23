# freeze makes one object immutable and every later mutation a FrozenError --
# but only that object: freeze is shallow. Integers, symbols and nil are born
# frozen; a file's string literals are frozen by a magic comment. The Python
# twin (freeze_and_frozen_error_py.py) prints the same rows with tuple,
# frozenset, MappingProxyType and dataclass(frozen=True).
Warning[:experimental] = false
require "open3"
require "rbconfig"
require "tmpdir"

def row(label, shown)
  puts "   #{label.ljust(50)} #{shown}"
end

def attempt(label)
  yield
  row label, "worked"
rescue FrozenError => e
  row label, "#{e.class}: #{e.message}"
end

puts "1. freeze, frozen?, and what the copies do"
s = "abc".dup
row "s = \"abc\".dup; s.frozen?", s.frozen?.inspect
row "s.freeze.frozen?", s.freeze.frozen?.inspect
row "s.freeze.equal?(s)  (freeze returns self)", s.freeze.equal?(s).inspect
row "s.dup.frozen?", s.dup.frozen?.inspect
row "s.clone.frozen?", s.clone.frozen?.inspect

puts "2. FrozenError names the object"
attempt("s << \"d\"") { s << "d" }
attempt("[1].freeze << 2") { [1].freeze << 2 }
attempt("{a: 1}.freeze[:b] = 2") { { a: 1 }.freeze[:b] = 2 }
row "FrozenError.ancestors.take(3)", FrozenError.ancestors.take(3).inspect

puts "3. freeze is shallow"
nested = [[1]].freeze
nested.first << 2
row "nested = [[1]].freeze; nested.first << 2", nested.inspect
row "nested.first.frozen?", nested.first.frozen?.inspect
attempt("nested << [3]") { nested << [3] }

puts "4. Ractor.make_shareable freezes all the way down"
row "Ractor.shareable?(nested)  (before)", Ractor.shareable?(nested).inspect
Ractor.make_shareable(nested)
row "after make_shareable: nested.first.frozen?", nested.first.frozen?.inspect
row "Ractor.shareable?(nested)  (after)", Ractor.shareable?(nested).inspect

puts "5. born frozen: immediates and ranges; a literal is not"
row "1.frozen?", 1.frozen?.inspect
row ":a.frozen?", :a.frozen?.inspect
row "nil.frozen?", nil.frozen?.inspect
row "true.frozen?", true.frozen?.inspect
row "1.5.frozen?", 1.5.frozen?.inspect
row "(1..2).frozen?", (1..2).frozen?.inspect
row "\"lit\".frozen?  (chilled, not frozen)", "lit".frozen?.inspect
row "[].frozen?", [].frozen?.inspect

puts "6. # frozen_string_literal: true, in a child ruby"
program = <<~'RUBY'
  def row(label, shown) = puts("   #{label.ljust(50)} #{shown}")
  s = "lit"
  row "\"lit\".frozen?", s.frozen?.inspect
  begin
    s << "!"
    row "s << \"!\"", s.inspect
  rescue FrozenError => e
    row "s << \"!\"", "#{e.class}: #{e.message}"
  end
RUBY
Dir.mktmpdir do |dir|
  File.write(File.join(dir, "plain.rb"), program)
  File.write(File.join(dir, "magic.rb"), "# frozen_string_literal: true\n" + program)
  { "plain.rb" => "", "magic.rb" => "   (line 1 is the magic comment)" }.each do |file, note|
    out, _err, _status = Open3.capture3(RbConfig.ruby, file, chdir: dir)
    puts "   $ ruby #{file}#{note}"
    print out
  end
end

puts "7. a frozen object of your own class has no back door"
class Config
  attr_accessor :host

  def inspect = "#<Config>"
end
c = Config.new.freeze
attempt("c = Config.new.freeze; c.host = \"x\"") { c.host = "x" }
attempt("c.instance_variable_set(:@host, \"x\")") { c.instance_variable_set(:@host, "x") }
row "c.frozen?", c.frozen?.inspect
