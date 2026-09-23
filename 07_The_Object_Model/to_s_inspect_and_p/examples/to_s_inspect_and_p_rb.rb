# to_s is for people, inspect is for programmers; puts calls one and p the
# other. The Python twin, to_s_inspect_and_p_py.py, prints the same rows.
# The defaults contain an object address, so the program prints tests of
# their shape rather than the strings themselves.

require "pp"
require "stringio"

def section(n, title) = puts("#{n}. #{title}")
def row(label, value) = puts(format("   %-40s %s", label, value))

# What a printing call writes, as a string, so the page can show a newline.
def writes
  saved, $stdout = $stdout, StringIO.new
  yield
  $stdout.string.inspect
ensure
  $stdout = saved
end

class Plain; end

class Point
  def initialize(x, y) = (@x, @y = x, y)
end

class OnlyToS
  def to_s = "only to_s"
end

class OnlyInspect
  def inspect = "<OnlyInspect>"
end

class Both
  def initialize(n) = @n = n
  def to_s = "to_s of #{@n}"
  def inspect = "#<Both #{@n}>"
end

S = Struct.new(:x, :y)
D = Data.define(:a)

section 1, "the two defaults"
row "Plain.new.to_s starts with \"#<Plain:0x\"", Plain.new.to_s.start_with?("#<Plain:0x")
row "Plain.new.inspect == Plain.new.to_s (shape)", Plain.new.inspect.sub(/0x\h+/, "") == Plain.new.to_s.sub(/0x\h+/, "")
row "Point.new(1, 2).inspect ends \" @x=1, @y=2>\"", Point.new(1, 2).inspect.end_with?(" @x=1, @y=2>")
row "Point.new(1, 2).to_s includes \"@x\"", Point.new(1, 2).to_s.include?("@x")

section 2, "defining one never defines the other"
row "OnlyToS.new.to_s", OnlyToS.new.to_s
row "OnlyToS.new.inspect is still the default", OnlyToS.new.inspect.start_with?("#<OnlyToS:0x")
row "OnlyInspect.new.inspect", OnlyInspect.new.inspect
row "OnlyInspect.new.to_s is still the default", OnlyInspect.new.to_s.start_with?("#<OnlyInspect:0x")

obj = Both.new(3)
section 3, "who calls which"
print "   puts obj                                 "
puts obj
print "   p obj                                    "
p obj
row "\"\#{obj}\"", "#{obj}"
row "format(\"%s / %p\", obj, obj)", format("%s / %p", obj, obj)
row "String(obj)", String(obj)
row "obj.to_s", obj.to_s
row "obj.inspect", obj.inspect

section 4, "containers inspect their elements, even in to_s"
row "[obj].to_s", [obj].to_s
row "[obj].inspect", [obj].inspect
row "{ k: obj }.to_s", { k: obj }.to_s
row "\"\#{[obj]}\"", "#{[obj]}"
print "   puts [obj]                               "
puts [obj]

section 5, "p returns its argument, puts returns nil"
print "   p(obj) prints: "
returned = p(obj)
row "  ...and returns obj itself", returned.equal?(obj)
puts "   p(1, 2) prints two lines:"
returned = p(1, 2)
row "  ...and returns", returned.inspect
row "p() returns", p.inspect
print "   puts(\"one\") prints: "
returned = puts("one")
row "  ...and returns", returned.inspect

section 6, "nil"
row "puts nil writes", writes { puts nil }
row "p nil writes", writes { p nil }
row "print nil writes", writes { print nil }
row "\"\#{nil}\".inspect", "#{nil}".inspect
row "nil.to_s.inspect", nil.to_s.inspect
row "nil.inspect", nil.inspect
row "[nil].to_s", [nil].to_s

section 7, "strings and symbols"
row "\"str\".to_s", "str".to_s
row "\"str\".inspect", "str".inspect
row "\"tab\\there\".inspect", "tab\there".inspect
row "\"\\u{e9}\".inspect", "\u{e9}".inspect
row ":sym.to_s", :sym.to_s
row ":sym.inspect", :sym.inspect

section 8, "core classes define both"
row "S.new(1, 2).inspect", S.new(1, 2).inspect
row "S.new(1, 2).to_s == its inspect", S.new(1, 2).to_s == S.new(1, 2).inspect
row "D.new(1).inspect", D.new(1).inspect
row "RuntimeError.new(\"boom\").to_s", RuntimeError.new("boom").to_s
row "RuntimeError.new(\"boom\").inspect", RuntimeError.new("boom").inspect
row "1e20.to_s", 1e20.to_s
row "(1..3).inspect", (1..3).inspect

section 9, "pp wraps a nested structure at a width"
nested = { name: "widget", parts: (1..3).map { |i| { id: i, tags: %w[alpha beta gamma] } } }
PP.pp(nested, $stdout, 40)
row "obj.pretty_inspect == obj.inspect + \"\\n\"", obj.pretty_inspect == obj.inspect + "\n"

section 10, "where they live"
row "Object.instance_method(:to_s).owner", Object.instance_method(:to_s).owner
row "Object.instance_method(:inspect).owner", Object.instance_method(:inspect).owner
row "Kernel.private_instance_methods.include?(:p)", Kernel.private_instance_methods.include?(:p)
row "BasicObject.instance_methods.include?(:inspect)", BasicObject.instance_methods.include?(:inspect)
