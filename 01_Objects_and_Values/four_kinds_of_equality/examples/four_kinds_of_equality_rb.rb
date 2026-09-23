# Four questions, four methods: equal? (identity), == (value), eql? (value and
# type, the one Hash uses) and === (case equality, the one case/when uses).
# The Python twin (four_kinds_of_equality_py.py) prints the same rows with
# is, == and isinstance.

def row(label, shown)
  puts "   #{label.ljust(44)} #{shown}"
end

puts "1. equal? asks: the same object?"
a = [1]
b = [1]
row "a = [1]; b = [1]; a.equal?(b)", a.equal?(b).inspect
row "a.equal?(a)", a.equal?(a).inspect
row "1.equal?(1)", 1.equal?(1).inspect
row ":s.equal?(:s)", :s.equal?(:s).inspect
row "\"xy\".equal?(\"xy\")", "xy".equal?("xy").inspect

puts "2. == asks: the same value?"
row "a == b", (a == b).inspect
row "\"x\" == \"x\"", ("x" == "x").inspect
row "1 == 1.0", (1 == 1.0).inspect
row "\"a\" == :a", ("a" == :a).inspect
row "nil == false", (nil == false).inspect

puts "3. eql? asks: the same value and type? (Hash uses it)"
row "1.eql?(1.0)", 1.eql?(1.0).inspect
row "1.hash == 1.0.hash", (1.hash == 1.0.hash).inspect
row "{1 => :int}[1.0]", { 1 => :int }[1.0].inspect
row "{1 => :int}[1]", { 1 => :int }[1].inspect
row "[1, 1.0].uniq", [1, 1.0].uniq.inspect

puts "4. === asks: does the pattern match the value?"
row "Integer === 1", (Integer === 1).inspect
row "Integer === 1.0", (Integer === 1.0).inspect
row "/a/ === \"cat\"", (/a/ === "cat").inspect
row "(1..3) === 2", ((1..3) === 2).inspect
row "->(x) { x > 1 } === 2", (->(x) { x > 1 } === 2).inspect
row "\"cat\" === \"cat\"", ("cat" === "cat").inspect

puts "5. case/when calls ==="
row "case 2 when Integer", (case 2 when Integer then :int else :other end).inspect
row "case \"cat\" when /a/", (case "cat" when /a/ then :match else :no end).inspect
row "case 2 when 1..3", (case 2 when 1..3 then :in_range else :out end).inspect
row "case 7 when ->(n) { n > 5 }", (case 7 when ->(n) { n > 5 } then :big else :small end).inspect

puts "6. your own class: identity until you define =="
class Point
  attr_reader :x, :y

  def initialize(x, y)
    @x = x
    @y = y
  end
end
row "Point.new(1, 2) == Point.new(1, 2)", (Point.new(1, 2) == Point.new(1, 2)).inspect
class Point
  def ==(other)
    other.is_a?(Point) && x == other.x && y == other.y
  end
end
row "after def ==:  the same comparison", (Point.new(1, 2) == Point.new(1, 2)).inspect
row "Point.new(1, 2).eql?(Point.new(1, 2))", Point.new(1, 2).eql?(Point.new(1, 2)).inspect
row "Point.new(1, 2) === Point.new(1, 2)", (Point.new(1, 2) === Point.new(1, 2)).inspect
row "{p1 => :a, p2 => :b}.size  (equal points)", { Point.new(1, 2) => :a, Point.new(1, 2) => :b }.size.inspect
