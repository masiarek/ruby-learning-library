# Twenty-three things Ruby does that a Python programmer does not expect,
# one measured line each, numbered as in the page's table.
require "stringio"

def row(n, label, value)
  puts format("%2d. %-42s %s", n, label, value)
end

def show(value) = value.inspect

def compiles?(source)
  RubyVM::InstructionSequence.compile(source)
  "compiles"
rescue SyntaxError => e
  e.class.to_s
end

zero = 0
empty = ""
row 1, '0 and "" in a condition', "#{zero ? "truthy" : "falsy"} / #{empty ? "truthy" : "falsy"}"
row 2, "[1, 2, 3][10]", [1, 2, 3][10].inspect
row 3, "7 / 2 / 7.fdiv(2) / 7 / 2.0", "#{7 / 2} / #{7.fdiv(2)} / #{7 / 2.0}"
s = "abc"
before = s
s << "d"
row 4, 's = "abc"; s << "d"', "#{s.inspect}, same object? #{s.equal?(before)}"
row 5, '"a" == :a', ("a" == :a).to_s
x1 = false or true
x2 = false || true
row 6, "x1 = false or true / x2 = false || true", "x1=#{x1} / x2=#{x2}"
captured = StringIO.new
$stdout = captured
returned = puts("hi")
$stdout = STDOUT
row 7, "puts \"hi\" returns  (printed #{captured.string.inspect})", returned.inspect
y = 5 if false
row 8, "y = 5 if false; y / defined?(y)", "#{y.inspect} / #{defined?(y).inspect}"
row 9, "elsif / elif", "#{compiles?("if 1 then 1 elsif 2 then 2 end")} / #{compiles?("if 1 then 1 elif 2 then 2 end")}"
row 10, "an if without end / with end", "#{compiles?("if true\n  1\n")} / #{compiles?("if true\n  1\nend\n")}"
row 11, "2.5.round / (-2.5).round / 2.5.round(half: :even)", "#{2.5.round} / #{(-2.5).round} / #{2.5.round(half: :even)}"
row 12, "[1, 2].uniq! / [1, 1].uniq!", "#{[1, 2].uniq!.inspect} / #{[1, 1].uniq!.inspect}"
shared = Hash.new([])
shared[:a] << 1
row 13, "h = Hash.new([]); h[:a] << 1; h[:b] / h.size", "#{shared[:b].inspect} / #{shared.size}  (one array, no keys)"
row 14, '{"a": 1}.keys.first.class', { "a": 1 }.keys.first.class.to_s
row 15, "show [1].map do |v| v * 2 end / with { }", "#{show [1].map do |v| v * 2 end} / #{show [1].map { |v| v * 2 }}"
row 16, "?a / ?a.class", "#{?a.inspect} / #{?a.class}"
begin
  Integer("08")
rescue ArgumentError => e
  bad = e.class
end
row 17, 'Integer("08") / "08".to_i / Integer("010")', "#{bad} / #{"08".to_i} / #{Integer("010")}  (a leading 0 means octal)"
row 18, "%w[a b c]", %w[a b c].inspect
for i in 1..3 do end
[1, 2, 3].each { |elem| elem }
row 19, "for i in 1..3: i after / each { |elem| }: defined?(elem)", "#{i} / #{defined?(elem).inspect}"
row 20, '1.equal?(1) / "a".equal?("a") / "a" == "a"', "#{1.equal?(1)} / #{"a".equal?("a")} / #{"a" == "a"}"

class Safe
  def reveal = secret
  private
  def secret = "s3cret"
end
begin
  Safe.new.secret
rescue NoMethodError => e
  denied = e.class
end
row 21, "private: obj.secret / obj.reveal / obj.send(:secret)", "#{denied} / #{Safe.new.reveal.inspect} / #{Safe.new.send(:secret).inspect}"

class Person
  attr_accessor :name
end
row 22, "attr_accessor :name defines", Person.instance_methods(false).sort.inspect
begin
  import json
rescue NameError => e
  imported = e.class
end
row 23, 'require "json" / import json', "#{require "json"} / #{imported}"
