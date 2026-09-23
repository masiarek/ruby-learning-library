# Duck typing: ask an object what it can do (respond_to?), not what it is
# (class). Ruby's core does the same through the implicit-conversion protocol:
# to_str, to_ary, to_proc, to_int and to_path. The Python twin
# (duck_typing_and_respond_to_py.py) prints the same rows with hasattr,
# isinstance, Protocol and the dunder protocols.

def row(label, shown)
  puts "   #{label.ljust(52)} #{shown}"
end

puts "1. ask what it does, not what it is"
row "[].respond_to?(:each)", [].respond_to?(:each).inspect
row "{}.respond_to?(:each)", {}.respond_to?(:each).inspect
row "(1..2).respond_to?(:each)", (1..2).respond_to?(:each).inspect
row "\"\".respond_to?(:each)  (each_char, not each)", "".respond_to?(:each).inspect
row "1.respond_to?(:each)", 1.respond_to?(:each).inspect

puts "2. the three what-is-it tests"
row "1.is_a?(Numeric)", 1.is_a?(Numeric).inspect
row "1.kind_of?(Numeric)  (the same test)", 1.kind_of?(Numeric).inspect
row "1.instance_of?(Numeric)", 1.instance_of?(Numeric).inspect
row "1.instance_of?(Integer)", 1.instance_of?(Integer).inspect
row "1.is_a?(Comparable)  (a module counts)", 1.is_a?(Comparable).inspect

puts "3. anything that quacks"
class Duck
  def quack = "Quack"
end

class Robot
  def quack = "Beep"
end

class Rock
end

flock = [Duck.new, Robot.new]
row "flock.map { |d| d.quack if d.respond_to?(:quack) }", flock.map { |d| d.quack if d.respond_to?(:quack) }.inspect
row "Rock.new.respond_to?(:quack)", Rock.new.respond_to?(:quack).inspect
begin
  Rock.new.quack
rescue NoMethodError => e
  row "Rock.new.quack", e.class.to_s
end
row "flock.map { |d| d.is_a?(Duck) }  (class test)", flock.map { |d| d.is_a?(Duck) }.inspect

puts "4. each + Enumerable makes a collection"
class Countdown
  include Enumerable

  def initialize(from) = @from = from

  def each
    return to_enum(:each) unless block_given?

    @from.downto(1) { |i| yield i }
  end
end

c = Countdown.new(3)
row "c = Countdown.new(3); c.respond_to?(:map)", c.respond_to?(:map).inspect
row "c.map { |i| i * 10 }", c.map { |i| i * 10 }.inspect
row "c.include?(2)", c.include?(2).inspect
row "c.sort", c.sort.inspect
row "c.is_a?(Enumerable)", c.is_a?(Enumerable).inspect
row "c.is_a?(Array)", c.is_a?(Array).inspect

puts "5. the implicit conversions the core calls for you"
class Name
  def initialize(n) = @n = n
  def to_str = @n
end

class Pair
  def to_ary = [1, 2]
end

class Doubler
  def to_proc = ->(x) { x * 2 }
end

class Idx
  def to_int = 1
end

class Loc
  def to_path = "some/path.txt"
end

class Plain
  def to_s = "plain"
end

row "\"Hello, \" + Name.new(\"Ada\")  (to_str)", ("Hello, " + Name.new("Ada")).inspect
a, b = Pair.new
row "a, b = Pair.new  (to_ary)", [a, b].inspect
row "[1, 2].map(&Doubler.new)  (to_proc)", [1, 2].map(&Doubler.new).inspect
row "[10, 20, 30][Idx.new]  (to_int)", [10, 20, 30][Idx.new].inspect
row "File.basename(Loc.new)  (to_path)", File.basename(Loc.new).inspect
begin
  "x" + Plain.new
rescue TypeError => e
  row "\"x\" + Plain.new  (to_s is not implicit)", "#{e.class}: #{e.message}"
end

puts "6. Array() and Integer() convert on request"
row "Array(nil)", Array(nil).inspect
row "Array([1])", Array([1]).inspect
row "Array(1)", Array(1).inspect
row "Array({a: 1})", Array({ a: 1 }).inspect
row "Integer(\"42\")", Integer("42").inspect
begin
  Integer("4x")
rescue ArgumentError => e
  row "Integer(\"4x\")", e.class.to_s
end
begin
  Integer(nil)
rescue TypeError => e
  row "Integer(nil)", e.class.to_s
end
row "\"4x\".to_i  (never fails)", "4x".to_i.inspect
